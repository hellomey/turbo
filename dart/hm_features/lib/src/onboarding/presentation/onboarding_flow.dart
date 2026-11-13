import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../plan/application/plan_setup_controller.dart';
import '../application/onboarding_controller.dart';
import 'answers_step.dart';
import 'dob_step.dart';
import 'later_steps.dart';

/// Onboarding (§17.1): value before login. When it finishes the session becomes signed in and the
/// app router opens the shell.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(onboardingControllerProvider.select((s) => s.step), (_, step) {
      if (step == OnboardingStep.done) {
        // Plan setup comes next (§17.1 step 9, BOLT-0018); set before sign-in so the router sees it.
        ref.read(planSetupPendingProvider.notifier).set(true);
        ref.read(sessionProvider.notifier).markSignedIn();
        onFinished?.call();
      }
    });
    final step = ref.watch(onboardingControllerProvider.select((s) => s.step));
    final c = ref.read(onboardingControllerProvider.notifier);
    final canGoBack = switch (step) {
      OnboardingStep.answers ||
      OnboardingStep.result ||
      OnboardingStep.pickExams ||
      OnboardingStep.mapPreview ||
      OnboardingStep.email ||
      OnboardingStep.code => true,
      _ => false,
    };
    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) c.back();
      },
      child: Scaffold(
        body: Column(
          children: [
            if (_stepNumber(step) case final n?)
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (canGoBack)
                      IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: c.back,
                      )
                    else
                      const SizedBox(width: HmSpace.sm),
                    Expanded(
                      child: HmStepHeader(step: n, total: _totalSteps),
                    ),
                  ],
                ),
              ),
            Expanded(child: _body(step)),
          ],
        ),
      ),
    );
  }

  static const _totalSteps = 8;

  /// The progress header number for each step (§17.1); none on the age stop or the hand-off.
  static int? _stepNumber(OnboardingStep step) => switch (step) {
    OnboardingStep.dob => 1,
    OnboardingStep.answers => 2,
    OnboardingStep.result => 3,
    OnboardingStep.pickExams => 4,
    OnboardingStep.mapPreview => 5,
    OnboardingStep.email => 6,
    OnboardingStep.code => 7,
    OnboardingStep.consent => 8,
    _ => null,
  };

  Widget _body(OnboardingStep step) => AnimatedSwitcher(
    duration: HmMotion.screenTransition,
    child: KeyedSubtree(
      key: ValueKey(step),
      child: switch (step) {
        OnboardingStep.dob => const DobStep(),
        OnboardingStep.under18 => const Under18View(),
        OnboardingStep.answers => const AnswersStep(),
        OnboardingStep.result => const ResultStep(),
        OnboardingStep.pickExams => const PickExamsStep(),
        OnboardingStep.mapPreview => const MapPreviewStep(),
        OnboardingStep.email => const EmailStep(),
        OnboardingStep.code => const CodeStep(),
        OnboardingStep.consent => const ConsentStep(),
        OnboardingStep.done => const HmLoadingView(label: 'Opening HeyMey'),
      },
    ),
  );
}
