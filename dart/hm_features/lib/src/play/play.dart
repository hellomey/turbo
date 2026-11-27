/// Feature: play - Play tab hub: Daily Spin, Confidence Duel, Rules & odds (BOLT-0115). Clue poker, district quest
/// and events arrive in later bolts.
///
/// Layers (blueprint §35):
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod providers, view models and the repository over hm_api
library;

export 'application/play_controller.dart';
export 'presentation/confidence_duel_screen.dart';
export 'presentation/daily_spin_screen.dart';
export 'presentation/play_tab.dart';
