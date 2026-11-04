import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../application/sync_status.dart';
import '../domain/practice_models.dart';
import '../domain/study_rules.dart';

/// One question: stem and big options (48 dp+, §10.6, §10.9). Tamil only inside Tamil paper content (§1).
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.chosen,
    this.onChoose,
    this.graded,
    this.number,
  });

  final QuestionView question;
  final List<String> chosen;
  final ValueChanged<String>? onChoose;
  final GradedView? graded;

  /// "Question 2 of 10".
  final String? number;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final contentStyle = question.tamil
        ? const TextStyle(fontFamily: HmFonts.tamilContentOnly)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (number != null) Text(number!, style: text.bodySmall),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            question.stem,
            style: text.titleMedium?.merge(contentStyle),
          ),
        ),
        if (question.affectedNote != null) ...[
          const SizedBox(height: 8),
          Text(
            'Note: ${question.affectedNote}',
            style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 16),
        for (final (i, o) in question.options.indexed) ...[
          _Option(
            key: Key('option-${o.id}'),
            letter: String.fromCharCode(65 + i),
            text: o.text,
            style: contentStyle,
            selected: chosen.contains(o.id),
            result: graded == null
                ? null
                : graded!.correctOptionIds.contains(o.id)
                ? true
                : (chosen.contains(o.id) ? false : null),
            onTap: onChoose == null ? null : () => onChoose!(o.id),
            scheme: scheme,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.result,
    required this.onTap,
    required this.scheme,
    this.style,
  });

  final String letter;
  final String text;
  final bool selected;

  /// true = the right answer, false = my wrong choice, null = neither / not graded.
  final bool? result;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final state = switch (result) {
      true => HmAnswerState.correct,
      false => HmAnswerState.wrong,
      null => selected ? HmAnswerState.selected : HmAnswerState.idle,
    };
    final status = switch (result) {
      true => ', correct answer',
      false => ', your answer, wrong',
      null => selected ? ', selected' : '',
    };
    return HmAnswerTile(
      label: letter,
      text: text,
      state: state,
      onTap: onTap,
      textStyle: style,
      semanticLabel: 'Option $letter: $text$status',
    );
  }
}

/// Right / wrong with the explanation and source (§19.4 Q32, Q38).
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({super.key, required this.graded, this.onRelight});

  final GradedView graded;

  /// Shown after a wrong answer: the lamp to relight (§19.4 Q38).
  final VoidCallback? onRelight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final card = HmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            header: true,
            child: Text(
              graded.correct ? 'Correct' : 'Not quite',
              style: text.titleMedium?.copyWith(
                color: graded.correct
                    ? context.hm.onSuccessTint
                    : context.hm.onErrorTint,
              ),
            ),
          ),
          if (!graded.correct && graded.whyChosenIsWrong != null) ...[
            const SizedBox(height: 8),
            Text('Why yours was wrong', style: text.labelLarge),
            Text(graded.whyChosenIsWrong!, style: text.bodyMedium),
          ],
          const SizedBox(height: 8),
          Text('Why this is right', style: text.labelLarge),
          Text(graded.explanation, style: text.bodyMedium),
          const SizedBox(height: 8),
          Text('Source: ${graded.source.line}', style: text.bodySmall),
        ],
      ),
    );
    if (graded.correct || onRelight == null) return card;
    // Outside the card: a Card merges its children into one screen-reader node (§10.9).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: 8),
        HmSecondaryButton(
          key: const Key('feedback-relight'),
          label: 'Relight this lamp',
          icon: Icons.lightbulb_outline,
          onPressed: onRelight,
        ),
      ],
    );
  }
}

/// "Will sync when online" (§39).
class WillSyncNote extends StatelessWidget {
  const WillSyncNote({super.key, this.detail});
  final String? detail;

  @override
  Widget build(BuildContext context) => HmCard(
    key: const Key('will-sync'),
    child: Row(
      children: [
        HmIconBadge(icon: Icons.cloud_off_outlined, color: context.hm.info),
        const SizedBox(width: HmSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  StudyCopy.willSync,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (detail != null) Text(detail!),
            ],
          ),
        ),
      ],
    ),
  );
}

/// "Couldn't save" with the server's reason (§39).
class CouldNotSaveNote extends StatelessWidget {
  const CouldNotSaveNote({super.key, required this.message, this.onDismiss});
  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => HmCard(
    key: const Key('could-not-save'),
    child: Row(
      children: [
        HmIconBadge(icon: Icons.error_outline, color: context.hm.error),
        const SizedBox(width: HmSpace.md),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text('${StudyCopy.couldNotSave}. $message'),
          ),
        ),
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    ),
  );
}

/// The app-wide outbox note shown above the tabs (§39): pending count and refused actions.
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    if (status.quiet) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.pending > 0)
            WillSyncNote(
              detail: status.pending == 1
                  ? '1 study action saved on this phone.'
                  : '${status.pending} study actions saved on this phone.',
            ),
          for (final e in status.rejected)
            CouldNotSaveNote(
              message: 'The server did not accept one study action.',
              onDismiss: () => ref
                  .read(syncStatusProvider.notifier)
                  .dismiss(e.clientActionId),
            ),
        ],
      ),
    );
  }
}

/// The free-limit sheet (§13, INT-002-S07, D-2026-10-22-19): the limit and "Not now". No price line, no
/// timer, no fake urgency. Lessons, relights and mocks stay open.
class LimitSheet extends StatelessWidget {
  const LimitSheet({super.key, required this.limit, required this.onNotNow});

  final int? limit;
  final VoidCallback onNotNow;

  static Future<void> show(BuildContext context, {int? limit}) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (c) =>
            LimitSheet(limit: limit, onNotNow: () => Navigator.of(c).pop()),
      );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        key: const Key('limit-sheet'),
        padding: const EdgeInsets.fromLTRB(
          HmSpace.xl,
          HmSpace.sm,
          HmSpace.xl,
          HmSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: HmIllustration(kind: HmIllustrationKind.soon, size: 88),
            ),
            const SizedBox(height: HmSpace.md),
            Semantics(
              header: true,
              child: Text(
                StudyCopy.limitTitle(limit),
                style: text.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: HmSpace.sm),
            Text(
              StudyCopy.limitBody,
              style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HmSpace.xl),
            HmPrimaryButton(
              key: const Key('limit-not-now'),
              label: StudyCopy.notNow,
              onPressed: onNotNow,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Free" / "Pro" shown before a tap (§19.9 Q82).
class TierChip extends StatelessWidget {
  const TierChip({super.key, required this.pro});
  final bool pro;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: HmSpace.sm,
      vertical: HmSpace.xxs,
    ),
    decoration: BoxDecoration(
      color: pro ? context.hm.gold.withValues(alpha: 0.14) : null,
      borderRadius: BorderRadius.circular(HmRadius.pill),
      border: Border.all(
        color: pro ? context.hm.gold : Theme.of(context).colorScheme.outline,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pro) const Icon(Icons.lock_outline, size: 14),
        if (pro) const SizedBox(width: 4),
        Text(pro ? StudyCopy.pro : StudyCopy.free),
      ],
    ),
  );
}
