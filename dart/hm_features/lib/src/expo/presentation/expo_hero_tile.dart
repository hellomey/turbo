import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

/// The Today tile for the Expo Challenge (BOLT-0111, design/ui/22): the stall picture, the title and a Start pill.
class ExpoHeroTile extends StatelessWidget {
  const ExpoHeroTile({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Expo Challenge: 10 questions. Start the challenge',
      child: ExcludeSemantics(
        child: HmCard(
          key: const Key('today-expo-hero'),
          color: HmTint.mint,
          onTap: onOpen,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(HmRadius.md),
                child: const HmPicture(
                  HmPic.expoStall,
                  width: 104,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: HmSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expo Challenge: 10 questions',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: HmSpace.xs),
                    Text(
                      'Finish to get your sticker code.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: HmSpace.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start the challenge',
                          style: text.labelLarge?.copyWith(
                            color: context.hm.primaryText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: HmSpace.xs),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: context.hm.primaryText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
