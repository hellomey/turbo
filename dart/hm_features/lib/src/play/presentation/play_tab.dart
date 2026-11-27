import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../../expo/presentation/expo_challenge_screen.dart';
import '../../progress/application/progress_controller.dart';
import '../application/play_controller.dart';
import 'confidence_duel_screen.dart';
import 'daily_spin_screen.dart';

/// Play hub (§10.5, BOLT-0115, design/ui/19): Daily Spin is the amber hero, Confidence Duel and Rules & odds sit
/// side by side, and the Points card shows the live balance. Games are free; prizes are Points only.
class PlayTab extends ConsumerWidget {
  const PlayTab({super.key, this.onOpenExpo});

  /// Opens the Expo Challenge. When null, the hub pushes the screen itself.
  final VoidCallback? onOpenExpo;

  Future<void> _open(BuildContext context, WidgetRef ref, Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    // Coming back from a game: refresh the spin state and the balance.
    ref
      ..invalidate(dailySpinProvider)
      ..invalidate(myProgressProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final spin = ref.watch(dailySpinProvider).value;
    final rules = ref.watch(gameRulesProvider).value;
    final points = ref.watch(myProgressProvider).value?.points;
    final spinLine = spin == null
        ? 'One free spin a day'
        : spin.asleep
        ? 'Games are sleeping until 5 AM'
        : spin.spunToday
        ? 'Spun today. Next spin at 5 AM'
        : '1 free spin today';
    final duelLine = rules == null
        ? 'Five questions, one clock'
        : '${rules.duel.questionsPerDuel} questions · ${rules.duel.timeLimitSeconds} s';

    final hero = HmEnter(
      child: _SpinHero(
        line: spinLine,
        ready: spin != null && !spin.spunToday && !spin.asleep,
        onTap: () => _open(context, ref, const DailySpinScreen()),
      ),
    );
    final duel = _GameTile(
      key: const Key('play-duel'),
      pic: HmPic.icDuel,
      title: 'Confidence Duel',
      body: duelLine,
      color: HmTint.sky,
      onTap: () => _open(context, ref, const ConfidenceDuelScreen()),
    );
    final rulesTile = _GameTile(
      key: const Key('play-rules'),
      pic: HmPic.icShield,
      title: 'Rules & odds',
      body: 'Every prize and chance',
      onTap: () => _open(context, ref, const GameRulesScreen()),
    );
    final pointsCard = HmCard(
      key: const Key('play-points'),
      child: Row(
        children: [
          const HmPicture(HmPic.coin, width: 56, height: 56),
          const SizedBox(width: HmSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Points', style: text.titleMedium),
                Text(
                  points == null ? '…' : '$points Points',
                  key: const Key('play-points-balance'),
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'From games, check-ins and study. Never money.',
                  style: text.bodySmall?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final expo = HmCard(
      key: const Key('play-expo'),
      color: HmTint.mint,
      onTap:
          onOpenExpo ?? () => _open(context, ref, const ExpoChallengeScreen()),
      semanticLabel:
          'Expo Challenge: 10 questions. Win a sticker at stall A130',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(HmRadius.md),
            child: const HmPicture(
              HmPic.expoStall,
              width: 84,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: HmSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expo Challenge',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '10 questions. Finish for a sticker code.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 720;
          final pair = IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: HmEnter(index: 1, child: duel)),
                const SizedBox(width: HmSpace.md),
                Expanded(child: HmEnter(index: 2, child: rulesTile)),
              ],
            ),
          );
          return RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(dailySpinProvider)
                ..invalidate(myProgressProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                HmSpace.lg,
                HmSpace.lg,
                HmSpace.lg,
                120,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Play',
                          style: text.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: HmSpace.xs),
                        Text(
                          'Prizes are Points only. Odds always shown. '
                          'Games sleep from 12 AM to 5 AM.',
                          style: text.bodyLarge?.copyWith(color: p.textMuted),
                        ),
                        const SizedBox(height: HmSpace.lg),
                        if (wide)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 3, child: hero),
                                const SizedBox(width: HmSpace.md),
                                Expanded(flex: 2, child: pair),
                              ],
                            ),
                          )
                        else ...[
                          hero,
                          const SizedBox(height: HmSpace.md),
                          pair,
                        ],
                        const SizedBox(height: HmSpace.md),
                        HmEnter(index: 3, child: pointsCard),
                        const SizedBox(height: HmSpace.md),
                        HmEnter(index: 4, child: expo),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The amber Daily Spin hero: a small wheel with Mey in front, the line and a Spin pill.
class _SpinHero extends StatelessWidget {
  const _SpinHero({
    required this.line,
    required this.ready,
    required this.onTap,
  });

  final String line;
  final bool ready;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HmCard(
      key: const Key('play-spin'),
      color: HmTint.amber,
      onTap: onTap,
      semanticLabel: 'Daily Spin. $line',
      child: Builder(
        builder: (context) {
          final art = math
              .min(150, MediaQuery.sizeOf(context).width * 0.3)
              .toDouble();
          return Row(
            children: [
              SizedBox(
                width: art,
                height: art,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(child: _TurningWheel(turning: ready)),
                    Positioned(
                      right: -art * 0.12,
                      bottom: -art * 0.06,
                      child: HmMey(HmPic.meySmall, size: art * 0.58),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: HmSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Spin',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: HmSpace.xs),
                    Text(
                      line,
                      key: const Key('play-spin-line'),
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: HmSpace.md),
                    ExcludeSemantics(
                      child: HmChunkyButton(
                        label: ready ? 'Spin' : 'Open',
                        onPressed: onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Six equal slices for the decorative wheel on the hero. The real wheel uses the server's exact odds.
final _demoSlices = [
  for (var i = 0; i < 6; i++)
    SpinPrizeView(
      id: 'deco-$i',
      label: '',
      kind: 'none',
      amount: 0,
      percent: 100 / 6,
    ),
];

class _GameTile extends StatelessWidget {
  const _GameTile({
    super.key,
    required this.pic,
    required this.title,
    required this.body,
    required this.onTap,
    this.color,
  });

  final HmPic pic;
  final String title;
  final String body;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HmCard(
      color: color,
      onTap: onTap,
      semanticLabel: '$title. $body',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HmPicture(pic, height: 64),
          const SizedBox(height: HmSpace.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: HmSpace.xs),
          Text(body, textAlign: TextAlign.center, style: text.bodySmall),
        ],
      ),
    );
  }
}

/// Game Rules & Odds (`GET /v1/games/rules`): the same tables the server draws and scores with.
class GameRulesScreen extends ConsumerWidget {
  const GameRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rules = ref.watch(gameRulesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rules & odds')),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(gameRulesProvider),
            child: Text('${messageOf(e)} Try again'),
          ),
        ),
        data: (g) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Games are free. You never pay or stake anything, and nothing '
              'can be cashed out. Prizes are Points only. Points cannot be '
              'bought and never turn into Sparks or money.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Daily Spin', style: text.titleMedium),
            Text(
              '${g.spinsPerDay} free spin a day. Exact chances (odds table '
              'version ${g.oddsVersion}):',
              style: text.bodySmall,
            ),
            for (final p in g.spinPrizes)
              ListTile(
                key: Key('rules-odds-${p.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(p.label),
                trailing: Text(p.percentText, style: text.titleSmall),
              ),
            const SizedBox(height: 16),
            Text('Confidence Duel', style: text.titleMedium),
            const SizedBox(height: 8),
            DuelRulesCard(rules: g.duel),
            const SizedBox(height: 16),
            Text(
              'Games sleep from ${g.sleepFrom} to ${g.sleepTo} India time. '
              'Study stays open.',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// The hero's little wheel: turns slowly a few times while a spin is waiting, then rests. Still under reduce motion.
class _TurningWheel extends StatefulWidget {
  const _TurningWheel({required this.turning});

  final bool turning;

  @override
  State<_TurningWheel> createState() => _TurningWheelState();
}

class _TurningWheelState extends State<_TurningWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_TurningWheel old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.turning && !HmModes.reduceMotion(context)) {
      if (!_c.isAnimating) _c.repeat(count: 3);
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) => CustomPaint(
      painter: SpinWheelPainter(
        prizes: _demoSlices,
        colors: spinWheelColors,
        edge: const Color(0xFF8A4B2A),
        turn: _c.value * 2 * math.pi,
      ),
    ),
  );
}
