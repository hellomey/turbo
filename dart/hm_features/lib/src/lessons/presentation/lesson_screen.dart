import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../study_map/application/study_providers.dart';
import '../application/listen_controller.dart';
import '../domain/lesson_view.dart';
import '../domain/markdown.dart';

/// A clean reading view with Listen, the textbook reference and the source (§10.6). Calm, no game styling.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.topicId, this.onFinished});

  final String topicId;

  /// "I've finished" → the 3-question Lit check (§5.1, INT-002-S01, BOLT-0017).
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonProvider(topicId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lesson.when(
        loading: () => const HmSkeletonList(label: 'Loading the lesson'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(lessonProvider(topicId)),
        ),
        data: (l) => LessonBody(lesson: l, onFinished: onFinished),
      ),
    );
  }
}

class LessonBody extends ConsumerWidget {
  const LessonBody({super.key, required this.lesson, this.onFinished});

  final LessonView lesson;
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final status = ref.watch(listenControllerProvider);
    final listen = ref.read(listenControllerProvider.notifier);
    final opener = ref.read(linkOpenerProvider);
    final p = context.hm;
    // Lesson reader (BOLT-0110): a yellow header block (the hero) with the lamp that flew in from
    // the Study Map, then plain, readable text. Reading screens stay calm: no tiles mid-text.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.lg,
        HmSpace.xxl,
      ),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: status == ListenStatus.speaking
              ? HmChunkyButton(
                  key: const Key('lesson-stop'),
                  label: 'Stop',
                  icon: Icons.stop_rounded,
                  expand: false,
                  tone: HmButtonTone.secondary,
                  onPressed: listen.stop,
                )
              : HmChunkyButton(
                  key: const Key('lesson-listen'),
                  label: 'Listen',
                  icon: Icons.volume_up_rounded,
                  expand: false,
                  tone: HmButtonTone.secondary,
                  onPressed: () => listen.listen(lesson.listenText),
                ),
        ),
        if (status == ListenStatus.unavailable)
          Padding(
            padding: const EdgeInsets.only(top: HmSpace.sm),
            child: Text(
              'Listen is not available on this phone.',
              textAlign: TextAlign.right,
              style: text.bodyMedium?.copyWith(color: p.textMuted),
            ),
          ),
        const SizedBox(height: HmSpace.md),
        // Shared element with the lamp on the Study Map.
        Center(
          child: Hero(
            tag: 'lamp-${lesson.topicId}',
            child: const HmMey(HmPic.meyReading, size: 170),
          ),
        ),
        const SizedBox(height: HmSpace.lg),
        Semantics(
          header: true,
          child: Text(
            lesson.title,
            style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: HmSpace.sm),
        Text(
          '${lesson.readingMinutes} min read',
          style: text.titleMedium?.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: HmSpace.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HmSpace.xs),
          child: MarkdownBlocks(blocks: lesson.blocks),
        ),
        if (lesson.textbookRefs.isNotEmpty) ...[
          const SizedBox(height: HmSpace.xl),
          Semantics(
            header: true,
            child: Text('Textbook', style: text.titleLarge),
          ),
          for (final ref in lesson.textbookRefs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(ref.line),
              trailing: ref.url == null
                  ? null
                  : const Icon(Icons.open_in_new, semanticLabel: 'Open'),
              onTap: ref.url == null ? null : () => opener.open(ref.url!),
            ),
        ],
        const SizedBox(height: HmSpace.xl),
        HmCard(
          color: p.surface2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text('Source', style: text.titleMedium),
              ),
              const SizedBox(height: HmSpace.xs),
              Text(lesson.citation, style: text.bodyMedium),
              if (lesson.citationUrl != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => opener.open(lesson.citationUrl!),
                    child: const Text('Open source'),
                  ),
                ),
            ],
          ),
        ),
        if (onFinished != null) ...[
          const SizedBox(height: HmSpace.xl),
          HmPrimaryButton(
            key: const Key('lesson-done'),
            label: "I've finished",
            onPressed: onFinished,
          ),
        ],
      ],
    );
  }
}

/// Renders [MdBlock]s with the theme's text styles.
class MarkdownBlocks extends StatelessWidget {
  const MarkdownBlocks({super.key, required this.blocks});

  final List<MdBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    TextSpan spans(MdBlock b, TextStyle? style) => TextSpan(
      style: style,
      children: [
        for (final s in b.spans)
          TextSpan(
            text: s.text,
            style: s.bold ? const TextStyle(fontWeight: FontWeight.w700) : null,
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final b in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: switch (b) {
              MdHeading() => Semantics(
                header: true,
                child: Text.rich(
                  spans(b, b.level <= 2 ? text.titleLarge : text.titleMedium),
                ),
              ),
              MdParagraph() => Text.rich(spans(b, text.bodyLarge)),
              MdBullet() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A small red Bauhaus square as the bullet.
                  ExcludeSemantics(
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 9, right: HmSpace.md),
                      decoration: BoxDecoration(
                        color: context.hm.primary,
                        border: Border.all(
                          color: context.hm.outline,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Text.rich(spans(b, text.bodyLarge))),
                ],
              ),
            },
          ),
      ],
    );
  }
}
