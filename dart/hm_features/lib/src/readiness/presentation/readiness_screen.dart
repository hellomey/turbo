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
    final p = context.hm;
    // Bento (BOLT-0110): the label is the hero; each evidence bar is a tile. Locked Pro bars are
    // small tiles side by side.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
      children: [
        HmBentoGrid(
          children: [
            HmBentoTile(
              span: 2,
              padding: const EdgeInsets.all(HmSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warm light (BOLT-0117, design/ui/15): the ring is the share of lamps lit, a
                  // real number; there is no overall readiness percentage (invariant 4).
                  Row(
                    children: [
                      HmRing(
                        value: view.litPct / 100,
                        size: 132,
                        semanticLabel: 'Lamps lit',
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${view.litPct}%',
                              style: text.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text('lamps lit', style: text.labelMedium),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const HmMey(HmPic.meyProud, size: 130),
                    ],
                  ),
                  const SizedBox(height: HmSpace.lg),
                  Semantics(
                    header: true,
                    child: Text(
                      'Readiness: ${ReadinessCopy.label(view.label)}',
                      key: const Key('readiness-label'),
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: HmSpace.xs),
                  Text(
                    'Updated ${formatIst(view.computedAt)}',
                    style: text.bodyMedium?.copyWith(color: p.textMuted),
                  ),
                  if (view.noEvidence) ...[
                    const SizedBox(height: HmSpace.sm),
                    Text(ReadinessCopy.noEvidence, style: text.bodyLarge),
                  ],
                  if (view.readyForFullMocks) ...[
                    const SizedBox(height: HmSpace.sm),
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
                ],
              ),
            ),
            HmBentoTile(
              span: 2,
              color: HmTint.cream,
              child: Text(
                'How we calculate this: each bar below is one part of the meter, with the evidence under it. No hidden factors.',
                style: text.bodyLarge,
              ),
            ),
            for (final bar in view.bars)
              HmBentoTile(
                span: bar.locked ? 1 : 2,
                padding: EdgeInsets.zero,
                child: _Bar(bar: bar, view: view),
              ),
            if (view.suggestion != null)
              HmBentoTile(
                span: 2,
                eyebrow: 'Next step',
                color: HmTint.mint,
                child: Text(view.suggestion!, style: text.bodyLarge),
              ),
          ],
        ),
        if (onOpenReports != null) ...[
          const SizedBox(height: HmSpace.lg),
          HmSecondaryButton(
            key: const Key('readiness-open-reports'),
            label: 'See Sunday Reports',
            onPressed: onOpenReports,
          ),
        ],
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
      return _BarBox(
        key: Key('readiness-bar-${bar.key.name}'),
        semanticLabel: '$name: locked. ${ReadinessCopy.proBarHint}',
        child: ExcludeSemantics(
          child: Row(
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: HmSpace.sm),
              Expanded(child: Text(name, style: text.titleSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.hm.gold,
                  border: Border.all(
                    color: context.hm.outline,
                    width: HmBauhaus.strokeSmall,
                  ),
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
              color: context.hm.blue,
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

/// The inside of a bar tile: padding plus semantics (the tile itself is the outlined box).
class _BarBox extends StatelessWidget {
  const _BarBox({super.key, required this.semanticLabel, required this.child});

  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: Padding(padding: const EdgeInsets.all(HmSpace.lg), child: child),
  );
}
