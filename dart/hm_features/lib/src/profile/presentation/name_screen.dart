import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/ports.dart';
import '../application/profile_controller.dart';

const _avatarKey = 'hm-avatar';
const _askedKey = 'hm-name-asked';

/// The avatar picked on this device (1-12), or null for the initial. Kept on the device only: it is a picture
/// choice, not personal data, and needs no server field.
class AvatarController extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final v = await ref.read(secureKeyValueProvider).read(_avatarKey);
    final id = int.tryParse(v ?? '');
    return HmAvatars.valid(id) ? id : null;
  }

  Future<void> pick(int id) async {
    state = AsyncData(id);
    await ref.read(secureKeyValueProvider).write(_avatarKey, '$id');
  }
}

final avatarProvider = AsyncNotifierProvider<AvatarController, int?>(
  AvatarController.new,
);

/// Allowed by the API: 3-24 letters, digits, spaces, dots or underscores.
final _nameRule = RegExp(r'^[A-Za-z0-9 ._]{3,24}$');

/// "What should we call you?" (last onboarding step): a display name and an avatar. The name is what the leaderboard
/// shows if you join it; it never has to be your real name.
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final _name = TextEditingController(
    text: ref.read(meProvider).value?.nickname ?? '',
  );
  int? _avatar;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _avatar = ref.read(avatarProvider).value ?? 1;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (!_nameRule.hasMatch(name)) {
      setState(
        () => _error =
            'Use 3 to 24 English letters or numbers, like Priya or Arun K.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(meProvider.notifier).setNickname(name);
      await ref.read(avatarProvider.notifier).pick(_avatar ?? 1);
      await ref.read(secureKeyValueProvider).write(_askedKey, '1');
      if (mounted) Navigator.of(context).maybePop();
    } on Object catch (e) {
      if (mounted) setState(() => _error = messageOf(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _skip() async {
    await ref.read(secureKeyValueProvider).write(_askedKey, '1');
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.hm;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(HmSpace.lg),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('name-skip'),
                    onPressed: _skip,
                    child: const Text('Later'),
                  ),
                ),
                Center(
                  child: HmAvatar(id: _avatar, name: _name.text, size: 112),
                ),
                const SizedBox(height: HmSpace.lg),
                Text(
                  'What should we call you?',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: HmSpace.xs),
                Text(
                  'Mey will greet you by this name. It is also the name the leaderboard shows if you join it.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: p.textMuted),
                ),
                const SizedBox(height: HmSpace.lg),
                TextField(
                  key: const Key('name-field'),
                  controller: _name,
                  maxLength: 24,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    errorText: _error,
                    filled: true,
                    fillColor: p.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(HmRadius.lg),
                    ),
                  ),
                ),
                const SizedBox(height: HmSpace.md),
                Text(
                  'Pick an avatar',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: HmSpace.sm),
                Wrap(
                  spacing: HmSpace.sm,
                  runSpacing: HmSpace.sm,
                  children: [
                    for (var i = 1; i <= HmAvatars.count; i++)
                      Semantics(
                        button: true,
                        selected: _avatar == i,
                        label: 'Avatar $i',
                        child: GestureDetector(
                          key: Key('avatar-$i'),
                          onTap: () => setState(() => _avatar = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _avatar == i
                                    ? p.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: HmAvatar(id: i, size: 56, ring: false),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: HmSpace.xl),
                HmChunkyButton(
                  key: const Key('name-save'),
                  label: 'Continue',
                  expand: true,
                  busy: _busy,
                  onPressed: _busy ? null : _save,
                ),
                const SizedBox(height: HmSpace.sm),
                Text(
                  'Avatars: DiceBear "Lorelei" by Lisa Wischofsky (CC0).',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [NameScreen] once after onboarding, when the account has no name yet. "Later" stops it asking again on
/// this device; the name can still be set from Profile.
class NamePrompt extends ConsumerStatefulWidget {
  const NamePrompt({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NamePrompt> createState() => _NamePromptState();
}

class _NamePromptState extends ConsumerState<NamePrompt> {
  bool _checked = false;

  Future<void> _check(MeInfo me) async {
    _checked = true;
    if ((me.nickname ?? '').trim().isNotEmpty) return;
    final asked = await ref.read(secureKeyValueProvider).read(_askedKey);
    if (asked != null || !mounted) return;
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const NameScreen(),
          fullscreenDialog: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider).value;
    if (me != null && !_checked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_check(me));
      });
    }
    return widget.child;
  }
}
