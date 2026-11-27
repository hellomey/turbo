import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../application/play_controller.dart';

/// Segment colours from the theme, so the wheel follows light, dark and high-contrast themes.
List<Color> wheelColors(ColorScheme c) => [
  c.primaryContainer,
  c.secondaryContainer,
  c.tertiaryContainer,
  c.surfaceContainerHighest,
  c.inversePrimary,
];

/// The wheel: one segment per prize, as wide as its exact chance. Segment 0 starts at the top and runs clockwise.
class SpinWheelPainter extends CustomPainter {
  SpinWheelPainter({
    required this.prizes,
    required this.colors,
    required this.edge,
    required this.turn,
  });

  final List<SpinPrizeView> prizes;
  final List<Color> colors;
  final Color edge;

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
    final rect = Rect.fromCircle(center: centre, radius: r - 2);
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = edge;
    var start = -math.pi / 2 + turn;
    for (var i = 0; i < prizes.length; i++) {
      final sweep = prizes[i].percent / 100 * 2 * math.pi;
      fill.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, true, fill);
      canvas.drawArc(rect, start, sweep, true, line);
      start += sweep;
    }
    canvas.drawCircle(centre, r * 0.12, fill..color = edge);
  }

  @override
  bool shouldRepaint(SpinWheelPainter old) =>
      old.turn != turn || old.prizes != prizes || old.colors != colors;
}

/// The fixed pointer above the wheel.
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
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

/// Daily Spin (BOLT-0115): the exact odds sit on the same screen as the wheel, before and after the spin.
/// The server draws; the wheel only turns to the prize the server sent. Under reduce-motion (OS, Calm or Lite)
/// it jumps straight there.
class DailySpinScreen extends ConsumerStatefulWidget {
  const DailySpinScreen({super.key});

  @override
  ConsumerState<DailySpinScreen> createState() => _DailySpinScreenState();
}

class _DailySpinScreenState extends ConsumerState<DailySpinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  double _from = 0;
  double _to = 0;
  bool _busy = false;
  SpinResultView? _result;
  String? _error;

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  double get _angle =>
      _from + (_to - _from) * Curves.easeOutBack.transform(_turn.value);

  void _land(
    List<SpinPrizeView> prizes,
    String prizeId, {
    required bool animate,
  }) {
    final target = -SpinWheelPainter.centreOf(prizes, prizeId);
    _from = animate ? target + 2 * math.pi : target;
    _to = target;
    if (animate) {
      _turn.forward(from: 0);
    } else {
      _turn.value = 1;
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
      ref.invalidate(dailySpinProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = messageOf(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final spin = ref.watch(dailySpinProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Spin')),
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

  Widget _body(BuildContext context, DailySpinView s) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = wheelColors(theme.colorScheme);
    final prize = _result?.prize ?? s.todaysPrize;
    // Before a spin in this visit, the wheel rests on today's prize (if any) with no motion.
    final rest = s.todaysPrize == null
        ? 0.0
        : -SpinWheelPainter.centreOf(s.prizes, s.todaysPrize!.id);
    final canSpin = !s.spunToday && !s.asleep && _result == null && !_busy;
    final odds = s.prizes.map((p) => '${p.label} ${p.percentText}').join(', ');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'One free spin a day. Free to play, nothing to pay. Prizes are Points only.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: Semantics(
            label: 'Prize wheel. Chances: $odds.',
            child: ExcludeSemantics(
              child: SizedBox(
                width: 240,
                height: 264,
                child: Column(
                  children: [
                    CustomPaint(
                      size: const Size(28, 24),
                      painter: _PointerPainter(theme.colorScheme.onSurface),
                    ),
                    AnimatedBuilder(
                      animation: _turn,
                      builder: (context, _) => CustomPaint(
                        key: const Key('spin-wheel'),
                        size: const Size(240, 240),
                        painter: SpinWheelPainter(
                          prizes: s.prizes,
                          colors: colors,
                          edge: theme.colorScheme.outline,
                          turn: _result == null ? rest : _angle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (prize != null)
          Semantics(
            liveRegion: true,
            child: Text(
              prize.kind == 'none'
                  ? 'Better luck tomorrow.'
                  : 'You won ${prize.label}.',
              key: const Key('spin-result'),
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        // The odds sit between the wheel and the button: nobody can spin without passing them.
        Text('Odds', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Exact chances for every spin (odds table version ${s.oddsVersion}).',
          style: text.bodySmall,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < s.prizes.length; i++)
          _OddsRow(prize: s.prizes[i], swatch: colors[i % colors.length]),
        const SizedBox(height: 16),
        if (_error != null)
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        FilledButton(
          key: const Key('spin-button'),
          onPressed: canSpin ? () => _spin(s) : null,
          child: Text(
            s.asleep
                ? 'Games are sleeping until 5 AM'
                : (s.spunToday || _result != null)
                ? 'Next free spin tomorrow at 5 AM'
                : 'Spin',
          ),
        ),
      ],
    );
  }
}

class _OddsRow extends StatelessWidget {
  const _OddsRow({required this.prize, required this.swatch});

  final SpinPrizeView prize;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: Key('odds-${prize.id}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: swatch,
              border: Border.all(color: theme.colorScheme.outline),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(prize.label)),
          Text(prize.percentText, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
