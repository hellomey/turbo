import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';

import '../domain/plan_setup_models.dart';
import 'plan_repository.dart' show parseApi;

/// Plan setup over `PUT /v1/me/plan` and, when cycles are chosen, `PUT /v1/me/exams` (R2).
abstract interface class PlanSetupRepository {
  Future<PlanSetupOptions> options();

  Future<void> saveCycles(PlanSetupOptions options, Map<String, String> cycles);

  Future<void> savePlan(PlanSetupDraft draft, {required String idempotencyKey});
}

class ApiPlanSetupRepository implements PlanSetupRepository {
  ApiPlanSetupRepository(this._api);

  final HmApi _api;

  @override
  Future<PlanSetupOptions> options() async {
    final mine = await _api.getMyExams();
    final codes = [?mine.mainCode, ...mine.otherCodes];
    final exams = <ExamCycles>[];
    for (final code in codes) {
      final json = await _api.getExamStructure(code);
      final s = parseApi(() => api.ExamStructure.fromJson(json));
      final open = [
        for (final c in s.attemptCycles)
          if (c.status != api.ExamAttemptCycleStatusEnum.closed)
            CycleOption(id: c.id, name: c.name),
      ];
      if (open.isNotEmpty) {
        exams.add(
          ExamCycles(
            examCode: code,
            examName: code == mine.mainCode ? (mine.mainName ?? code) : code,
            cycles: open,
          ),
        );
      }
    }
    return PlanSetupOptions(
      mainExamCode: mine.mainCode,
      otherExamCodes: mine.otherCodes,
      exams: exams,
    );
  }

  @override
  Future<void> saveCycles(
    PlanSetupOptions options,
    Map<String, String> cycles,
  ) async {
    final main = options.mainExamCode;
    if (main == null || cycles.isEmpty) return;
    await _api.putMyExamsWithCycles(main, options.otherExamCodes, cycles);
  }

  @override
  Future<void> savePlan(
    PlanSetupDraft draft, {
    required String idempotencyKey,
  }) async {
    await _api.putPlan(draft.toJson(), idempotencyKey: idempotencyKey);
  }
}
