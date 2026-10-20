/// Feature: onboarding - DOB gate, eligibility-first onboarding, first lamp, email OTP save (§17.1)
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'application/onboarding_controller.dart';
export 'data/onboarding_repository.dart';
export 'domain/age_gate.dart';
export 'domain/profile_draft.dart';
export 'presentation/onboarding_flow.dart';
