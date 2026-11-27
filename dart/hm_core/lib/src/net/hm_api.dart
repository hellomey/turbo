import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../config/api_config.dart';
import '../session/token_store.dart';
import 'hm_api_exception.dart';
import 'hm_http_client.dart';
import 'wire.dart';

/// Outcome of `POST /v1/auth/otp/verify` (contract `OtpVerifyResponse`, a oneOf on `kind`).
sealed class OtpVerifyOutcome {
  const OtpVerifyOutcome();
}

/// Signed in (`kind: session`). Tokens are already stored.
class OtpSessionOutcome extends OtpVerifyOutcome {
  const OtpSessionOutcome({
    required this.isNewUser,
    required this.deletionCancelled,
    this.guestProgress,
  });
  final bool isNewUser;

  /// Signing in cancelled a pending account deletion (§38 step 7).
  final bool deletionCancelled;

  /// Only when a guest signed in: `kept` (the guest account became this account) or `not_merged`
  /// (the email already had an account; the guest progress was not moved into it).
  final String? guestProgress;
}

/// HeyMey Desk needs the authenticator code next (`kind: desk_2fa`).
class OtpDeskChallengeOutcome extends OtpVerifyOutcome {
  const OtpDeskChallengeOutcome({
    required this.challengeToken,
    required this.totpEnrolled,
  });
  final String challengeToken;
  final bool totpEnrolled;
}

/// Contract `OtpPurpose`.
enum OtpPurpose {
  login('login'),
  deleteAccount('delete_account');

  const OtpPurpose(this.wire);
  final String wire;
}

/// Contract `OtpVerifyBody.platform`.
enum ClientPlatform { android, ios, web }

/// Contract `ClientKind`.
enum ClientKind { app, desk }

/// The signed-in user (contract `Me`).
@immutable
class MeInfo {
  const MeInfo({
    required this.id,
    required this.email,
    required this.calmMode,
    required this.roles,
    this.isGuest = false,
    this.nickname,
    this.liteMode,
    this.hasProfile = false,
    this.deletionScheduledFor,
  });

  final String id;

  /// null for a guest (no email yet).
  final String? email;

  /// Trying HeyMey without an email (guest mode). "Save your progress" signs in with email.
  final bool isGuest;
  final String? nickname;
  final bool calmMode;

  /// null = automatic.
  final bool? liteMode;
  final bool hasProfile;
  final List<String> roles;
  final DateTime? deletionScheduledFor;

  static MeInfo fromJson(Map<String, dynamic> json) => MeInfo(
    id: json['id'] as String,
    email: json['email'] as String?,
    isGuest: json['isGuest'] == true,
    nickname: json['nickname'] as String?,
    calmMode: json['calmMode'] as bool? ?? false,
    liteMode: json['liteMode'] as bool?,
    hasProfile: json['profile'] != null,
    roles: [for (final r in (json['roles'] as List? ?? const [])) '$r'],
    deletionScheduledFor: DateTime.tryParse('${json['deletionScheduledFor']}'),
  );
}

/// The user's exams (contract `UserExams`); `main` is null until onboarding saved it.
@immutable
class MyExams {
  const MyExams({this.mainCode, this.mainName, this.otherCodes = const []});
  final String? mainCode;
  final String? mainName;
  final List<String> otherCodes;
}

/// Contract `DeskTotpEnrollResponse`.
@immutable
class DeskEnrolment {
  const DeskEnrolment({required this.otpauthUri, required this.secret});
  final String otpauthUri;
  final String secret;
}

/// Contract `ConsentNotice`.
@immutable
class ConsentNoticeInfo {
  const ConsentNoticeInfo({required this.version, required this.purposes});
  final String version;
  final List<ConsentPurposeInfo> purposes;
}

@immutable
class ConsentPurposeInfo {
  const ConsentPurposeInfo({
    required this.purpose,
    required this.required,
    required this.title,
    required this.description,
  });

  /// Wire value, e.g. `core_service`.
  final String purpose;
  final bool required;
  final String title;
  final String description;
}

