import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../exam_hall/domain/exam_hall_models.dart' show formatIst;
import '../application/readiness_providers.dart';
import '../domain/readiness_models.dart';

/// Readiness Meter (INT-002-S14, §19.5 Q46): a plain label and four evidence bars. Free users see Coverage and
/// Memory; Exam performance and Speed show as locked Pro bars (Free/Pro shown before tap, §19.9 Q82). No
/// overall percentage.
class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({super.key, this.onOpenReports});

  final VoidCallback? onOpenReports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(readinessProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness')),
      body: meter.when(
        loading: () => const HmSkeletonList(label: 'Loading your readiness'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(readinessProvider),
        ),
        data: (view) => view == null
            ? const HmErrorView(message: 'Choose your main exam first.')
            : ReadinessBody(view: view, onOpenReports: onOpenReports),
      ),
    );
  }
}

/// Layout only, for tests and goldens.
class ReadinessBody extends StatelessWidget {
  const ReadinessBody({super.key, required this.view, this.onOpenReports});

  final ReadinessView view;
  final VoidCallback? onOpenReports;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Readiness: ${ReadinessCopy.label(view.label)}',
                  key: const Key('readiness-label'),
                  style: text.headlineSmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: HmSpace.xs),
        Text(
          'Updated ${formatIst(view.computedAt)}',
          style: text.bodySmall?.copyWith(color: context.hm.textMuted),
        ),
        if (view.noEvidence) ...[
          const SizedBox(height: 8),
          Text(ReadinessCopy.noEvidence, style: text.bodyLarge),
        ],
        if (view.readyForFullMocks) ...[
          const SizedBox(height: 8),
          Semantics(
            label: 'Badge: Ready for full mocks',
            child: const ExcludeSemantics(
              child: Chip(
                avatar: Icon(Icons.verified_outlined),
                label: Text('Ready for full mocks'),
              ),
            ),
          ),
        ],
        const SizedBox(height: HmSpace.lg),
        for (final bar in view.bars) ...[
          HmCard(
            child: _Bar(bar: bar, view: view),
          ),
          const SizedBox(height: HmSpace.md),
        ],
        if (view.suggestion != null) ...[
          HmCard(child: Text(view.suggestion!, style: text.bodyLarge)),
          const SizedBox(height: 12),
        ],
        if (onOpenReports != null)
          HmSecondaryButton(
            key: const Key('readiness-open-reports'),
            label: 'See Sunday Reports',
            onPressed: onOpenReports,
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar, required this.view});

  final ReadinessBarView bar;
  final ReadinessView view;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = ReadinessCopy.bar(bar.key);
    if (bar.locked) {
      return HmCard(
        key: Key('readiness-bar-${bar.key.name}'),
        semanticLabel: '$name: locked. ${ReadinessCopy.proBarHint}',
        child: ExcludeSemantics(
          child: Row(
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: text.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: HmColors.brassGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ReadinessCopy.proBar,
                  style: text.labelLarge?.copyWith(color: context.hm.onGold),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final value = bar.value;
    final shown = value == null ? 'no data yet' : '$value%';
    final coverageDetail = bar.key == ReadinessBarKey.coverage
        ? 'Lit ${view.litPct}% · Steady ${view.steadyPct}% · Gold ${view.goldPct}%'
        : null;
    return HmCard(
      key: Key('readiness-bar-${bar.key.name}'),
      semanticLabel:
          '$name: $shown. ${bar.evidence}${coverageDetail == null ? '' : '. $coverageDetail'}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: text.titleMedium)),
                Text(
                  value == null ? '–' : '$value%',
                  style: text.titleMedium?.copyWith(
                    fontFamily: HmFonts.numbers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            HmProgressBar(
              value: (value ?? 0) / 100,
              height: 12,
              color: context.hm.steady,
              semanticLabel: name,
            ),
            const SizedBox(height: 6),
            Text(bar.evidence, style: text.bodyMedium),
            if (coverageDetail != null)
              Text(coverageDetail, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
