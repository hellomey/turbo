import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../lessons/domain/lesson_view.dart';
import '../data/study_repository.dart';
import '../domain/study_map_view.dart';

final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => ApiStudyRepository(ref.watch(hmApiProvider)),
);

/// The signed-in user's main exam code (null until chosen).
final mainExamCodeProvider = FutureProvider<String?>(
  (ref) => ref.watch(studyRepositoryProvider).mainExamCode(),
);

final studyMapProvider = FutureProvider.family<StudyMapView, String>(
  (ref, examCode) => ref.watch(studyRepositoryProvider).studyMap(examCode),
);

final lessonProvider = FutureProvider.family<LessonView, String>(
  (ref, topicId) => ref.watch(studyRepositoryProvider).lesson(topicId),
);

/// Lite Mode (§10.8): static list instead of the island map. Automatic RAM detection arrives later;
/// apps override this from the user's setting.
final liteModeProvider = Provider<bool>((ref) => false);
