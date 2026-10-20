/// Feature: play - Play tab hub: duel, clue poker, district quest, quick games, events, rules cards with odds
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'presentation/play_tab.dart';
