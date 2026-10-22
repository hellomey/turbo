//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Mistake {
  /// Returns a new [Mistake] instance.
  Mistake({
    required this.questionId,
    required this.topicId,
    required this.stem,
    required this.wrongCount,
    required this.lastWrongAt,
    required this.graded,
  });

  String questionId;

  String topicId;

  String stem;

  int wrongCount;

  DateTime lastWrongAt;

  GradedAnswer graded;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Mistake &&
    other.questionId == questionId &&
    other.topicId == topicId &&
    other.stem == stem &&
    other.wrongCount == wrongCount &&
    other.lastWrongAt == lastWrongAt &&
    other.graded == graded;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (topicId.hashCode) +
    (stem.hashCode) +
    (wrongCount.hashCode) +
    (lastWrongAt.hashCode) +
    (graded.hashCode);

  @override
  String toString() => 'Mistake[questionId=$questionId, topicId=$topicId, stem=$stem, wrongCount=$wrongCount, lastWrongAt=$lastWrongAt, graded=$graded]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'topicId'] = this.topicId;
      json[r'stem'] = this.stem;
      json[r'wrongCount'] = this.wrongCount;
      json[r'lastWrongAt'] = this.lastWrongAt.toUtc().toIso8601String();
      json[r'graded'] = this.graded;
    return json;
  }

  /// Returns a new [Mistake] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Mistake? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Mistake[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Mistake[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Mistake(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        stem: mapValueOfType<String>(json, r'stem')!,
        wrongCount: mapValueOfType<int>(json, r'wrongCount')!,
        lastWrongAt: mapDateTime(json, r'lastWrongAt', r'')!,
        graded: GradedAnswer.fromJson(json[r'graded'])!,
      );
    }
    return null;
  }

  static List<Mistake> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Mistake>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Mistake.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Mistake> mapFromJson(dynamic json) {
    final map = <String, Mistake>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Mistake.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Mistake-objects as value to a dart map
  static Map<String, List<Mistake>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Mistake>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Mistake.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'topicId',
    'stem',
    'wrongCount',
    'lastWrongAt',
    'graded',
  };
}

