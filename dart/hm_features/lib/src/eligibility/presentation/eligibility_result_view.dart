import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/eligibility_view.dart';

/// "You're eligible for N exams", the top 5 highlighted, each with its official link, and the line
/// "Always confirm with the official notification." (§17.1 step 3, §10.6).
class EligibilityResultView extends StatelessWidget {
  const EligibilityResultView({
    super.key,
    required this.result,
    required this.onOpenLink,
    this.onShare,
    this.onContinue,
    this.onChangeAnswers,
  });

  final EligibilityView result;
  final ValueChanged<ExamFit> onOpenLink;
  final VoidCallback? onShare;
  final VoidCallback? onContinue;
  final VoidCallback? onChangeAnswers;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.xl,
        HmSpace.sm,
        HmSpace.xl,
        HmSpace.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: HmIllustration(kind: HmIllustrationKind.trophy, size: 104),
          ),
          const SizedBox(height: HmSpace.lg),
          Semantics(
            header: true,
            child: Text(
              result.headline,
              key: const Key('eligibility-headline'),
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          // "Always confirm with the official notification." appears exactly once: the server's
          // disclaimer already carries it; otherwise the line is shown above the disclaimer.
          if (result.disclaimer.contains(officialConfirmLine))
            Text(
              result.disclaimer,
              key: const Key('eligibility-confirm-line'),
              style: text.bodyMedium?.copyWith(color: scheme.secondary),
            )
          else ...[
            Text(
              officialConfirmLine,
              key: const Key('eligibility-confirm-line'),
              style: text.bodyMedium?.copyWith(color: scheme.secondary),
            ),
            if (result.disclaimer.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(result.disclaimer, style: text.bodySmall),
            ],
          ],
          const SizedBox(height: 16),
          if (result.eligible.isEmpty)
            Text(
              'No exam in our list matches these answers yet. '
              'We are adding more exams. If an answer is wrong, tap Change answers.',
              key: const Key('eligibility-empty'),
              style: text.bodyLarge,
            )
          else ...[
            Text('Your top ${result.top.length}', style: text.titleMedium),
            const SizedBox(height: 8),
            for (final exam in result.top) ...[
              _ExamCard(exam: exam, highlighted: true, onOpenLink: onOpenLink),
              const SizedBox(height: 8),
            ],
            if (result.more.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('More exams you can write', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final exam in result.more) ...[
                _ExamCard(
                  exam: exam,
                  highlighted: false,
                  onOpenLink: onOpenLink,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
          const SizedBox(height: 16),
          if (onContinue != null && result.eligible.isNotEmpty)
            HmPrimaryButton(label: 'Continue', onPressed: onContinue),
          if (onShare != null && result.eligible.isNotEmpty) ...[
            const SizedBox(height: 8),
            HmSecondaryButton(
              label: 'Share',
              icon: Icons.share_outlined,
              semanticLabel: 'Share my result',
              onPressed: onShare,
            ),
          ],
          if (onChangeAnswers != null) ...[
            const SizedBox(height: 8),
            HmSecondaryButton(
              label: 'Change answers',
              onPressed: onChangeAnswers,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.highlighted,
    required this.onOpenLink,
  });

  final ExamFit exam;
  final bool highlighted;
  final ValueChanged<ExamFit> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HmCard(
      key: Key('exam-${exam.code}'),
      highlighted: highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exam.name, style: text.titleMedium),
          Text(exam.conductingBody, style: text.bodySmall),
          for (final reason in exam.reasons.take(2))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(reason, style: text.bodyMedium),
            ),
          const SizedBox(height: 4),
          Semantics(
            link: true,
            label: 'Open the official notification for ${exam.name}',
            excludeSemantics: true,
            onTap: () => onOpenLink(exam),
            child: TextButton.icon(
              key: Key('official-${exam.code}'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
              ),
              onPressed: () => onOpenLink(exam),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Official notification'),
            ),
          ),
        ],
      ),
    );
  }
}
