import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_features/hm_features.dart';

import 'support/fakes.dart';

/// BOLT-0113: XP / level card, trophies, opt-in leaderboard.
void main() {
  ProgressView progress({
    bool checkedIn = false,
    List<TrophyView> trophies = const [],
  }) => ProgressView(
    xp: 150,
    level: 2,
    levelStartXp: 100,
    nextLevelXp: 300,
    points: 20,
    checkedInToday: checkedIn,
    trophies: trophies,
  );

  testWidgets('progress card shows level, XP and an enabled check-in', (
    tester,
  ) async {
    final h = Harness(
      extra: [myProgressProvider.overrideWith((ref) async => progress())],
    );
    await tester.pumpWidget(
      h.app(Scaffold(body: ProgressCard(onOpenLeaderboard: () {}))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('150 / 300 XP'), findsOneWidget);
    expect(find.text('20 Points'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('today-check-in')),
    );
    expect(button.onPressed, isNotNull);
    expect(find.textContaining('streak'), findsNothing);
  });

  testWidgets('after checking in today the button is disabled', (tester) async {
    final h = Harness(
      extra: [
        myProgressProvider.overrideWith(
          (ref) async => progress(checkedIn: true),
        ),
      ],
    );
    await tester.pumpWidget(h.app(const Scaffold(body: ProgressCard())));
    await tester.pumpAndSettle();
    expect(find.text('Checked in today'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('today-check-in')))
          .onPressed,
      isNull,
    );
    expect(find.byKey(const Key('today-open-leaderboard')), findsNothing);
  });

  testWidgets('trophies list earned badges', (tester) async {
    final h = Harness(
      extra: [
        myProgressProvider.overrideWith(
          (ref) async => progress(
            trophies: [
              TrophyView(
                code: 'first_lamp',
                title: 'First lamp lit',
                earnedAt: DateTime.utc(2026, 11, 25),
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pumpWidget(h.app(const Scaffold(body: TrophiesSection())));
    await tester.pumpAndSettle();
    expect(find.text('First lamp lit'), findsOneWidget);
  });

  testWidgets('no trophies yet shows a hint', (tester) async {
    final empty = Harness(
      extra: [myProgressProvider.overrideWith((ref) async => progress())],
    );
    await tester.pumpWidget(empty.app(const Scaffold(body: TrophiesSection())));
    await tester.pumpAndSettle();
    expect(
      find.text('Light your first lamp to earn your first trophy.'),
      findsOneWidget,
    );
  });

  testWidgets('leaderboard is off by default and never padded', (tester) async {
    final h = Harness(
      extra: [
        weeklyLeaderboardProvider.overrideWith(
          (ref) async => const LeaderboardView(optedIn: false, entries: []),
        ),
      ],
    );
    await tester.pumpWidget(h.app(const LeaderboardScreen()));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('leaderboard-opt-in')))
          .value,
      isFalse,
    );
    expect(
      find.text("No one has joined this week's board yet."),
      findsOneWidget,
    );
    expect(find.textContaining(RegExp(r'^\d+ XP$')), findsNothing);
  });

  testWidgets('leaderboard rows show nickname, XP and mark me', (tester) async {
    final h = Harness(
      extra: [
        weeklyLeaderboardProvider.overrideWith(
          (ref) async => const LeaderboardView(
            optedIn: true,
            entries: [
              LeaderboardEntryView(
                rank: 1,
                displayName: 'Kavi',
                xp: 90,
                isMe: false,
              ),
              LeaderboardEntryView(
                rank: 2,
                displayName: 'Arun',
                xp: 40,
                isMe: true,
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pumpWidget(h.app(const LeaderboardScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Kavi'), findsOneWidget);
    expect(find.text('Arun (you)'), findsOneWidget);
    expect(find.text('90 XP'), findsOneWidget);
  });
}
