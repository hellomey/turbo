//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StartMockBody {
  /// Returns a new [StartMockBody] instance.
  StartMockBody({
    required this.mode,
  });

  MockMode mode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StartMockBody &&
    other.mode == mode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mode.hashCode);

  @override
  String toString() => 'StartMockBody[mode=$mode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mode'] = this.mode;
    return json;
  }

  /// Returns a new [StartMockBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StartMockBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StartMockBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StartMockBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StartMockBody(
        mode: MockMode.fromJson(json[r'mode'])!,
      );
    }
    return null;
  }

  static List<StartMockBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StartMockBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StartMockBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StartMockBody> mapFromJson(dynamic json) {
    final map = <String, StartMockBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StartMockBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StartMockBody-objects as value to a dart map
  static Map<String, List<StartMockBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StartMockBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StartMockBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mode',
  };
}

