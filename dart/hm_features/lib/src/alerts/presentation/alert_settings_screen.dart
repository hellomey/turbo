import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/alerts_controller.dart';
import '../domain/alert_models.dart';

/// Alert settings (INT-002-S16, §19.8 Q78): at most 3 alerts a day, Exam Alerts separate, offers opt-in only,
/// quiet hours. Changes need a connection.
class AlertSettingsScreen extends ConsumerWidget {
  const AlertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(alertSettingsProvider);
    final controller = ref.read(alertSettingsProvider.notifier);
    ref.listen(alertSettingsProvider.select((s) => s.value?.message), (_, msg) {
      if (msg == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
      controller.clearMessage();
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Alert settings')),
      body: settings.when(
        loading: () => const HmSkeletonList(label: 'Loading alert settings'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(alertSettingsProvider),
        ),
        data: (s) => AlertSettingsBody(
          settings: s.settings,
          saving: s.saving,
          onChanged: controller.save,
        ),
      ),
    );
  }
}

/// Layout only, for tests and goldens.
class AlertSettingsBody extends StatelessWidget {
  const AlertSettingsBody({
    super.key,
    required this.settings,
    required this.onChanged,
    this.saving = false,
  });

  final AlertSettingsView settings;
  final void Function(AlertSettingsView next) onChanged;
  final bool saving;

  Future<void> _pickTime(
    BuildContext context,
    int current,
    AlertSettingsView Function(int minute) apply,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) onChanged(apply(picked.hour * 60 + picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = settings;
    final enabled = !saving;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchListTile(
          key: const Key('alerts-exam'),
          title: const Text('Exam Alerts'),
          subtitle: const Text(
            'Official news about your exams. These never count toward your daily limit.',
          ),
          value: s.examAlerts,
          onChanged: enabled
              ? (v) => onChanged(s.copyWith(examAlerts: v))
              : null,
        ),
        SwitchListTile(
          key: const Key('alerts-study'),
          title: const Text('Study reminders'),
          subtitle: const Text(
            'A nudge when lamps are dimming or your plan is waiting.',
          ),
          value: s.studyReminders,
          onChanged: enabled
              ? (v) => onChanged(s.copyWith(studyReminders: v))
              : null,
        ),
        SwitchListTile(
          key: const Key('alerts-offers'),
          title: const Text('Offers'),
          subtitle: const Text(
            'Off unless you turn it on. Needs your consent for offers in Privacy.',
          ),
          value: s.offers,
          onChanged: enabled ? (v) => onChanged(s.copyWith(offers: v)) : null,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Semantics(
            header: true,
            child: Text('Alerts per day', style: text.titleMedium),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            'Study reminders and offers together. Never more than 3.',
            style: text.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var n = 0; n <= AlertSettingsView.maxDailyLimit; n++)
                Semantics(
                  key: Key('alerts-limit-$n'),
                  button: true,
                  selected: s.dailyLimit == n,
                  label: '$n alerts a day',
                  child: ExcludeSemantics(
                    child: ChoiceChip(
                      label: Text('$n'),
                      selected: s.dailyLimit == n,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onSelected: enabled
                          ? (_) => onChanged(s.copyWith(dailyLimit: n))
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
        SwitchListTile(
          key: const Key('alerts-quiet'),
          title: const Text('Quiet hours'),
          subtitle: const Text(
            'No study reminders or offers in this time. Exam Alerts wait until it ends.',
          ),
          value: s.quietEnabled,
          onChanged: enabled
              ? (v) => onChanged(s.copyWith(quietEnabled: v))
              : null,
        ),
        if (s.quietEnabled) ...[
          ListTile(
            key: const Key('alerts-quiet-start'),
            enabled: enabled,
            title: const Text('Quiet from'),
            trailing: Text(formatMinuteOfDay(s.quietStartMinute)),
            onTap: () => _pickTime(
              context,
              s.quietStartMinute,
              (m) => s.copyWith(quietStartMinute: m),
            ),
          ),
          ListTile(
            key: const Key('alerts-quiet-end'),
            enabled: enabled,
            title: const Text('Quiet until'),
            trailing: Text(formatMinuteOfDay(s.quietEndMinute)),
            onTap: () => _pickTime(
              context,
              s.quietEndMinute,
              (m) => s.copyWith(quietEndMinute: m),
            ),
          ),
        ],
        ListTile(
          key: const Key('alerts-morning'),
          enabled: enabled,
          title: const Text('Morning reminder time'),
          trailing: Text(formatMinuteOfDay(s.morningAlertMinute)),
          onTap: () => _pickTime(
            context,
            s.morningAlertMinute,
            (m) => s.copyWith(morningAlertMinute: m),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Times are India time. Changes need a connection.',
            style: text.bodySmall,
          ),
        ),
      ],
    );
  }
}
