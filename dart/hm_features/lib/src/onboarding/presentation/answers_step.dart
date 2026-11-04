import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'onboarding_page.dart';

/// Step 2: qualification, community, Tamil medium, special categories. One-tap choices, no typing
/// (the only text field is the optional degree subject, §17.1).
class AnswersStep extends ConsumerWidget {
  const AnswersStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    final draft = state.draft;
    final text = Theme.of(context).textTheme;

    Widget section(String title, Widget child, {String? help}) => Padding(
      padding: const EdgeInsets.only(bottom: HmSpace.lg),
      child: HmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: text.titleMedium),
            ),
            if (help != null) ...[
              const SizedBox(height: HmSpace.xs),
              Text(
                help,
                style: text.bodySmall?.copyWith(color: context.hm.textMuted),
              ),
            ],
            const SizedBox(height: HmSpace.md),
            child,
          ],
        ),
      ),
    );

    return OnboardingPage(
      title: 'About your studies',
      subtitle: 'Tap one answer for each question.',
      children: [
        section(
          'Highest qualification',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in QualificationChoice.values)
                ChoiceChip(
                  key: Key('qualification-${q.wire}'),
                  label: Text(q.label),
                  selected: draft.qualification == q,
                  onSelected: (_) => c.setQualification(q),
                ),
            ],
          ),
          help: 'The highest one you have finished.',
        ),
        if (draft.qualification?.asksDegreeSubject ?? false)
          section(
            'Degree subject (optional)',
            TextFormField(
              key: const Key('degree-subject'),
              initialValue: draft.degreeSubject,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'For example: Mathematics',
              ),
              onChanged: c.setDegreeSubject,
            ),
            help: 'Some exams need a degree in a certain subject.',
          ),
        section(
          'Community',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cm in CommunityChoice.values)
                Tooltip(
                  message: cm.meaning,
                  child: ChoiceChip(
                    key: Key('community-${cm.wire}'),
                    label: Text(cm.label, semanticsLabel: cm.meaning),
                    selected: draft.community == cm,
                    onSelected: (_) => c.setCommunity(cm),
                  ),
                ),
            ],
          ),
          help: 'Used only for age limits and reserved seats.',
        ),
        section(
          'Did you study in Tamil medium (PSTM)?',
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                key: const Key('pstm-yes'),
                label: const Text('Yes'),
                selected: draft.pstm == true,
                onSelected: (_) => c.setPstm(true),
              ),
              ChoiceChip(
                key: const Key('pstm-no'),
                label: const Text('No'),
                selected: draft.pstm == false,
                onSelected: (_) => c.setPstm(false),
              ),
            ],
          ),
          help: 'PSTM means Person Studied in Tamil Medium.',
        ),
        section(
          'Special categories (optional)',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in SpecialCategoryChoice.values)
                FilterChip(
                  key: Key('special-${s.wire}'),
                  label: Text(s.label),
                  selected: draft.specialCategories.contains(s),
                  onSelected: (_) => c.toggleSpecialCategory(s),
                ),
            ],
          ),
          help:
              'Tap any that apply. We use this only to check age relaxations. You can skip this.',
        ),
        StepError(state.error),
        const SizedBox(height: HmSpace.lg),
        HmPrimaryButton(
          key: const Key('answers-check'),
          label: 'Check my exams',
          busy: state.busy,
          onPressed: draft.isComplete ? c.checkEligibility : null,
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Back', onPressed: c.back),
      ],
    );
  }
}
