import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../application/play_controller.dart';
import 'confidence_duel_screen.dart';
import 'daily_spin_screen.dart';

/// Play hub (§10.5, BOLT-0115): a bento grid with Daily Spin as the hero tile, Confidence Duel beside it and
/// Rules & odds always one tap away. Games are free; prizes are Points only.
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  void _open(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spin = _PlayTile(
      key: const Key('play-spin'),
      icon: Icons.incomplete_circle,
      title: 'Daily Spin',
      body: 'One free spin a day. See the exact odds before you spin.',
      color: scheme.primaryContainer,
      onColor: scheme.onPrimaryContainer,
      hero: true,
      onTap: () => _open(context, const DailySpinScreen()),
    );
    final duel = _PlayTile(
      key: const Key('play-duel'),
      icon: Icons.bolt_outlined,
      title: 'Confidence Duel',
      body: 'Five questions against the clock. Be sure and be right.',
      color: scheme.secondaryContainer,
      onColor: scheme.onSecondaryContainer,
      onTap: () => _open(context, const ConfidenceDuelScreen()),
    );
    final rules = _PlayTile(
      key: const Key('play-rules'),
      icon: Icons.rule_outlined,
      title: 'Rules & odds',
      body: 'Every prize, chance and limit.',
      color: scheme.surfaceContainerHighest,
      onColor: scheme.onSurface,
      onTap: () => _open(context, const GameRulesScreen()),
    );
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 600;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Play', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Free to play. Prizes are Points only, never money. '
                'Games sleep from 12 AM to 5 AM.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (wide)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: spin),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: duel),
                            const SizedBox(height: 12),
                            Expanded(child: rules),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                spin,
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: duel),
                      const SizedBox(width: 12),
                      Expanded(child: rules),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PlayTile extends StatelessWidget {
  const _PlayTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onColor,
    required this.onTap,
    this.hero = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(hero ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: hero ? 40 : 28, color: onColor),
              SizedBox(height: hero ? 16 : 10),
              Text(
                title,
                style: (hero ? text.headlineSmall : text.titleMedium)?.copyWith(
                  color: onColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: text.bodyMedium?.copyWith(color: onColor)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Game Rules & Odds (`GET /v1/games/rules`): the same tables the server draws and scores with.
class GameRulesScreen extends ConsumerWidget {
  const GameRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rules = ref.watch(gameRulesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rules & odds')),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(gameRulesProvider),
            child: Text('${messageOf(e)} Try again'),
          ),
        ),
        data: (g) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Games are free. You never pay or stake anything, and nothing '
              'can be cashed out. Prizes are Points only. Points cannot be '
              'bought and never turn into Sparks or money.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Daily Spin', style: text.titleMedium),
            Text(
              '${g.spinsPerDay} free spin a day. Exact chances (odds table '
              'version ${g.oddsVersion}):',
              style: text.bodySmall,
            ),
            for (final p in g.spinPrizes)
              ListTile(
                key: Key('rules-odds-${p.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(p.label),
                trailing: Text(p.percentText, style: text.titleSmall),
              ),
            const SizedBox(height: 16),
            Text('Confidence Duel', style: text.titleMedium),
            const SizedBox(height: 8),
            DuelRulesCard(rules: g.duel),
            const SizedBox(height: 16),
            Text(
              'Games sleep from ${g.sleepFrom} to ${g.sleepTo} India time. '
              'Study stays open.',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
