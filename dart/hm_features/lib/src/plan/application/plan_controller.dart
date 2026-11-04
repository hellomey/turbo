import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

import '../../common/ports.dart';
import '../../exam_hall/application/exam_hall_controller.dart'
    show idempotencyKeyFactoryProvider;
import '../../practice/application/practice_providers.dart'
    show studySyncNudgeProvider;
import '../../practice/application/sync_status.dart';
import '../data/plan_repository.dart';
import '../domain/plan_models.dart';

/// Plan wiring (INT-002-S12). Tests override the repository and the outbox.

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => ApiPlanRepository(ref.watch(hmApiProvider)),
);

/// The server's Today screen (rank, Today Card, relight, pocket sessions).
final todayProvider = FutureProvider<TodayView>(
  (ref) => ref.watch(planRepositoryProvider).today(),
);

/// How many days My Plan shows (S12: the 14-day view).
const planWindowDays = 14;

/// 14 days from the server's IST day (§37: never the phone's date).
final planDaysProvider = FutureProvider<List<PlanDayView>>((ref) async {
  final today = await ref.watch(todayProvider.future);
  final to = today.day.add(const Duration(days: planWindowDays - 1));
  return ref.watch(planRepositoryProvider).days(today.day, dateOnly(to));
});

class PlanState {
  const PlanState({
    this.overrides = const {},
    this.rebalancing = false,
    this.message,
  });

  /// Status marked on this phone and queued in the outbox, shown until the server's plan is reloaded.
  final Map<String, PlanItemStatusView> overrides;
  final bool rebalancing;
  final String? message;

  PlanItemView apply(PlanItemView item) {
    final s = overrides[item.id];
    return s == null ? item : item.withStatus(s);
  }
}

/// Item status (outbox first, §39) and rebalance (online, §34.3). No business rules live in widgets.
class PlanController extends Notifier<PlanState> {
  @override
  PlanState build() => const PlanState();

  /// Marks [item] done or skipped: written to the phone's outbox first, then synced. Returns false when the
  /// item can't be marked (not pending).
  Future<bool> mark(PlanItemView item, PlanItemStatusView status) async {
    if (!item.canMark) return false;
    final wire = switch (status) {
      PlanItemStatusView.done => PlanItemStatus.done,
      PlanItemStatusView.skipped => PlanItemStatus.skipped,
      _ => null,
    };
    if (wire == null) return false;
    await ref
        .read(outboxRepositoryProvider)
        .record(PlanItemStatusAction(itemId: item.id, status: wire));
    state = PlanState(
      overrides: {...state.overrides, item.id: status},
      rebalancing: state.rebalancing,
    );
    unawaited(_sync());
    return true;
  }

  Future<void> _sync() async {
    try {
      unawaited(ref.read(syncStatusProvider.notifier).refresh());
      await ref.read(studySyncNudgeProvider)();
    } on Object {
      // Stays queued; the sync triggers retry when the network returns (§39).
    }
  }

  /// Asks the server to rebalance the plan (needs a connection). Returns true on success.
  Future<bool> rebalance() async {
    if (state.rebalancing) return false;
    state = PlanState(overrides: state.overrides, rebalancing: true);
    final key = ref.read(idempotencyKeyFactoryProvider)();
    try {
      await ref.read(planRepositoryProvider).rebalance(idempotencyKey: key);
      state = const PlanState(message: PlanCopy.rebalanced);
      ref.invalidate(todayProvider);
      return true;
    } on Exception catch (e) {
      state = PlanState(overrides: state.overrides, message: messageOf(e));
      return false;
    }
  }

  void clearMessage() => state = PlanState(
    overrides: state.overrides,
    rebalancing: state.rebalancing,
  );
}

final planControllerProvider = NotifierProvider<PlanController, PlanState>(
  PlanController.new,
);

/// Today with this phone's queued status applied.
final todayViewProvider = Provider<AsyncValue<TodayView>>((ref) {
  final plan = ref.watch(planControllerProvider);
  return ref
      .watch(todayProvider)
      .whenData(
        (t) => TodayView(
          day: t.day,
          rank: t.rank,
          todayCard: plan.apply(t.todayCard),
          relightCount: t.relightCount,
          relightMinutes: t.relightMinutes,
          pocketSessions: t.pocketSessions,
          stretch: t.stretch,
          welcomeBack: t.welcomeBack,
          hasPlan: t.hasPlan,
        ),
      );
});

/// My Plan days with this phone's queued status applied.
final planDaysViewProvider = Provider<AsyncValue<List<PlanDayView>>>((ref) {
  final plan = ref.watch(planControllerProvider);
  return ref
      .watch(planDaysProvider)
      .whenData(
        (days) => [
          for (final d in days)
            PlanDayView(
              day: d.day,
              minutes: d.minutes,
              items: [for (final i in d.items) plan.apply(i)],
            ),
        ],
      );
});
