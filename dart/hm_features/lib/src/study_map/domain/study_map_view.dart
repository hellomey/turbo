import 'package:flutter/foundation.dart';
import 'package:hm_design/hm_design.dart';

@immutable
class TopicView {
  const TopicView({
    required this.id,
    required this.name,
    required this.order,
    required this.hasLesson,
    this.lamp = HmLampState.unlit,
    this.examCodes = const [],
  });

  final String id;
  final String name;
  final int order;
  final bool hasLesson;
  final HmLampState lamp;

  /// Exams that share this lamp.
  final List<String> examCodes;
}

@immutable
class SubjectView {
  const SubjectView({
    required this.code,
    required this.name,
    required this.order,
    required this.topics,
  });

  final String code;
  final String name;
  final int order;
  final List<TopicView> topics;
}

/// The Study Map of one exam (§5.1): subjects (islands) and topics (lamps), in order.
@immutable
class StudyMapView {
  const StudyMapView({
    required this.examCode,
    required this.subjects,
    required this.totalTopics,
  });

  final String examCode;
  final List<SubjectView> subjects;
  final int totalTopics;
}
