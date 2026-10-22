//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StartPracticeBody {
  /// Returns a new [StartPracticeBody] instance.
  StartPracticeBody({
    required this.mode,
    required this.examCode,
    this.subjectCode,
    this.topicId,
    this.drillId,
    this.size = 10,
  });

  PracticeMode mode;

  String examCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subjectCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? topicId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? drillId;

  /// Minimum value: 1
  /// Maximum value: 50
  int size;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StartPracticeBody &&
    other.mode == mode &&
    other.examCode == examCode &&
    other.subjectCode == subjectCode &&
    other.topicId == topicId &&
    other.drillId == drillId &&
    other.size == size;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mode.hashCode) +
    (examCode.hashCode) +
    (subjectCode == null ? 0 : subjectCode!.hashCode) +
    (topicId == null ? 0 : topicId!.hashCode) +
    (drillId == null ? 0 : drillId!.hashCode) +
    (size.hashCode);

  @override
  String toString() => 'StartPracticeBody[mode=$mode, examCode=$examCode, subjectCode=$subjectCode, topicId=$topicId, drillId=$drillId, size=$size]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mode'] = this.mode;
      json[r'examCode'] = this.examCode;
    if (this.subjectCode != null) {
      json[r'subjectCode'] = this.subjectCode;
    } else {
      json[r'subjectCode'] = null;
    }
    if (this.topicId != null) {
      json[r'topicId'] = this.topicId;
    } else {
      json[r'topicId'] = null;
    }
    if (this.drillId != null) {
      json[r'drillId'] = this.drillId;
    } else {
      json[r'drillId'] = null;
    }
      json[r'size'] = this.size;
    return json;
  }

  /// Returns a new [StartPracticeBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StartPracticeBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StartPracticeBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StartPracticeBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StartPracticeBody(
        mode: PracticeMode.fromJson(json[r'mode'])!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        subjectCode: mapValueOfType<String>(json, r'subjectCode'),
        topicId: mapValueOfType<String>(json, r'topicId'),
        drillId: mapValueOfType<String>(json, r'drillId'),
        size: mapValueOfType<int>(json, r'size') ?? 10,
      );
    }
    return null;
  }

  static List<StartPracticeBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StartPracticeBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StartPracticeBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StartPracticeBody> mapFromJson(dynamic json) {
    final map = <String, StartPracticeBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StartPracticeBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StartPracticeBody-objects as value to a dart map
  static Map<String, List<StartPracticeBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StartPracticeBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StartPracticeBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mode',
    'examCode',
  };
}

