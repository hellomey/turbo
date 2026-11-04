import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../plan/domain/plan_models.dart' show formatDay;
import '../application/readiness_providers.dart';
import '../domain/readiness_models.dart';

/// Sunday Report list (INT-002-S15).
class SundayReportListScreen extends ConsumerWidget {
  const SundayReportListScreen({super.key, required this.onOpenReport});

  final void Function(String id) onOpenReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(sundayReportsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sunday Reports')),
      body: page.when(
        loading: () => const HmSkeletonList(label: 'Loading your reports'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(sundayReportsProvider),
        ),
        data: (p) => SundayReportListBody(page: p, onOpenReport: onOpenReport),
      ),
    );
  }
}

class SundayReportListBody extends StatelessWidget {
  const SundayReportListBody({
    super.key,
    required this.page,
    required this.onOpenReport,
  });

  final SundayReportPageView page;
  final void Function(String id) onOpenReport;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (page.items.isEmpty) {
      return const HmEmptyView(
        kind: HmIllustrationKind.chart,
        title: 'No reports yet',
        message: 'Your first report comes on Sunday morning.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final r in page.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HmCard(
              key: Key('report-${r.id}'),
              semanticLabel:
                  'Open report for the week of ${formatDay(r.weekStart)}, ${ReadinessCopy.tier(r.tier)}',
              onTap: () => onOpenReport(r.id),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    const Icon(Icons.event_note_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week of ${formatDay(r.weekStart)}',
                            style: text.titleMedium,
                          ),
                          Text(
                            ReadinessCopy.tier(r.tier),
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One Sunday Report (INT-002-S15). Text comes from the server only; it never promises selection.
class SundayReportScreen extends ConsumerWidget {
  const SundayReportScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(sundayReportProvider(reportId));
    return Scaffold(
      appBar: AppBar(title: const Text('Sunday Report')),
      body: report.when(
        loading: () => const HmSkeletonList(label: 'Loading the report'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(sundayReportProvider(reportId)),
        ),
        data: (r) => SundayReportBody(report: r),
      ),
    );
  }
}

class SundayReportBody extends StatelessWidget {
  const SundayReportBody({super.key, required this.report});

  final SundayReportView report;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final r = report;
    final stats = <(String, String)>[
      ('Lamps lit', '${r.lampsLit}'),
      ('Steady earned', '${r.steadyEarned}'),
      ('Gold earned', '${r.goldEarned}'),
      ('Lamps relit', '${r.relit}'),
      ('Dimming now', '${r.dimmedNow}'),
      ('Questions answered', '${r.questionsAnswered}'),
      if (r.accuracyPct != null) ('Accuracy', '${r.accuracyPct}%'),
      ('Mocks taken', '${r.mocksTaken}'),
      ('Study time', '${r.studyMinutes} min'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Week of ${formatDay(r.weekStart)}',
            style: text.headlineSmall,
          ),
        ),
        Text(ReadinessCopy.tier(r.tier), style: text.bodyMedium),
        const SizedBox(height: 16),
        HmCard(
          child: Column(
            children: [
              for (final (label, value) in stats)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(label, style: text.bodyLarge)),
                        Text(
                          value,
                          style: text.titleMedium?.copyWith(
                            fontFamily: HmFonts.numbers,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final line in r.lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line, style: text.bodyLarge),
          ),
        if (r.nextWeek case final next? when next.isNotEmpty) ...[
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text('Next week', style: text.titleMedium),
          ),
          const SizedBox(height: 4),
          for (final line in next)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $line', style: text.bodyLarge),
            ),
        ],
      ],
    );
  }
}
