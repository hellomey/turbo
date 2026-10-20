import 'package:flutter/foundation.dart';

import 'markdown.dart';

@immutable
class TextbookRefView {
  const TextbookRefView({
    required this.book,
    this.classLevel,
    this.chapter,
    this.pages,
    this.url,
  });

  final String book;
  final int? classLevel;
  final String? chapter;
  final String? pages;
  final String? url;

  /// e.g. "Class 10 Social Science, Chapter 3, pages 41-45".
  String get line {
    final parts = <String>[
      [if (classLevel != null) 'Class $classLevel', book].join(' '),
      if (chapter != null && chapter!.isNotEmpty) 'Chapter $chapter',
      if (pages != null && pages!.isNotEmpty) 'pages $pages',
    ];
    return parts.join(', ');
  }
}

/// A published lesson (contract `Lesson`, §10.6).
@immutable
class LessonView {
  const LessonView({
    required this.id,
    required this.topicId,
    required this.title,
    required this.blocks,
    required this.readingMinutes,
    required this.textbookRefs,
    required this.citation,
    this.citationUrl,
  });

  final String id;
  final String topicId;
  final String title;
  final List<MdBlock> blocks;
  final int readingMinutes;
  final List<TextbookRefView> textbookRefs;
  final String citation;
  final String? citationUrl;

  /// What Listen Mode reads: the title, then the text without markdown symbols.
  String get listenText => '$title.\n${plainText(blocks)}';
}
