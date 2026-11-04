/// Feature: plan - My Plan, auto-rebalance, Final Stretch, Today Card, rank bar (INT-002-S12/S13).
///
/// Layers (blueprint §35):
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline outbox)
library;

export 'application/plan_controller.dart';
export 'data/plan_repository.dart';
export 'domain/plan_models.dart';
export 'presentation/my_plan_screen.dart';
export 'presentation/plan_card.dart';
export 'presentation/rank_bar.dart';
export 'application/plan_setup_controller.dart';
export 'data/plan_setup_repository.dart';
export 'domain/plan_setup_models.dart';
export 'presentation/plan_setup_screen.dart';