/// Profile answers as sent to the server (contract `ProfileAnswers` / `EligibilityCheckBody`).
/// Enum fields carry the contract's wire values (`degree`, `MBC_DNC`, `PWD`, ...).
@immutable
class ProfileAnswersInput {
  const ProfileAnswersInput({
    required this.dateOfBirth,
    required this.qualification,
    required this.community,
    required this.pstm,
    this.degreeSubject,
    this.specialCategories = const [],
  });

  /// A calendar date: only year, month and day are used (never converted to UTC).
  final DateTime dateOfBirth;
  final String qualification;
  final String? degreeSubject;
  final String community;
  final bool pstm;
  final List<String> specialCategories;

  Map<String, Object> toJson() {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = dateOfBirth;
    final subject = degreeSubject?.trim();
    return {
      'dateOfBirth':
          '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}',
      'qualification': qualification,
      if (subject != null && subject.isNotEmpty) 'degreeSubject': subject,
      'community': community,
      'pstm': pstm,
      'specialCategories': specialCategories,
    };
  }
}

/// The one way the apps talk to the API (routes from `@heymey/contracts` routes.ts). It owns tokens,
/// idempotency, refresh and error parsing (via [HmHttpClient]) and turns every failure into
/// [HmApiException] whose `message` is safe to show.
///
/// TEMPORARY (BOLT-0004): the generated client `dart/hm_api` does not compile today
/// (`OkResponse` literal `true` → String const in a bool enum; `HealthResponse.checks` map of enums),
/// so importing it breaks every build. Until the contract/codegen is fixed (architect/devops follow-up),
/// this class calls the routes directly and returns JSON maps or the small typed results below;
/// feature repositories map the JSON to their domain models. Once `hm_api` compiles, the transport here
/// switches to `ApiClient(..)..client = HmHttpClient(..)` with no change to callers.
class HmApi {
  HmApi({
    required this.config,
    required TokenStore tokens,
    http.Client? httpClient,
    void Function()? onSignedOut,
    String Function()? newIdempotencyKey,
  }) : _tokens = tokens,
       _newKey = newIdempotencyKey ?? (() => const Uuid().v4()) {
    _http = HmHttpClient(
      inner: httpClient ?? http.Client(),
      tokens: tokens,
      baseUrl: config.baseUrl,
      appVersion: config.appVersion,
      updateRequired: updateRequired,
      onSignedOut: onSignedOut,
      newIdempotencyKey: _newKey,
    );
  }

  final ApiConfig config;
  final TokenStore _tokens;
  final String Function() _newKey;
  late final HmHttpClient _http;

  /// True once the server says this app version is too old (§37).
  final ValueNotifier<bool> updateRequired = ValueNotifier(false);

  Future<bool> hasSession() async => (await _tokens.read()) != null;

  /// Forgets the tokens on this phone (no server call).
  Future<void> clearSession() => _tokens.clear();

  // ------------------------------------------------------------------ auth (§38)

  /// Sends a 6-digit code. Returns the seconds until "Resend" unlocks.
  Future<int> requestOtp(
    String email, {
    OtpPurpose purpose = OtpPurpose.login,
  }) async {
    final json = await _write('POST', '/v1/auth/otp/request', {
      'email': email.trim(),
      'purpose': purpose.wire,
    });
    final seconds = asJsonMap(json)['resendAfterSeconds'];
    return seconds is int ? seconds : 60;
  }

  Future<OtpVerifyOutcome> verifyOtp({
    required String email,
    required String code,
    required String deviceId,
    required ClientPlatform platform,
    ClientKind client = ClientKind.app,
  }) async {
    final json = await _write('POST', '/v1/auth/otp/verify', {
      'email': email.trim(),
      'code': code,
      'deviceId': deviceId,
      'platform': platform.name,
      'client': client.name,
    });
    final map = _map(json);
    if (map['kind'] == 'session') {
      await _storeTokens(map['tokens']);
      return OtpSessionOutcome(
        isNewUser: map['isNewUser'] == true,
        deletionCancelled: map['deletionCancelled'] == true,
        guestProgress: map['guestProgress'] as String?,
      );
    }
    if (map['kind'] == 'desk_2fa' && map['challengeToken'] is String) {
      return OtpDeskChallengeOutcome(
        challengeToken: map['challengeToken'] as String,
        totpEnrolled: map['totpEnrolled'] == true,
      );
    }
    throw _unknown;
  }

