import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/progress_controller.dart';

/// Today: level, XP bar and the daily check-in button (BOLT-0113). Uses theme colours only.
/// Missing a day changes nothing, so there is no streak wording here.
class ProgressCard extends ConsumerStatefulWidget {
  const ProgressCard({super.key, this.onOpenLeaderboard});

  final VoidCallback? onOpenLeaderboard;

  @override
  ConsumerState<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends ConsumerState<ProgressCard> {
  bool _busy = false;
  String? _note;

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    try {
      final a = await checkInToday(ref);
      _note = a.xp == 0
          ? 'You have already checked in today.'
          : 'Checked in: +${a.xp} XP, +${a.points} Points.';
    } on Object catch (e) {
      _note = messageOf(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = ref.watch(myProgressProvider).value;
    if (p == null) return const SizedBox.shrink();
    // Drawn inside a Today bento tile (BOLT-0110), so no card of its own.
    return KeyedSubtree(
      key: const Key('today-progress'),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Level ${p.level}', style: text.titleMedium),
                ),
                Text('${p.points} Points', style: text.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '${p.xp} XP. Level ${p.level + 1} at ${p.nextLevelXp} XP',
              child: ExcludeSemantics(
                child: HmProgressBar(
                  value: p.levelFraction,
                  height: 12,
                  color: context.hm.gold,
                  semanticLabel: 'XP',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('${p.xp} / ${p.nextLevelXp} XP', style: text.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: HmPrimaryButton(
                    key: const Key('today-check-in'),
                    expand: false,
                    tone: HmButtonTone.gold,
                    label: p.checkedInToday ? 'Checked in today' : 'Check in',
                    onPressed: p.checkedInToday || _busy ? null : _checkIn,
                  ),
                ),
                const SizedBox(width: HmSpace.sm),
                if (widget.onOpenLeaderboard != null)
                  TextButton(
                    key: const Key('today-open-leaderboard'),
                    onPressed: widget.onOpenLeaderboard,
                    child: const Text('Leaderboard'),
                  ),
              ],
            ),
            if (_note != null) ...[
              const SizedBox(height: 8),
              Semantics(liveRegion: true, child: Text(_note!)),
            ],
          ],
        ),
      ),
    );
  }
}
