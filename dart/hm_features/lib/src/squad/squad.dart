/// Feature: squad - Squad, chat, Help Requests, Squad Battles, Squad Goal, kind leaderboards
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'presentation/squad_tab.dart';
