import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/ports.dart';
import '../application/progress_controller.dart';

/// Weekly XP leaderboard (BOLT-0113). Off by default; only people who chose to join appear, by nickname.
/// No made-up rows: an empty week shows an empty board.
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
      appBar: AppBar(title: const Text('Weekly leaderboard')),
      body: board.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(weeklyLeaderboardProvider),
            child: Text('${messageOf(e)} Try again'),
          ),
        ),
        data: (b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              key: const Key('leaderboard-opt-in'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Show me on the leaderboard'),
              subtitle: const Text(
                "Off by default. Only your nickname and this week's XP are shown.",
              ),
              value: b.optedIn,
              onChanged: (v) => _toggle(context, ref, v),
            ),
            const Divider(),
            if (b.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "No one has joined this week's board yet.",
                  style: text.bodyLarge,
                ),
              )
            else
              for (final e in b.entries)
                ListTile(
                  key: Key('leaderboard-row-${e.rank}-${e.displayName}'),
                  leading: Text('${e.rank}', style: text.titleMedium),
                  title: Text(
                    e.isMe ? '${e.displayName} (you)' : e.displayName,
                  ),
                  trailing: Text('${e.xp} XP'),
                  selected: e.isMe,
                ),
          ],
        ),
      ),
    );
  }
}
