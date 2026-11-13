import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'buttons.dart';

/// State of an answer option (§10.6 practice: instant feedback).
enum HmAnswerState { idle, selected, correct, wrong, disabled }

/// A big tappable answer option. Correct and wrong differ by icon (tick / cross) and words for
/// screen readers, not by colour alone (§10.9). Inside [HmPlain] (Exam Hall) it stays flat.
class HmAnswerTile extends StatefulWidget {
  const HmAnswerTile({
    super.key,
    required this.label,
    required this.text,
    this.state = HmAnswerState.idle,
    this.onTap,
    this.textStyle,
    this.semanticLabel,
  });

  /// "A", "B", "C", "D".
  final String label;
  final String text;
  final HmAnswerState state;
  final VoidCallback? onTap;

  /// Optional style for the option text (e.g. the Tamil content font).
  final TextStyle? textStyle;

  /// Overrides the default "Option B: text, wrong" screen-reader label.
  final String? semanticLabel;

  @override
  State<HmAnswerTile> createState() => _HmAnswerTileState();
}

class _HmAnswerTileState extends State<HmAnswerTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final plain = HmPlain.of(context);
    final s = widget.state;
    final (bg, edge, fg) = switch (s) {
      HmAnswerState.correct => (p.successTint, p.success, p.onSuccessTint),
      HmAnswerState.wrong => (p.errorTint, p.error, p.onErrorTint),
      HmAnswerState.selected => (p.surface2, p.primaryText, p.text),
      HmAnswerState.disabled => (p.surface, p.outline, p.textMuted),
      HmAnswerState.idle => (p.surface, p.outline, p.text),
    };
    final tappable = widget.onTap != null && s != HmAnswerState.disabled;
    final depth = plain ? 0.0 : HmElevation.tileDepth;
    final sink = _pressed ? depth : 0.0;
    final mark = switch (s) {
      HmAnswerState.correct => Icons.check_circle_rounded,
      HmAnswerState.wrong => Icons.cancel_rounded,
      _ => null,
    };
    final stateWord = switch (s) {
      HmAnswerState.correct => ', correct',
      HmAnswerState.wrong => ', wrong',
      HmAnswerState.selected => ', selected',
      _ => '',
    };
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: tappable,
      selected: s == HmAnswerState.selected,
      enabled: tappable,
      label:
          widget.semanticLabel ??
          'Option ${widget.label}: ${widget.text}$stateWord',
      onTap: tappable ? widget.onTap : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
        onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: tappable ? widget.onTap : null,
        child: AnimatedContainer(
          duration: HmMotion.press,
          constraints: const BoxConstraints(minHeight: 56),
          margin: EdgeInsets.only(top: sink, bottom: depth - sink),
          padding: const EdgeInsets.symmetric(
            horizontal: HmSpace.md,
            vertical: HmSpace.md,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(HmRadius.md),
            border: Border.all(color: edge, width: 2),
            boxShadow: depth - sink > 0
                ? [BoxShadow(color: edge, offset: Offset(0, depth - sink))]
                : null,
          ),
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(HmRadius.sm),
                  border: Border.all(color: edge, width: 2),
                ),
                child: Text(
                  widget.label,
                  style: text.labelLarge?.copyWith(color: fg),
                ),
              ),
              const SizedBox(width: HmSpace.md),
              Expanded(
                child: Text(
                  widget.text,
                  style: (text.bodyLarge ?? const TextStyle())
                      .merge(widget.textStyle)
                      .copyWith(color: fg),
                ),
              ),
              if (mark != null) ...[
                const SizedBox(width: HmSpace.sm),
                Icon(mark, color: edge, size: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
