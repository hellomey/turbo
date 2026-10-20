/// Feature: study_map - Subjects, lamps with three rings, dimming, zoom/parallax (Lite: static)
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'application/study_providers.dart';
export 'data/study_repository.dart';
export 'domain/study_map_view.dart';
export 'presentation/study_map_body.dart';
