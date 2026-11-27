import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// One card of the first-run story (design/ui/02, BOLT-0117).
class StoryIntroCard {
  const StoryIntroCard(this.pic, this.title, this.line);

  final HmPic pic;
  final String title;
  final String line;
}

/// The four first-run cards. The readiness card describes a meter with visible parts, never a single
/// percentage (U-readiness invariant 4).
const storyIntroCards = [
  StoryIntroCard(
    HmPic.story1,
    'Every topic is a lamp',
    'Learn a topic and its lamp lights up.',
  ),
  StoryIntroCard(
    HmPic.meySleepy,
    'Lamps dim when you forget',
    'A quick recall check brings the light back.',
  ),
  StoryIntroCard(
    HmPic.meyProud,
    'See how ready you are',
    'A simple meter, and we show you how it works.',
  ),
  StoryIntroCard(
    HmPic.logo,
    "Let's light your first lamp",
    'Answer a few questions and we will set you up.',
  ),
];

/// Swipeable story cards with "Skip", page dots and Next/Start. Calls [onDone] at the end or on Skip.
class StoryIntro extends StatefulWidget {
  const StoryIntro({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<StoryIntro> createState() => _StoryIntroState();
}

class _StoryIntroState extends State<StoryIntro> {
  final _pages = PageController();
  int _i = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_i == storyIntroCards.length - 1) {
      widget.onDone();
      return;
    }
    final still = HmModes.reduceMotion(context);
    if (still) {
      _pages.jumpToPage(_i + 1);
    } else {
      _pages.nextPage(
        duration: HmMotion.screenTransition,
        curve: HmMotion.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final last = _i == storyIntroCards.length - 1;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              HmSpace.xl,
              HmSpace.sm,
              HmSpace.xl,
              HmSpace.xl,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('story-intro-skip'),
                    onPressed: widget.onDone,
                    style: TextButton.styleFrom(foregroundColor: p.textMuted),
                    child: Text(
                      'Skip',
                      style: text.titleMedium?.copyWith(color: p.textMuted),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: storyIntroCards.length,
                    onPageChanged: (i) => setState(() => _i = i),
                    itemBuilder: (context, i) {
                      final c = storyIntroCards[i];
                      return Semantics(
                        container: true,
                        label: 'Story ${i + 1} of ${storyIntroCards.length}',
                        child: LayoutBuilder(
                          builder: (context, box) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: box.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 0.95,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        HmRadius.xl,
                                      ),
                                      child: ColoredBox(
                                        color: HmTint.amber,
                                        child: c.pic == HmPic.story1
                                            ? HmPicture(
                                                c.pic,
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: HmMey(
                                                  c.pic,
                                                  size: box.maxWidth * 0.55,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: HmSpace.xl),
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      c.title,
                                      textAlign: TextAlign.center,
                                      style: text.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: HmSpace.sm),
                                  Text(
                                    c.line,
                                    textAlign: TextAlign.center,
                                    style: text.titleMedium?.copyWith(
                                      color: p.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: HmSpace.lg),
                ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var d = 0; d < storyIntroCards.length; d++)
                        AnimatedContainer(
                          duration: HmMotion.fast,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: d == _i ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: d == _i
                                ? p.primary
                                : const Color(0xFFEBDDCB),
                            borderRadius: BorderRadius.circular(HmRadius.pill),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: HmSpace.xl),
                HmPrimaryButton(
                  key: const Key('story-intro-next'),
                  label: last ? 'Start' : 'Next',
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
