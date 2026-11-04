//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PyqFacets {
  /// Returns a new [PyqFacets] instance.
  PyqFacets({
    required this.examCode,
    this.years = const [],
    this.subjects = const [],
  });

  String examCode;

  List<PyqFacetsYearsInner> years;

  List<PyqFacetsSubjectsInner> subjects;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PyqFacets &&
    other.examCode == examCode &&
    _deepEquality.equals(other.years, years) &&
    _deepEquality.equals(other.subjects, subjects);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (years.hashCode) +
    (subjects.hashCode);

  @override
  String toString() => 'PyqFacets[examCode=$examCode, years=$years, subjects=$subjects]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'years'] = this.years;
      json[r'subjects'] = this.subjects;
    return json;
  }

  /// Returns a new [PyqFacets] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PyqFacets? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PyqFacets[$key]" is missing from JSON.');
        });
        assert(json[r'examCode'] != null, 'Required key "PyqFacets[examCode]" has a null value in JSON.');
        assert(json[r'years'] != null, 'Required key "PyqFacets[years]" has a null value in JSON.');
        assert(json[r'subjects'] != null, 'Required key "PyqFacets[subjects]" has a null value in JSON.');
        return true;
      }());

      return PyqFacets(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        years: PyqFacetsYearsInner.listFromJson(json[r'years']),
        subjects: PyqFacetsSubjectsInner.listFromJson(json[r'subjects']),
      );
    }
    return null;
  }

  static List<PyqFacets> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PyqFacets>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PyqFacets.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PyqFacets> mapFromJson(dynamic json) {
    final map = <String, PyqFacets>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PyqFacets.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PyqFacets-objects as value to a dart map
  static Map<String, List<PyqFacets>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PyqFacets>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PyqFacets.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'years',
    'subjects',
  };
}

