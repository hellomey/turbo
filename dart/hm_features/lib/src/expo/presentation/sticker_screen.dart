import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../application/expo_controller.dart';

/// "You won a sticker!" (CLAUDE.md §8, design/ui/23): the one-time code staff check on Desk, on a ticket.
/// [initialCode] comes from the challenge result; without one the screen asks the server.
class StickerScreen extends ConsumerWidget {
  const StickerScreen({super.key, this.initialCode, this.onBackToToday});

  final String? initialCode;

  /// Leaves for Today. When null the screen pops back to the first route.
  final VoidCallback? onBackToToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.hm;
    final Widget body;
    var celebrate = false;
    if (initialCode != null) {
      celebrate = true;
      body = _CodeView(code: initialCode!, redeemed: false);
    } else {
      body = switch (ref.watch(stickerCodeProvider)) {
        AsyncData(:final value) =>
          value.code == null
              ? const _NoCodeView()
              : _CodeView(code: value.code!, redeemed: value.redeemed),
        AsyncError(:final error) => HmErrorView(
          message: messageOf(error),
          onRetry: () => ref.invalidate(stickerCodeProvider),
        ),
        _ => const HmLoadingView(label: 'Getting your code'),
      };
    }
    void back() {
      if (onBackToToday != null) {
        onBackToToday!();
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Your sticker',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Expanded(child: body),
                    Padding(
                      padding: const EdgeInsets.all(HmSpace.lg),
                      child: HmSecondaryButton(
                        key: const Key('sticker-back-today'),
                        label: 'Back to Today',
                        expand: true,
                        onPressed: back,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (celebrate) const Positioned.fill(child: HmConfetti(seed: 23)),
          ],
        ),
      ),
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
    final p = context.hm;
    return ListView(
      padding: const EdgeInsets.all(HmSpace.lg),
      children: [
        HmMey(redeemed ? HmPic.meyCheer : HmPic.meySticker, size: 190),
        const SizedBox(height: HmSpace.sm),
        Semantics(
          header: true,
          child: Text(
            redeemed ? 'Sticker collected' : 'You won a sticker!',
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: HmSpace.lg),
        _Ticket(
          top: Column(
            children: [
              Text(
                'YOUR STICKER CODE',
                style: text.labelLarge?.copyWith(
                  color: p.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: HmSpace.sm),
              Semantics(
                label: 'Your code: ${code.split('').join(' ')}',
                child: ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SelectableText(
                      code,
                      key: const Key('sticker-code'),
                      style: text.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: redeemed ? p.textMuted : p.text,
                        decoration: redeemed
                            ? TextDecoration.lineThrough
                            : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: Column(
            children: [
              Text(
                redeemed
                    ? 'This code has been used. You already collected your sticker.'
                    : 'Show this at the HeyMey stall.',
                key: const Key('sticker-hint'),
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (!redeemed)
                Text(
                  'Stall A130, Hall A, CODISSIA.',
                  textAlign: TextAlign.center,
                  style: text.titleSmall,
                ),
              const SizedBox(height: HmSpace.sm),
              Text(
                'One code per person. Staff check it once, then it is used up.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: p.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A white ticket with a dashed tear line and notches on both sides.
class _Ticket extends StatelessWidget {
  const _Ticket({required this.top, required this.bottom});

  final Widget top;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HmRadius.xl),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: ColoredBox(
          color: p.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HmSpace.lg,
                  HmSpace.xl,
                  HmSpace.lg,
                  HmSpace.lg,
                ),
                child: top,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: HmSpace.lg),
                child: CustomPaint(
                  size: Size(double.infinity, 2),
                  painter: _DashPainter(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HmSpace.lg,
                  HmSpace.lg,
                  HmSpace.lg,
                  HmSpace.xl,
                ),
                child: bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // The tear line sits a little under the middle of the top part; the notches follow it.
    const notch = 14.0;
    final y = size.height * 0.48;
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28)),
      );
    final holes = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: notch));
    return Path.combine(PathOperation.difference, body, holes);
  }

  @override
  bool shouldReclip(_TicketClipper old) => false;
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9D0C2)
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 1), Offset(x + 6, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => false;
}

class _NoCodeView extends StatelessWidget {
  const _NoCodeView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(HmSpace.xl),
      children: [
        const HmMey(HmPic.meyThink, size: 160),
        const SizedBox(height: HmSpace.lg),
        Text(
          'No sticker code yet',
          key: const Key('sticker-none'),
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
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
