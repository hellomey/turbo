import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/progress_controller.dart';

/// Profile: earned trophies (BOLT-0113). Badges only: they carry nothing worth money.
class TrophiesSection extends ConsumerWidget {
  const TrophiesSection({super.key, this.onOpenLeaderboard});

  final VoidCallback? onOpenLeaderboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final p = ref.watch(myProgressProvider).value;
    if (p == null) return const SizedBox.shrink();
    return Column(
      key: const Key('profile-trophies'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text('Trophies', style: text.titleMedium),
        ),
        const SizedBox(height: 8),
        if (p.trophies.isEmpty)
          Text(
            'Light your first lamp to earn your first trophy.',
            style: text.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in p.trophies)
                Chip(
                  avatar: const Icon(Icons.emoji_events_outlined),
                  label: Text(t.title),
                ),
            ],
          ),
        if (onOpenLeaderboard != null)
          ListTile(
            key: const Key('profile-open-leaderboard'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.leaderboard_outlined),
            title: const Text('Weekly leaderboard'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenLeaderboard,
          ),
      ],
    );
  }
}
