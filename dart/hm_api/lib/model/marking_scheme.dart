//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MarkingScheme {
  /// Returns a new [MarkingScheme] instance.
  MarkingScheme({
    required this.version,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    this.sections = const [],
    required this.verified,
    required this.sourceUrl,
  });

  int version;

  int durationMinutes;

  /// Minimum value: 0
  int totalQuestions;

  Marks totalMarks;

  List<MarkingSection> sections;

  bool verified;

  String sourceUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MarkingScheme &&
    other.version == version &&
    other.durationMinutes == durationMinutes &&
    other.totalQuestions == totalQuestions &&
    other.totalMarks == totalMarks &&
    _deepEquality.equals(other.sections, sections) &&
    other.verified == verified &&
    other.sourceUrl == sourceUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (durationMinutes.hashCode) +
    (totalQuestions.hashCode) +
    (totalMarks.hashCode) +
    (sections.hashCode) +
    (verified.hashCode) +
    (sourceUrl.hashCode);

  @override
  String toString() => 'MarkingScheme[version=$version, durationMinutes=$durationMinutes, totalQuestions=$totalQuestions, totalMarks=$totalMarks, sections=$sections, verified=$verified, sourceUrl=$sourceUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'durationMinutes'] = this.durationMinutes;
      json[r'totalQuestions'] = this.totalQuestions;
      json[r'totalMarks'] = this.totalMarks;
      json[r'sections'] = this.sections;
      json[r'verified'] = this.verified;
      json[r'sourceUrl'] = this.sourceUrl;
    return json;
  }

  /// Returns a new [MarkingScheme] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MarkingScheme? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MarkingScheme[$key]" is missing from JSON.');
        });
        assert(json[r'version'] != null, 'Required key "MarkingScheme[version]" has a null value in JSON.');
        assert(json[r'durationMinutes'] != null, 'Required key "MarkingScheme[durationMinutes]" has a null value in JSON.');
        assert(json[r'totalQuestions'] != null, 'Required key "MarkingScheme[totalQuestions]" has a null value in JSON.');
        assert(json[r'totalMarks'] != null, 'Required key "MarkingScheme[totalMarks]" has a null value in JSON.');
        assert(json[r'sections'] != null, 'Required key "MarkingScheme[sections]" has a null value in JSON.');
        assert(json[r'verified'] != null, 'Required key "MarkingScheme[verified]" has a null value in JSON.');
        assert(json[r'sourceUrl'] != null, 'Required key "MarkingScheme[sourceUrl]" has a null value in JSON.');
        return true;
      }());

      return MarkingScheme(
        version: mapValueOfType<int>(json, r'version')!,
        durationMinutes: mapValueOfType<int>(json, r'durationMinutes')!,
        totalQuestions: mapValueOfType<int>(json, r'totalQuestions')!,
        totalMarks: Marks.fromJson(json[r'totalMarks'])!,
        sections: MarkingSection.listFromJson(json[r'sections']),
        verified: mapValueOfType<bool>(json, r'verified')!,
        sourceUrl: mapValueOfType<String>(json, r'sourceUrl')!,
      );
    }
    return null;
  }

  static List<MarkingScheme> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MarkingScheme>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MarkingScheme.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MarkingScheme> mapFromJson(dynamic json) {
    final map = <String, MarkingScheme>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MarkingScheme.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MarkingScheme-objects as value to a dart map
  static Map<String, List<MarkingScheme>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MarkingScheme>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MarkingScheme.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'durationMinutes',
    'totalQuestions',
    'totalMarks',
    'sections',
    'verified',
    'sourceUrl',
  };
}

