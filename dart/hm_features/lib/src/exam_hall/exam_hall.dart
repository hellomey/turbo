/// Feature: exam_hall - OMR + CBT mocks. NO game styling, no sounds, no alerts (§10.6, §9.10).
///
/// Layers (blueprint §35):
///   presentation/  widgets + screens (no logic beyond layout)
///   application/   Riverpod controllers (state + intents)
///   domain/        feature models
///   data/          repositories over hm_api (online) + hm_data (offline)
library;

export 'application/exam_hall_controller.dart';
export 'data/exam_hall_repository.dart';
export 'domain/exam_hall_models.dart';
export 'presentation/attempt_view.dart';
export 'presentation/exam_hall_screens.dart';
export 'presentation/mock_list_body.dart';
export 'presentation/mock_start_body.dart';
export 'presentation/report_body.dart';
