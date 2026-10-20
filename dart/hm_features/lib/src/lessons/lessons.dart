/// Feature: lessons - Reading view, Listen Mode, textbook reference, check yourself
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'application/listen_controller.dart';
export 'domain/lesson_view.dart';
export 'domain/markdown.dart';
export 'presentation/lesson_screen.dart';
