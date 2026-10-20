import 'package:flutter/material.dart';

import '../tokens.dart';

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
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Shows a small spinner and ignores taps while work is running.
  final bool busy;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label, textAlign: TextAlign.center);
    final style = FilledButton.styleFrom(
      minimumSize: Size(expand ? double.infinity : 64, HmSizes.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
    return Semantics(
      button: true,
      enabled: onPressed != null && !busy,
      onTap: semanticLabel != null && !busy ? onPressed : null,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: icon == null
          ? FilledButton(
              onPressed: busy ? null : onPressed,
              style: style,
              child: child,
            )
          : FilledButton.icon(
              onPressed: busy ? null : onPressed,
              style: style,
              icon: Icon(icon),
              label: child,
            ),
    );
  }
}

/// A secondary action ("Not now", "Share", "Try again").
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
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: Size(expand ? double.infinity : 64, HmSizes.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
    final text = Text(label, textAlign: TextAlign.center);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: semanticLabel != null ? onPressed : null,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: icon == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: text)
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon),
              label: text,
            ),
    );
  }
}