  /// "Try it now" (guest mode): an 18+ visitor starts without an email. The guest tokens are stored.
  /// Only call this after the 18+ check passed; the server refuses otherwise.
  Future<void> startGuestSession({
    required String deviceId,
    required ClientPlatform platform,
  }) async {
    await _storeTokens(
      await _write('POST', '/v1/auth/guest', {
        'deviceId': deviceId,
        'platform': platform.name,
        'ageConfirmed18': true,
      }),
    );
  }

  Future<DeskEnrolment> enrollDeskTotp(String challengeToken) async {
    final map = _map(
      await _write('POST', '/v1/auth/desk/totp/enroll', {
        'challengeToken': challengeToken,
      }),
    );
    final uri = map['otpauthUri'];
    final secret = map['secret'];
    if (uri is! String || secret is! String) throw _unknown;
    return DeskEnrolment(otpauthUri: uri, secret: secret);
  }

  /// Completes Desk sign-in; the Desk session tokens are stored.
  Future<void> verifyDeskTotp(String challengeToken, String code) async {
    final map = _map(
      await _write('POST', '/v1/auth/desk/totp/verify', {
        'challengeToken': challengeToken,
        'code': code,
      }),
    );
    await _storeTokens(map['tokens']);
  }

  /// Ends this session. Tokens are forgotten even if the server cannot be reached.
  Future<void> logout() async {
    try {
      await _write('POST', '/v1/auth/logout', null);
    } finally {
      await _tokens.clear();
    }
  }

  /// "Log out of all devices" (§38 step 6).
  Future<void> logoutAll() async {
    try {
      await _write('POST', '/v1/auth/logout-all', null);
    } finally {
      await _tokens.clear();
    }
  }

  /// Confirms deletion with a `delete_account` code. Returns when personal data will be erased;
  /// signing in before then cancels it (§38 step 7). This phone is signed out.
  Future<DateTime> deleteAccount(String code) async {
    final map = _map(
      await _write('POST', '/v1/auth/delete-account', {'code': code}),
    );
    final when = DateTime.tryParse('${map['deletionScheduledFor']}');
    await _tokens.clear();
    if (when == null) throw _unknown;
    return when;
  }

  // ------------------------------------------------------------------ users

  Future<MeInfo> getMe() async => MeInfo.fromJson(_map(await _get('/v1/me')));

  Future<MeInfo> updateMe({
    bool? calmMode,
    bool? hideFromLeaderboards,
    String? nickname,
  }) async {
    final json = await _write('PATCH', '/v1/me', {
      'nickname': ?nickname,
      'calmMode': ?calmMode,
      'hideFromLeaderboards': ?hideFromLeaderboards,
    });
    return MeInfo.fromJson(_map(json));
  }

  Future<void> putProfile(ProfileAnswersInput answers) =>
      _write('PUT', '/v1/me/profile', answers.toJson());

  Future<ConsentNoticeInfo> getConsentNotice() async {
    final map = _map(await _get('/v1/consents/notice'));
    return ConsentNoticeInfo(
      version: '${map['version']}',
      purposes: [
        for (final p in asJsonList(map['purposes']))
          ConsentPurposeInfo(
            purpose: '${p['purpose']}',
            required: p['required'] == true,
            title: '${p['title']}',
            description: '${p['description']}',
          ),
      ],
    );
  }

  /// `GET /v1/me/consents`: the latest choice per purpose (wire value → granted).
  Future<Map<String, bool>> getMyConsents() async {
    final map = _map(await _get('/v1/me/consents'));
    return {
      for (final c in asJsonList(map['choices']))
        '${c['purpose']}': c['granted'] == true,
    };
  }

  /// [choices] maps purpose wire values (`core_service`, ...) to granted.
  Future<void> recordConsents(
    String noticeVersion,
    Map<String, bool> choices,
  ) => _write('POST', '/v1/me/consents', {
    'noticeVersion': noticeVersion,
    'choices': [
      for (final e in choices.entries) {'purpose': e.key, 'granted': e.value},
    ],
  });

  // ------------------------------------------------------------------ exams (§19.1)

