import 'package:flutter/foundation.dart';
import 'package:hm_design/hm_design.dart';

import 'practice_models.dart';

/// Pure display rules for the study screens. No widget decides any of these (AGENTS.md §8).

/// A lamp's state in words, so nothing depends on colour (§10.9).
String lampWords(HmLampState s) {
  final dim = switch (s.dim) {
    HmLampDim.dimming => ' · Dimming',
    HmLampDim.dim => ' · Dim, relight it',
    HmLampDim.bright => '',
  };
  if (s.gold) return 'Gold$dim';
  if (s.steadyLevel > 0) {
    return 'Steady ${s.steadyLevel} of ${HmLampState.maxSteady}$dim';
  }
  if (s.lit) return 'Lit$dim';
  return 'Not lit yet';
}

/// The limit sheet appears at most once per IST day (§13, invariant 12): the server flag from the last usage it
/// sent, plus a guard on this phone for the same IST day.
bool shouldShowLimitSheet({
  required UsageView? lastUsage,
  required String? shownOnIstDay,
}) {
  if (lastUsage == null) return shownOnIstDay == null;
  if (lastUsage.limitSheetShownToday) return false;
  return shownOnIstDay != lastUsage.istDay;
}

/// Simple-English copy (§10.2). Limit text is T2: compliance + founder approval (D-2026-10-22-19).
abstract final class StudyCopy {
  static String limitTitle(int? limit) => limit == null
      ? "You've used today's free questions."
      : "You've used today's $limit free questions.";
  static const limitBody =
      'More open tomorrow at 12 AM. Lessons, relights and mocks are still open.';
  static const notNow = 'Not now';
  static const willSync = 'Will sync when online';
  static const couldNotSave = "Couldn't save";
  static const savedOffline =
      'Saved on this phone. You will see the answer when you are online.';
  static const goldNeedsConnection =
      'Gold needs a connection because it is timed by the server.';
  static const checkNeedsConnection =
      'This check needs a connection to load its questions. Your progress is saved.';
  static const drillLocked = 'Concept drills are part of Pro.';
  static const pyqLocked = 'Older years are part of Pro.';
  static const pro = 'Pro';
  static const free = 'Free';

  static String checkTitle(CheckKind k) => switch (k) {
    CheckKind.lit => 'Lit check',
    CheckKind.recall => 'Recall check',
    CheckKind.relight => 'Relight',
    CheckKind.gold => 'Gold check',
  };

  static String checkIntro(CheckKind k, int count, int passMark) => switch (k) {
    CheckKind.lit =>
      'Answer $count questions. Get $passMark right to light this lamp.',
    CheckKind.recall =>
      'Answer $count questions. Get $passMark right to keep it Steady.',
    CheckKind.relight =>
      'Answer $count questions. Get $passMark right to relight this lamp.',
    CheckKind.gold =>
      'Answer $count exam-level questions in time. Get $passMark right for Gold.',
  };

  static String checkPassed(CheckKind k) => switch (k) {
    CheckKind.lit => 'Lamp lit.',
    CheckKind.recall => 'Remembered. Your Steady ring grew.',
    CheckKind.relight => 'Lamp relit.',
    CheckKind.gold => 'Gold earned.',
  };

  static const checkFailed = 'Not this time. Read the lesson again and retry.';
}

/// What happened to one answer or check result after it was written to the phone (§39).
@immutable
sealed class SaveOutcome<T> {
  const SaveOutcome();
}

/// The server graded it.
class Graded<T> extends SaveOutcome<T> {
  const Graded(this.value);
  final T value;
}

/// Saved on the phone; the outbox will send it ("Will sync when online").
class SavedOffline<T> extends SaveOutcome<T> {
  const SavedOffline();
}

/// The free daily limit was reached (§11). Nothing was stored.
class LimitReached<T> extends SaveOutcome<T> {
  const LimitReached({required this.showSheet, this.usage});
  final bool showSheet;
  final UsageView? usage;
}

/// The server refused it ("Couldn't save").
class NotSaved<T> extends SaveOutcome<T> {
  const NotSaved(this.message);
  final String message;
}

/// Which check a lamp offers now (contract `TopicState.nextCheck`, §5.1).
enum NextCheck { lesson, lit, recall, relight, gold, none }

NextCheck nextCheckOf(Object? v) => NextCheck.values.firstWhere(
  (n) => n.name == v,
  orElse: () => NextCheck.none,
);

/// One action in the lamp sheet. [kind] null = open the lesson.
@immutable
class TopicAction {
  const TopicAction(this.label, this.kind, {this.needsConnection = false});
  final String label;
  final CheckKind? kind;
  final bool needsConnection;
}

/// The lamp sheet's actions, the server's next check first (one clear next action, §10.1):
/// "Start recall" when a recall is due; "Try Gold" when the lamp is Lit or above (online only, §5.1).
List<TopicAction> topicActions({
  required NextCheck next,
  required HmLampState lamp,
  required bool hasLesson,
}) => [
  if (next == NextCheck.relight || lamp.dim != HmLampDim.bright)
    const TopicAction('Relight', CheckKind.relight),
  if (next == NextCheck.recall)
    const TopicAction('Start recall', CheckKind.recall),
  if (next == NextCheck.lit)
    const TopicAction('Take the Lit check', CheckKind.lit),
  if ((lamp.lit || next == NextCheck.gold) && !lamp.gold)
    const TopicAction('Try Gold', CheckKind.gold, needsConnection: true),
  if (hasLesson) const TopicAction('Read the lesson', null),
];
