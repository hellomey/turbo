import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../eligibility/presentation/eligibility_result_view.dart';
import '../../study_map/application/study_providers.dart';
import '../../study_map/presentation/study_map_body.dart';
import '../application/onboarding_controller.dart';
import 'onboarding_page.dart';

/// Step 3: the eligibility result with share + official links.
class ResultStep extends ConsumerWidget {
  const ResultStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    final result = state.result!;
    return SafeArea(
      child: EligibilityResultView(
        result: result,
        onOpenLink: (exam) =>
            ref.read(linkOpenerProvider).open(exam.officialUrl),
        onShare: () =>
            ref.read(shareServiceProvider).shareText(result.shareText()),
        onContinue: c.continueToPickExams,
        onChangeAnswers: c.back,
      ),
    );
  }
}

/// Step 4: main exam + up to 2 more.
class PickExamsStep extends ConsumerWidget {
  const PickExamsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    final exams = state.result?.eligible ?? const [];
    final text = Theme.of(context).textTheme;
    final full = state.otherExams.length >= OnboardingState.maxOtherExams;
    return OnboardingPage(
      title: 'Pick your main exam',
      subtitle:
          'Your Study Map is built for this exam. You can change it later.',
      children: [
        for (final e in exams)
          Semantics(
            inMutuallyExclusiveGroup: true,
            checked: state.mainExam == e.code,
            child: ListTile(
              key: Key('main-${e.code}'),
              minTileHeight: 48,
              leading: Icon(
                state.mainExam == e.code
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(e.name),
              subtitle: Text(e.conductingBody),
              onTap: () => c.chooseMainExam(e.code),
            ),
          ),
        if (exams.length > 1) ...[
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text('Add up to 2 more (optional)', style: text.titleMedium),
          ),
          for (final e in exams.where((e) => e.code != state.mainExam))
            CheckboxListTile(
              key: Key('other-${e.code}'),
              value: state.otherExams.contains(e.code),
              title: Text(e.name),
              onChanged: full && !state.otherExams.contains(e.code)
                  ? null
                  : (_) => c.toggleOtherExam(e.code),
            ),
        ],
        const SizedBox(height: 16),
        HmPrimaryButton(
          key: const Key('exams-continue'),
          label: 'Continue',
          onPressed: state.mainExam == null ? null : c.continueToMapPreview,
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Back', onPressed: c.back),
      ],
    );
  }
}

/// Step 5: the Study Map preview (public route), then "Save your progress".
class MapPreviewStep extends ConsumerWidget {
  const MapPreviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    final map = ref.watch(studyMapProvider(state.mainExam!));
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: map.when(
              loading: () =>
                  const HmLoadingView(label: 'Loading your Study Map'),
              error: (e, _) => HmErrorView(
                message: messageOf(e),
                onRetry: () =>
                    ref.invalidate(studyMapProvider(state.mainExam!)),
              ),
              data: (m) => StudyMapBody(
                map: m,
                lite: ref.watch(liteModeProvider),
                header: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Your Study Map',
                          style: text.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Each lamp is one topic. Study a topic to light its lamp.',
                        style: text.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                HmPrimaryButton(
                  key: const Key('save-progress'),
                  label: 'Save your progress',
                  onPressed: c.continueToSave,
                ),
                const SizedBox(height: 8),
                HmSecondaryButton(label: 'Back', onPressed: c.back),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 7a: email.
class EmailStep extends ConsumerStatefulWidget {
  const EmailStep({super.key});

  @override
  ConsumerState<EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends ConsumerState<EmailStep> {
  late final _controller = TextEditingController(
    text: ref.read(onboardingControllerProvider).email,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    return OnboardingPage(
      title: state.signInOnly ? 'Sign in' : 'Save your progress',
      subtitle:
          'We will send a 6-digit code to your email. You do not need a password.',
      children: [
        TextField(
          key: const Key('email-field'),
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => c.requestCode(_controller.text),
        ),
        StepError(state.error),
        const SizedBox(height: 16),
        HmPrimaryButton(
          key: const Key('send-code'),
          label: 'Send code',
          busy: state.busy,
          onPressed: () => c.requestCode(_controller.text),
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Back', onPressed: c.back),
      ],
    );
  }
}

/// Step 7b: the 6-digit code (paste works, resend after 60 s).
class CodeStep extends ConsumerWidget {
  const CodeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    return OnboardingPage(
      title: 'Enter your code',
      subtitle:
          'We sent a 6-digit code to ${state.email}. It works for 10 minutes.',
      children: [
        HmCodeEntry(
          onSubmit: c.verifyCode,
          onResend: c.resendCode,
          resendAfter: Duration(seconds: state.resendAfterSeconds),
          errorText: state.error,
          busy: state.busy,
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(label: 'Change email', onPressed: c.back),
      ],
    );
  }
}

/// Shown under the consent choices (compliance C3).
const consentFooter =
    'You can change these choices any time in Profile. Questions or complaints: grievance@heymey.app.';

/// Step 8: DPDP consent. Short, required item separate from optional choices, NOTHING pre-ticked.
class ConsentStep extends ConsumerWidget {
  const ConsentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    final notice = state.notice!;
    final text = Theme.of(context).textTheme;
    final required = notice.purposes.where((p) => p.required).toList();
    final optional = notice.purposes.where((p) => !p.required).toList();

    Widget tile(ConsentPurposeInfo p, {required bool isRequired}) =>
        CheckboxListTile(
          key: Key('consent-${p.purpose}'),
          value: state.consents[p.purpose] == true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(isRequired ? '${p.title} (needed)' : p.title),
          subtitle: Text(p.description),
          onChanged: (v) => c.setConsent(p.purpose, v ?? false),
        );

    return OnboardingPage(
      title: 'Your data, your choice',
      subtitle: 'Please read and choose. Nothing is ticked for you.',
      children: [
        if (required.isNotEmpty) ...[
          Semantics(
            header: true,
            child: Text('Needed to use HeyMey', style: text.titleMedium),
          ),
          for (final p in required) tile(p, isRequired: true),
        ],
        if (optional.isNotEmpty) ...[
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text('Optional choices', style: text.titleMedium),
          ),
          for (final p in optional) tile(p, isRequired: false),
        ],
        const SizedBox(height: 16),
        Text(
          consentFooter,
          key: const Key('consent-footer'),
          style: text.bodyMedium,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const Key('consent-privacy'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => ref.read(linkOpenerProvider).open(privacyUrl),
            child: const Text('Read our Privacy Policy'),
          ),
        ),
        StepError(state.error),
        const SizedBox(height: 16),
        HmPrimaryButton(
          key: const Key('consent-continue'),
          label: 'Save my choices and continue',
          busy: state.busy,
          onPressed: state.requiredConsentsGiven ? c.acceptConsents : null,
        ),
      ],
    );
  }
}