  /// Pure computation: no Idempotency-Key, nothing stored. Under 18 → `UNDER_18`.
  /// Returns the contract `EligibilityResult` JSON.
  Future<Map<String, dynamic>> checkEligibility(
    ProfileAnswersInput answers,
  ) async => _map(
    await _call(
      'POST',
      '/v1/eligibility/check',
      body: answers.toJson(),
      idempotent: false,
    ),
  );

  Future<MyExams> getMyExams() async {
    final json = _map(await _get('/v1/me/exams'));
    final main = json['main'];
    return MyExams(
      mainCode: main is Map ? main['code'] as String? : null,
      mainName: main is Map ? main['name'] as String? : null,
      otherCodes: [
        for (final o in asJsonList(json['others']))
          if (o['code'] is String) o['code'] as String,
      ],
    );
  }

  Future<void> putMyExams(String mainExamCode, List<String> otherExamCodes) =>
      _write('PUT', '/v1/me/exams', {
        'mainExamCode': mainExamCode,
        'otherExamCodes': otherExamCodes,
      });

  // ------------------------------------------------------------------ study (§5.1, §10.6)

  /// Contract `StudyMap` JSON.
  Future<Map<String, dynamic>> getStudyMap(String examCode) async =>
      _map(await _get('/v1/exams/${Uri.encodeComponent(examCode)}/study-map'));

  /// Contract `Lesson` JSON.
  Future<Map<String, dynamic>> getLesson(String topicId) async =>
      _map(await _get('/v1/topics/${Uri.encodeComponent(topicId)}/lesson'));

  // ------------------------------------------------------------------ offline sync (§39)

