import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:hm_design/hm_design.dart';

import '../domain/exam_hall_models.dart';

/// Mock report: score, sections, mistakes (INT-002-S10). Free users see score and sections, and a blurred
/// preview of the full report with "Not now" and no price line (§13 "Proof before payment",
/// D-2026-10-22-19, D-2026-10-22-22).
class ReportBody extends StatelessWidget {
  const ReportBody({
    super.key,
    required this.report,
    required this.onDone,
    this.message,
  });

  final ReportView report;
  final VoidCallback onDone;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text('Your report', style: text.headlineSmall),
        ),
        if (message != null) ...[
          const SizedBox(height: 4),
          Text(message!, style: text.bodyMedium),
        ],
        const SizedBox(height: 16),
        HmCard(
          highlighted: true,
          semanticLabel:
              'Score ${report.scoreDisplay} out of ${report.maxScoreDisplay}. '
              'Correct ${report.correct}, wrong ${report.wrong}, not answered ${report.unanswered}.',
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score', style: text.titleSmall),
                Text(
                  '${report.scoreDisplay} / ${report.maxScoreDisplay}',
                  key: const Key('report-score'),
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct ${report.correct} · Wrong ${report.wrong} · Not answered ${report.unanswered}',
                  style: text.bodyMedium,
                ),
                if (!report.ranked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'This attempt does not count for a rank.',
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (report.sections.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Sections', style: text.titleMedium),
          const SizedBox(height: 8),
          for (final s in report.sections) ...[
            HmCard(
              semanticLabel:
                  '${s.name}: ${s.score} out of ${s.maxScore}. '
                  'Correct ${s.correct}, wrong ${s.wrong}, not answered ${s.unanswered}.',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(child: Text(s.name, style: text.bodyLarge)),
                    Text('${s.score} / ${s.maxScore}', style: text.titleSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 8),
        if (report.fullReportLocked)
          _LockedPreview(onNotNow: onDone)
        else ...[
          Text('Mistakes', style: text.titleMedium),
          const SizedBox(height: 8),
          if (report.mistakes.isEmpty)
            Text('No mistakes in this mock.', style: text.bodyLarge),
          for (var i = 0; i < report.mistakes.length; i++) ...[
            HmCard(
              key: Key('mistake-${report.mistakes[i].questionId}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mistake ${i + 1}', style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(report.mistakes[i].explanation, style: text.bodyMedium),
                  if (report.mistakes[i].whyChosenIsWrong != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Why your answer is wrong: ${report.mistakes[i].whyChosenIsWrong}',
                      style: text.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          HmPrimaryButton(
            key: const Key('report-done'),
            label: 'Back to Exam Hall',
            onPressed: onDone,
          ),
        ],
      ],
    );
  }
}

/// Blurred preview of the full report. Only "Not now": Pro cannot be bought yet (D-2026-10-22-19).
class _LockedPreview extends StatelessWidget {
  const _LockedPreview({required this.onNotNow});

  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Full report', style: text.titleMedium),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: HmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in const [
                      'Mistake 1: why the answer is right, with the source.',
                      'Mistake 2: why your choice was wrong.',
                      'Time spent on each section.',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(line, style: text.bodyMedium),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ExamHallCopy.lockedReport,
          key: const Key('report-locked'),
          style: text.bodyLarge,
        ),
        const SizedBox(height: 12),
        HmSecondaryButton(
          key: const Key('report-not-now'),
          label: ExamHallCopy.notNow,
          semanticLabel: 'Not now. Back to Exam Hall',
          onPressed: onNotNow,
        ),
      ],
    );
  }
}
