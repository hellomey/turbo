import 'package:hm_core/hm_core.dart';
import 'package:hm_design/hm_design.dart';

import '../../lessons/domain/lesson_view.dart';
import '../../lessons/domain/markdown.dart';
import '../domain/study_map_view.dart';

/// Study Map + lessons data (§5.1, §10.6).
abstract interface class StudyRepository {
  /// The main exam code, or null before onboarding saved one.
  Future<String?> mainExamCode();
  Future<StudyMapView> studyMap(String examCode);
  Future<LessonView> lesson(String topicId);
}

class ApiStudyRepository implements StudyRepository {
  ApiStudyRepository(this._api);

  final HmApi _api;

  @override
  Future<String?> mainExamCode() async => (await _api.getMyExams()).mainCode;

  @override
  Future<StudyMapView> studyMap(String examCode) async =>
      studyMapFromJson(await _api.getStudyMap(examCode));

  @override
  Future<LessonView> lesson(String topicId) async =>
      lessonFromJson(await _api.getLesson(topicId));
}

/// Maps contract `StudyMap` JSON, sorted by `order`.
StudyMapView studyMapFromJson(Map<String, dynamic> json) {
  final subjects = [
    for (final s in asJsonList(json['subjects']))
      SubjectView(
        code: '${s['code']}',
        name: '${s['name']}',
        order: s['order'] as int? ?? 0,
        topics: [
          for (final t in asJsonList(s['topics']))
            TopicView(
              id: '${t['id']}',
              name: '${t['name']}',
              order: t['order'] as int? ?? 0,
              hasLesson: t['hasLesson'] == true,
              lamp: _lamp(t['ring']),
              examCodes: [
                for (final c in (t['examCodes'] as List? ?? const [])) '$c',
              ],
            ),
        ]..sort((a, b) => a.order.compareTo(b.order)),
      ),
  ]..sort((a, b) => a.order.compareTo(b.order));
  return StudyMapView(
    examCode: '${json['examCode']}',
    subjects: subjects,
    totalTopics:
        json['totalTopics'] as int? ??
        subjects.fold<int>(0, (n, s) => n + s.topics.length),
  );
}

HmLampState _lamp(Object? ring) {
  if (ring is! Map) return HmLampState.unlit;
  final level = (ring['steadyLevel'] as int? ?? 0).clamp(
    0,
    HmLampState.maxSteady,
  );
  return HmLampState(
    lit: ring['lit'] == true,
    steadyLevel: level,
    gold: ring['gold'] == true,
    dim: switch (ring['dim']) {
      'dimming' => HmLampDim.dimming,
      'dim' => HmLampDim.dim,
      _ => HmLampDim.bright,
    },
  );
}

/// Maps contract `Lesson` JSON.
LessonView lessonFromJson(Map<String, dynamic> json) {
  final source = json['source'] is Map
      ? (json['source'] as Map).cast<String, dynamic>()
      : const <String, dynamic>{};
  return LessonView(
    id: '${json['id']}',
    topicId: '${json['topicId']}',
    title: '${json['title']}',
    blocks: parseMarkdown('${json['bodyMarkdown'] ?? ''}'),
    readingMinutes: json['readingMinutes'] as int? ?? 1,
    textbookRefs: [
      for (final r in asJsonList(json['textbookRefs']))
        TextbookRefView(
          book: '${r['book']}',
          classLevel: r['classLevel'] as int?,
          chapter: r['chapter'] as String?,
          pages: r['pages'] as String?,
          url: r['url'] as String?,
        ),
    ],
    citation: '${source['citation'] ?? ''}',
    citationUrl: source['url'] as String?,
  );
}
