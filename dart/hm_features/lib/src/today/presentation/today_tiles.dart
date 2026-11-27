import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../alerts/application/alerts_controller.dart';
import '../../common/ports.dart';
import '../../profile/application/profile_controller.dart';
import '../../progress/application/progress_controller.dart';
import '../../readiness/application/readiness_providers.dart';
import '../../readiness/domain/readiness_models.dart';

/// Today's live tiles in the warm light design (design/ui/05, BOLT-0117). Each reads its own
/// provider and hides itself quietly when its data is missing, so one slow call never blanks Today.

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];
const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday', //
];

/// Greeting, date, avatar and the "Lv 3 • 240 XP" pill.
class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key, this.onOpenProfile, this.now});

  final VoidCallback? onOpenProfile;

  /// Fixed time for tests; defaults to the device clock in IST.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final me = ref.watch(meProvider).value;
    final progress = ref.watch(myProgressProvider).value;
    final ist =
        now ??
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final greeting = ist.hour < 12
        ? 'Good morning'
        : ist.hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final name = (me?.nickname?.trim().isNotEmpty ?? false)
        ? me!.nickname!.trim()
        : null;
    final date =
        '${_days[ist.weekday - 1]}, ${_months[ist.month - 1]} ${ist.day}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HmBetaChip(),
            const SizedBox(width: HmSpace.xs),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  name == null ? '$greeting!' : '$greeting, $name',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: HmSpace.sm),
            _Avatar(
              initial: name?.characters.first.toUpperCase(),
              onTap: onOpenProfile,
            ),
          ],
        ),
        const SizedBox(height: HmSpace.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                date,
                style: text.titleMedium?.copyWith(
                  color: p.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (progress != null)
              Semantics(
                label: 'Level ${progress.level}, ${progress.xp} XP',
                excludeSemantics: true,
                child: Container(
                  key: const Key('today-xp-pill'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: HmSpace.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: HmTint.amber,
                    borderRadius: BorderRadius.circular(HmRadius.pill),
                  ),
                  child: Text(
                    'Lv ${progress.level} • ${progress.xp} XP',
                    style: text.labelLarge?.copyWith(
                      color: p.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.initial, this.onTap});

  final String? initial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final circle = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HmTint.amber,
        border: Border.all(color: p.primary, width: 2),
      ),
      child: initial == null
          ? Icon(Icons.person_rounded, color: p.primaryText)
          : Text(
              initial!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: p.primaryText),
            ),
    );
    return Semantics(
      button: onTap != null,
      label: 'Open your profile',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: circle),
    );
  }
}

/// A tinted tile with rounded corners (the small bento tiles in the mock-ups).
class TintTile extends StatelessWidget {
  const TintTile({
    super.key,
    required this.color,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minHeight = 0,
  });

  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minHeight;

  @override
  Widget build(BuildContext context) => HmCard(
    color: color,
    onTap: onTap,
    semanticLabel: semanticLabel,
    padding: const EdgeInsets.all(HmSpace.lg + 4),
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}

/// Mint "Day check-in" tile. Missing a day changes nothing, so there is no streak wording.
class CheckInTile extends ConsumerStatefulWidget {
  const CheckInTile({super.key});

