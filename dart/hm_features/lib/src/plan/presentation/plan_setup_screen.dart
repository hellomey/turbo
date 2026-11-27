import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/plan_setup_controller.dart';
import '../domain/plan_setup_models.dart';

/// Plan setup (INT-002-S12, §17.1 step 9): study time on weekdays and weekends, pocket sessions, the balance
/// dial and the attempt cycle per exam when the server offers one. One action: "Create my plan".
class PlanSetupScreen extends ConsumerWidget {
  const PlanSetupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(planSetupControllerProvider);
    final c = ref.read(planSetupControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Build your plan')),
      body: setup.when(
        loading: () => const HmSkeletonList(label: 'Loading your exams'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(planSetupControllerProvider),
        ),
        data: (s) => PlanSetupBody(
          state: s,
          onEdit: c.edit,
          onSave: () async {
            if (await c.save()) onDone();
          },
        ),
      ),
    );
  }
}

/// Layout only, for tests and goldens. Warm light (BOLT-0117, design/ui/04): every question sits in
/// its own white card with amber pill choices, and "Your week" previews the minutes picked.
class PlanSetupBody extends StatelessWidget {
  const PlanSetupBody({
    super.key,
    required this.state,
    required this.onEdit,
    required this.onSave,
  });

  final PlanSetupState state;
  final void Function(PlanSetupDraft Function(PlanSetupDraft d)) onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final d = state.draft;
    final exams = state.options?.exams ?? const <ExamCycles>[];
    Widget header(String t) => Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.md),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
    Widget card(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.lg),
      child: HmCard(
        padding: const EdgeInsets.all(HmSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
    Widget chips<T>(
      String keyPrefix,
      List<T> values,
      T selected,
      String Function(T) label,
      String Function(T) spoken,
      void Function(T) pick,
    ) => Wrap(
      spacing: HmSpace.sm,
      runSpacing: HmSpace.sm,
      children: [
        for (final v in values)
          Semantics(
            key: Key('$keyPrefix-$v'),
            button: true,
            selected: v == selected,
            label: spoken(v),
            onTap: state.saving ? null : () => pick(v),
            child: ExcludeSemantics(
              child: InkWell(
                borderRadius: BorderRadius.circular(HmRadius.pill),
                onTap: state.saving ? null : () => pick(v),
                child: AnimatedContainer(
                  duration: HmMotion.fast,
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: HmSpace.lg),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v == selected ? p.primary : p.surface,
                    borderRadius: BorderRadius.circular(HmRadius.pill),
                    border: Border.all(
                      color: v == selected ? p.primary : p.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label(v),
                    style: text.titleMedium?.copyWith(
                      color: v == selected ? p.onPrimary : p.textMuted,
                      fontWeight: v == selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HmSpace.xl,
            HmSpace.md,
            HmSpace.xl,
            HmSpace.xxl,
          ),
          children: [
            Text(
              'Tell us how much time you have. You can change this later.',
              style: text.bodyLarge?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: HmSpace.lg),
            for (final e in exams)
              card([
                header('Which ${e.examName} attempt?'),
                chips<String>(
                  'setup-cycle-${e.examCode}',
                  [for (final c in e.cycles) c.id],
                  d.cycles[e.examCode] ?? '',
                  (id) => e.cycles.firstWhere((c) => c.id == id).name,
                  (id) =>
                      '${e.examName} attempt ${e.cycles.firstWhere((c) => c.id == id).name}',
                  (id) => onEdit(
                    (x) => x.copyWith(cycles: {...x.cycles, e.examCode: id}),
                  ),
                ),
              ]),
            card([
              header('How much time on weekdays?'),
              chips<int>(
                'setup-weekday',
                PlanSetupDraft.minutePresets,
                d.weekdayMinutes,
                PlanSetupCopy.minutes,
                (m) => '${PlanSetupCopy.minutes(m)} on weekdays',
                (m) => onEdit((x) => x.copyWith(weekdayMinutes: m)),
              ),
              const SizedBox(height: HmSpace.xl),
              header('And on weekends?'),
              chips<int>(
                'setup-weekend',
                PlanSetupDraft.minutePresets,
                d.weekendMinutes,
                PlanSetupCopy.minutes,
                (m) => '${PlanSetupCopy.minutes(m)} on weekends',
                (m) => onEdit((x) => x.copyWith(weekendMinutes: m)),
              ),
            ]),
            _WeekPreview(weekday: d.weekdayMinutes, weekend: d.weekendMinutes),
            const SizedBox(height: HmSpace.lg),
            card([
              header('Short sessions'),
              Text('For a quick study break.', style: text.bodyMedium),
              const SizedBox(height: HmSpace.md),
              chips<int>(
                'setup-pocket',
                PlanSetupDraft.pocketPresets,
                d.pocketMinutes,
                (m) => '$m min',
                (m) => '$m minute short sessions',
                (m) => onEdit((x) => x.copyWith(pocketMinutes: m)),
              ),
            ]),
            card([
              header('New topics or relighting?'),
              Text(
                PlanSetupCopy.balance(d.balance),
                key: const Key('setup-balance-label'),
                style: text.bodyLarge,
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: p.primary,
                  thumbColor: p.primary,
                  inactiveTrackColor: HmTint.amber,
                ),
                child: Slider(
                  key: const Key('setup-balance'),
                  min: PlanSetupDraft.minBalance.toDouble(),
                  max: PlanSetupDraft.maxBalance.toDouble(),
                  divisions:
                      PlanSetupDraft.maxBalance - PlanSetupDraft.minBalance,
                  value: d.balance.toDouble(),
                  semanticFormatterCallback: (v) =>
                      'Balance: ${PlanSetupCopy.balance(v.round())}',
                  onChanged: state.saving
                      ? null
                      : (v) => onEdit((x) => x.copyWith(balance: v.round())),
                ),
              ),
            ]),
            if (state.error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  '${state.error} (${state.errorCode})',
                  key: const Key('setup-error'),
                  style: text.bodyLarge?.copyWith(color: p.onErrorTint),
                ),
              ),
              const SizedBox(height: HmSpace.md),
            ],
            HmPrimaryButton(
              key: const Key('setup-save'),
              label: 'Make my plan',
              busy: state.saving,
              onPressed: state.saving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Your week": one bar per day sized by the minutes picked above, with Mey thinking it over. The
/// bars show only the user's own choices; nothing here is predicted.
class _WeekPreview extends StatelessWidget {
  const _WeekPreview({required this.weekday, required this.weekend});

  final int weekday;
  final int weekend;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final days = [for (var i = 0; i < 7; i++) i < 5 ? weekday : weekend];
    final most = days.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    final hours = (weekday * 5 + weekend * 2) / 60;
    final h = hours == hours.roundToDouble()
        ? hours.round().toString()
        : hours.toStringAsFixed(1);
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return HmCard(
      key: const Key('setup-week-preview'),
      padding: const EdgeInsets.all(HmSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Your week',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const HmMey(HmPic.meyThink, size: 84),
            ],
          ),
          const SizedBox(height: HmSpace.sm),
          ExcludeSemantics(
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (i, m) in days.indexed) ...[
                    if (i > 0) const SizedBox(width: HmSpace.sm),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: HmMotion.progress,
                            curve: HmMotion.spring,
                            height: 92 * m / most,
                            decoration: BoxDecoration(
                              color: i < 5 ? p.primary : p.success,
                              borderRadius: BorderRadius.circular(HmRadius.sm),
                            ),
                          ),
                          const SizedBox(height: HmSpace.xs),
                          Text(letters[i], style: text.labelLarge),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: HmSpace.md),
          Center(
            child: Text(
              'About $h hours of study a week',
              style: text.bodyLarge?.copyWith(color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
