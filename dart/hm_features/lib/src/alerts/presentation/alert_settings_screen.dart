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
      backgroundColor: context.hm.background,
      appBar: AppBar(
        backgroundColor: context.hm.background,
        title: const Text(
          'Alert settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
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

/// Layout only, for tests and goldens. Grouped white cards (design/ui/25): Exam alerts, Daily reminders,
/// Sleep & quiet hours with a sleepy Mey, and Offers. The footer says where alerts come from.
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
    final p = context.hm;
    final s = settings;
    final enabled = !saving;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.sm,
        HmSpace.lg,
        HmSpace.xl,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Group(
                  title: 'Exam alerts',
                  children: [
                    _Toggle(
                      tileKey: const Key('alerts-exam'),
                      icon: Icons.notifications_none_rounded,
                      title: 'Exam Alerts',
                      subtitle:
                          'Official news about your exams. These never count toward your daily limit.',
                      value: s.examAlerts,
                      onChanged: enabled
                          ? (v) => onChanged(s.copyWith(examAlerts: v))
                          : null,
                    ),
                  ],
                ),
                _Group(
                  title: 'Daily reminders',
                  children: [
                    _Toggle(
                      tileKey: const Key('alerts-study'),
                      icon: Icons.menu_book_outlined,
                      title: 'Study reminders',
                      subtitle:
                          'A nudge when lamps are dimming or your plan is waiting.',
                      value: s.studyReminders,
                      onChanged: enabled
                          ? (v) => onChanged(s.copyWith(studyReminders: v))
                          : null,
                    ),
                    _TimeRow(
                      key: const Key('alerts-morning'),
                      title: 'Reminder time',
                      value: formatMinuteOfDay(s.morningAlertMinute),
                      enabled: enabled,
                      onTap: () => _pickTime(
                        context,
                        s.morningAlertMinute,
                        (m) => s.copyWith(morningAlertMinute: m),
                      ),
                    ),
                    const SizedBox(height: HmSpace.sm),
                    Semantics(
                      header: true,
                      child: Text(
                        'Alerts per day',
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'Study reminders and offers together. Never more than 3.',
                      style: text.bodySmall?.copyWith(color: p.textMuted),
                    ),
                    const SizedBox(height: HmSpace.sm),
                    Wrap(
                      spacing: HmSpace.sm,
                      runSpacing: HmSpace.sm,
                      children: [
                        for (
                          var n = 0;
                          n <= AlertSettingsView.maxDailyLimit;
                          n++
                        )
                          Semantics(
                            key: Key('alerts-limit-$n'),
                            button: true,
                            selected: s.dailyLimit == n,
                            label: '$n alerts a day',
                            child: ExcludeSemantics(
                              child: ChoiceChip(
                                label: Text('$n'),
                                selected: s.dailyLimit == n,
                                showCheckmark: false,
                                shape: const StadiumBorder(),
                                selectedColor: HmTint.amber,
                                side: BorderSide(
                                  color: s.dailyLimit == n
                                      ? p.primary
                                      : p.outline,
                                  width: 1.5,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                onSelected: enabled
                                    ? (_) =>
                                          onChanged(s.copyWith(dailyLimit: n))
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                _Group(
                  title: 'Sleep & quiet hours',
                  children: [
                    _Toggle(
                      tileKey: const Key('alerts-quiet'),
                      icon: Icons.bedtime_outlined,
                      title:
                          'Quiet hours (${formatMinuteOfDay(s.quietStartMinute)} to ${formatMinuteOfDay(s.quietEndMinute)})',
                      subtitle:
                          'No study reminders or offers in this time. Exam Alerts wait until it ends.',
                      value: s.quietEnabled,
                      onChanged: enabled
                          ? (v) => onChanged(s.copyWith(quietEnabled: v))
                          : null,
                    ),
                    if (s.quietEnabled) ...[
                      _TimeRow(
                        key: const Key('alerts-quiet-start'),
                        title: 'Quiet from',
                        value: formatMinuteOfDay(s.quietStartMinute),
                        enabled: enabled,
                        onTap: () => _pickTime(
                          context,
                          s.quietStartMinute,
                          (m) => s.copyWith(quietStartMinute: m),
                        ),
                      ),
                      _TimeRow(
                        key: const Key('alerts-quiet-end'),
                        title: 'Quiet until',
                        value: formatMinuteOfDay(s.quietEndMinute),
                        enabled: enabled,
                        onTap: () => _pickTime(
                          context,
                          s.quietEndMinute,
                          (m) => s.copyWith(quietEndMinute: m),
                        ),
                      ),
                    ],
                    const Center(
                      child: HmMey(HmPic.meySleep, size: 130, float: false),
                    ),
                  ],
                ),
                _Group(
                  title: 'Offers',
                  children: [
                    _Toggle(
                      tileKey: const Key('alerts-offers'),
                      icon: Icons.local_offer_outlined,
                      title: 'Offers',
                      subtitle:
                          'Off unless you turn it on. Needs your consent for offers in Privacy.',
                      value: s.offers,
                      onChanged: enabled
                          ? (v) => onChanged(s.copyWith(offers: v))
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: HmSpace.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 16,
                      color: p.textMuted,
                    ),
                    const SizedBox(width: HmSpace.xs),
                    Flexible(
                      child: Text(
                        'Exam Alerts use official TNPSC sources only. Times are India time.',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: p.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.md),
      child: HmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: HmSpace.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.tileKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Key tileKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return SwitchListTile(
      key: tileKey,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: p.textMuted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: p.primary,
      onChanged: onChanged,
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    super.key,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      title: Text(title),
      onTap: onTap,
      trailing: HmTag(label: value, textColor: p.primaryText),
    );
  }
}