  /// `POST /v1/sync/study-actions` (contract `SyncBatchBody` → `SyncBatchResult` JSON). The caller owns the
  /// [idempotencyKey] so a retried batch reuses it (§34.3).
  Future<Map<String, dynamic>> syncStudyActions(
    Map<String, Object> body, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/sync/study-actions',
      body: body,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `GET /v1/content/packs?examCode=` (contract `ContentPackList` JSON).
  Future<Map<String, dynamic>> listContentPacks(String examCode) async => _map(
    await _get(
      '/v1/content/packs?examCode=${Uri.encodeQueryComponent(examCode)}',
    ),
  );

  // ------------------------------------------------------------------ exam hall (§10.6, INT-002-S10/S11)

  /// `GET /v1/exams/{code}/structure` (contract `ExamStructure` JSON): papers carry the answer mode.
  Future<Map<String, dynamic>> getExamStructure(String examCode) async =>
      _map(await _get('/v1/exams/${Uri.encodeComponent(examCode)}/structure'));

  /// `GET /v1/mocks?examCode=` (contract `MockList` JSON).
  Future<Map<String, dynamic>> listMocks(String examCode) async => _map(
    await _get('/v1/mocks?examCode=${Uri.encodeQueryComponent(examCode)}'),
  );

  /// `GET /v1/state-mock-sunday?examCode=` (contract `StateMockInfo` JSON).
  Future<Map<String, dynamic>> getStateMockSunday(
    String examCode,
  ) async => _map(
    await _get(
      '/v1/state-mock-sunday?examCode=${Uri.encodeQueryComponent(examCode)}',
    ),
  );

  /// `POST /v1/mocks/{id}/attempts` (contract `StartMockBody` → `MockAttemptState`). The caller owns the key
  /// so a retried start resumes the same attempt (§34.3).
  Future<Map<String, dynamic>> startMockAttempt(
    String mockId, {
    required String mode,
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/mocks/${Uri.encodeComponent(mockId)}/attempts',
      body: {'mode': mode},
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `GET /v1/mock-attempts/{id}` (contract `MockAttemptState`).
  Future<Map<String, dynamic>> getMockAttempt(String attemptId) async =>
      _map(await _get('/v1/mock-attempts/${Uri.encodeComponent(attemptId)}'));

  /// `PUT /v1/mock-attempts/{id}/answers` (contract `SaveMockAnswersBody` → `MockAnswersSaved`).
  Future<Map<String, dynamic>> saveMockAnswers(
    String attemptId,
    Map<String, Object> body, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'PUT',
      '/v1/mock-attempts/${Uri.encodeComponent(attemptId)}/answers',
      body: body,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `POST /v1/mock-attempts/{id}/submit` (contract `MockReport`).
  Future<Map<String, dynamic>> submitMockAttempt(
    String attemptId, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/mock-attempts/${Uri.encodeComponent(attemptId)}/submit',
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `GET /v1/mock-attempts/{id}/report` (contract `MockReport`).
  Future<Map<String, dynamic>> getMockReport(String attemptId) async => _map(
    await _get('/v1/mock-attempts/${Uri.encodeComponent(attemptId)}/report'),
  );

  // ------------------------------------------------------------------ mastery (§5.1, INT-002-S01..S04, BOLT-0017)

  /// `GET /v1/me/topic-states?examCode=` (contract `TopicStatePage` JSON): `nextCheck` per lamp.
  Future<Map<String, dynamic>> listMyTopicStates(String examCode) async => _map(
    await _get(
      '/v1/me/topic-states?examCode=${Uri.encodeQueryComponent(examCode)}&limit=500',
    ),
  );

  /// `GET /v1/me/relight-queue` (contract `RelightQueue` JSON).
  Future<Map<String, dynamic>> getRelightQueue() async =>
      _map(await _get('/v1/me/relight-queue'));

  /// `POST /v1/topics/{topicId}/checks` (contract `StartCheckBody` → `TopicCheck` JSON). The caller owns the key.
  Future<Map<String, dynamic>> startTopicCheck(
    String topicId, {
    required String kind,
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/topics/${Uri.encodeComponent(topicId)}/checks',
      body: {'kind': kind},
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `POST /v1/checks/{checkId}/submit` (contract `SubmitCheckBody` → `CheckResult` JSON).
  Future<Map<String, dynamic>> submitTopicCheck(
    String checkId,
    List<Map<String, Object>> answers, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/checks/${Uri.encodeComponent(checkId)}/submit',
      body: {'answers': answers},
      idempotencyKey: idempotencyKey,
    ),
  );

  // ------------------------------------------------------------------ practice (§10.6, §11, INT-002-S06..S09, BOLT-0017)

  /// `POST /v1/practice/sessions` (contract `StartPracticeBody` → `PracticeSession` JSON).
  Future<Map<String, dynamic>> startPracticeSession(
    Map<String, Object> body, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/practice/sessions',
      body: body,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `POST /v1/practice/sessions/{id}/answers` (contract `PracticeAnswerBody` → `PracticeAnswerResult` JSON).
  /// The key is the answer's `clientActionId`, the same id the outbox uses (§39).
  Future<Map<String, dynamic>> answerPracticeQuestion(
    String sessionId,
    Map<String, Object> body, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/practice/sessions/${Uri.encodeComponent(sessionId)}/answers',
      body: body,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `GET /v1/me/practice/usage` (contract `PracticeUsage` JSON).
  Future<Map<String, dynamic>> getPracticeUsage() async =>
      _map(await _get('/v1/me/practice/usage'));

  /// `GET /v1/me/mistakes` (contract `MistakePage` JSON).
  Future<Map<String, dynamic>> listMyMistakes({String? cursor}) async => _map(
    await _get(
      '/v1/me/mistakes${cursor == null ? '' : '?cursor=${Uri.encodeQueryComponent(cursor)}'}',
    ),
  );

  /// `GET /v1/me/drills` (contract `ConceptDrillList` JSON).
  Future<Map<String, dynamic>> listMyDrills() async =>
      _map(await _get('/v1/me/drills'));

  /// `GET /v1/pyq/facets?examCode=` (contract `PyqFacets` JSON).
  Future<Map<String, dynamic>> getPyqFacets(String examCode) async => _map(
    await _get('/v1/pyq/facets?examCode=${Uri.encodeQueryComponent(examCode)}'),
  );

  /// `GET /v1/pyq` (contract `PyqPage` JSON), cursor-paginated (§37).
  Future<Map<String, dynamic>> searchPyqs(
    String examCode, {
    int? year,
    String? subjectCode,
    int? difficulty,
    String? cursor,
    int limit = 20,
  }) async {
    final q = <String, String>{
      'examCode': examCode,
      'year': ?year?.toString(),
      'subjectCode': ?subjectCode,
      'difficulty': ?difficulty?.toString(),
      'cursor': ?cursor,
      'limit': '$limit',
    };
    return _map(await _get('/v1/pyq?${Uri(queryParameters: q).query}'));
  }

  /// `POST /v1/questions/{id}/reports` (contract `QuestionReportBody` → `QuestionReportAck`, §19.4 Q34).
  Future<void> reportQuestion(
    String questionId, {
    required int questionVersion,
    required String reason,
  }) => _write(
    'POST',
    '/v1/questions/${Uri.encodeComponent(questionId)}/reports',
    {'questionVersion': questionVersion, 'reason': reason},
  );

  // ------------------------------------------------------------------ plan (§10.6 Today, INT-002-S12/S13)

  /// `GET /v1/me/today` (contract `TodayScreen` JSON).
  Future<Map<String, dynamic>> getToday() async =>
      _map(await _get('/v1/me/today'));

  /// `GET /v1/me/plan/days?from=&to=` (contract `PlanDays` JSON). Dates are IST `YYYY-MM-DD`.
  Future<Map<String, dynamic>> getPlanDays(
    String from,
    String to,
  ) async => _map(
    await _get(
      '/v1/me/plan/days?${Uri(queryParameters: {'from': from, 'to': to}).query}',
    ),
  );

  /// `POST /v1/me/plan/rebalance` (contract `Plan` JSON). The caller owns the key (§34.3).
  Future<Map<String, dynamic>> rebalancePlan({
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/me/plan/rebalance',
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `PUT /v1/me/plan` (contract `PutPlanBody` → `Plan` JSON). The caller owns the key (§34.3).
  Future<Map<String, dynamic>> putPlan(
    Map<String, Object> body, {
    required String idempotencyKey,
  }) async => _map(
    await _call(
      'PUT',
      '/v1/me/plan',
      body: body,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// `PUT /v1/me/exams` with the chosen attempt cycle per exam code (contract `UserExamsBody.attemptCycles`, R2).
  Future<void> putMyExamsWithCycles(
    String mainExamCode,
    List<String> otherExamCodes,
    Map<String, String> attemptCycles,
  ) => _write('PUT', '/v1/me/exams', {
    'mainExamCode': mainExamCode,
    'otherExamCodes': otherExamCodes,
    'attemptCycles': attemptCycles,
  });

  // ------------------------------------------------------------------ readiness (INT-002-S14/S15)

  /// `GET /v1/me/readiness?examCode=` (contract `ReadinessMeter` JSON).
  Future<Map<String, dynamic>> getReadiness(String examCode) async => _map(
    await _get(
      '/v1/me/readiness?examCode=${Uri.encodeQueryComponent(examCode)}',
    ),
  );

  /// `GET /v1/me/sunday-reports` (contract `SundayReportPage` JSON).
  Future<Map<String, dynamic>> listSundayReports({
    String? cursor,
  }) async => _map(
    await _get(
      '/v1/me/sunday-reports${cursor == null ? '' : '?cursor=${Uri.encodeQueryComponent(cursor)}'}',
    ),
  );

  /// `GET /v1/me/sunday-reports/{id}` (contract `SundayReport` JSON).
  Future<Map<String, dynamic>> getSundayReport(String reportId) async => _map(
    await _get('/v1/me/sunday-reports/${Uri.encodeComponent(reportId)}'),
  );

  // ------------------------------------------------------------------ alerts (INT-002-S16/S17)

  /// `GET /v1/me/exam-alerts` (contract `ExamAlertPage` JSON).
  Future<Map<String, dynamic>> listMyExamAlerts({String? cursor}) async => _map(
    await _get(
      '/v1/me/exam-alerts${cursor == null ? '' : '?cursor=${Uri.encodeQueryComponent(cursor)}'}',
    ),
  );

  /// `GET /v1/me/alert-settings` (contract `AlertSettings` JSON).
  Future<Map<String, dynamic>> getAlertSettings() async =>
      _map(await _get('/v1/me/alert-settings'));

  /// `PUT /v1/me/alert-settings` (contract `PutAlertSettingsBody` → `AlertSettings` JSON).
  Future<Map<String, dynamic>> putAlertSettings(
    Map<String, Object> body,
  ) async => _map(
    await _call('PUT', '/v1/me/alert-settings', body: body, idempotent: true),
  );

  /// `POST /v1/me/push-tokens` (contract `RegisterPushTokenBody` → `PushTokenAck`).
  Future<void> registerPushToken({
    required String deviceId,
    required String platform,
    required String token,
  }) => _write('POST', '/v1/me/push-tokens', {
    'deviceId': deviceId,
    'platform': platform,
    'token': token,
  });

  /// `DELETE /v1/me/push-tokens/{deviceId}` (logout removes this device's token).
  Future<void> deletePushToken(String deviceId) => _write(
    'DELETE',
    '/v1/me/push-tokens/${Uri.encodeComponent(deviceId)}',
    null,
  );

  // ------------------------------------------------------------------ economy: XP, Points, trophies (BOLT-0113)

  /// `GET /v1/me/progress` (contract `MyProgress` JSON).
  Future<Map<String, dynamic>> getMyProgress() async =>
      _map(await _get('/v1/me/progress'));

  /// `POST /v1/me/check-in` (contract `CheckInResult` JSON). Once per IST day.
  Future<Map<String, dynamic>> checkIn() async =>
      _map(await _write('POST', '/v1/me/check-in', null));

  /// `GET /v1/leaderboard/weekly` (contract `WeeklyLeaderboard` JSON).
  Future<Map<String, dynamic>> getWeeklyLeaderboard() async =>
      _map(await _get('/v1/leaderboard/weekly'));

  /// `PUT /v1/me/leaderboard-opt-in` (contract `LeaderboardOptIn` JSON).
  Future<Map<String, dynamic>> putLeaderboardOptIn(bool optIn) async =>
      _map(await _write('PUT', '/v1/me/leaderboard-opt-in', {'optIn': optIn}));

  // ------------------------------------------------------------------ games: Daily Spin, Confidence Duel (BOLT-0115)

  /// `GET /v1/games/rules` (contract `GameRules` JSON): odds, scoring, limits.
  Future<Map<String, dynamic>> getGameRules() async =>
      _map(await _get('/v1/games/rules'));

  /// `GET /v1/games/daily-spin` (contract `DailySpinState` JSON).
  Future<Map<String, dynamic>> getDailySpin() async =>
      _map(await _get('/v1/games/daily-spin'));

  /// `POST /v1/games/daily-spin` (contract `DailySpinResult` JSON). The server draws.
  Future<Map<String, dynamic>> spinDailySpin() async =>
      _map(await _write('POST', '/v1/games/daily-spin', null));

  /// `GET /v1/games/confidence-duel?examCode=` (contract `ConfidenceDuel` JSON).
  Future<Map<String, dynamic>> startConfidenceDuel(
    String examCode,
  ) async => _map(
    await _get(
      '/v1/games/confidence-duel?examCode=${Uri.encodeQueryComponent(examCode)}',
    ),
  );

  /// `POST /v1/games/confidence-duel/{duelId}/submit` (contract `DuelResult` JSON).
  Future<Map<String, dynamic>> submitConfidenceDuel(
    String duelId,
    List<Map<String, Object>> answers,
  ) async => _map(
    await _write(
      'POST',
      '/v1/games/confidence-duel/${Uri.encodeComponent(duelId)}/submit',
      {'answers': answers},
    ),
  );

  // ------------------------------------------------------------------ Desk: exam changes (§20.2, OPS / ADMIN)

  /// `GET /v1/desk/exam-changes?status=` (contract `ExamChangePage`).
  Future<Map<String, dynamic>> deskExamChanges({
    String status = 'pending',
    String? cursor,
  }) async => _map(
    await _get(
      '/v1/desk/exam-changes?${Uri(queryParameters: {'status': status, 'cursor': ?cursor}).query}',
    ),
  );

  /// `POST /v1/desk/exam-changes/{id}/approve` (contract `ApproveExamChangeBody`).
  Future<Map<String, dynamic>> deskApproveExamChange(
    String changeId,
    Map<String, Object> body,
  ) async => _map(
    await _write(
      'POST',
      '/v1/desk/exam-changes/${Uri.encodeComponent(changeId)}/approve',
      body,
    ),
  );

  /// `POST /v1/desk/exam-changes/{id}/reject` (contract `RejectExamChangeBody`).
  Future<Map<String, dynamic>> deskRejectExamChange(
    String changeId,
    String reason,
  ) async => _map(
    await _write(
      'POST',
      '/v1/desk/exam-changes/${Uri.encodeComponent(changeId)}/reject',
      {'reason': reason},
    ),
  );

  // ------------------------------------------------------------------ Stall: expo challenge + sticker codes (BOLT-0112)

  /// `GET /v1/expo/challenge` (contract `ExpoChallenge`). Never carries answers.
  Future<Map<String, dynamic>> startExpoChallenge() async =>
      _map(await _get('/v1/expo/challenge'));

  /// `POST /v1/expo/challenge/{id}/submit` (contract `SubmitExpoChallengeBody` -> `ExpoChallengeResult`).
  /// Each answer: `{questionId, optionId (null = no answer), ms}`.
  /// Pass the same [idempotencyKey] on a retry so the server scores the attempt once; a fresh key is
  /// used when it is null.
  Future<Map<String, dynamic>> submitExpoChallenge(
    String challengeId,
    List<Map<String, Object?>> answers, {
    String? idempotencyKey,
  }) async => _map(
    await _call(
      'POST',
      '/v1/expo/challenge/${Uri.encodeComponent(challengeId)}/submit',
      body: {'answers': answers},
      idempotent: true,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// A fresh Idempotency-Key for a write the caller may retry.
  String newIdempotencyKey() => _newKey();

  /// `GET /v1/me/sticker-code` (contract `MyStickerCode`): `{code: String?, redeemed: bool}`.
  Future<Map<String, dynamic>> getMyStickerCode() async =>
      _map(await _get('/v1/me/sticker-code'));

  /// `POST /v1/desk/sticker-codes/redeem` (OPS, ADMIN, SUPPORT_AGENT). Throws `STICKER_CODE_NOT_FOUND` or
  /// `STICKER_CODE_ALREADY_REDEEMED`.
  Future<Map<String, dynamic>> deskRedeemStickerCode(String code) async => _map(
    await _write('POST', '/v1/desk/sticker-codes/redeem', {'code': code}),
  );

  void dispose() {
    _http.close();
    updateRequired.dispose();
  }

  // ------------------------------------------------------------------ plumbing

  static const _unknown = HmApiException(
    HmApiException.unknownError,
    HmApiException.unknownMessage,
  );

  Future<void> _storeTokens(Object? json) async {
    final tokens = tokensFromJson(json);
    if (tokens == null) throw _unknown;
    await _tokens.write(tokens);
  }

  Future<Object?> _get(String path) => _call('GET', path);

  Future<Object?> _write(
    String method,
    String path,
    Map<String, Object>? body,
  ) => _call(method, path, body: body, idempotent: true);

  Future<Object?> _call(
    String method,
    String path, {
    Map<String, Object>? body,
    bool idempotent = false,
    String? idempotencyKey,
  }) async {
    final request = http.Request(method, Uri.parse('${config.baseUrl}$path'))
      ..headers['accept'] = 'application/json';
    if (idempotencyKey != null) {
      request.headers[HmHttpClient.idempotencyHeader] = idempotencyKey;
    } else if (idempotent) {
      request.headers[HmHttpClient.idempotencyHeader] = _newKey();
    }
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(request));
    } on http.ClientException {
      throw HmApiException.network();
    } on Exception {
      throw HmApiException.network();
    }
    final text = utf8.decode(res.bodyBytes, allowMalformed: true);
    if (res.statusCode >= 400) {
      final error = HmApiException.fromResponse(
        res.statusCode,
        text,
        headers: res.headers,
      );
      if (error.code == 'APP_UPDATE_REQUIRED') updateRequired.value = true;
      throw error;
    }
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      throw _unknown;
    }
  }

  static Map<String, dynamic> _map(Object? json) {
    if (json is Map) return json.cast<String, dynamic>();
    throw _unknown;
  }
}
