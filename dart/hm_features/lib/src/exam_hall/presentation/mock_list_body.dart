import 'package:flutter/material.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/exam_hall_models.dart';

/// Exam Hall home: State Mock Sunday card, then the mock list (§10.6 Exam Hall, INT-002-S10/S11).
/// Calm and plain: no game styling, sounds, animations or alerts (§9.10).
class MockListBody extends StatelessWidget {
  const MockListBody({
    super.key,
    required this.list,
    required this.now,
    required this.onOpenMock,
    this.stateMock,
    this.calm = false,
    this.onResume,
  });

  final MockListView list;
  final StateMockCardView? stateMock;
  final DateTime now;
  final ValueChanged<MockItem> onOpenMock;

  /// Calm Mode hides rank talk (§10.7).
  final bool calm;

  /// Shown when an attempt was left open on this phone.
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final sunday = stateMock;
    final regular = [
      for (final m in list.items)
        if (m.kind != MockKindView.stateMockSunday) m,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text('Exam Hall', style: text.headlineSmall),
        ),
        const SizedBox(height: 4),
        Text(
          'Mocks with the real pattern, marking and time.',
          style: text.bodyMedium,
        ),
        if (onResume != null) ...[
          const SizedBox(height: 16),
          HmCard(
            key: const Key('exam-resume'),
            highlighted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('You have a mock in progress', style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'The clock kept running on the server.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 12),
                HmPrimaryButton(
                  label: 'Continue mock',
                  semanticLabel: 'Continue the mock in progress',
                  onPressed: onResume,
                ),
              ],
            ),
          ),
        ],
        if (sunday != null) ...[
          const SizedBox(height: 16),
          StateMockSundayCard(
            info: sunday,
            now: now,
            calm: calm,
            onStart: () => onOpenMock(sunday.asMock),
          ),
        ],
        if (list.allowanceLine != null) ...[
          const SizedBox(height: 16),
          Text(
            list.allowanceLine!,
            key: const Key('exam-allowance'),
            style: text.bodyMedium,
          ),
        ],
        const SizedBox(height: 8),
        if (regular.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No mocks for your exam yet. We are adding them.',
              style: text.bodyLarge,
            ),
          ),
        for (final m in regular) ...[
          const SizedBox(height: 8),
          _MockTile(mock: m, onOpen: () => onOpenMock(m)),
        ],
      ],
    );
  }
}

class _MockTile extends StatelessWidget {
  const _MockTile({required this.mock, required this.onOpen});

  final MockItem mock;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final kind = mock.kind == MockKindView.sectional ? 'Sectional' : 'Full';
    final lockNote = mock.locked ? ' Locked.' : '';
    return HmCard(
      key: Key('mock-${mock.id}'),
      onTap: onOpen,
      semanticLabel:
          '${mock.title}. $kind mock. ${mock.accessLabel}.$lockNote ${mock.facts}. Open',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mock.title, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(mock.facts, style: text.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AccessChip(label: mock.accessLabel, locked: mock.locked),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// "Free" / "Pro" shown before tap (§19.9 Q82). Locked adds a lock shape, not only colour (§10.9).
class _AccessChip extends StatelessWidget {
  const _AccessChip({required this.label, required this.locked});

  final String label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (locked) ...[
            Icon(Icons.lock_outline, size: 14, color: scheme.onSurface),
            const SizedBox(width: 4),
          ],
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// State Mock Sunday: one mock for the whole state, 1st and 3rd Sunday, free for everyone
/// (§9.9, INT-002-S11, D-2026-10-22-23).
class StateMockSundayCard extends StatelessWidget {
  const StateMockSundayCard({
    super.key,
    required this.info,
    required this.now,
    required this.onStart,
    this.calm = false,
  });

  final StateMockCardView info;
  final DateTime now;
  final VoidCallback onStart;
  final bool calm;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final phase = info.phaseAt(now);
    final when = switch (phase) {
      StateMockPhase.upcoming => 'Starts ${formatIst(info.opensAt)}',
      StateMockPhase.open =>
        'Open now. Join by ${formatIst(info.lateJoinUntil)}${calm ? '' : ' to get a statewide rank'}.',
      StateMockPhase.practiceOnly =>
        'Practice only now (no rank). Open until ${formatIst(info.closesAt)}.',
      StateMockPhase.closed =>
        'This one has ended. The next one is on a 1st or 3rd Sunday.',
    };
    final rankLine = calm || info.rankPublishAt == null
        ? null
        : 'Ranks are shown ${formatIst(info.rankPublishAt!)}.';
    return HmCard(
      key: const Key('state-mock-card'),
      highlighted: info.canStartAt(now),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('State Mock Sunday', style: text.titleMedium),
          ),
          const SizedBox(height: 4),
          Text(info.title, style: text.bodyLarge),
          Text(
            'Free · ${info.questionCount} questions · ${info.durationMinutes} minutes',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(when, key: const Key('state-mock-when'), style: text.bodyMedium),
          if (rankLine != null) Text(rankLine, style: text.bodySmall),
          if (info.canStartAt(now)) ...[
            const SizedBox(height: 12),
            HmPrimaryButton(
              key: const Key('state-mock-start'),
              label: 'Open State Mock',
              semanticLabel: 'Open the State Mock Sunday',
              onPressed: onStart,
            ),
          ],
        ],
      ),
    );
  }
}
