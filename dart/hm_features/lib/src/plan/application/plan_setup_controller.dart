import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../exam_hall/application/exam_hall_controller.dart'
    show idempotencyKeyFactoryProvider;
import '../data/plan_setup_repository.dart';
import '../domain/plan_setup_models.dart';
import 'plan_controller.dart';

final planSetupRepositoryProvider = Provider<PlanSetupRepository>(
  (ref) => ApiPlanSetupRepository(ref.watch(hmApiProvider)),
);

/// True right after onboarding finishes: the router opens plan setup once instead of Today (§17.1 step 9).
class PlanSetupPending extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final planSetupPendingProvider = NotifierProvider<PlanSetupPending, bool>(
  PlanSetupPending.new,
);

class PlanSetupState {
  const PlanSetupState({
    this.options,
    this.draft = const PlanSetupDraft(),
    this.saving = false,
    this.error,
    this.errorCode,
    this.done = false,
  });

  final PlanSetupOptions? options;
  final PlanSetupDraft draft;
  final bool saving;
  final String? error;

  /// The server error code, shown with the message so testers can report it.
  final String? errorCode;
  final bool done;

  PlanSetupState copyWith({
    PlanSetupOptions? options,
    PlanSetupDraft? draft,
    bool? saving,
    String? Function()? error,
    String? Function()? errorCode,
    bool? done,
  }) => PlanSetupState(
    options: options ?? this.options,
    draft: draft ?? this.draft,
    saving: saving ?? this.saving,
    error: error == null ? this.error : error(),
    errorCode: errorCode == null ? this.errorCode : errorCode(),
    done: done ?? this.done,
  );
}

/// Plan setup (INT-002-S12): load cycles, edit the draft, save cycles then `PUT /v1/me/plan`.
class PlanSetupController extends AsyncNotifier<PlanSetupState> {
  String? _key;

  @override
  Future<PlanSetupState> build() async {
    final options = await ref.read(planSetupRepositoryProvider).options();
    // Preselect the first open cycle per exam (the server lists the nearest first).
    return PlanSetupState(
      options: options,
      draft: PlanSetupDraft(
        cycles: {for (final e in options.exams) e.examCode: e.cycles.first.id},
      ),
    );
  }

  void edit(PlanSetupDraft Function(PlanSetupDraft d) change) {
    final s = state.value;
    if (s == null || s.saving) return;
    _key = null; // A changed body is a new write.
    state = AsyncData(s.copyWith(draft: change(s.draft)));
  }

  Future<bool> save() async {
    final s = state.value;
    if (s == null || s.saving) return false;
    // The same key is reused while retrying the same body (§34.3).
    final key = _key ??= ref.read(idempotencyKeyFactoryProvider)();
    state = AsyncData(
      s.copyWith(saving: true, error: () => null, errorCode: () => null),
    );
    final repo = ref.read(planSetupRepositoryProvider);
    try {
      if (s.options != null) await repo.saveCycles(s.options!, s.draft.cycles);
      await repo.savePlan(s.draft, idempotencyKey: key);
      ref.read(planSetupPendingProvider.notifier).set(false);
      ref.invalidate(todayProvider);
      state = AsyncData(s.copyWith(saving: false, done: true));
      return true;
    } on HmApiException catch (e) {
      state = AsyncData(
        s.copyWith(
          saving: false,
          error: () => e.message,
          errorCode: () => e.code,
        ),
      );
      return false;
    } on Exception {
      state = AsyncData(
        s.copyWith(
          saving: false,
          error: () => HmApiException.unknownMessage,
          errorCode: () => HmApiException.unknownError,
        ),
      );
      return false;
    }
  }
}

final planSetupControllerProvider =
    AsyncNotifierProvider.autoDispose<PlanSetupController, PlanSetupState>(
      PlanSetupController.new,
    );
