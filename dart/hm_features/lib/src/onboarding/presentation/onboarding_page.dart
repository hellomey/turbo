import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

/// Layout shared by onboarding steps: a scrollable column (200% text never overflows) with a
/// readable maximum width.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.illustration,
  });

  final String title;
  final String? subtitle;

  /// A friendly drawn picture above the title (BOLT-0022).
  final HmIllustrationKind? illustration;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              HmSpace.xl,
              HmSpace.sm,
              HmSpace.xl,
              HmSpace.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (illustration != null) ...[
                  Center(child: HmIllustration(kind: illustration!, size: 104)),
                  const SizedBox(height: HmSpace.lg),
                ],
                Semantics(
                  header: true,
                  child: Text(title, style: text.headlineSmall),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: HmSpace.sm),
                  Text(
                    subtitle!,
                    style: text.bodyLarge?.copyWith(
                      color: context.hm.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: HmSpace.xl),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A red message under a form, read out by screen readers.
class StepError extends StatelessWidget {
  const StepError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: HmSpace.md),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(HmSpace.md),
          decoration: BoxDecoration(
            color: context.hm.errorTint,
            borderRadius: BorderRadius.circular(HmRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: context.hm.onErrorTint,
              ),
              const SizedBox(width: HmSpace.sm),
              Expanded(
                child: Text(
                  message!,
                  style: TextStyle(color: context.hm.onErrorTint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded, outlined box around one list choice (exam, consent item). The border turns
/// primary when [selected], so the choice reads by colour and by its tick/radio icon (§10.9).
class ChoiceBox extends StatelessWidget {
  const ChoiceBox({super.key, required this.child, this.selected = false});

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.sm),
      child: AnimatedContainer(
        duration: HmMotion.fast,
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(p.primary.withValues(alpha: 0.10), p.surface)
              : p.surface,
          borderRadius: BorderRadius.circular(HmRadius.lg),
          border: Border.all(
            color: selected ? p.primary : p.outline,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HmRadius.lg),
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }
}
