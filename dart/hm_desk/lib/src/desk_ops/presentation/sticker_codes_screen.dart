// Stall sticker check (CLAUDE.md section 8): a visitor shows the code the app gave them; staff redeem it once.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

/// Roles that may redeem sticker codes. The server checks again on every call.
const stickerCodeRoles = {'OPS', 'ADMIN', 'SUPPORT_AGENT'};

/// Redeems one code. Overridden in tests.
final stickerCodeRedeemerProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  final api = ref.watch(hmApiProvider);
  return (code) async => api.deskRedeemStickerCode(code);
});

/// Result of the last check: `null` before any check.
typedef StickerCheck = ({bool give, String message});

/// Plain reason for a refused code.
String stickerRefusal(HmApiException e) => switch (e.code) {
  'STICKER_CODE_NOT_FOUND' =>
    'No sticker. This code does not exist. Check the letters and try again.',
  'STICKER_CODE_ALREADY_REDEEMED' =>
    'No sticker. This code was already used for a sticker.',
  _ => 'No sticker yet. ${e.message}',
};

class StickerCodesScreen extends ConsumerStatefulWidget {
  const StickerCodesScreen({super.key});

  @override
  ConsumerState<StickerCodesScreen> createState() => _StickerCodesScreenState();
}

class _StickerCodesScreenState extends ConsumerState<StickerCodesScreen> {
  final _code = TextEditingController();
  StickerCheck? _result;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final code = _code.text.trim();
    if (code.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _result = null;
    });
    StickerCheck result;
    try {
      await ref.read(stickerCodeRedeemerProvider)(code);
      result = (give: true, message: 'Give a sticker');
    } on HmApiException catch (e) {
      result = (give: false, message: stickerRefusal(e));
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
      if (result.give) _code.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final result = _result;
    final hm = context.hm;
    return Scaffold(
      appBar: AppBar(title: const Text('Sticker codes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Type the code from the visitor\'s phone, for example HM-7KQX. '
            'Each code gets one sticker.',
            style: text.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('sticker-code-input'),
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Sticker code',
              hintText: 'HM-7KQX',
            ),
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('sticker-code-redeem'),
            onPressed: _busy ? null : _check,
            child: Text(_busy ? 'Checking...' : 'Check and redeem'),
          ),
          const SizedBox(height: 24),
          if (result != null)
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('sticker-code-result'),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: result.give ? hm.successTint : hm.errorTint,
                  border: Border.all(
                    color: result.give ? hm.success : hm.error,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      result.give ? Icons.check_circle : Icons.cancel,
                      color: result.give ? hm.success : hm.error,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        result.message,
                        style:
                            (result.give
                                    ? text.headlineMedium
                                    : text.titleMedium)
                                ?.copyWith(
                                  color: result.give
                                      ? hm.onSuccessTint
                                      : hm.onErrorTint,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
