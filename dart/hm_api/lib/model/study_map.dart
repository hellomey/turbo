//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudyMap {
  /// Returns a new [StudyMap] instance.
  StudyMap({
    required this.examCode,
    this.subjects = const [],
    required this.totalTopics,
  });

  String examCode;

  List<StudyMapSubjectsInner> subjects;

  int totalTopics;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudyMap &&
    other.examCode == examCode &&
    _deepEquality.equals(other.subjects, subjects) &&
    other.totalTopics == totalTopics;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (subjects.hashCode) +
    (totalTopics.hashCode);

  @override
  String toString() => 'StudyMap[examCode=$examCode, subjects=$subjects, totalTopics=$totalTopics]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'subjects'] = this.subjects;
      json[r'totalTopics'] = this.totalTopics;
    return json;
  }

  /// Returns a new [StudyMap] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudyMap? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StudyMap[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StudyMap[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StudyMap(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        subjects: StudyMapSubjectsInner.listFromJson(json[r'subjects']),
        totalTopics: mapValueOfType<int>(json, r'totalTopics')!,
      );
    }
    return null;
  }

  static List<StudyMap> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudyMap>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudyMap.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudyMap> mapFromJson(dynamic json) {
    final map = <String, StudyMap>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudyMap.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudyMap-objects as value to a dart map
  static Map<String, List<StudyMap>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudyMap>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudyMap.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'subjects',
    'totalTopics',
  };
}

