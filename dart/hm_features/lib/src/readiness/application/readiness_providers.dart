import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../study_map/application/study_providers.dart'
    show mainExamCodeProvider;
import '../data/readiness_repository.dart';
import '../domain/readiness_models.dart';

/// Readiness wiring (INT-002-S14/S15). Tests override the repository.

final readinessRepositoryProvider = Provider<ReadinessRepository>(
  (ref) => ApiReadinessRepository(ref.watch(hmApiProvider)),
);

/// The meter for the main exam; null when no main exam is chosen yet.
final readinessProvider = FutureProvider<ReadinessView?>((ref) async {
  final exam = await ref.watch(mainExamCodeProvider.future);
  if (exam == null) return null;
  return ref.watch(readinessRepositoryProvider).meter(exam);
});

/// The first page of Sunday Reports (one a week, so one page covers months).
final sundayReportsProvider = FutureProvider<SundayReportPageView>(
  (ref) => ref.watch(readinessRepositoryProvider).reports(),
);

final sundayReportProvider = FutureProvider.family<SundayReportView, String>(
  (ref, id) => ref.watch(readinessRepositoryProvider).report(id),
);
