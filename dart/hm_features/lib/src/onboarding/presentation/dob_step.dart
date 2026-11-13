import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../application/onboarding_controller.dart';
import '../domain/age_gate.dart';
import 'onboarding_page.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Step 1: date of birth, picked (no typing). Nothing is stored (§17.1).
class DobStep extends ConsumerStatefulWidget {
  const DobStep({super.key});

  @override
  ConsumerState<DobStep> createState() => _DobStepState();
}

class _DobStepState extends ConsumerState<DobStep> {
  int? _day;
  int? _month;
  int? _year;
  String? _error;

  void _submit() {
    if (_day == null || _month == null || _year == null) return;
    if (!AgeGate.isRealDate(_year!, _month!, _day!)) {
      setState(() => _error = 'Please pick a real date.');
      return;
    }
    ref
        .read(onboardingControllerProvider.notifier)
        .submitDateOfBirth(DateTime(_year!, _month!, _day!));
  }

  @override
  Widget build(BuildContext context) {
    final thisYear = AgeGate.istToday(ref.read(clockProvider)()).year;
    final ready = _day != null && _month != null && _year != null;
    return OnboardingPage(
      title: "Let's find your exams",
      illustration: HmIllustrationKind.welcome,
      subtitle:
          'Answer a few quick questions. We will show the government exams you can write.',
      children: [
        Text(
          'Your date of birth',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: HmSpace.md),
        Wrap(
          spacing: HmSpace.md,
          runSpacing: HmSpace.md,
          children: [
            _Picker(
              key: const Key('dob-day'),
              label: 'Day',
              width: 96,
              value: _day,
              items: {for (var d = 1; d <= 31; d++) d: '$d'},
              onChanged: (v) => setState(() {
                _day = v;
                _error = null;
              }),
            ),
            _Picker(
              key: const Key('dob-month'),
              label: 'Month',
              width: 160,
              value: _month,
              items: {for (var m = 1; m <= 12; m++) m: _months[m - 1]},
              onChanged: (v) => setState(() {
                _month = v;
                _error = null;
              }),
            ),
            _Picker(
              key: const Key('dob-year'),
              label: 'Year',
              width: 120,
              value: _year,
              items: {for (var y = thisYear; y >= thisYear - 80; y--) y: '$y'},
              onChanged: (v) => setState(() {
                _year = v;
                _error = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: HmSpace.md),
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: context.hm.textMuted,
            ),
            const SizedBox(width: HmSpace.sm),
            Expanded(
              child: Text(
                'We use it only to check exam age limits.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        StepError(_error),
        const SizedBox(height: HmSpace.xl),
        HmPrimaryButton(
          key: const Key('dob-continue'),
          label: 'Continue',
          onPressed: ready ? _submit : null,
        ),
        const SizedBox(height: 8),
        HmSecondaryButton(
          label: 'I already have an account',
          onPressed: ref
              .read(onboardingControllerProvider.notifier)
              .startSignIn,
        ),
      ],
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    super.key,
    required this.label,
    required this.width,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final double width;
  final int? value;
  final Map<int, String> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final e in items.entries)
            DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Under 18: exactly the blueprint message. Nothing was stored (§17.1 step 1).
class Under18View extends ConsumerWidget {
  const Under18View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HmIllustration(kind: HmIllustrationKind.empty, size: 112),
              const SizedBox(height: HmSpace.xl),
              Semantics(
                liveRegion: true,
                child: Text(
                  AgeGate.under18Message,
                  key: const Key('under-18-message'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 24),
              HmSecondaryButton(
                label: 'Go back',
                expand: false,
                onPressed: ref
                    .read(onboardingControllerProvider.notifier)
                    .restart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
