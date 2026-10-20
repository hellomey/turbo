import 'package:flutter/foundation.dart';

/// A tiny markdown model for lessons: headings, paragraphs, bullets, and **bold** inline.
/// Enough for Phase 1 lesson bodies; anything else is shown as plain text.
sealed class MdBlock {
  const MdBlock(this.spans);
  final List<MdSpan> spans;

  String get text => spans.map((s) => s.text).join();
}

class MdHeading extends MdBlock {
  const MdHeading(this.level, super.spans);
  final int level;
}

class MdParagraph extends MdBlock {
  const MdParagraph(super.spans);
}

class MdBullet extends MdBlock {
  const MdBullet(super.spans);
}

@immutable
class MdSpan {
  const MdSpan(this.text, {this.bold = false});
  final String text;
  final bool bold;

  @override
  bool operator ==(Object other) =>
      other is MdSpan && other.text == text && other.bold == bold;

  @override
  int get hashCode => Object.hash(text, bold);

  @override
  String toString() => bold ? '**$text**' : text;
}

final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
final _bullet = RegExp(r'^\s*(?:[-*+]|\d+[.)])\s+(.*)$');

List<MdBlock> parseMarkdown(String source) {
  final blocks = <MdBlock>[];
  final paragraph = <String>[];

  void flush() {
    if (paragraph.isEmpty) return;
    blocks.add(MdParagraph(parseInline(paragraph.join(' '))));
    paragraph.clear();
  }

  for (final raw in source.replaceAll('\r\n', '\n').split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      flush();
      continue;
    }
    final h = _heading.firstMatch(line);
    if (h != null) {
      flush();
      blocks.add(MdHeading(h.group(1)!.length, parseInline(h.group(2)!)));
      continue;
    }
    final b = _bullet.firstMatch(line);
    if (b != null) {
      flush();
      blocks.add(MdBullet(parseInline(b.group(1)!)));
      continue;
    }
    paragraph.add(line.trim());
  }
  flush();
  return blocks;
}

/// Splits `**bold**` (or `__bold__`) runs; single `*`/`_` emphasis markers are dropped.
List<MdSpan> parseInline(String text) {
  final spans = <MdSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|__(.+?)__');
  var last = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > last) {
      spans.add(MdSpan(_clean(text.substring(last, m.start))));
    }
    spans.add(MdSpan(_clean(m.group(1) ?? m.group(2)!), bold: true));
    last = m.end;
  }
  if (last < text.length) spans.add(MdSpan(_clean(text.substring(last))));
  return spans.where((s) => s.text.isNotEmpty).toList();
}

String _clean(String s) => s
    .replaceAllMapped(RegExp(r'(?<!\w)[*_](\S.*?)[*_](?!\w)'), (m) => m[1]!)
    .replaceAll('`', '');

/// The blocks as plain sentences (for Listen Mode).
String plainText(List<MdBlock> blocks) => blocks
    .map(
      (b) => switch (b) {
        MdHeading() => '${b.text}.',
        MdBullet() => b.text,
        MdParagraph() => b.text,
      },
    )
    .join('\n');
