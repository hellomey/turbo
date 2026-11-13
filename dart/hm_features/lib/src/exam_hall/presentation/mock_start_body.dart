import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/exam_hall_models.dart';

/// Before a mock: what it is, the rules, and one action, "Start mock" (§10.1, §10.6 Exam Hall).
/// Starting needs a connection (D-2026-10-22-24).
class MockStartBody extends StatelessWidget {
  const MockStartBody({
    super.key,
    required this.mock,
    required this.onStart,
    required this.onNotNow,
    this.busy = false,
    this.message,
    this.messageIsLimit = false,
  });

  final MockItem mock;
  final VoidCallback onStart;
  final VoidCallback onNotNow;
  final bool busy;
  final String? message;

  /// The message is a limit: the only actions are "Not now" (D-2026-10-22-19, no price line).
  final bool messageIsLimit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final blocked = mock.locked || messageIsLimit;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(mock.title, style: text.headlineSmall),
        ),
        const SizedBox(height: 4),
        Text('${mock.accessLabel} · ${mock.facts}', style: text.bodyMedium),
        const SizedBox(height: 16),
        HmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Before you start', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final line in [
                'The clock is set by the server and keeps running if you leave the app.',
                'Your answers are saved on this phone and sent as you go.',
                'You need an internet connection to start.',
                if (mock.negativeMarking)
                  'Wrong answers lose marks. Leave a question blank if you are not sure.',
                if (mock.kind == MockKindView.stateMockSunday)
                  'Only attempts started on time and sent before the end time count for the rank.',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $line', style: text.bodyMedium),
                ),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              message!,
              key: const Key('mock-start-message'),
              style: text.bodyLarge?.copyWith(
                color: messageIsLimit ? scheme.onSurface : scheme.error,
              ),
            ),
          ),
        ],
        if (mock.locked && message == null) ...[
          const SizedBox(height: 16),
          Text(
            mock.free
                ? ExamHallCopy.monthlyLimit
                : 'This mock is part of Pro. Pro is not on sale yet.',
            key: const Key('mock-locked-note'),
            style: text.bodyLarge,
          ),
        ],
        const SizedBox(height: 24),
        if (!blocked)
          HmPrimaryButton(
            key: const Key('mock-start'),
            label: 'Start mock',
            semanticLabel: 'Start mock. Needs an internet connection',
            busy: busy,
            onPressed: onStart,
          ),
        const SizedBox(height: 8),
        HmSecondaryButton(
          key: const Key('mock-not-now'),
          label: ExamHallCopy.notNow,
          onPressed: onNotNow,
        ),
      ],
    );
  }
}
