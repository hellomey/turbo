/// Feature: profile - Profile, settings, privacy, Calm Mode, Lite Mode, role switcher, account deletion
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'application/profile_controller.dart';
export 'data/profile_repository.dart';
export 'presentation/profile_tab.dart';
