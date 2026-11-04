import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';

import '../../plan/data/plan_repository.dart' show parseApi;
import '../../plan/domain/plan_models.dart' show dateOnly;
import '../domain/readiness_models.dart';

/// Readiness Meter + Sunday Reports (INT-002-S14/S15) over the readiness routes.
abstract interface class ReadinessRepository {
  Future<ReadinessView> meter(String examCode);

  Future<SundayReportPageView> reports({String? cursor});

  Future<SundayReportView> report(String id);
}

class ApiReadinessRepository implements ReadinessRepository {
  ApiReadinessRepository(this._api);

  final HmApi _api;

  @override
  Future<ReadinessView> meter(String examCode) async {
    final json = await _api.getReadiness(examCode);
    return readinessFromApi(parseApi(() => api.ReadinessMeter.fromJson(json)));
  }

  @override
  Future<SundayReportPageView> reports({String? cursor}) async {
    final json = await _api.listSundayReports(cursor: cursor);
    final page = parseApi(() => api.SundayReportPage.fromJson(json));
    return SundayReportPageView(
      items: [
        for (final s in page.items)
          SundayReportSummaryView(
            id: s.id,
            weekStart: dateOnly(s.weekStart),
            tier: s.tier.value == 'full' ? ReportTier.full : ReportTier.short,
          ),
      ],
      nextCursor: page.nextCursor,
    );
  }

  @override
  Future<SundayReportView> report(String id) async {
    final json = await _api.getSundayReport(id);
    return sundayReportFromApi(parseApi(() => api.SundayReport.fromJson(json)));
  }
}

ReadinessLabelView _label(String v) => switch (v) {
  'building' => ReadinessLabelView.building,
  'close' => ReadinessLabelView.close,
  'mock_ready' => ReadinessLabelView.mockReady,
  _ => ReadinessLabelView.notYet,
};

ReadinessBarKey? _barKey(String v) => switch (v) {
  'coverage' => ReadinessBarKey.coverage,
  'memory' => ReadinessBarKey.memory,
  'exam_performance' => ReadinessBarKey.examPerformance,
  'speed' => ReadinessBarKey.speed,
  _ => null,
};

ReadinessView readinessFromApi(api.ReadinessMeter m) => ReadinessView(
  examCode: m.examCode,
  label: _label(m.label.value),
  bars: [
    for (final b in m.bars)
      if (_barKey(b.key.value) case final key?)
        ReadinessBarView(
          key: key,
          value: b.locked ? null : b.value,
          locked: b.locked,
          evidence: b.evidence,
        ),
  ],
  litPct: m.coverage.litPct,
  steadyPct: m.coverage.steadyPct,
  goldPct: m.coverage.goldPct,
  readyForFullMocks: m.readyForFullMocks,
  suggestion: m.suggestion,
  computedAt: m.computedAt,
);

SundayReportView sundayReportFromApi(api.SundayReport r) => SundayReportView(
  id: r.id,
  weekStart: dateOnly(r.weekStart),
  tier: r.tier.value == 'full' ? ReportTier.full : ReportTier.short,
  lampsLit: r.lampsLit,
  steadyEarned: r.steadyEarned,
  goldEarned: r.goldEarned,
  relit: r.relit,
  dimmedNow: r.dimmedNow,
  questionsAnswered: r.questionsAnswered,
  accuracyPct: r.accuracyPct,
  mocksTaken: r.mocksTaken,
  studyMinutes: r.studyMinutes,
  lines: r.lines,
  nextWeek: r.nextWeek,
);
