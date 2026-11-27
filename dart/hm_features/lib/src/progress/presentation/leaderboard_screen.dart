import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/progress_controller.dart';

/// Weekly XP leaderboard (BOLT-0113). Off by default; only people who chose to join appear, by nickname.
/// No made-up rows: an empty week shows an empty board. Warm light (BOLT-0117, design/ui/18): a podium
/// for the top three, cards for the rest and the user's own row pinned in amber. Avatars are
/// initials only; no photos.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final listed = await setLeaderboardOptIn(ref, on);
      if (on && !listed) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Set a nickname in your profile so the board can show you.',
            ),
          ),
        );
      }
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(messageOf(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final board = ref.watch(weeklyLeaderboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),
      body: board.when(
        loading: () => const HmSkeletonList(label: 'Loading the leaderboard'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(weeklyLeaderboardProvider),
        ),
        data: (b) {
          final top = b.entries.take(3).toList();
          final rest = b.entries.skip(3).toList();
          final me = b.entries.where((e) => e.isMe).firstOrNull;
          final meInTop = me != null && top.contains(me);
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  HmSpace.xl,
                  HmSpace.sm,
                  HmSpace.xl,
                  HmSpace.xxl,
                ),
                children: [
                  Text(
                    'Opt-in players only. XP comes from learning.',
                    textAlign: TextAlign.center,
                    style: text.bodyLarge?.copyWith(
                      color: context.hm.textMuted,
                    ),
                  ),
                  const SizedBox(height: HmSpace.md),
                  HmCard(
                    padding: const EdgeInsets.symmetric(horizontal: HmSpace.md),
                    child: SwitchListTile(
                      key: const Key('leaderboard-opt-in'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show me on the leaderboard'),
                      subtitle: const Text(
                        "Off by default. Only your nickname and this week's XP are shown.",
                      ),
                      value: b.optedIn,
                      onChanged: (v) => _toggle(context, ref, v),
                    ),
                  ),
                  const SizedBox(height: HmSpace.xl),
                  if (b.entries.isEmpty)
                    HmEmptyView(
                      art: HmArtName.mascotSleep,
                      title: "No one has joined this week's board yet.",
                      message: b.optedIn
                          ? 'Learn something today to get on the board.'
                          : null,
                    )
                  else ...[
                    _Podium(top: top),
                    const SizedBox(height: HmSpace.lg),
                    for (final e in rest)
                      if (!e.isMe) _Row(entry: e),
                    if (me != null && !meInTop) ...[
                      const SizedBox(height: HmSpace.sm),
                      _Row(entry: me, pinned: true),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A round avatar with the person's initial. Real photos are never shown; nicknames only.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.ring, this.size = 56});

  final String name;
  final Color ring;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: HmTint.amber,
      border: Border.all(color: ring, width: 3),
    ),
    child: Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: context.hm.primaryText,
        fontSize: size * 0.4,
      ),
    ),
  );
}

/// The top three on blocks: 2nd left, 1st in the middle (tallest, crowned), 3rd right.
class _Podium extends StatelessWidget {
  const _Podium({required this.top});

  final List<LeaderboardEntryView> top;

  static const _gold = Color(0xFFE5A823);
  static const _silver = Color(0xFFB4B8BF);
  static const _bronze = Color(0xFFC9825A);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final still = HmModes.reduceMotion(context);
    Widget column(int place) {
      if (place > top.length) return const Expanded(child: SizedBox());
      final e = top[place - 1];
      final (colour, height) = switch (place) {
        1 => (_gold, 120.0),
        2 => (_silver, 88.0),
        _ => (_bronze, 64.0),
      };
      return Expanded(
        child: Semantics(
          key: Key('leaderboard-row-${e.rank}-${e.displayName}'),
          label:
              'Rank ${e.rank}, ${e.displayName}${e.isMe ? ', you' : ''}, ${e.xp} XP',
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (place == 1)
                Icon(Icons.workspace_premium_rounded, color: colour, size: 34),
              _Avatar(
                name: e.displayName,
                ring: colour,
                size: place == 1 ? 68 : 56,
              ),
              const SizedBox(height: HmSpace.xs),
              Text(
                e.isMe ? '${e.displayName} (you)' : e.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              Text('${e.xp} XP', style: text.bodyMedium),
              const SizedBox(height: HmSpace.xs),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: still ? 1 : 0, end: 1),
                duration: HmMotion.progress,
                curve: HmMotion.spring,
                builder: (context, t, child) => Container(
                  height: height * t,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colour,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(HmRadius.md),
                    ),
                  ),
                  child: child,
                ),
                child: FittedBox(
                  child: Text(
                    '$place',
                    style: text.displaySmall?.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [column(2), column(1), column(3)],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, this.pinned = false});

  final LeaderboardEntryView entry;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final e = entry;
    return Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.sm),
      child: HmCard(
        key: pinned
            ? const Key('leaderboard-me')
            : Key('leaderboard-row-${e.rank}-${e.displayName}'),
        color: pinned ? HmTint.amber : null,
        highlighted: pinned,
        padding: const EdgeInsets.symmetric(
          horizontal: HmSpace.lg,
          vertical: HmSpace.md,
        ),
        child: MergeSemantics(
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  pinned ? '#${e.rank}' : '${e.rank}',
                  style: text.titleLarge,
                ),
              ),
              _Avatar(
                name: e.displayName,
                ring: pinned ? p.primary : p.outline,
                size: 44,
              ),
              const SizedBox(width: HmSpace.md),
              Expanded(
                child: Text(
                  e.isMe ? '${e.displayName} (you)' : e.displayName,
                  style: text.titleMedium,
                ),
              ),
              Text(
                '${e.xp} XP',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
