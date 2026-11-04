/// Feature: readiness - Readiness Meter (four evidence bars), Sunday Report (INT-002-S14/S15)
///
/// Layers (blueprint §35):
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api
library;

export 'application/readiness_providers.dart';
export 'data/readiness_repository.dart';
export 'domain/readiness_models.dart';
export 'presentation/readiness_screen.dart';
export 'presentation/sunday_report_screens.dart';
