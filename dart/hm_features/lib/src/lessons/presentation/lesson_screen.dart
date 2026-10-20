import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../study_map/application/study_providers.dart';
import '../application/listen_controller.dart';
import '../domain/lesson_view.dart';
import '../domain/markdown.dart';

/// A clean reading view with Listen, the textbook reference and the source (§10.6). Calm, no game styling.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonProvider(topicId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lesson.when(
        loading: () => const HmLoadingView(label: 'Loading the lesson'),
        error: (e, _) => HmErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(lessonProvider(topicId)),
        ),
        data: (l) => LessonBody(lesson: l),
      ),
    );
  }
}

class LessonBody extends ConsumerWidget {
  const LessonBody({super.key, required this.lesson});

  final LessonView lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final status = ref.watch(listenControllerProvider);
    final listen = ref.read(listenControllerProvider.notifier);
    final opener = ref.read(linkOpenerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Semantics(
          header: true,
          child: Text(lesson.title, style: text.headlineSmall),
        ),
        const SizedBox(height: 4),
        Text('${lesson.readingMinutes} min read', style: text.bodySmall),
        const SizedBox(height: 12),
        if (status == ListenStatus.speaking)
          HmSecondaryButton(
            key: const Key('lesson-stop'),
            label: 'Stop',
            icon: Icons.stop,
            onPressed: listen.stop,
          )
        else
          HmSecondaryButton(
            key: const Key('lesson-listen'),
            label: 'Listen',
            icon: Icons.volume_up_outlined,
            onPressed: () => listen.listen(lesson.listenText),
          ),
        if (status == ListenStatus.unavailable)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Listen is not available on this phone.'),
          ),
        const SizedBox(height: 16),
        MarkdownBlocks(blocks: lesson.blocks),
        if (lesson.textbookRefs.isNotEmpty) ...[
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text('Textbook', style: text.titleMedium),
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
        const SizedBox(height: 16),
        Semantics(header: true, child: Text('Source', style: text.titleMedium)),
        const SizedBox(height: 4),
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
                  Text('•  ', style: text.bodyLarge),
                  Expanded(child: Text.rich(spans(b, text.bodyLarge))),
                ],
              ),
            },
          ),
      ],
    );
  }
}
