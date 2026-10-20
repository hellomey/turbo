/// Feature: eligibility - Eligibility Checker, exam pages, compare, share card
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'domain/eligibility_view.dart';
export 'presentation/eligibility_result_view.dart';
