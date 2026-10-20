/// Feature: desk_admin - Admin Desk: prices, payouts, roles, refunds, data deletion (two-person approval)
///
/// Layers (blueprint §35), created as the feature is built:
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;
