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
      appBar: AppBar(
        title: const Text('Exam Alerts'),
        actions: [
          if (onOpenSettings != null)
            IconButton(
              key: const Key('alerts-open-settings'),
              tooltip: 'Alert settings',
              icon: const Icon(Icons.tune),
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

/// Layout only, for tests and goldens.
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
    if (items.isEmpty) {
      return const HmEmptyView(
        kind: HmIllustrationKind.bell,
        title: 'All quiet for now',
        message: AlertCopy.noAlerts,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final a in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HmCard(
              key: Key('exam-alert-${a.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AlertCopy.kind(a.kind)} · ${formatIst(a.publishedAt)}',
                    style: text.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    header: true,
                    child: Text(a.title, style: text.titleMedium),
                  ),
                  const SizedBox(height: 4),
                  Text(a.summary, style: text.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    a.confirmLine,
                    style: text.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  HmSecondaryButton(
                    key: Key('exam-alert-open-${a.id}'),
                    label: 'Open official notice',
                    semanticLabel:
                        'Open the official notice for ${a.title}. Opens your browser.',
                    icon: Icons.open_in_new,
                    onPressed: () => onOpenOfficial(a),
                  ),
                ],
              ),
            ),
          ),
        if (hasMore)
          HmSecondaryButton(
            key: const Key('exam-alerts-more'),
            label: loadingMore ? 'Loading…' : 'Show older alerts',
            onPressed: loadingMore ? null : onLoadMore,
          ),
      ],
    );
  }
}
