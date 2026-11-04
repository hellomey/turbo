import 'package:flutter_test/flutter_test.dart';
import 'package:hm_data/hm_data.dart';

/// Exam Hall answers on the phone (BOLT-0019, D-2026-10-22-24): Drift and memory behave the same.
void main() {
  final t0 = DateTime.utc(2026, 10, 20, 4, 30);

  LocalMockAnswer answer(String q, List<String> chosen, DateTime at) =>
      LocalMockAnswer(
        attemptId: 'a-1',
        questionId: q,
        chosenOptionIds: chosen,
        markedForReview: false,
        clientAt: at,
      );

  for (final (name, make) in <(String, MockAnswerStore Function())>[
    ('memory', MemoryMockAnswerStore.new),
    ('drift', () => DriftMockAnswerStore(HmDatabase.memory())),
  ]) {
    test('$name: put, sync, newer change stays unsynced, clear', () async {
      final store = make();
      await store.setActiveAttempt('a-1');
      final first = answer('q1', ['o1'], t0);
      await store.put(first);
      await store.put(answer('q2', ['o2'], t0));
      expect((await store.unsynced('a-1')).length, 2);

      // A newer change to q1 arrives while the first batch is in flight.
      await store.put(answer('q1', ['o3'], t0.add(const Duration(seconds: 1))));
      await store.markSynced([
        first,
        answer('q2', ['o2'], t0),
      ]);
      final left = await store.unsynced('a-1');
      expect(left.single.chosenOptionIds, ['o3']);
      expect((await store.all('a-1')).length, 2);

      expect(await store.activeAttempt(), 'a-1');
      await store.clear('a-1');
      expect(await store.all('a-1'), isEmpty);
      expect(await store.activeAttempt(), isNull);
    });
  }
}
