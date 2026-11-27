import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../../progress/application/progress_controller.dart';
import '../application/play_controller.dart';
import 'play_tab.dart';

/// Segment colours from design/ui/20: amber, mint, sky, coral, rose and cream, in that order.
const spinWheelColors = [
  Color(0xFFF5A524),
  Color(0xFF9FDAB8),
  Color(0xFF7FB3E8),
  Color(0xFFF59A86),
  Color(0xFFEE6A5E),
  Color(0xFFFBEBD3),
];

/// Kept for callers that pick colours from the theme (high contrast); the light design uses [spinWheelColors].
List<Color> wheelColors(ColorScheme c) => spinWheelColors;

/// The wheel: one segment per prize, as wide as its exact chance. Segment 0 starts at the top and runs clockwise.
class SpinWheelPainter extends CustomPainter {
  SpinWheelPainter({
    required this.prizes,
    required this.colors,
    required this.edge,
    required this.turn,
    this.labelStyle,
  });

  final List<SpinPrizeView> prizes;
  final List<Color> colors;
  final Color edge;
  final TextStyle? labelStyle;

  /// Rotation in radians.
  final double turn;

  /// Centre angle of a prize's segment, measured clockwise from the top.
  static double centreOf(List<SpinPrizeView> prizes, String id) {
    var start = 0.0;
    for (final p in prizes) {
      final sweep = p.percent / 100 * 2 * math.pi;
      if (p.id == id) return start + sweep / 2;
      start += sweep;
    }
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final centre = Offset(size.width / 2, size.height / 2);
    // Cream rim with a thin brown edge, like the mock-up.
    canvas
      ..drawCircle(centre, r, Paint()..color = const Color(0xFFF6E3C4))
      ..drawCircle(
        centre,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = edge,
      );
    final inner = r * 0.9;
    final rect = Rect.fromCircle(center: centre, radius: inner);
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = edge;
    var start = -math.pi / 2 + turn;
    for (var i = 0; i < prizes.length; i++) {
      final sweep = prizes[i].percent / 100 * 2 * math.pi;
      fill.color = colors[i % colors.length];
      canvas
        ..drawArc(rect, start, sweep, true, fill)
        ..drawArc(rect, start, sweep, true, line);
      if (labelStyle != null && sweep > 0.32) {
        _label(canvas, centre, inner, start + sweep / 2, prizes[i]);
      }
      start += sweep;
    }
    canvas
      ..drawCircle(centre, r * 0.14, Paint()..color = const Color(0xFFF6E3C4))
      ..drawCircle(centre, r * 0.14, line);
  }

