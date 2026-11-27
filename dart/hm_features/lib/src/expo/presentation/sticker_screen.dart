import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/lamp_art.dart';
import '../../common/ports.dart';
import '../application/expo_controller.dart';

/// "Collect your sticker" (CLAUDE.md §8): the one-time code staff check on Desk. [initialCode] comes
/// from the challenge result; without one the screen asks the server.
class StickerScreen extends ConsumerWidget {
  const StickerScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget body;
    if (initialCode != null) {
      body = _CodeView(code: initialCode!, redeemed: false);
    } else {
      body = switch (ref.watch(stickerCodeProvider)) {
        AsyncData(:final value) => value.code == null
            ? const _NoCodeView()
            : _CodeView(code: value.code!, redeemed: value.redeemed),
        AsyncError(:final error) => HmErrorView(
          message: messageOf(error),
          onRetry: () => ref.invalidate(stickerCodeProvider),
        ),
        _ => const HmLoadingView(label: 'Getting your code'),
      };
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Your sticker')),
      body: SafeArea(child: body),
    );
  }
}

class _CodeView extends StatelessWidget {
  const _CodeView({required this.code, required this.redeemed});

  final String code;
  final bool redeemed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(HmSpace.xl),
      children: [
        const Center(child: LampArt(glow: 1, size: 88)),
        const SizedBox(height: HmSpace.lg),
        Semantics(
          header: true,
          child: Text(
            'Collect your sticker',
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
        ),
        const SizedBox(height: HmSpace.lg),
        Semantics(
          label: 'Your code: ${code.split('').join(' ')}',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: HmSpace.xl,
                horizontal: HmSpace.md,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.onSurface, width: 3),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SelectableText(
                  code,
                  key: const Key('sticker-code'),
                  style: text.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: HmSpace.lg),
        Text(
          redeemed
              ? 'This code has been used. You already collected your sticker.'
              : 'Show this at the HeyMey stall.',
          key: const Key('sticker-hint'),
          textAlign: TextAlign.center,
          style: text.titleMedium,
        ),
        const SizedBox(height: HmSpace.sm),
        Text(
          'Staff check the code once, then it is used up.',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NoCodeView extends StatelessWidget {
  const _NoCodeView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(HmSpace.xl),
      children: [
        const Center(child: LampArt(glow: 0, size: 88)),
        const SizedBox(height: HmSpace.lg),
        Text(
          'No sticker code yet',
          key: const Key('sticker-none'),
          textAlign: TextAlign.center,
          style: text.headlineSmall,
        ),
        const SizedBox(height: HmSpace.sm),
        Text(
          'Light your first lamp or finish the Expo Challenge to get one.',
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
      ],
    );
  }
}
