import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';

import '../../plan/data/plan_repository.dart' show parseApi;
import '../domain/alert_models.dart';

/// Exam Alerts, alert settings and push tokens (INT-002-S16/S17) over the notifications + exams routes.
abstract interface class AlertsRepository {
  Future<ExamAlertPageView> examAlerts({String? cursor});

  Future<AlertSettingsView> settings();

  Future<AlertSettingsView> saveSettings(AlertSettingsView settings);

  Future<void> registerPushToken({
    required String deviceId,
    required String platform,
    required String token,
  });
}

class ApiAlertsRepository implements AlertsRepository {
  ApiAlertsRepository(this._api);

  final HmApi _api;

  @override
  Future<ExamAlertPageView> examAlerts({String? cursor}) async {
    final json = await _api.listMyExamAlerts(cursor: cursor);
    final page = parseApi(() => api.ExamAlertPage.fromJson(json));
    return ExamAlertPageView(
      items: [for (final a in page.items) examAlertFromApi(a)],
      nextCursor: page.nextCursor,
    );
  }

  @override
  Future<AlertSettingsView> settings() async {
    final json = await _api.getAlertSettings();
    return settingsFromApi(parseApi(() => api.AlertSettings.fromJson(json)));
  }

  @override
  Future<AlertSettingsView> saveSettings(AlertSettingsView settings) async {
    final json = await _api.putAlertSettings(settings.toJson());
    return settingsFromApi(parseApi(() => api.AlertSettings.fromJson(json)));
  }

  @override
  Future<void> registerPushToken({
    required String deviceId,
    required String platform,
    required String token,
  }) => _api.registerPushToken(
    deviceId: deviceId,
    platform: platform,
    token: token,
  );
}

ExamAlertKindView _kind(String v) => switch (v) {
  'notification' => ExamAlertKindView.notification,
  'date_change' => ExamAlertKindView.dateChange,
  'admit_card' => ExamAlertKindView.admitCard,
  'result' => ExamAlertKindView.result,
  'answer_key' => ExamAlertKindView.answerKey,
  _ => ExamAlertKindView.other,
};

ExamAlertView examAlertFromApi(api.ExamAlert a) => ExamAlertView(
  id: a.id,
  examCode: a.examCode,
  kind: _kind(a.kind.value),
  title: a.title,
  summary: a.summary,
  officialUrl: a.officialUrl,
  publishedAt: a.publishedAt,
  confirmLine: a.confirmLine,
);

AlertSettingsView settingsFromApi(api.AlertSettings s) => AlertSettingsView(
  studyReminders: s.studyReminders,
  examAlerts: s.examAlerts,
  offers: s.offers,
  quietEnabled: s.quietHours.enabled,
  quietStartMinute: s.quietHours.startMinute,
  quietEndMinute: s.quietHours.endMinute,
  morningAlertMinute: s.morningAlertMinute,
  dailyLimit: s.dailyLimit,
);
