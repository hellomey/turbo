import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:hm_core/hm_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _config = ApiConfig(baseUrl: 'http://api.test', appVersion: '0.1.0');

StoredTokens _tokens(String access) => StoredTokens(
  accessToken: access,
  refreshToken: 'refresh-$access-0123456789',
  accessTokenExpiresAt: DateTime.utc(2026, 10, 20, 12),
);

http.Response _json(
  Object body, {
  int status = 200,
  Map<String, String>? headers,
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json', ...?headers},
);

http.Response _error(int status, String code, String message) => _json({
  'error': {'code': code, 'message': message},
}, status: status);

final _profile = ProfileAnswersInput(
  dateOfBirth: DateTime(2000, 1, 15),
  qualification: 'degree',
  community: 'BC',
  pstm: true,
);

void main() {
  group('Idempotency-Key (§34.3)', () {
    test('every write gets a UUID key; the eligibility check does not', () async {
      final seen = <String, String?>{};
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(_tokens('a1')),
        httpClient: MockClient((req) async {
          seen['${req.method} ${req.url.path}'] =
              req.headers['idempotency-key'];
          return switch (req.url.path) {
            '/v1/eligibility/check' => _json({
              'eligibleCount': 0,
              'eligible': <Object>[],
              'notEligible': <Object>[],
              'disclaimer': 'Always confirm with the official notification.',
            }),
            '/v1/auth/otp/request' => _json({'resendAfterSeconds': 60}),
            '/v1/me' => _json({
              'id': '6f1c1c56-6c7e-4c41-9d5c-1d1f6f2a0b11',
              'email': 'a@b.in',
              'nickname': null,
              'district': null,
              'calmMode': true,
              'liteMode': null,
              'hideFromLeaderboards': false,
              'profile': null,
              'roles': ['ASPIRANT'],
              'deletionScheduledFor': null,
              'createdAt': '2026-10-20T00:00:00.000Z',
            }),
            _ => _json({'ok': true}),
          };
        }),
      );

      await api.checkEligibility(_profile);
      await api.requestOtp('a@b.in');
      await api.updateMe(calmMode: true);
      await api.putProfile(_profile);
      await api.putMyExams('tnpsc-group-4', const []);

      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(seen['POST /v1/eligibility/check'], isNull);
      for (final key in [
        'POST /v1/auth/otp/request',
        'PATCH /v1/me',
        'PUT /v1/me/profile',
        'PUT /v1/me/exams',
      ]) {
        expect(seen[key], matches(uuid), reason: key);
      }
      final keys = seen.values.whereType<String>().toSet();
      expect(keys.length, 4, reason: 'a fresh key for every write');
    });

    test('GET requests carry no key', () async {
      String? key = 'unset';
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(),
        httpClient: MockClient((req) async {
          key = req.headers['idempotency-key'];
          return _json({'version': 'v1', 'purposes': <Object>[]});
        }),
      );
      await api.getConsentNotice();
      expect(key, isNull);
    });

    test(
      'bodies are compact JSON and the date of birth is the calendar date',
      () async {
        Map<String, dynamic>? body;
        final api = HmApi(
          config: _config,
          tokens: MemoryTokenStore(),
          httpClient: MockClient((req) async {
            body = jsonDecode(req.body) as Map<String, dynamic>;
            return _json({
              'eligibleCount': 0,
              'eligible': <Object>[],
              'notEligible': <Object>[],
              'disclaimer': 'x',
            });
          }),
        );
        await api.checkEligibility(
          ProfileAnswersInput(
            dateOfBirth: DateTime(2000, 1, 15),
            qualification: 'hsc',
            community: 'MBC_DNC',
            pstm: false,
          ),
        );
        expect(body, {
          'dateOfBirth': '2000-01-15',
          'qualification': 'hsc',
          'community': 'MBC_DNC',
          'pstm': false,
          'specialCategories': <Object>[],
        });
      },
    );
  });

  group('error envelope (§37)', () {
    test('parses code and message into HmApiException', () async {
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(),
        httpClient: MockClient(
          (_) async => _error(
            422,
            'UNDER_18',
            'HeyMey is for 18+. See you on your 18th birthday.',
          ),
        ),
      );
      await expectLater(
        api.checkEligibility(_profile),
        throwsA(
          isA<HmApiException>()
              .having((e) => e.code, 'code', 'UNDER_18')
              .having((e) => e.statusCode, 'status', 422)
              .having(
                (e) => e.message,
                'message',
                'HeyMey is for 18+. See you on your 18th birthday.',
              ),
        ),
      );
    });

    test('non-envelope bodies become a generic simple-English error', () {
      final e = HmApiException.fromResponse(502, '<html>bad gateway</html>');
      expect(e.code, 'INTERNAL_ERROR');
      expect(e.message, 'Something went wrong. Please try again.');
    });

    test('network failures become NETWORK_ERROR', () async {
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(),
        httpClient: MockClient((_) async => throw http.ClientException('down')),
      );
      await expectLater(
        api.getConsentNotice(),
        throwsA(
          isA<HmApiException>().having((e) => e.isNetwork, 'network', true),
        ),
      );
    });

    test('Retry-After is kept for RATE_LIMITED', () {
      final e = HmApiException.fromResponse(
        429,
        jsonEncode({
          'error': {'code': 'RATE_LIMITED', 'message': 'Too many tries.'},
        }),
        headers: {'retry-after': '120'},
      );
      expect(e.retryAfterSeconds, 120);
    });
  });

  group('refresh on 401 (§38)', () {
    test(
      'concurrent 401s share ONE refresh, then each request is retried',
      () async {
        final store = MemoryTokenStore(_tokens('old'));
        var refreshCalls = 0;
        final refreshGate = Completer<void>();
        final authSeen = <String>[];
        final api = HmApi(
          config: _config,
          tokens: store,
          httpClient: MockClient((req) async {
            if (req.url.path == '/v1/auth/refresh') {
              refreshCalls++;
              expect(req.headers['idempotency-key'], isNotNull);
              await refreshGate.future;
              return _json({
                'accessToken': 'new',
                'refreshToken': 'refresh-new-0123456789',
                'accessTokenExpiresAt': '2026-10-20T13:00:00.000Z',
              });
            }
            authSeen.add(req.headers['authorization'] ?? '');
            if (req.headers['authorization'] == 'Bearer old') {
              return _error(401, 'UNAUTHENTICATED', 'Please sign in again.');
            }
            return _json({
              'examCode': 'x',
              'subjects': <Object>[],
              'totalTopics': 0,
            });
          }),
        );

        final a = api.getStudyMap('tnpsc-group-4');
        final b = api.getStudyMap('tnpsc-group-2');
        final c = api.getStudyMap('tnpsc-group-1');
        await Future<void>.delayed(Duration.zero);
        refreshGate.complete();
        await Future.wait([a, b, c]);

        expect(refreshCalls, 1);
        expect((await store.read())!.accessToken, 'new');
        expect(authSeen.where((h) => h == 'Bearer new').length, 3);
      },
    );

    test('a retried write keeps its Idempotency-Key', () async {
      final keys = <String?>[];
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(_tokens('old')),
        httpClient: MockClient((req) async {
          if (req.url.path == '/v1/auth/refresh') {
            return _json({
              'accessToken': 'new',
              'refreshToken': 'refresh-new-0123456789',
              'accessTokenExpiresAt': '2026-10-20T13:00:00.000Z',
            });
          }
          keys.add(req.headers['idempotency-key']);
          return req.headers['authorization'] == 'Bearer old'
              ? _error(401, 'UNAUTHENTICATED', 'Please sign in again.')
              : _json({'ok': true});
        }),
      );
      await api.putMyExams('tnpsc-group-4', const []);
      expect(keys, hasLength(2));
      expect(keys[0], keys[1]);
    });

    test('SESSION_REVOKED on refresh clears tokens and signs out', () async {
      final store = MemoryTokenStore(_tokens('old'));
      var signedOut = 0;
      final api = HmApi(
        config: _config,
        tokens: store,
        onSignedOut: () => signedOut++,
        httpClient: MockClient((req) async {
          if (req.url.path == '/v1/auth/refresh') {
            return _error(
              401,
              'SESSION_REVOKED',
              'You were signed out. Please sign in again.',
            );
          }
          return _error(401, 'UNAUTHENTICATED', 'Please sign in again.');
        }),
      );
      await expectLater(
        api.getMe(),
        throwsA(
          isA<HmApiException>().having((e) => e.statusCode, 'status', 401),
        ),
      );
      expect(await store.read(), isNull);
      expect(signedOut, 1);
    });

    test('public calls without a token are not refreshed', () async {
      var refreshCalls = 0;
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(),
        httpClient: MockClient((req) async {
          if (req.url.path == '/v1/auth/refresh') refreshCalls++;
          return _error(
            401,
            'OTP_INVALID',
            'That code is not right. Please check your email and try again.',
          );
        }),
      );
      await expectLater(
        api.verifyOtp(
          email: 'a@b.in',
          code: '123456',
          deviceId: '6f1c1c56-6c7e-4c41-9d5c-1d1f6f2a0b11',
          platform: ClientPlatform.android,
        ),
        throwsA(
          isA<HmApiException>().having((e) => e.code, 'code', 'OTP_INVALID'),
        ),
      );
      expect(refreshCalls, 0);
    });
  });

  group('OTP verify oneOf decoding', () {
    test('kind=session stores the tokens', () async {
      final store = MemoryTokenStore();
      Map<String, dynamic>? sent;
      final api = HmApi(
        config: _config,
        tokens: store,
        httpClient: MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return _json({
            'kind': 'session',
            'tokens': {
              'accessToken': 'acc',
              'refreshToken': 'refresh-acc-0123456789',
              'accessTokenExpiresAt': '2026-10-20T13:00:00.000Z',
            },
            'isNewUser': true,
            'deletionCancelled': false,
          });
        }),
      );
      final outcome = await api.verifyOtp(
        email: ' a@b.in ',
        code: '123456',
        deviceId: '6f1c1c56-6c7e-4c41-9d5c-1d1f6f2a0b11',
        platform: ClientPlatform.android,
      );
      expect(outcome, isA<OtpSessionOutcome>());
      expect((await store.read())!.accessToken, 'acc');
      expect(sent, containsPair('client', 'app'));
      expect(sent, containsPair('email', 'a@b.in'));
    });

    test('kind=desk_2fa returns the challenge and stores nothing', () async {
      final store = MemoryTokenStore();
      final api = HmApi(
        config: _config,
        tokens: store,
        httpClient: MockClient(
          (_) async => _json({
            'kind': 'desk_2fa',
            'challengeToken': 'chal',
            'totpEnrolled': false,
          }),
        ),
      );
      final outcome = await api.verifyOtp(
        email: 'staff@heymey.app',
        code: '123456',
        deviceId: '6f1c1c56-6c7e-4c41-9d5c-1d1f6f2a0b11',
        platform: ClientPlatform.web,
        client: ClientKind.desk,
      );
      expect(
        outcome,
        isA<OtpDeskChallengeOutcome>().having(
          (o) => o.totpEnrolled,
          'enrolled',
          false,
        ),
      );
      expect(await store.read(), isNull);
    });
  });

  group('X-Min-App-Version (§37)', () {
    test('a higher minimum raises the update-required signal', () async {
      final api = HmApi(
        config: _config,
        tokens: MemoryTokenStore(),
        httpClient: MockClient(
          (_) async => _json(
            {'version': 'v1', 'purposes': <Object>[]},
            headers: {'x-min-app-version': '0.2.0'},
          ),
        ),
      );
      expect(api.updateRequired.value, isFalse);
      await api.getConsentNotice();
      expect(api.updateRequired.value, isTrue);
    });

    test('version comparison', () {
      expect(isVersionLower('0.1.0', '0.2.0'), isTrue);
      expect(isVersionLower('1.2.3+4', '1.2.3'), isFalse);
      expect(isVersionLower('1.10.0', '1.9.9'), isFalse);
      expect(isVersionLower('1.0.0', 'garbage'), isFalse);
    });
  });

  group('consents', () {
    test(
      'GET /v1/me/consents decodes; POST sends every purpose with the version',
      () async {
        Map<String, dynamic>? posted;
        final api = HmApi(
          config: _config,
          tokens: MemoryTokenStore(_tokens('a')),
          httpClient: MockClient((req) async {
            if (req.method == 'POST') {
              posted = jsonDecode(req.body) as Map<String, dynamic>;
              return _json({
                'noticeVersion': '2026-10-v2',
                'choices': <Object>[],
              });
            }
            return _json({
              'noticeVersion': '2026-10-v2',
              'choices': [
                {
                  'purpose': 'core_service',
                  'granted': true,
                  'at': '2026-10-20T00:00:00.000Z',
                },
                {
                  'purpose': 'offers_email',
                  'granted': false,
                  'at': '2026-10-20T00:00:00.000Z',
                },
              ],
            });
          }),
        );
        expect(await api.getMyConsents(), {
          'core_service': true,
          'offers_email': false,
        });
        await api.recordConsents('2026-10-v2', {
          'core_service': true,
          'offers_email': true,
        });
        expect(posted, {
          'noticeVersion': '2026-10-v2',
          'choices': [
            {'purpose': 'core_service', 'granted': true},
            {'purpose': 'offers_email', 'granted': true},
          ],
        });
      },
    );
  });

  group('Me decoding', () {
    test('a new user with profile=null decodes', () {
      final me = MeInfo.fromJson({
        'id': 'id',
        'email': 'a@b.in',
        'nickname': null,
        'calmMode': false,
        'liteMode': null,
        'profile': null,
        'roles': ['ASPIRANT'],
        'deletionScheduledFor': null,
      });
      expect(me.hasProfile, isFalse);
      expect(me.roles, ['ASPIRANT']);
      expect(me.deletionScheduledFor, isNull);
    });
  });

  group('ApiConfig', () {
    test('defaults per platform; an explicit define wins', () {
      expect(
        ApiConfig.resolveBaseUrl(
          '',
          platform: TargetPlatform.android,
          isWeb: false,
        ),
        'http://10.0.2.2:4567',
      );
      expect(
        ApiConfig.resolveBaseUrl(
          '',
          platform: TargetPlatform.iOS,
          isWeb: false,
        ),
        'http://localhost:4567',
      );
      expect(
        ApiConfig.resolveBaseUrl(
          '',
          platform: TargetPlatform.android,
          isWeb: true,
        ),
        'http://localhost:4567',
      );
      expect(
        ApiConfig.resolveBaseUrl(
          'https://api.heymey.app/',
          platform: TargetPlatform.android,
          isWeb: false,
        ),
        'https://api.heymey.app',
      );
    });
  });

  group('stores', () {
    test('device id is created once and reused', () async {
      final kv = MemoryKeyValue();
      final first = await DeviceIdStore(kv).deviceId();
      final second = await DeviceIdStore(kv).deviceId();
      expect(first, second);
      expect(first, hasLength(36));
    });

    test('secure token store round-trips', () async {
      final store = SecureTokenStore(MemoryKeyValue());
      await store.write(_tokens('x'));
      expect((await store.read())!.refreshToken, 'refresh-x-0123456789');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('cached token store keeps a memory copy', () async {
      final persistent = MemoryTokenStore(_tokens('p'));
      final cached = CachedTokenStore(persistent);
      expect((await cached.read())!.accessToken, 'p');
      await cached.clear();
      expect(await persistent.read(), isNull);
    });
  });
}
