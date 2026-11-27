import 'package:material_ui/material_ui.dart';
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
    // Warm light (BOLT-0117, design/ui/16): the newest report is the amber hero with the envelope.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.xl,
        HmSpace.md,
        HmSpace.xl,
        HmSpace.xxl,
      ),
      children: [
        for (final (i, r) in page.items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: HmSpace.lg),
            child: HmCard(
              key: Key('report-${r.id}'),
              color: i == 0 ? HmTint.amber : null,
              padding: const EdgeInsets.all(HmSpace.xl),
              semanticLabel:
                  'Open report for the week of ${formatDay(r.weekStart)}, ${ReadinessCopy.tier(r.tier)}',
              onTap: () => onOpenReport(r.id),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week of ${formatDay(r.weekStart)}',
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (i == 0) ...[
                            const SizedBox(height: HmSpace.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: HmSpace.md,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.hm.primaryShade,
                                borderRadius: BorderRadius.circular(
                                  HmRadius.pill,
                                ),
                              ),
                              child: Text(
                                'New',
                                style: text.labelLarge?.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            const SizedBox(height: HmSpace.sm),
                          ],
                          Text(
                            ReadinessCopy.tier(r.tier),
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (i == 0) const HmMey(HmPic.envelope, size: 92),
                    const Icon(Icons.chevron_right_rounded, size: 30),
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
    final p = context.hm;
    Widget big(String value, String label, {HmPic? pic}) => Expanded(
      child: MergeSemantics(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pic != null) HmPicture(pic, height: 40),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      value,
                      style: text.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
    // Warm light (BOLT-0117, design/ui/17).
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.xl,
        HmSpace.md,
        HmSpace.xl,
        HmSpace.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Week of ${formatDay(r.weekStart)}',
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    ReadinessCopy.tier(r.tier),
                    style: text.bodyMedium?.copyWith(color: p.textMuted),
                  ),
                ],
              ),
            ),
            const HmMey(HmPic.meyCelebrate, size: 96),
          ],
        ),
        const SizedBox(height: HmSpace.lg),
        HmEnter(
          child: HmCard(
            key: const Key('report-summary'),
            color: HmTint.amber,
            padding: const EdgeInsets.all(HmSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly summary',
                  style: text.titleLarge?.copyWith(color: p.goldText),
                ),
                const SizedBox(height: HmSpace.md),
                Row(
                  children: [
                    big('${r.lampsLit}', 'lit', pic: HmPic.lampLit),
                    big('${r.relit}', 'relit'),
                    if (r.accuracyPct != null)
                      big('${r.accuracyPct}%', 'accuracy'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: HmSpace.lg),
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
