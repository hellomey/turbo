import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// Every hm_design component on one screen, for the gallery goldens (BOLT-0021).
class HmGallery extends StatelessWidget {
  const HmGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget h(String s) => Padding(
      padding: const EdgeInsets.only(top: HmSpace.xl, bottom: HmSpace.sm),
      child: Text(s, style: text.titleMedium),
    );
    return Scaffold(
      bottomNavigationBar: HmBottomNav(
        currentIndex: 0,
        onSelect: (_) {},
        items: const [
          HmNavItem(
            label: 'Today',
            icon: Icons.wb_sunny_outlined,
            selectedIcon: Icons.wb_sunny_rounded,
          ),
          HmNavItem(label: 'Study Map', icon: Icons.map_outlined),
          HmNavItem(label: 'Play', icon: Icons.sports_esports_outlined),
          HmNavItem(label: 'Squad', icon: Icons.groups_outlined),
          HmNavItem(label: 'Profile', icon: Icons.person_outline),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(HmSpace.lg),
        children: [
          Text('Good morning', style: text.headlineMedium),
          const SizedBox(height: HmSpace.sm),
          const Wrap(
            spacing: HmSpace.sm,
            runSpacing: HmSpace.sm,
            children: [
              HmRankChip(level: 3, title: 'Junior Assistant'),
              HmXpChip(xp: 1240),
            ],
          ),
          const SizedBox(height: HmSpace.md),
          const HmProgressBar(value: 0.62, semanticLabel: 'XP to next rank'),
          h('Buttons'),
          HmPrimaryButton(label: 'Start', onPressed: () {}),
          const SizedBox(height: HmSpace.sm),
          HmPrimaryButton(
            label: 'Claim reward',
            tone: HmButtonTone.gold,
            icon: Icons.bolt_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: HmSpace.sm),
          HmSecondaryButton(label: 'Not now', onPressed: () {}),
          const SizedBox(height: HmSpace.sm),
          const HmPrimaryButton(label: 'Continue', onPressed: null),
          HmGhostButton(label: 'Skip', onPressed: () {}),
          h('Card'),
          HmCard(
            highlighted: true,
            onTap: () {},
            child: Text(
              'Today Card: Relight 4 lamps · 8 min',
              style: text.bodyLarge,
            ),
          ),
          h('Lamps'),
          Wrap(
            spacing: HmSpace.xs,
            runSpacing: HmSpace.sm,
            children: [
              for (final s in HmLampStatus.values)
                HmLampBadge(topic: s.label, state: s.state, size: 44),
            ],
          ),
          h('Answers'),
          HmAnswerTile(label: 'A', text: 'Article 14', onTap: () {}),
          const SizedBox(height: HmSpace.sm),
          const HmAnswerTile(
            label: 'B',
            text: 'Article 21',
            state: HmAnswerState.correct,
          ),
          const SizedBox(height: HmSpace.sm),
          const HmAnswerTile(
            label: 'C',
            text: 'Article 32',
            state: HmAnswerState.wrong,
          ),
          h('Celebration'),
          const SizedBox(
            height: 300,
            child: HmCelebrationView(
              kind: HmCelebrationKind.rankUp,
              title: 'You are now a Typist',
              subtitle: 'Game title. Not an official designation.',
              progress: 0.6,
            ),
          ),
          h('States'),
          const SizedBox(
            height: 260,
            child: HmEmptyView(
              title: 'No mistakes yet',
              message: 'Questions you get wrong will show here.',
            ),
          ),
          SizedBox(
            height: 300,
            child: HmErrorView(
              message: 'No internet connection. Please check and try again.',
              onRetry: () {},
            ),
          ),
          HmSkeleton.card(),
        ],
      ),
    );
  }
}
