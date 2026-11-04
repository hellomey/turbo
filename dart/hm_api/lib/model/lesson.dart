//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Lesson {
  /// Returns a new [Lesson] instance.
  Lesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.bodyMarkdown,
    required this.readingMinutes,
    this.textbookRefs = const [],
    required this.source_,
    required this.version,
    required this.updatedAt,
  });

  String id;

  String topicId;

  String title;

  String bodyMarkdown;

  int readingMinutes;

  List<TextbookRef> textbookRefs;

  LessonSource source_;

  int version;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Lesson &&
    other.id == id &&
    other.topicId == topicId &&
    other.title == title &&
    other.bodyMarkdown == bodyMarkdown &&
    other.readingMinutes == readingMinutes &&
    _deepEquality.equals(other.textbookRefs, textbookRefs) &&
    other.source_ == source_ &&
    other.version == version &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (topicId.hashCode) +
    (title.hashCode) +
    (bodyMarkdown.hashCode) +
    (readingMinutes.hashCode) +
    (textbookRefs.hashCode) +
    (source_.hashCode) +
    (version.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'Lesson[id=$id, topicId=$topicId, title=$title, bodyMarkdown=$bodyMarkdown, readingMinutes=$readingMinutes, textbookRefs=$textbookRefs, source_=$source_, version=$version, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'topicId'] = this.topicId;
      json[r'title'] = this.title;
      json[r'bodyMarkdown'] = this.bodyMarkdown;
      json[r'readingMinutes'] = this.readingMinutes;
      json[r'textbookRefs'] = this.textbookRefs;
      json[r'source'] = this.source_;
      json[r'version'] = this.version;
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Lesson] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Lesson? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Lesson[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "Lesson[id]" has a null value in JSON.');
        assert(json[r'topicId'] != null, 'Required key "Lesson[topicId]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "Lesson[title]" has a null value in JSON.');
        assert(json[r'bodyMarkdown'] != null, 'Required key "Lesson[bodyMarkdown]" has a null value in JSON.');
        assert(json[r'readingMinutes'] != null, 'Required key "Lesson[readingMinutes]" has a null value in JSON.');
        assert(json[r'textbookRefs'] != null, 'Required key "Lesson[textbookRefs]" has a null value in JSON.');
        assert(json[r'source'] != null, 'Required key "Lesson[source]" has a null value in JSON.');
        assert(json[r'version'] != null, 'Required key "Lesson[version]" has a null value in JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "Lesson[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return Lesson(
        id: mapValueOfType<String>(json, r'id')!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        title: mapValueOfType<String>(json, r'title')!,
        bodyMarkdown: mapValueOfType<String>(json, r'bodyMarkdown')!,
        readingMinutes: mapValueOfType<int>(json, r'readingMinutes')!,
        textbookRefs: TextbookRef.listFromJson(json[r'textbookRefs']),
        source_: LessonSource.fromJson(json[r'source'])!,
        version: mapValueOfType<int>(json, r'version')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<Lesson> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Lesson>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Lesson.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Lesson> mapFromJson(dynamic json) {
    final map = <String, Lesson>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Lesson.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Lesson-objects as value to a dart map
  static Map<String, List<Lesson>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Lesson>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Lesson.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'topicId',
    'title',
    'bodyMarkdown',
    'readingMinutes',
    'textbookRefs',
    'source',
    'version',
    'updatedAt',
  };
}

