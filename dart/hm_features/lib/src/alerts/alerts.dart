/// Feature: alerts - Exam Alerts, alert settings (max 3 a day), push token registration (INT-002-S16/S17)
///
/// Layers (blueprint §35):
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api
library;

export 'application/alerts_controller.dart';
export 'application/push_registration.dart';
export 'data/alerts_repository.dart';
export 'domain/alert_models.dart';
export 'presentation/alert_settings_screen.dart';
export 'presentation/exam_alerts_screen.dart';
