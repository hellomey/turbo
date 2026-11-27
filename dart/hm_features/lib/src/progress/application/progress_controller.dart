import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

@immutable
class TrophyView {
  const TrophyView({
    required this.code,
    required this.title,
    required this.earnedAt,
  });

  factory TrophyView.fromJson(Map<String, dynamic> j) => TrophyView(
    code: j['code'] as String,
    title: j['title'] as String,
    earnedAt: DateTime.parse(j['earnedAt'] as String),
  );

  final String code;
  final String title;
  final DateTime earnedAt;
}

/// `GET /v1/me/progress`.
@immutable
class ProgressView {
  const ProgressView({
    required this.xp,
    required this.level,
    required this.levelStartXp,
    required this.nextLevelXp,
    required this.points,
    required this.checkedInToday,
    required this.trophies,
  });

  factory ProgressView.fromJson(Map<String, dynamic> j) => ProgressView(
    xp: j['xp'] as int,
    level: j['level'] as int,
    levelStartXp: j['levelStartXp'] as int,
    nextLevelXp: j['nextLevelXp'] as int,
    points: j['points'] as int,
    checkedInToday: j['checkedInToday'] as bool,
    trophies: [
      for (final t in (j['trophies'] as List).cast<Map<String, dynamic>>())
        TrophyView.fromJson(t),
    ],
  );

  final int xp;
  final int level;
  final int levelStartXp;
  final int nextLevelXp;
  final int points;
  final bool checkedInToday;
  final List<TrophyView> trophies;

  /// 0..1 through the current level, for the bar.
  double get levelFraction {
    final span = nextLevelXp - levelStartXp;
    return span <= 0 ? 0 : ((xp - levelStartXp) / span).clamp(0, 1).toDouble();
  }
}

@immutable
class LeaderboardEntryView {
  const LeaderboardEntryView({
    required this.rank,
    required this.displayName,
    required this.xp,
    required this.isMe,
  });

  final int rank;
  final String displayName;
  final int xp;
  final bool isMe;
}

@immutable
class LeaderboardView {
  const LeaderboardView({required this.optedIn, required this.entries});

  factory LeaderboardView.fromJson(Map<String, dynamic> j) => LeaderboardView(
    optedIn: j['optedIn'] as bool,
    entries: [
      for (final e in (j['entries'] as List).cast<Map<String, dynamic>>())
        LeaderboardEntryView(
          rank: e['rank'] as int,
          displayName: e['displayName'] as String,
          xp: e['xp'] as int,
          isMe: e['isMe'] as bool,
        ),
    ],
  );

  final bool optedIn;
  final List<LeaderboardEntryView> entries;
}

final myProgressProvider = FutureProvider.autoDispose<ProgressView>(
  (ref) async =>
      ProgressView.fromJson(await ref.watch(hmApiProvider).getMyProgress()),
);

final weeklyLeaderboardProvider = FutureProvider.autoDispose<LeaderboardView>(
  (ref) async => LeaderboardView.fromJson(
    await ref.watch(hmApiProvider).getWeeklyLeaderboard(),
  ),
);

/// Daily check-in. Returns the XP and Points awarded (zero when already done today).
Future<({int xp, int points})> checkInToday(WidgetRef ref) async {
  final r = await ref.read(hmApiProvider).checkIn();
  ref.invalidate(myProgressProvider);
  final awarded = r['awarded'] as Map<String, dynamic>;
  return (xp: awarded['xp'] as int, points: awarded['points'] as int);
}

/// Join or leave the weekly leaderboard. Returns whether the board can show me.
Future<bool> setLeaderboardOptIn(WidgetRef ref, bool optIn) async {
  final r = await ref.read(hmApiProvider).putLeaderboardOptIn(optIn);
  ref.invalidate(weeklyLeaderboardProvider);
  return r['listed'] as bool;
}
