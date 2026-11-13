import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';
import 'package:hm_features/hm_features.dart';

import 'shell.dart';

/// Routes (§10.5): onboarding when signed out, the five tabs when signed in, lessons on top.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<SessionStatus>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) {
    // A new session (or none) must never show the previous user's data.
    ref.invalidate(meProvider);
    ref.invalidate(dataChoicesProvider);
    ref.invalidate(mainExamCodeProvider);
    if (next == SessionStatus.signedOut) {
      ref.invalidate(onboardingControllerProvider);
    }
    session.value = next;
  });
  ref.onDispose(session.dispose);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: session,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      switch (session.value) {
        case SessionStatus.unknown:
          return loc == '/loading' ? null : '/loading';
        case SessionStatus.signedOut:
          return loc == '/start' ? null : '/start';
        case SessionStatus.signedIn:
          if (loc == '/start' || loc == '/loading') {
            // Straight after onboarding: plan setup once (§17.1 step 9, BOLT-0018).
            return ref.read(planSetupPendingProvider)
                ? '/plan-setup'
                : '/today';
          }
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (_, _) =>
            const Scaffold(body: HmLoadingView(label: 'Opening HeyMey')),
      ),
      GoRoute(path: '/start', builder: (_, _) => const OnboardingFlow()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, _) => TodayTab(
                  onOpenStudyMap: () => context.go('/map'),
                  onOpenExamHall: () => context.push('/exam-hall'),
                  // BOLT-0018: Today Card, My Plan, relight, pocket sessions (§10.6 Today).
                  onOpenPlan: () => context.push('/plan'),
                  onSetUpPlan: () => context.push('/plan-setup'),
                  onStartItem: (item) => context.push(planItemRoute(item)),
                  onOpenRelight: () => context.push('/relight'),
                  onStartPocket: (_) => context.go('/map'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, _) => StudyMapTab(
                  onOpenTopic: (t) => context.push('/lesson/${t.id}'),
                  onStartCheck: (t, kind) =>
                      context.push('/check/${t.id}/${kind.name}'),
                  actions: (
                    onRelight: () => context.push('/relight'),
                    onPractice: (exam) => context.push('/practice/$exam'),
                    onMistakes: () => context.push('/mistakes'),
                    onPyqVault: (exam) => context.push('/pyq/$exam'),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/play', builder: (_, _) => const PlayTab()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/squad', builder: (_, _) => const SquadTab()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, _) => ProfileTab(
                  onOpenReadiness: () => context.push('/readiness'),
                  onOpenReports: () => context.push('/reports'),
                  onOpenAlerts: () => context.push('/alerts'),
                  onOpenAlertSettings: () => context.push('/alert-settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/exam-hall', builder: (_, _) => const ExamHallScreen()),
      GoRoute(
        path: '/lesson/:topicId',
        builder: (context, state) {
          final id = state.pathParameters['topicId']!;
          return LessonScreen(
            topicId: id,
            onFinished: () => context.pushReplacement('/check/$id/lit?done=1'),
          );
        },
      ),
      // Study screens (BOLT-0017, §5.1, §10.6, §11).
      GoRoute(
        path: '/check/:topicId/:kind',
        builder: (_, state) {
          final kind = CheckKind.values.firstWhere(
            (k) => k.name == state.pathParameters['kind'],
            orElse: () => CheckKind.lit,
          );
          final done = state.uri.queryParameters['done'] == '1';
          return CheckScreen(
            request: (
              topicId: state.pathParameters['topicId']!,
              kind: kind,
              lessonStep: done,
            ),
            lessonAlreadyFinished: done,
          );
        },
      ),
      GoRoute(
        path: '/relight',
        builder: (context, _) => RelightQueueScreen(
          onRelight: (id) => context.push('/check/$id/relight'),
        ),
      ),
      GoRoute(
        path: '/practice/:examCode',
        builder: (context, state) => PracticeScreen(
          request: (
            mode: StudyMode.values.firstWhere(
              (m) => m.name == state.uri.queryParameters['mode'],
              orElse: () => StudyMode.practice,
            ),
            examCode: state.pathParameters['examCode']!,
            topicId: state.uri.queryParameters['topicId'],
            subjectCode: state.uri.queryParameters['subjectCode'],
            drillId: state.uri.queryParameters['drillId'],
          ),
          onRelight: (id) => context.push('/check/$id/relight'),
        ),
      ),
      GoRoute(
        path: '/mistakes',
        builder: (context, _) => MistakesScreen(
          onRelight: (id) => context.push('/check/$id/relight'),
          onStartDrill: (d) {
            final exam = ref.read(mainExamCodeProvider).value;
            if (exam != null) {
              context.push('/practice/$exam?mode=drill&drillId=${d.id}');
            }
          },
        ),
      ),
      GoRoute(
        path: '/pyq/:examCode',
        builder: (context, state) {
          final exam = state.pathParameters['examCode']!;
          return PyqVaultScreen(
            examCode: exam,
            onPractise: (f) => context.push(
              Uri(
                path: '/practice/$exam',
                queryParameters: {'mode': 'pyq', 'subjectCode': ?f.subjectCode},
              ).toString(),
            ),
          );
        },
      ),
      // Plan, readiness, reports, alerts (BOLT-0018, INT-002-S12..S17).
      GoRoute(path: '/plan', builder: (_, _) => const MyPlanScreen()),
      GoRoute(
        path: '/plan-setup',
        builder: (context, _) => PlanSetupScreen(
          onDone: () => context.canPop() ? context.pop() : context.go('/today'),
        ),
      ),
      GoRoute(
        path: '/readiness',
        builder: (context, _) =>
            ReadinessScreen(onOpenReports: () => context.push('/reports')),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, _) => SundayReportListScreen(
          onOpenReport: (id) => context.push('/reports/$id'),
        ),
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (_, state) =>
            SundayReportScreen(reportId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, _) => ExamAlertsScreen(
          onOpenSettings: () => context.push('/alert-settings'),
        ),
      ),
      GoRoute(
        path: '/alert-settings',
        builder: (_, _) => const AlertSettingsScreen(),
      ),
    ],
  );
});

/// Where a Today Card item opens (§10.6 Today). Navigation only; the server chose the item.
String planItemRoute(PlanItemView item) {
  final topic = item.topicId;
  final exam = Uri.encodeComponent(item.examCode);
  return switch (item.kind) {
    PlanItemKindView.lesson when topic != null => '/lesson/$topic',
    PlanItemKindView.litCheck when topic != null => '/check/$topic/lit',
    PlanItemKindView.gold when topic != null => '/check/$topic/gold',
    PlanItemKindView.relight when topic != null => '/check/$topic/relight',
    PlanItemKindView.relight => '/relight',
    PlanItemKindView.practice => Uri(
      path: '/practice/$exam',
      queryParameters: {'topicId': ?topic},
    ).toString(),
    PlanItemKindView.pyq => '/pyq/$exam',
    PlanItemKindView.mock => '/exam-hall',
    PlanItemKindView.mistakeReview => '/mistakes',
    _ => '/map',
  };
}
