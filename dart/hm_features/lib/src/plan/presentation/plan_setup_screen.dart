import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/plan_setup_controller.dart';
import '../domain/plan_setup_models.dart';

/// Plan setup (INT-002-S12, §17.1 step 9): study time on weekdays and weekends, pocket sessions, the balance
/// dial and the attempt cycle per exam when the server offers one. One action: "Make my plan".
class PlanSetupScreen extends ConsumerWidget {
  const PlanSetupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(planSetupControllerProvider);
    final c = ref.read(planSetupControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your plan')),
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

/// Layout only, for tests and goldens.
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
    final d = state.draft;
    final exams = state.options?.exams ?? const <ExamCycles>[];
    Widget header(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Semantics(header: true, child: Text(t, style: text.titleMedium)),
    );
    Widget chips<T>(
      String keyPrefix,
      List<T> values,
      T selected,
      String Function(T) label,
      String Function(T) spoken,
      void Function(T) pick,
    ) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          Semantics(
            key: Key('$keyPrefix-$v'),
            button: true,
            selected: v == selected,
            label: spoken(v),
            child: ExcludeSemantics(
              child: ChoiceChip(
                label: Text(label(v)),
                selected: v == selected,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: state.saving ? null : (_) => pick(v),
              ),
            ),
          ),
      ],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tell us how much time you have. You can change this later.',
          style: text.bodyLarge,
        ),
        header('Study time on weekdays'),
        chips<int>(
          'setup-weekday',
          PlanSetupDraft.minutePresets,
          d.weekdayMinutes,
          PlanSetupCopy.minutes,
          (m) => '${PlanSetupCopy.minutes(m)} on weekdays',
          (m) => onEdit((x) => x.copyWith(weekdayMinutes: m)),
        ),
        header('Study time on weekends'),
        chips<int>(
          'setup-weekend',
          PlanSetupDraft.minutePresets,
          d.weekendMinutes,
          PlanSetupCopy.minutes,
          (m) => '${PlanSetupCopy.minutes(m)} on weekends',
          (m) => onEdit((x) => x.copyWith(weekendMinutes: m)),
        ),
        header('Short sessions'),
        Text('For a quick study break.', style: text.bodyMedium),
        const SizedBox(height: 8),
        chips<int>(
          'setup-pocket',
          PlanSetupDraft.pocketPresets,
          d.pocketMinutes,
          (m) => '$m min',
          (m) => '$m minute short sessions',
          (m) => onEdit((x) => x.copyWith(pocketMinutes: m)),
        ),
        header('New topics or relighting'),
        Text(
          PlanSetupCopy.balance(d.balance),
          key: const Key('setup-balance-label'),
          style: text.bodyLarge,
        ),
        Slider(
          key: const Key('setup-balance'),
          min: PlanSetupDraft.minBalance.toDouble(),
          max: PlanSetupDraft.maxBalance.toDouble(),
          divisions: PlanSetupDraft.maxBalance - PlanSetupDraft.minBalance,
          value: d.balance.toDouble(),
          semanticFormatterCallback: (v) =>
              'Balance: ${PlanSetupCopy.balance(v.round())}',
          onChanged: state.saving
              ? null
              : (v) => onEdit((x) => x.copyWith(balance: v.round())),
        ),
        for (final e in exams) ...[
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
        ],
        const SizedBox(height: 24),
        if (state.error != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              '${state.error} (${state.errorCode})',
              key: const Key('setup-error'),
              style: text.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        HmPrimaryButton(
          key: const Key('setup-save'),
          label: 'Make my plan',
          busy: state.saving,
          onPressed: state.saving ? null : onSave,
        ),
      ],
    );
  }
}
