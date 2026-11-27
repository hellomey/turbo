import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../exam_hall/domain/exam_hall_models.dart' show formatIst;
import '../application/alerts_controller.dart';
import '../domain/alert_models.dart';

/// Exam Alerts (INT-002-S17): human-checked official news, each with a link to the official notice and the
/// server's "Always confirm with the official notification." line.
class ExamAlertsScreen extends ConsumerWidget {
  const ExamAlertsScreen({super.key, this.onOpenSettings});

  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(examAlertsProvider);
    final links = ref.read(linkOpenerProvider);
    return Scaffold(
      backgroundColor: context.hm.background,
      appBar: AppBar(
        backgroundColor: context.hm.background,
        actions: [
          if (onOpenSettings != null)
            IconButton(
              key: const Key('alerts-open-settings'),
              tooltip: 'Alert settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: onOpenSettings,
            ),
        ],
      ),
      body: alerts.when(
        loading: () => const HmSkeletonList(label: 'Loading exam alerts'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(examAlertsProvider),
        ),
        data: (s) => ExamAlertsBody(
          items: s.items,
          hasMore: s.hasMore,
          loadingMore: s.loadingMore,
          onLoadMore: () => ref.read(examAlertsProvider.notifier).loadMore(),
          onOpenOfficial: (a) async {
            final ok = await links.open(a.officialUrl);
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open the page.')),
              );
            }
          },
        ),
      ),
    );
  }
}

/// Layout only, for tests and goldens. A timeline (design/ui/24): Mey with a bell on top, then one tinted card
/// per alert with its date, an "Official" tag naming the site, and an "Open source" strip at the bottom.
class ExamAlertsBody extends StatelessWidget {
  const ExamAlertsBody({
    super.key,
    required this.items,
    required this.onOpenOfficial,
    this.hasMore = false,
    this.loadingMore = false,
    this.onLoadMore,
  });

  final List<ExamAlertView> items;
  final void Function(ExamAlertView alert) onOpenOfficial;
  final bool hasMore;
  final bool loadingMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final header = [
      const HmMey(HmPic.meyBell, size: 120),
      Text(
        'Exam Alerts',
        textAlign: TextAlign.center,
        style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: HmSpace.lg),
    ];
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(HmSpace.lg),
        children: [
          ...header,
          Text(
            'All quiet for now',
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: HmSpace.xs),
          Text(
            AlertCopy.noAlerts,
            textAlign: TextAlign.center,
            style: text.bodyLarge,
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(HmSpace.md, 0, HmSpace.lg, HmSpace.xl),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...header,
                for (var i = 0; i < items.length; i++)
                  HmEnter(
                    index: i.clamp(0, 6),
                    child: _TimelineRow(
                      alert: items[i],
                      first: i == 0,
                      last: i == items.length - 1 && !hasMore,
                      onOpen: () => onOpenOfficial(items[i]),
                    ),
                  ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, top: HmSpace.sm),
                    child: HmSecondaryButton(
                      key: const Key('exam-alerts-more'),
                      label: loadingMore ? 'Loading…' : 'Show older alerts',
                      onPressed: loadingMore ? null : onLoadMore,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Card colours by kind: news is blue, date changes coral, results mint, answer keys amber, hall tickets cream.
({Color fill, Color band, Color dot}) _tone(ExamAlertKindView k) => switch (k) {
  ExamAlertKindView.notification => (
    fill: const Color(0xFFD7E8FB),
    band: const Color(0xFFC0DAF7),
    dot: const Color(0xFF6AAEF0),
  ),
  ExamAlertKindView.dateChange => (
    fill: const Color(0xFFFFA48F),
    band: const Color(0xFFF7846C),
    dot: const Color(0xFFF2645A),
  ),
  ExamAlertKindView.result => (
    fill: HmTint.mint,
    band: const Color(0xFFC9ECD8),
    dot: const Color(0xFF2BB673),
  ),
  ExamAlertKindView.answerKey => (
    fill: HmTint.amber,
    band: const Color(0xFFFCE0B0),
    dot: const Color(0xFFF5A524),
  ),
  ExamAlertKindView.admitCard || ExamAlertKindView.other => (
    fill: const Color(0xFFEDEAE4),
    band: Colors.white,
    dot: const Color(0xFFC9C4BC),
  ),
};

String _site(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  return host.startsWith('www.') ? host.substring(4) : host;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.alert,
    required this.first,
    required this.last,
    required this.onOpen,
  });

  final ExamAlertView alert;
  final bool first;
  final bool last;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    final tone = _tone(alert.kind);
    final a = alert;
    final site = _site(a.officialUrl);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: CustomPaint(
              painter: _RailPainter(
                dot: tone.dot,
                first: first,
                last: last,
                line: const Color(0xFFCFC6B8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: HmSpace.md),
              child: DecoratedBox(
                key: Key('exam-alert-${a.id}'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(HmRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: p.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(HmRadius.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ColoredBox(
                        color: tone.fill,
                        child: Padding(
                          padding: const EdgeInsets.all(HmSpace.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  a.title,
                                  style: text.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: HmSpace.xs),
                              Wrap(
                                spacing: HmSpace.sm,
                                runSpacing: HmSpace.xs,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${AlertCopy.kind(a.kind)} · ${formatIst(a.publishedAt)}',
                                    style: text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (site.isNotEmpty)
                                    HmTag(
                                      label: 'Official · $site',
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      textColor: p.text,
                                      dense: true,
                                    ),
                                ],
                              ),
                              const SizedBox(height: HmSpace.sm),
                              Text(a.summary, style: text.bodyLarge),
                              const SizedBox(height: HmSpace.xs),
                              Text(
                                a.confirmLine,
                                style: text.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: tone.band,
                        child: InkWell(
                          key: Key('exam-alert-open-${a.id}'),
                          onTap: onOpen,
                          child: Semantics(
                            button: true,
                            label:
                                'Open the official notice for ${a.title}. Opens your browser.',
                            child: ExcludeSemantics(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: HmSpace.lg,
                                  vertical: HmSpace.md,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Open source',
                                      style: text.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: HmSpace.xs),
                                    const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
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
        ],
      ),
    );
  }
}

/// The dotted rail with a ringed dot level with the card's title.
class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.dot,
    required this.first,
    required this.last,
    required this.line,
  });

  final Color dot;
  final bool first;
  final bool last;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    const y = 34.0;
    final x = size.width / 2 - 4;
    final dash = Paint()
      ..color = line
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final top = first ? y : 0.0;
    final bottom = last ? y : size.height;
    for (var d = top; d < bottom; d += 8) {
      canvas.drawLine(Offset(x, d), Offset(x, d + 2), dash);
    }
    canvas
      ..drawCircle(
        Offset(x, y),
        14,
        Paint()..color = dot.withValues(alpha: 0.25),
      )
      ..drawCircle(Offset(x, y), 9, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.dot != dot || old.first != first || old.last != last;
}
