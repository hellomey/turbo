import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'mey.dart';

/// The opening screen (design/ui/01, BOLT-0118): Beta chip, the round HeyMey logo (it carries the wordmark), the
/// tagline and a looping amber loading bar. Screen readers hear "Opening HeyMey".
class HmSplash extends StatefulWidget {
  const HmSplash({super.key});

  @override
  State<HmSplash> createState() => _HmSplashState();
}

class _HmSplashState extends State<HmSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (HmModes.reduceMotion(context)) {
      _bar.value = 0.4;
    } else if (!_bar.isAnimating) {
      _bar.repeat();
    }
  }

  @override
  void dispose() {
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Semantics(
          label: 'Opening HeyMey',
          liveRegion: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(HmSpace.xl),
                child: Column(
                  children: [
                    const Spacer(),
                    const HmMey(HmPic.logo, size: 260),
                    const SizedBox(height: HmSpace.lg),
                    Text(
                      'Light up your TNPSC prep',
                      style: text.titleMedium?.copyWith(
                        color: p.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(flex: 2),
                    ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(HmRadius.pill),
                        child: SizedBox(
                          height: 8,
                          child: LayoutBuilder(
                            builder: (context, box) => AnimatedBuilder(
                              animation: _bar,
                              builder: (context, _) => Stack(
                                children: [
                                  const Positioned.fill(
                                    child: ColoredBox(color: Color(0xFFF6E8D2)),
                                  ),
                                  Positioned(
                                    left:
                                        (box.maxWidth * 1.4) * _bar.value -
                                        box.maxWidth * 0.4,
                                    top: 0,
                                    bottom: 0,
                                    width: box.maxWidth * 0.4,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: p.primary,
                                        borderRadius: BorderRadius.circular(
                                          HmRadius.pill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: HmSpace.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
