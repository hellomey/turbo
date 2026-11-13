import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/exam_hall_models.dart';

/// The mock in progress: OMR bubble sheet or CBT screen with palette, picked from the paper's answer mode
/// (INT-002-S10). Plain exam styling: no game look, sounds, animations, haptics or alerts (§10.6, §9.10).
class AttemptView extends StatelessWidget {
  const AttemptView({
    super.key,
    required this.session,
    required this.index,
    required this.timeLeft,
    required this.pending,
    required this.onChoose,
    required this.onToggleMark,
    required this.onGoTo,
    required this.onSubmit,
    this.message,
    this.submitting = false,
  });

  final MockSession session;
  final int index;

  /// Server deadline minus corrected phone time (never a local timer as truth).
  final Duration timeLeft;
  final int pending;
  final void Function(String questionId, String optionId) onChoose;
  final ValueChanged<String> onToggleMark;
  final ValueChanged<int> onGoTo;
  final VoidCallback onSubmit;
  final String? message;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          session: session,
          timeLeft: timeLeft,
          pending: pending,
          message: message,
        ),
        const Divider(height: 1),
        Expanded(
          child: session.mode == AnswerMode.omr
              ? _OmrSheet(session: session, onChoose: onChoose)
              : _CbtView(
                  session: session,
                  index: index,
                  onChoose: onChoose,
                  onToggleMark: onToggleMark,
                  onGoTo: onGoTo,
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: HmPrimaryButton(
              key: const Key('attempt-submit'),
              label: 'Submit',
              semanticLabel: 'Submit mock',
              busy: submitting,
              onPressed: onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.timeLeft,
    required this.pending,
    this.message,
  });

  final MockSession session;
  final Duration timeLeft;
  final int pending;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                session.title,
                style: text.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Semantics(
                label: 'Time left: ${spokenTimeLeft(timeLeft)}',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      formatClock(timeLeft),
                      key: const Key('attempt-clock'),
                      style: text.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${session.answeredCount} of ${session.questions.length} answered'
            '${session.markedCount > 0 ? ' · ${session.markedCount} marked for review' : ''}',
            style: text.bodySmall,
          ),
          if (pending > 0)
            Text(
              ExamHallCopy.savedOnPhone,
              key: const Key('attempt-pending'),
              style: text.bodySmall,
            ),
          if (message != null)
            Text(
              message!,
              key: const Key('attempt-message'),
              style: text.bodyMedium,
            ),
        ],
      ),
    );
  }
}

String _letter(int i) => String.fromCharCode(65 + i);

/// OMR: every question with a row of bubbles, like the paper sheet.
class _OmrSheet extends StatelessWidget {
  const _OmrSheet({required this.session, required this.onChoose});

  final MockSession session;
  final void Function(String questionId, String optionId) onChoose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final qs = session.questions;
    return ListView.separated(
      key: const Key('omr-sheet'),
      padding: const EdgeInsets.all(16),
      itemCount: qs.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, i) {
        final q = qs[i];
        final chosen = session.answerOf(q.id).chosen;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${i + 1}. ${q.stem}', style: text.bodyLarge),
            const SizedBox(height: 8),
            for (var o = 0; o < q.options.length; o++)
              _Bubble(
                key: Key('omr-${q.id}-${q.options[o].id}'),
                letter: _letter(o),
                text: q.options[o].text,
                selected: chosen.contains(q.options[o].id),
                semanticLabel:
                    'Question ${i + 1}, option ${_letter(o)}: ${q.options[o].text}',
                onTap: () => onChoose(q.id, q.options[o].id),
              ),
          ],
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HmSizes.minTapTarget),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? scheme.onSurface : null,
                  border: Border.all(color: scheme.onSurface, width: 2),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? scheme.surface : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CBT: one question per screen, options, Mark for review, Previous / Next, and the question palette.
class _CbtView extends StatelessWidget {
  const _CbtView({
    required this.session,
    required this.index,
    required this.onChoose,
    required this.onToggleMark,
    required this.onGoTo,
  });

