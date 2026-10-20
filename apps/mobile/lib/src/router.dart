import 'package:flutter/material.dart';
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
          return (loc == '/start' || loc == '/loading') ? '/today' : null;
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
                builder: (context, _) =>
                    TodayTab(onOpenStudyMap: () => context.go('/map')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, _) => StudyMapTab(
                  onOpenTopic: (t) => context.push('/lesson/${t.id}'),
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
              GoRoute(path: '/profile', builder: (_, _) => const ProfileTab()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:topicId',
        builder: (_, state) =>
            LessonScreen(topicId: state.pathParameters['topicId']!),
      ),
    ],
  );
});
