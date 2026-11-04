import 'package:flutter/material.dart';

import '../tokens.dart';

/// Colour role of a chunky button.
enum HmButtonTone { primary, secondary, gold, danger }

/// Marks a calm study area (the Exam Hall, §10.6): hm_design widgets inside render flat, with no
/// 3D press, no shine, no celebration.
class HmPlain extends InheritedWidget {
  const HmPlain({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HmPlain>() != null;

  @override
  bool updateShouldNotify(HmPlain old) => false;
}

/// A chunky, 3D-press button (BOLT-0021): a solid darker bottom edge that the face sinks into when
/// pressed. At least 48 dp tall (§10.9); labels wrap at 200% text; screen readers hear [label]
/// (or [semanticLabel]) as a button. Inside [HmPlain] it renders flat.
class HmChunkyButton extends StatefulWidget {
  const HmChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = HmButtonTone.primary,
    this.semanticLabel,
    this.busy = false,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final HmButtonTone tone;
  final String? semanticLabel;

  /// Shows a small spinner and ignores taps while work is running.
  final bool busy;
  final bool expand;
  final IconData? icon;

  bool get enabled => onPressed != null && !busy;

  @override
  State<HmChunkyButton> createState() => _HmChunkyButtonState();
}

class _HmChunkyButtonState extends State<HmChunkyButton> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final plain = HmPlain.of(context);
    final enabled = widget.enabled;
    final (face, shade, ink, border) = switch (widget.tone) {
      _ when !enabled => (p.disabled, p.disabled, p.onDisabled, p.outline),
      HmButtonTone.primary => (p.primary, p.primaryShade, p.onPrimary, null),
      HmButtonTone.gold => (p.gold, p.goldShade, p.onGold, null),
      HmButtonTone.danger => (p.errorTint, p.error, p.onErrorTint, p.error),
      HmButtonTone.secondary => (
        p.surface,
        p.outline,
        p.primaryText,
        p.outline,
      ),
    };
    final depth = plain || !enabled ? 0.0 : HmElevation.buttonDepth;
    final sink = _pressed ? depth : 0.0;
    final radius = BorderRadius.circular(HmRadius.md);
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: ink, fontWeight: FontWeight.w900);

    final content = widget.busy
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: ink),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: ink, size: 22),
                const SizedBox(width: HmSpace.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
            ],
          );

    final faceBox = AnimatedContainer(
      duration: HmMotion.press,
      curve: HmMotion.standard,
      constraints: const BoxConstraints(minHeight: HmSizes.buttonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: HmSpace.xl,
        vertical: HmSpace.md,
      ),
      decoration: BoxDecoration(
        color: face,
        borderRadius: radius,
        border: Border.all(
          color: _focused ? p.text : (border ?? face),
          width: _focused ? 3 : 2,
        ),
      ),
      child: Center(
        heightFactor: 1,
        widthFactor: widget.expand ? null : 1,
        child: content,
      ),
    );

    final body = Stack(
      children: [
        if (depth > 0)
          Positioned.fill(
            top: depth,
            child: DecoratedBox(
              decoration: BoxDecoration(color: shade, borderRadius: radius),
            ),
          ),
        AnimatedPadding(
          duration: HmMotion.press,
          curve: HmMotion.standard,
          padding: EdgeInsets.only(top: sink, bottom: depth - sink),
          child: faceBox,
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      onTap: enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: () => _setPressed(false),
          onTap: enabled ? widget.onPressed : null,
          child: SizedBox(
            width: widget.expand ? double.infinity : null,
            child: body,
          ),
        ),
      ),
    );
  }
}

/// The one main action on a screen (§10.1). Labels are verbs (§10.2): "Start", "Continue", "Send code".
class HmPrimaryButton extends StatelessWidget {
  const HmPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.busy = false,
    this.expand = true,
    this.icon,
    this.tone = HmButtonTone.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool busy;
  final bool expand;
  final IconData? icon;
  final HmButtonTone tone;

  @override
  Widget build(BuildContext context) => HmChunkyButton(
    label: label,
    onPressed: onPressed,
    semanticLabel: semanticLabel,
    busy: busy,
    expand: expand,
    icon: icon,
    tone: tone,
  );
}

/// A secondary action ("Not now", "Share", "Try again"): a white/surface chunky button.
class HmSecondaryButton extends StatelessWidget {
  const HmSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => HmChunkyButton(
    label: label,
    onPressed: onPressed,
    semanticLabel: semanticLabel,
    expand: expand,
    icon: icon,
    tone: HmButtonTone.secondary,
  );
}

/// A quiet text action with a 48 dp target ("Skip", "See all").
class HmGhostButton extends StatelessWidget {
  const HmGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final style = TextButton.styleFrom(
      foregroundColor: p.primaryText,
      minimumSize: const Size(HmSizes.minTapTarget, HmSizes.minTapTarget),
      textStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
    );
    final text = Text(label, textAlign: TextAlign.center);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      onTap: onPressed,
      excludeSemantics: true,
      child: icon == null
          ? TextButton(onPressed: onPressed, style: style, child: text)
          : TextButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon),
              label: text,
            ),
    );
  }
}
