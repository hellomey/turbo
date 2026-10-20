//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsentChoicesBody {
  /// Returns a new [ConsentChoicesBody] instance.
  ConsentChoicesBody({
    required this.noticeVersion,
    this.choices = const [],
  });

  String noticeVersion;

  List<ConsentChoicesBodyChoicesInner> choices;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsentChoicesBody &&
    other.noticeVersion == noticeVersion &&
    _deepEquality.equals(other.choices, choices);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (noticeVersion.hashCode) +
    (choices.hashCode);

  @override
  String toString() => 'ConsentChoicesBody[noticeVersion=$noticeVersion, choices=$choices]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'noticeVersion'] = this.noticeVersion;
      json[r'choices'] = this.choices;
    return json;
  }

  /// Returns a new [ConsentChoicesBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsentChoicesBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConsentChoicesBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ConsentChoicesBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ConsentChoicesBody(
        noticeVersion: mapValueOfType<String>(json, r'noticeVersion')!,
        choices: ConsentChoicesBodyChoicesInner.listFromJson(json[r'choices']),
      );
    }
    return null;
  }

  static List<ConsentChoicesBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsentChoicesBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsentChoicesBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsentChoicesBody> mapFromJson(dynamic json) {
    final map = <String, ConsentChoicesBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsentChoicesBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsentChoicesBody-objects as value to a dart map
  static Map<String, List<ConsentChoicesBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsentChoicesBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsentChoicesBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'noticeVersion',
    'choices',
  };
}

