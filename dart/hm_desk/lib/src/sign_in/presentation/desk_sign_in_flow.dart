import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_design/hm_design.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../home/presentation/desk_home.dart';
import '../application/desk_sign_in_controller.dart';

/// HeyMey Desk: email code → authenticator (enrol with a QR code the first time) → Desk home (§15).
class DeskSignInFlow extends ConsumerStatefulWidget {
  const DeskSignInFlow({super.key, this.autoStart = true});

  /// Restore a saved session on open.
  final bool autoStart;

  @override
  ConsumerState<DeskSignInFlow> createState() => _DeskSignInFlowState();
}

class _DeskSignInFlowState extends ConsumerState<DeskSignInFlow> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      Future.microtask(() => ref.read(deskSignInProvider.notifier).start());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deskSignInProvider);
    if (state.step == DeskStep.home) return const DeskHome();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: HmCard(
              padding: const EdgeInsets.all(HmSpace.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (switch (state.step) {
                        DeskStep.email => 1,
                        DeskStep.code => 2,
                        DeskStep.enroll || DeskStep.totp => 3,
                        _ => null,
                      }
                      case final n?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HmSpace.md),
                      child: HmStepHeader(step: n, total: 3),
                    ),
                  switch (state.step) {
                    DeskStep.starting => const SizedBox(
                      height: 120,
                      child: HmLoadingView(),
                    ),
                    DeskStep.email => const _EmailStep(),
                    DeskStep.code => const _CodeStep(),
                    DeskStep.enroll => const _EnrollStep(),
                    DeskStep.totp => const _TotpStep(),
                    DeskStep.home => const SizedBox.shrink(),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HmIconBadge(icon: Icons.shield_outlined, size: 36),
            const SizedBox(width: HmSpace.sm),
            Text('HeyMey Desk', style: text.labelLarge),
          ],
        ),
        const SizedBox(height: HmSpace.lg),
        Semantics(header: true, child: Text(title, style: text.headlineSmall)),
        const SizedBox(height: HmSpace.sm),
        Text(
          body,
          style: text.bodyLarge?.copyWith(color: context.hm.textMuted),
        ),
        const SizedBox(height: HmSpace.xl),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message!,
          key: const Key('desk-error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class _EmailStep extends ConsumerStatefulWidget {
  const _EmailStep();

  @override
  ConsumerState<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<_EmailStep> {
  late final _email = TextEditingController(
    text: ref.read(deskSignInProvider).email,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deskSignInProvider);
    final c = ref.read(deskSignInProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          'Sign in',
          'For partners and staff. We will send a 6-digit code to your work email.',
        ),
        TextField(
          key: const Key('desk-email'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => c.requestCode(_email.text),
        ),
        _Error(state.error),
        const SizedBox(height: 16),
        HmPrimaryButton(
          key: const Key('desk-send-code'),
          label: 'Send code',
          busy: state.busy,
          onPressed: () => c.requestCode(_email.text),
        ),
      ],
    );
  }
}

class _CodeStep extends ConsumerWidget {
  const _CodeStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deskSignInProvider);
    final c = ref.read(deskSignInProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          'Enter your email code',
          'We sent a 6-digit code to ${state.email}.',
        ),
        HmCodeEntry(
          onSubmit: c.verifyCode,
          onResend: () => c.requestCode(state.email),
          errorText: state.error,
          busy: state.busy,
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Use another email', onPressed: c.startAgain),
      ],
    );
  }
}

class _EnrollStep extends ConsumerWidget {
  const _EnrollStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deskSignInProvider);
    final c = ref.read(deskSignInProvider.notifier);
    final enrolment = state.enrolment!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          'Set up your authenticator',
          'Scan this QR code with an authenticator app (for example Google Authenticator '
              'or Aegis). Desk always asks for its code.',
        ),
        Center(
          child: Semantics(
            label: 'QR code for your authenticator app',
            image: true,
            excludeSemantics: true,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  key: const Key('desk-qr'),
                  data: enrolment.otpauthUri,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cannot scan? Type this key instead:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                enrolment.secret,
                key: const Key('desk-secret'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
            ),
            IconButton(
              tooltip: 'Copy key',
              icon: const Icon(Icons.copy),
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: enrolment.secret)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        HmPrimaryButton(
          key: const Key('desk-enrolled'),
          label: 'Continue',
          onPressed: c.continueToTotp,
        ),
      ],
    );
  }
}

class _TotpStep extends ConsumerWidget {
  const _TotpStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deskSignInProvider);
    final c = ref.read(deskSignInProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          'Enter your authenticator code',
          'Open your authenticator app and type the 6-digit code for HeyMey Desk.',
        ),
        HmCodeEntry(
          key: const Key('desk-totp'),
          label: 'Authenticator code',
          hint: null,
          onSubmit: c.verifyTotp,
          errorText: state.error,
          busy: state.busy,
          submitLabel: 'Sign in',
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Start again', onPressed: c.startAgain),
      ],
    );
  }
}