  final MockSession session;
  final int index;
  final void Function(String questionId, String optionId) onChoose;
  final ValueChanged<String> onToggleMark;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = session.questions.length;
    if (total == 0) return const SizedBox.shrink();
    final i = index.clamp(0, total - 1);
    final q = session.questions[i];
    final answer = session.answerOf(q.id);
    final section = session.sectionNameOf(q.id);
    return ListView(
      key: const Key('cbt-view'),
      padding: const EdgeInsets.all(16),
      children: [
        if (section != null) Text(section, style: text.labelLarge),
        Semantics(
          header: true,
          child: Text('Question ${i + 1} of $total', style: text.titleSmall),
        ),
        const SizedBox(height: 8),
        Text(q.stem, style: text.bodyLarge),
        const SizedBox(height: 12),
        for (var o = 0; o < q.options.length; o++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              button: true,
              inMutuallyExclusiveGroup: true,
              checked: answer.chosen.contains(q.options[o].id),
              label: 'Option ${_letter(o)}: ${q.options[o].text}',
              excludeSemantics: true,
              onTap: () => onChoose(q.id, q.options[o].id),
              child: Material(
                color: answer.chosen.contains(q.options[o].id)
                    ? scheme.secondaryContainer
                    : scheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: answer.chosen.contains(q.options[o].id)
                        ? scheme.secondary
                        : scheme.outlineVariant,
                    width: answer.chosen.contains(q.options[o].id) ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  key: Key('cbt-option-${q.options[o].id}'),
                  onTap: () => onChoose(q.id, q.options[o].id),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: HmSizes.minTapTarget,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            answer.chosen.contains(q.options[o].id)
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('${_letter(o)}. ', style: text.titleSmall),
                          Expanded(child: Text(q.options[o].text)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Semantics(
          toggled: answer.marked,
          label: 'Mark question ${i + 1} for review',
          excludeSemantics: true,
          onTap: () => onToggleMark(q.id),
          child: CheckboxListTile(
            key: const Key('cbt-mark'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: answer.marked,
            onChanged: (_) => onToggleMark(q.id),
            title: const Text('Mark for review'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: HmSecondaryButton(
                key: const Key('cbt-previous'),
                label: 'Previous',
                semanticLabel: 'Previous question',
                onPressed: i > 0 ? () => onGoTo(i - 1) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: HmSecondaryButton(
                key: const Key('cbt-next'),
                label: 'Next',
                semanticLabel: 'Next question',
                onPressed: i < total - 1 ? () => onGoTo(i + 1) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('All questions', style: text.titleSmall),
        const SizedBox(height: 4),
        const _PaletteKey(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var n = 0; n < total; n++)
              _PaletteCell(
                key: Key('palette-$n'),
                number: n + 1,
                state: session.paletteOf(session.questions[n].id),
                current: n == i,
                onTap: () => onGoTo(n),
              ),
          ],
        ),
      ],
    );
  }
}

/// Palette states differ by shape (square / circle, outline / filled), not colour alone (§10.9).
class _PaletteCell extends StatelessWidget {
  const _PaletteCell({
    super.key,
    required this.number,
    required this.state,
    required this.current,
    required this.onTap,
  });

  final int number;
  final PaletteState state;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled =
        state == PaletteState.answered ||
        state == PaletteState.answeredAndMarked;
    final circle =
        state == PaletteState.marked || state == PaletteState.answeredAndMarked;
    return Semantics(
      button: true,
      selected: current,
      label: 'Question $number, ${paletteStateName(state)}. Go to question',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: HmSizes.minTapTarget,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: circle ? null : BorderRadius.circular(4),
                color: filled ? scheme.secondary : null,
                border: Border.all(
                  color: current ? scheme.primary : scheme.outline,
                  width: current ? 3 : 1.5,
                ),
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  color: filled ? scheme.onSecondary : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteKey extends StatelessWidget {
  const _PaletteKey();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Text(
      'Square: not marked · Circle: marked for review · Filled: answered',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}

/// Asks before submitting (INT-002-S10). Returns true to submit.
Future<bool> confirmSubmit(BuildContext context, MockSession session) async {
  // No transition: the Exam Hall has no animations (§10.6).
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    transitionDuration: Duration.zero,
    pageBuilder: (context, _, _) => AlertDialog(
      title: const Text('Submit this mock?'),
      content: Text(
        'Answered: ${session.answeredCount}. '
        'Not answered: ${session.unansweredCount}. '
        'Marked for review: ${session.markedCount}.\n'
        'You cannot change answers after you submit.',
      ),
      actions: [
        TextButton(
          key: const Key('submit-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          child: const Text('Keep going'),
        ),
        FilledButton(
          key: const Key('submit-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
          child: const Text('Submit'),
        ),
      ],
    ),
  );
  return result ?? false;
}
