import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

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
        body: AnimatedSwitcher(
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
              OnboardingStep.done => const HmLoadingView(
                label: 'Opening HeyMey',
              ),
            },
          ),
        ),
      ),
    );
  }
}
