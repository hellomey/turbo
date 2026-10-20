//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsentChoicesBodyChoicesInner {
  /// Returns a new [ConsentChoicesBodyChoicesInner] instance.
  ConsentChoicesBodyChoicesInner({
    required this.purpose,
    required this.granted,
  });

  ConsentPurpose purpose;

  bool granted;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsentChoicesBodyChoicesInner &&
    other.purpose == purpose &&
    other.granted == granted;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (purpose.hashCode) +
    (granted.hashCode);

  @override
  String toString() => 'ConsentChoicesBodyChoicesInner[purpose=$purpose, granted=$granted]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'purpose'] = this.purpose;
      json[r'granted'] = this.granted;
    return json;
  }

  /// Returns a new [ConsentChoicesBodyChoicesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsentChoicesBodyChoicesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConsentChoicesBodyChoicesInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ConsentChoicesBodyChoicesInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ConsentChoicesBodyChoicesInner(
        purpose: ConsentPurpose.fromJson(json[r'purpose'])!,
        granted: mapValueOfType<bool>(json, r'granted')!,
      );
    }
    return null;
  }

  static List<ConsentChoicesBodyChoicesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsentChoicesBodyChoicesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsentChoicesBodyChoicesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsentChoicesBodyChoicesInner> mapFromJson(dynamic json) {
    final map = <String, ConsentChoicesBodyChoicesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsentChoicesBodyChoicesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsentChoicesBodyChoicesInner-objects as value to a dart map
  static Map<String, List<ConsentChoicesBodyChoicesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsentChoicesBodyChoicesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsentChoicesBodyChoicesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'purpose',
    'granted',
  };
}

