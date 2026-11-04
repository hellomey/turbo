import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../common/ports.dart';
import '../../profile/application/profile_controller.dart';
import '../../study_map/application/study_providers.dart';
import '../application/exam_hall_controller.dart';
import '../domain/exam_hall_models.dart';
import 'attempt_view.dart';
import 'mock_list_body.dart';
import 'mock_start_body.dart';
import 'report_body.dart';

/// No screen transitions in the Exam Hall (§10.6: no animations).
Route<void> _plainRoute(Widget page) => PageRouteBuilder<void>(
  pageBuilder: (_, _, _) => page,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);

/// Exam Hall home (§10.6 Exam Hall, INT-002-S10/S11).
class ExamHallScreen extends ConsumerStatefulWidget {
  const ExamHallScreen({super.key});

  @override
  ConsumerState<ExamHallScreen> createState() => _ExamHallScreenState();
}

class _ExamHallScreenState extends ConsumerState<ExamHallScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(
        () => ref.read(examHallControllerProvider.notifier).checkResume(),
      ),
    );
  }

  Future<void> _resume() async {
    final ok = await ref.read(examHallControllerProvider.notifier).resume();
    if (ok && mounted) {
      await Navigator.of(context).push(_plainRoute(const MockAttemptScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final examCode = ref.watch(mainExamCodeProvider);
    final calm = ref.watch(meProvider).value?.calmMode ?? false;
    final resumable = ref.watch(
      examHallControllerProvider.select((s) => s.resumableAttemptId),
    );
    // Exam Hall: no game styling, sounds, animations or celebrations (§10.6).
    return HmPlain(
      child: Scaffold(
        appBar: AppBar(title: const Text('Exam Hall')),
        body: examCode.when(
          loading: () => const HmLoadingView(label: 'Loading mocks'),
          error: (e, _) => HmErrorView(
            message: messageOf(e),
            onRetry: () => ref.invalidate(mainExamCodeProvider),
          ),
          data: (code) {
            if (code == null) {
              return const HmComingSoon(
                title: 'Pick your exam first',
                body: 'Choose your main exam in Profile to see its mocks.',
              );
            }
            final list = ref.watch(mockListProvider(code));
            final sunday = ref.watch(stateMockProvider(code));
            return list.when(
              loading: () => const HmLoadingView(label: 'Loading mocks'),
              error: (e, _) => HmErrorView(
                message: messageOf(e),
                onRetry: () => ref.invalidate(mockListProvider(code)),
              ),
              data: (view) => MockListBody(
                list: view,
                stateMock: sunday.value,
                now: ref.watch(clockProvider)(),
                calm: calm,
                onResume: resumable == null ? null : _resume,
                onOpenMock: (m) => Navigator.of(
                  context,
                ).push(_plainRoute(MockStartScreen(mock: m))),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Start screen for one mock. Starting needs a connection (D-2026-10-22-24).
class MockStartScreen extends ConsumerWidget {
  const MockStartScreen({super.key, required this.mock});

  final MockItem mock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examHallControllerProvider);
    final controller = ref.read(examHallControllerProvider.notifier);
    // Exam Hall: no game styling, sounds, animations or celebrations (§10.6).
    return HmPlain(
      child: Scaffold(
        appBar: AppBar(title: const Text('Exam Hall')),
        body: MockStartBody(
          mock: mock,
          busy: state.phase == ExamPhase.starting,
          message: state.message,
          messageIsLimit: state.blockedWithNotNow,
          onStart: () async {
            final ok = await controller.start(mock);
            if (ok && context.mounted) {
              await Navigator.of(
                context,
              ).pushReplacement(_plainRoute(const MockAttemptScreen()));
            }
          },
          onNotNow: () {
            controller.dismissMessage();
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}

/// The mock in progress, then its report. The clock is redrawn once a second from the server deadline.
class MockAttemptScreen extends ConsumerStatefulWidget {
  const MockAttemptScreen({super.key});

  @override
  ConsumerState<MockAttemptScreen> createState() => _MockAttemptScreenState();
}

class _MockAttemptScreenState extends ConsumerState<MockAttemptScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      unawaited(ref.read(examHallControllerProvider.notifier).tick());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _done(String? examCode) {
    final controller = ref.read(examHallControllerProvider.notifier)..reset();
    unawaited(controller.checkResume());
    if (examCode != null) ref.invalidate(mockListProvider(examCode));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examHallControllerProvider);
    final controller = ref.read(examHallControllerProvider.notifier);
    final report = state.report;
    final session = state.session;
    final Widget body;
    if (state.phase == ExamPhase.finished && report != null) {
      body = ReportBody(
        report: report,
        message: state.message,
        onDone: () => _done(ref.read(mainExamCodeProvider).value),
      );
    } else if (session == null) {
      body = state.message == null
          ? const HmLoadingView(label: 'Opening your mock')
          : HmErrorView(
              message: state.message!,
              onRetry: () => unawaited(controller.resume()),
            );
    } else {
      body = AttemptView(
        session: session,
        index: state.index,
        timeLeft: controller.timeLeftNow,
        pending: state.pending,
        message: state.message,
        submitting: state.phase == ExamPhase.submitting,
        onChoose: (q, o) => unawaited(controller.choose(q, o)),
        onToggleMark: (q) => unawaited(controller.toggleMark(q)),
        onGoTo: controller.goTo,
        onSubmit: () async {
          if (await confirmSubmit(context, session)) {
            await controller.submit();
          }
        },
      );
    }
    // Exam Hall: no game styling, sounds, animations or celebrations (§10.6).
    return HmPlain(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            state.phase == ExamPhase.finished ? 'Report' : 'Exam Hall',
          ),
        ),
        body: body,
      ),
    );
  }
}