  @override
  ConsumerState<CheckInTile> createState() => _CheckInTileState();
}

class _CheckInTileState extends ConsumerState<CheckInTile> {
  bool _busy = false;
  String? _note;

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    try {
      final a = await checkInToday(ref);
      _note = a.xp == 0
          ? 'Already checked in today.'
          : '+${a.xp} XP, +${a.points} Points';
    } on Object catch (e) {
      _note = messageOf(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final progress = ref.watch(myProgressProvider).value;
    final done = progress?.checkedInToday ?? false;
    return TintTile(
      key: const Key('today-check-in-tile'),
      color: HmTint.mint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_month_rounded, size: 36, color: p.onSuccessTint),
          const SizedBox(height: HmSpace.md),
          Text('Day check-in', style: text.titleMedium),
          const SizedBox(height: HmSpace.sm),
          Semantics(
            button: true,
            enabled: !done && !_busy,
            label: done ? 'Checked in today' : 'Check in for today',
            excludeSemantics: true,
            child: InkWell(
              key: const Key('today-check-in'),
              borderRadius: BorderRadius.circular(HmRadius.pill),
              onTap: done || _busy || progress == null ? null : _checkIn,
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: HmSpace.md,
                  vertical: HmSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(HmRadius.pill),
                ),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        done ? 'Checked in ✓' : 'Check in',
                        style: text.labelLarge?.copyWith(
                          color: done ? p.onSuccessTint : p.text,
                        ),
                      ),
              ),
            ),
          ),
          if (_note != null) ...[
            const SizedBox(height: HmSpace.sm),
            Semantics(
              liveRegion: true,
              child: Text(
                _note!,
                style: text.bodySmall?.copyWith(color: p.onSuccessTint),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Coral "Recall" tile: how many lamps are dimming, with a Relight link.
class RecallTile extends StatelessWidget {
  const RecallTile({super.key, required this.count, this.minutes, this.onOpen});

  final int count;

  /// About how long relighting takes, when known.
  final int? minutes;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    return TintTile(
      key: const Key('today-relight'),
      color: HmTint.coral,
      onTap: onOpen,
      semanticLabel: count == 0
          ? 'Recall. No lamps dimming'
          : 'Relight $count dimming lamps',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recall',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: HmSpace.xs),
            Text(
              count == 0
                  ? 'No lamps dimming'
                  : '$count ${count == 1 ? 'lamp' : 'lamps'} dimming'
                        '${minutes == null ? '' : ' · $minutes min'}',
              style: text.bodyLarge,
            ),
            if (count > 0) ...[
              const SizedBox(height: HmSpace.sm),
              Text(
                'Relight now',
                style: text.titleMedium?.copyWith(
                  color: p.onErrorTint,
                  decoration: TextDecoration.underline,
                  decorationColor: p.onErrorTint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String readinessLabel(ReadinessLabelView l) => switch (l) {
  ReadinessLabelView.notYet => 'Not yet',
  ReadinessLabelView.building => 'Building',
  ReadinessLabelView.close => 'Close',
  ReadinessLabelView.mockReady => 'Mock ready',
};

/// White readiness tile. The ring shows the share of lamps lit, a real number; there is no overall
/// readiness percentage anywhere (U-readiness invariant 4). The word under it is the meter's label.
class ReadinessTile extends ConsumerWidget {
  const ReadinessTile({super.key, this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final r = ref.watch(readinessProvider).value;
    final lit = r?.litPct ?? 0;
    return HmCard(
      key: const Key('today-readiness'),
      onTap: onOpen,
      semanticLabel: r == null
          ? 'Readiness'
          : 'Readiness: ${readinessLabel(r.label)}. $lit percent of lamps lit',
      padding: const EdgeInsets.all(HmSpace.lg),
      child: ExcludeSemantics(
        child: Column(
          children: [
            const SizedBox(height: HmSpace.sm),
            HmRing(
              value: lit / 100,
              size: 118,
              semanticLabel: 'Lamps lit',
              center: Text(
                '$lit%',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: HmSpace.md),
            Text('Lamps lit', style: text.titleMedium),
            Text(
              r == null ? 'Readiness' : 'Readiness: ${readinessLabel(r.label)}',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sky-blue "Exam alert" tile with the newest official alert.
class AlertTile extends ConsumerWidget {
  const AlertTile({super.key, this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final items = ref.watch(examAlertsProvider).value?.items ?? const [];
    final latest = items.isEmpty ? null : items.first;
    return TintTile(
      key: const Key('today-alert'),
      color: HmTint.sky,
      onTap: onOpen,
      semanticLabel: latest == null
          ? 'Exam alerts. No new alerts'
          : 'Exam alert: ${latest.title}',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFCFE2F8),
                borderRadius: BorderRadius.circular(HmRadius.md),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: p.info,
                size: 30,
              ),
            ),
            const SizedBox(width: HmSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exam alert',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: HmSpace.xxs),
                  Text(
                    latest?.title ??
                        'No new alerts. We watch the official TNPSC pages for you.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: HmSpace.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HmSpace.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(HmRadius.pill),
                    ),
                    child: Text('Official source', style: text.labelMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
