import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/lamp_art.dart';

/// "The Lamplighter" (BOLT-0111): five short story scenes woven into onboarding. Each scene sits at the
/// top of an existing step and changes nothing about the step itself.
enum StoryScene {
  darkHall(
    'The dark hall',
    "Tamil Nadu's study halls have gone dark. You are the new Lamplighter.",
  ),
  chooseExam(
    'Choose your exam',
    'Each exam has its own hall. Pick the one you are aiming for.',
  ),
  yourPlan(
    'Your plan',
    'Every topic is a lamp. Your plan tells you which lamp to light next.',
  ),
  firstLesson(
    'Your first lesson',
    'A lesson is how you light a lamp. Read it, then answer a short check.',
  ),
  firstLamp(
    'Your first lamp',
    'Light one lamp and the hall starts to glow. Lamps dim as you forget, and relighting them helps you remember.',
  );

  const StoryScene(this.title, this.line);

  final String title;
  final String line;

  /// The lamp warms a little with each scene: dark in the first, lit in the last.
  double get glow => index / (StoryScene.values.length - 1);
}

/// Shown on the welcome scene while HeyMey is in testing.
const storyBetaLine = 'Beta: HeyMey is still being built.';

/// True while story scenes show in onboarding. "Skip story" turns it off.
class StoryToggle extends Notifier<bool> {
  @override
  bool build() => true;

  void skip() => state = false;

  void show() => state = true;
}

final storyOnProvider = NotifierProvider<StoryToggle, bool>(StoryToggle.new);

/// One scene as a compact dark panel above an onboarding step, with "Skip story". Fades in over
/// 300 ms; still under reduce motion, Calm Mode and Lite Mode.
class StorySceneCard extends ConsumerWidget {
  const StorySceneCard({super.key, required this.scene});

  final StoryScene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(storyOnProvider)) return const SizedBox.shrink();
    final panel = _ScenePanel(
      scene: scene,
      onSkip: () => ref.read(storyOnProvider.notifier).skip(),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.lg),
      child: StoryEntrance(key: ValueKey(scene), child: panel),
    );
  }
}

/// Fades and lifts [child] in once (300 ms). No motion under reduce motion, Calm Mode or Lite Mode.
class StoryEntrance extends StatelessWidget {
  const StoryEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (HmModes.reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: c),
      ),
    );
  }
}

class _ScenePanel extends StatelessWidget {
  const _ScenePanel({
    super.key,
    required this.scene,
    this.onSkip,
    this.large = false,
  });

  final StoryScene scene;
  final VoidCallback? onSkip;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // The hall is drawn dark in both themes: inverse surface with its own text colour.
    final ink = cs.onInverseSurface;
    return Semantics(
      container: true,
      label: 'Story, ${scene.title}',
      child: Container(
        key: Key('story-${scene.name}'),
        color: cs.inverseSurface,
        padding: EdgeInsets.all(large ? HmSpace.xl : HmSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LampArt(glow: scene.glow, size: large ? 120 : 64),
                const SizedBox(width: HmSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Lamplighter · ${scene.index + 1} of ${StoryScene.values.length}',
                        style: text.labelMedium?.copyWith(color: ink),
                      ),
                      const SizedBox(height: HmSpace.xs),
                      Text(
                        scene.title,
                        style: (large ? text.headlineSmall : text.titleMedium)
                            ?.copyWith(color: ink, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: HmSpace.md),
            Text(
              scene.line,
              style: (large ? text.titleLarge : text.bodyLarge)?.copyWith(
                color: ink,
              ),
            ),
            if (scene == StoryScene.darkHall) ...[
              const SizedBox(height: HmSpace.md),
              Container(
                key: const Key('story-beta'),
                padding: const EdgeInsets.symmetric(
                  horizontal: HmSpace.sm,
                  vertical: HmSpace.xs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: ink, width: 1.5),
                ),
                child: Text(
                  storyBetaLine,
                  style: text.labelLarge?.copyWith(color: ink),
                ),
              ),
            ],
            if (onSkip != null) ...[
              const SizedBox(height: HmSpace.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('story-skip'),
                  style: TextButton.styleFrom(
                    foregroundColor: ink,
                    minimumSize: const Size(
                      HmSizes.minTapTarget,
                      HmSizes.minTapTarget,
                    ),
                  ),
                  onPressed: onSkip,
                  child: const Text('Skip story'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Replays all five scenes from Profile. "Skip story" or the last "Done" closes it.
class StoryReplayScreen extends StatefulWidget {
  const StoryReplayScreen({super.key});

  @override
  State<StoryReplayScreen> createState() => _StoryReplayScreenState();
}

class _StoryReplayScreenState extends State<StoryReplayScreen> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final scene = StoryScene.values[_i];
    final last = _i == StoryScene.values.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Lamplighter'),
        actions: [
          TextButton(
            key: const Key('story-replay-skip'),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Skip story'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HmSpace.lg),
          children: [
            AnimatedSwitcher(
              duration: HmModes.reduceMotion(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              child: _ScenePanel(
                key: ValueKey(scene),
                scene: scene,
                large: true,
              ),
            ),
            const SizedBox(height: HmSpace.xl),
            HmPrimaryButton(
              key: const Key('story-replay-next'),
              label: last ? 'Done' : 'Next scene',
              onPressed: last
                  ? () => Navigator.of(context).maybePop()
                  : () => setState(() => _i++),
            ),
          ],
        ),
      ),
    );
  }
}
