import 'package:flutter/foundation.dart';

/// A study action done on this phone (blueprint §39, contract `SyncAction` in
/// `packages/contracts/src/http/sync.ts`).
///
/// Only these kinds go through the offline outbox. Gold checks and mock starts are online only and never
/// queued (U-app-shell invariant 5). Offline actions earn study progress only, never Sparks or ranked
/// rewards (§39, §5.3).
@immutable
sealed class StudyAction {
  const StudyAction();

  /// Contract discriminator (`kind`).
  String get kind;

  /// Fields of this kind, without `clientActionId` / `clientAt` (the outbox adds those).
  Map<String, Object> fieldsJson();

  /// Rebuilds an action stored in the outbox. Throws [FormatException] for an unknown kind.
  static StudyAction fromStored(
    String kind,
    Map<String, dynamic> json,
  ) => switch (kind) {
    PracticeAnswerAction.kindWire => PracticeAnswerAction(
      questionId: json['questionId'] as String,
      questionVersion: json['questionVersion'] as int,
      chosenOptionIds: [for (final o in json['chosenOptionIds'] as List) '$o'],
      timeMs: json['timeMs'] as int,
      mode: PracticeMode.values.byName(json['mode'] as String),
    ),
    LessonCompleteAction.kindWire => LessonCompleteAction(
      topicId: json['topicId'] as String,
      via: LessonVia.values.byName(json['via'] as String),
    ),
    TopicCheckAction.kindWire => TopicCheckAction(
      topicId: json['topicId'] as String,
      checkKind: OfflineCheckKind.values.byName(json['checkKind'] as String),
      answers: [
        for (final a in json['answers'] as List)
          (a as Map).cast<String, Object>(),
      ],
    ),
    PlanItemStatusAction.kindWire => PlanItemStatusAction(
      itemId: json['itemId'] as String,
      status: PlanItemStatus.values.byName(json['status'] as String),
    ),
    _ => throw FormatException('Unknown study action kind', kind),
  };
}

enum PracticeMode { practice, pyq, mistakes, drill }

enum LessonVia { lesson, textbook }

/// Gold is timed by the server and is never accepted offline, so it is not in this enum.
enum OfflineCheckKind { lit, recall, relight }

enum PlanItemStatus { done, skipped }

class PracticeAnswerAction extends StudyAction {
  const PracticeAnswerAction({
    required this.questionId,
    required this.questionVersion,
    required this.chosenOptionIds,
    required this.timeMs,
    required this.mode,
  });

  static const kindWire = 'practice_answer';

  final String questionId;
  final int questionVersion;
  final List<String> chosenOptionIds;
  final int timeMs;
  final PracticeMode mode;

  @override
  String get kind => kindWire;

  @override
  Map<String, Object> fieldsJson() => {
    'questionId': questionId,
    'questionVersion': questionVersion,
    'chosenOptionIds': chosenOptionIds,
    'timeMs': timeMs,
    'mode': mode.name,
  };
}

class LessonCompleteAction extends StudyAction {
  const LessonCompleteAction({required this.topicId, required this.via});

  static const kindWire = 'lesson_complete';

  final String topicId;
  final LessonVia via;

  @override
  String get kind => kindWire;

  @override
  Map<String, Object> fieldsJson() => {'topicId': topicId, 'via': via.name};
}

class TopicCheckAction extends StudyAction {
  const TopicCheckAction({
    required this.topicId,
    required this.checkKind,
    required this.answers,
  });

  static const kindWire = 'topic_check';

  final String topicId;
  final OfflineCheckKind checkKind;

  /// Contract `AnswerInput` objects.
  final List<Map<String, Object>> answers;

  @override
  String get kind => kindWire;

  @override
  Map<String, Object> fieldsJson() => {
    'topicId': topicId,
    'checkKind': checkKind.name,
    'answers': answers,
  };
}

class PlanItemStatusAction extends StudyAction {
  const PlanItemStatusAction({required this.itemId, required this.status});

  static const kindWire = 'plan_item_status';

  final String itemId;
  final PlanItemStatus status;

  @override
  String get kind => kindWire;

  @override
  Map<String, Object> fieldsJson() => {'itemId': itemId, 'status': status.name};
}