  void _label(
    Canvas canvas,
    Offset c,
    double r,
    double angle,
    SpinPrizeView p,
  ) {
    final words = p.kind == 'none' ? 'Tomorrow' : '${p.amount}\nPoints';
    final tp = TextPainter(
      text: TextSpan(text: words, style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: r * 0.7);
    final at = c + Offset(math.cos(angle), math.sin(angle)) * r * 0.62;
    // Labels in the lower half are turned the other way so no label reads upside down.
    final a = angle % (2 * math.pi);
    final lower = a > 0 && a < math.pi;
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(lower ? angle - math.pi / 2 : angle + math.pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(SpinWheelPainter old) =>
      old.turn != turn || old.prizes != prizes || old.colors != colors;
}

/// The fixed amber pointer above the wheel.
class _PointerPainter extends CustomPainter {
  _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF8A4B2A),
      );
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

/// Daily Spin (BOLT-0115, design/ui/20): the exact odds sit on the same screen as the wheel, before and after the
/// spin. The server draws; the wheel only turns to the prize the server sent. Under reduce-motion (OS, Calm or
/// Lite) it jumps straight there and no confetti falls.
class DailySpinScreen extends ConsumerStatefulWidget {
  const DailySpinScreen({super.key});

  @override
  ConsumerState<DailySpinScreen> createState() => _DailySpinScreenState();
}

class _DailySpinScreenState extends ConsumerState<DailySpinScreen>
    with SingleTickerProviderStateMixin {
  /// How long the wheel turns before it lands.
  static const spinTime = Duration(milliseconds: 2400);

  late final AnimationController _turn =
      AnimationController(vsync: this, duration: spinTime)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed && mounted) {
            setState(() => _landed = true);
          }
        });
  double _from = 0;
  double _to = 0;
  bool _busy = false;
  bool _landed = false;
  bool _popupClosed = false;
  SpinResultView? _result;
  String? _error;

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  double get _angle =>
      _from + (_to - _from) * Curves.easeOutCubic.transform(_turn.value);

  void _land(
    List<SpinPrizeView> prizes,
    String prizeId, {
    required bool animate,
  }) {
    final target = -SpinWheelPainter.centreOf(prizes, prizeId);
    _from = animate ? target + 5 * 2 * math.pi : target;
    _to = target;
    if (animate) {
      _landed = false;
      _turn.forward(from: 0);
    } else {
      _turn.value = 1;
      _landed = true;
    }
  }

  Future<void> _spin(DailySpinView state) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(playRepositoryProvider).spin();
      if (!mounted) return;
      _land(state.prizes, r.prize.id, animate: !HmModes.reduceMotion(context));
      setState(() => _result = r);
      unawaited(HapticFeedback.mediumImpact());
      // The new balance shows on Play and Me as soon as the server has it.
      ref
        ..invalidate(dailySpinProvider)
        ..invalidate(myProgressProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = messageOf(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final spin = ref.watch(dailySpinProvider);
    final p = context.hm;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        centerTitle: true,
        title: const Text(
          'Daily Spin',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: HmSpace.md),
            child: ActionChip(
              key: const Key('spin-rules'),
              label: const Text('Rules'),
              shape: const StadiumBorder(),
              side: BorderSide.none,
              backgroundColor: HmTint.cream,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GameRulesScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: spin.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(dailySpinProvider),
            child: Text('${messageOf(e)} Try again'),
          ),
        ),
        data: (s) => _body(context, s),
      ),
    );
  }

  String _prizeLine(SpinPrizeView prize) => prize.kind == 'none'
      ? 'Better luck tomorrow.'
      : '+${prize.amount} Points!';

  Widget _body(BuildContext context, DailySpinView s) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final prize = _result?.prize ?? s.todaysPrize;
    // Before a spin in this visit, the wheel rests on today's prize (if any) with no motion.
    final rest = s.todaysPrize == null
        ? 0.0
        : -SpinWheelPainter.centreOf(s.prizes, s.todaysPrize!.id);
    final canSpin = !s.spunToday && !s.asleep && _result == null && !_busy;
    final odds = s.prizes.map((p) => '${p.label} ${p.percentText}').join(', ');
    final showPopup = _result != null && _landed && !_popupClosed;
    final labelStyle = text.labelLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFF1C1C1E),
      height: 1.05,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final wheel = math.min(
          math.min(box.maxWidth - 48, 340.0),
          box.maxHeight * 0.46,
        );
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                HmSpace.lg,
                HmSpace.sm,
                HmSpace.lg,
                HmSpace.xl,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          label: 'Prize wheel. Chances: $odds.',
                          child: ExcludeSemantics(
                            child: Column(
                              children: [
                                const HmPicture(HmPic.meySmall, height: 56),
                                CustomPaint(
                                  size: const Size(26, 22),
                                  painter: _PointerPainter(p.primary),
                                ),
                                AnimatedBuilder(
                                  animation: _turn,
                                  builder: (context, _) => CustomPaint(
                                    key: const Key('spin-wheel'),
                                    size: Size.square(wheel),
                                    painter: SpinWheelPainter(
                                      prizes: s.prizes,
                                      colors: spinWheelColors,
                                      edge: const Color(0xFF8A4B2A),
                                      labelStyle: labelStyle,
                                      turn: _result == null ? rest : _angle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: HmSpace.md),
                        if (prize != null &&
                            !showPopup &&
                            (_result == null || _landed))
                          Center(
                            child: HmTag(
                              key: const Key('spin-today'),
                              label: _result == null
                                  ? "Today's spin: ${prize.kind == 'none' ? 'better luck tomorrow' : prize.label}"
                                  : _prizeLine(prize),
                            ),
                          ),
                        // The odds sit between the wheel and the button: nobody can spin without passing them.
                        const SizedBox(height: HmSpace.md),
                        HmCard(
                          key: const Key('spin-odds'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Odds',
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: HmSpace.sm),
                              Wrap(
                                spacing: HmSpace.lg,
                                runSpacing: HmSpace.xs,
                                children: [
                                  for (var i = 0; i < s.prizes.length; i++)
                                    _OddsEntry(
                                      prize: s.prizes[i],
                                      swatch:
                                          spinWheelColors[i %
                                              spinWheelColors.length],
                                    ),
                                ],
                              ),
                              const SizedBox(height: HmSpace.sm),
                              Text(
                                'Exact chances for every spin (odds table version ${s.oddsVersion}). '
                                'Free to play. Prizes are Points only.',
                                style: text.bodySmall?.copyWith(
                                  color: p.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: HmSpace.lg),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: HmSpace.sm),
                            child: Text(
                              _error!,
                              style: TextStyle(color: p.error),
                            ),
                          ),
                        HmChunkyButton(
                          key: const Key('spin-button'),
                          expand: true,
                          busy: _busy || (_result != null && !_landed),
                          onPressed: canSpin ? () => _spin(s) : null,
                          label: s.asleep
                              ? 'Games are sleeping until 5 AM'
                              : (s.spunToday || _result != null)
                              ? 'Next free spin tomorrow at 5 AM'
                              : 'Spin',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showPopup) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _popupClosed = true),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              if (_result!.prize.kind != 'none')
                const Positioned.fill(child: HmConfetti()),
              Center(
                child: HmPop(
                  haptic: true,
                  child: _PrizeCard(
                    prize: _result!.prize,
                    line: _prizeLine(_result!.prize),
                    onClose: () => setState(() => _popupClosed = true),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// The win card that pops over the wheel (design/ui/20).
class _PrizeCard extends StatelessWidget {
  const _PrizeCard({
    required this.prize,
    required this.line,
    required this.onClose,
  });

  final SpinPrizeView prize;
  final String line;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    final none = prize.kind == 'none';
    return Semantics(
      liveRegion: true,
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(HmSpace.lg),
        padding: const EdgeInsets.all(HmSpace.lg),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(HmRadius.xl),
          boxShadow: [
            BoxShadow(
              color: p.shadow,
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (none)
              const HmMey(HmPic.meySleepy, size: 120)
            else
              const SizedBox(
                width: 160,
                height: 124,
                child: Stack(
                  children: [
                    Center(child: HmMey(HmPic.meyCheer, size: 120)),
                    Positioned(
                      right: 0,
                      bottom: 8,
                      child: HmPop(child: HmPicture(HmPic.coin, width: 48)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: HmSpace.sm),
            Text(
              line,
              key: const Key('spin-result'),
              textAlign: TextAlign.center,
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: none ? p.text : p.primaryShade,
              ),
            ),
            const SizedBox(height: HmSpace.xs),
            Text(
              none
                  ? 'Come back tomorrow for a new spin.'
                  : 'Added to your balance',
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            const SizedBox(height: HmSpace.md),
            HmChunkyButton(
              key: const Key('spin-awesome'),
              label: none ? 'OK' : 'Awesome!',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _OddsEntry extends StatelessWidget {
  const _OddsEntry({required this.prize, required this.swatch});

  final SpinPrizeView prize;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      key: Key('odds-${prize.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: swatch,
            border: Border.all(color: const Color(0xFF8A4B2A), width: 1),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: HmSpace.xs),
        Flexible(child: Text('${prize.label}: ', style: text.bodyMedium)),
        Text(
          prize.percentText,
          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
