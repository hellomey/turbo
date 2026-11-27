import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/lamp_art.dart';

/// The Today hero tile for the Expo Challenge (BOLT-0111): a bold block in the theme's primary colour
/// with a geometric lamp, so it reads as the one hero on the screen.
class ExpoHeroTile extends StatelessWidget {
  const ExpoHeroTile({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    // Bauhaus (BOLT-0110): the red hero block with an ink outline and hard shadow.
    final p = context.hm;
    final cs = (primary: p.primary, onPrimary: p.onPrimary);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Expo Challenge: 10 questions. Start the challenge',
      child: ExcludeSemantics(
        child: HmCard(
          key: const Key('today-expo-hero'),
          color: cs.primary,
          onTap: onOpen,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(HmSpace.xl),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expo Challenge: 10 questions',
                        style: text.titleLarge?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: HmSpace.xs),
                      Text(
                        'Answer each one before the bar runs out. Finish to get your sticker code.',
                        style: text.bodyLarge?.copyWith(color: cs.onPrimary),
                      ),
                      const SizedBox(height: HmSpace.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start the challenge',
                            style: text.labelLarge?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: HmSpace.xs),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: cs.onPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HmSpace.md),
                const LampArt(glow: 0, size: 72),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
