import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

import '../../exam_hall/application/exam_hall_controller.dart'
    show idempotencyKeyFactoryProvider;
import '../data/practice_repository.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';
import 'study_recorder.dart';
import 'sync_status.dart';

final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => ApiPracticeRepository(ref.watch(hmApiProvider)),
);

/// Asks the outbox to send now (if online). Started by the app shell (BOLT-0016 sync triggers, §39).
final studySyncNudgeProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    await ref.read(syncTriggersProvider).actionRecorded();
  },
);

/// New client UUID for an outbox entry (§39); the same id is the Idempotency-Key online.
final clientActionIdProvider = Provider<String Function()>(
  (ref) => ref.watch(idempotencyKeyFactoryProvider),
);

final studyRecorderProvider = Provider<StudyRecorder>(
  (ref) => StudyRecorder(
    outbox: ref.watch(outboxRepositoryProvider),
    repository: ref.watch(practiceRepositoryProvider),
    nudge: ref.watch(studySyncNudgeProvider),
    newId: ref.watch(clientActionIdProvider),
    onLocalChange: () =>
        unawaited(ref.read(syncStatusProvider.notifier).refresh()),
  ),
);

final relightQueueProvider = FutureProvider<RelightQueueView>(
  (ref) => ref.watch(practiceRepositoryProvider).relightQueue(),
);

final mistakesProvider = FutureProvider<MistakesView>(
  (ref) => ref.watch(practiceRepositoryProvider).mistakes(),
);

final practiceUsageProvider = FutureProvider<UsageView>(
  (ref) => ref.watch(practiceRepositoryProvider).usage(),
);

/// The IST day the limit sheet was shown on this phone (§13: at most once a day).
final limitSheetShownDayProvider =
    NotifierProvider<LimitSheetShownDay, String?>(LimitSheetShownDay.new);

class LimitSheetShownDay extends Notifier<String?> {
  @override
  String? build() => null;

  void mark(String istDay) => state = istDay;
}

/// Next check per lamp for the Study Map's lamp sheet (empty if it can't load: the sheet then offers the lesson).
final nextChecksProvider =
    FutureProvider.family<Map<String, NextCheck>, String>((
      ref,
      examCode,
    ) async {
      try {
        return await ref.watch(practiceRepositoryProvider).nextChecks(examCode);
      } on Object {
        return const {};
      }
    });
