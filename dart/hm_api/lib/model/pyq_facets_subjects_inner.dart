//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PyqFacetsSubjectsInner {
  /// Returns a new [PyqFacetsSubjectsInner] instance.
  PyqFacetsSubjectsInner({
    required this.code,
    required this.name,
    required this.count,
  });

  String code;

  String name;

  int count;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PyqFacetsSubjectsInner &&
    other.code == code &&
    other.name == name &&
    other.count == count;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (count.hashCode);

  @override
  String toString() => 'PyqFacetsSubjectsInner[code=$code, name=$name, count=$count]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'count'] = this.count;
    return json;
  }

  /// Returns a new [PyqFacetsSubjectsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PyqFacetsSubjectsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PyqFacetsSubjectsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PyqFacetsSubjectsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PyqFacetsSubjectsInner(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        count: mapValueOfType<int>(json, r'count')!,
      );
    }
    return null;
  }

  static List<PyqFacetsSubjectsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PyqFacetsSubjectsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PyqFacetsSubjectsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PyqFacetsSubjectsInner> mapFromJson(dynamic json) {
    final map = <String, PyqFacetsSubjectsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PyqFacetsSubjectsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PyqFacetsSubjectsInner-objects as value to a dart map
  static Map<String, List<PyqFacetsSubjectsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PyqFacetsSubjectsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PyqFacetsSubjectsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'count',
  };
}

