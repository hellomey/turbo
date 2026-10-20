import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'buttons.dart';

/// Keeps only digits and at most [length] of them, so a pasted "Your code is 482 913." becomes "482913".
class DigitsOnlyFormatter extends TextInputFormatter {
  const DigitsOnlyFormatter(this.length);

  final int length;

  static String clean(String input, int length) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length > length ? digits.substring(0, length) : digits;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = clean(newValue.text, length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// The 6-digit code field (§17.1 step 7, §38): type or paste; "Didn't get it? Check spam";
/// "Resend code" unlocks after [resendAfter] (60 s by default).
class HmCodeEntry extends StatefulWidget {
  const HmCodeEntry({
    super.key,
    required this.onSubmit,
    this.onResend,
    this.resendAfter = const Duration(seconds: 60),
    this.length = 6,
    this.errorText,
    this.busy = false,
    this.label = '6-digit code',
    this.submitLabel = 'Continue',
    this.hint = "Didn't get it? Check spam.",
  });

  final ValueChanged<String> onSubmit;

  /// Sends a new code. Null hides the resend button (e.g. authenticator codes).
  final Future<void> Function()? onResend;
  final Duration resendAfter;
  final int length;
  final String? errorText;
  final bool busy;
  final String label;
  final String submitLabel;
  final String? hint;

  @override
  State<HmCodeEntry> createState() => _HmCodeEntryState();
}

class _HmCodeEntryState extends State<HmCodeEntry> {
  final _controller = TextEditingController();
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = widget.onResend == null ? 0 : widget.resendAfter.inSeconds;
    if (_secondsLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  void _onChanged() {
    setState(() {});
    if (_controller.text.length == widget.length && !widget.busy) {
      widget.onSubmit(_controller.text);
    }
  }

  Future<void> _resend() async {
    final resend = widget.onResend;
    if (resend == null) return;
    _controller.clear();
    await resend();
    if (mounted) setState(_startCountdown);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complete = _controller.text.length == widget.length;
    final canResend = _secondsLeft <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          textField: true,
          label: widget.label,
          child: TextField(
            key: const Key('hm-code-field'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [DigitsOnlyFormatter(widget.length)],
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(letterSpacing: 8),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: widget.errorText,
              errorMaxLines: 3,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: 8),
          Text(widget.hint!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        HmPrimaryButton(
          label: widget.submitLabel,
          busy: widget.busy,
          onPressed: complete ? () => widget.onSubmit(_controller.text) : null,
        ),
        if (widget.onResend != null) ...[
          const SizedBox(height: 8),
          HmSecondaryButton(
            key: const Key('hm-code-resend'),
            label: canResend ? 'Resend code' : 'Resend code in $_secondsLeft s',
            onPressed: canResend && !widget.busy ? _resend : null,
          ),
        ],
      ],
    );
  }
}
