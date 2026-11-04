//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsentStateChoicesInner {
  /// Returns a new [ConsentStateChoicesInner] instance.
  ConsentStateChoicesInner({
    required this.purpose,
    required this.granted,
    required this.at,
  });

  ConsentPurpose purpose;

  bool granted;

  DateTime at;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsentStateChoicesInner &&
    other.purpose == purpose &&
    other.granted == granted &&
    other.at == at;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (purpose.hashCode) +
    (granted.hashCode) +
    (at.hashCode);

  @override
  String toString() => 'ConsentStateChoicesInner[purpose=$purpose, granted=$granted, at=$at]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'purpose'] = this.purpose;
      json[r'granted'] = this.granted;
      json[r'at'] = this.at.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ConsentStateChoicesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsentStateChoicesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConsentStateChoicesInner[$key]" is missing from JSON.');
        });
        assert(json[r'purpose'] != null, 'Required key "ConsentStateChoicesInner[purpose]" has a null value in JSON.');
        assert(json[r'granted'] != null, 'Required key "ConsentStateChoicesInner[granted]" has a null value in JSON.');
        assert(json[r'at'] != null, 'Required key "ConsentStateChoicesInner[at]" has a null value in JSON.');
        return true;
      }());

      return ConsentStateChoicesInner(
        purpose: ConsentPurpose.fromJson(json[r'purpose'])!,
        granted: mapValueOfType<bool>(json, r'granted')!,
        at: mapDateTime(json, r'at', r'')!,
      );
    }
    return null;
  }

  static List<ConsentStateChoicesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsentStateChoicesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsentStateChoicesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsentStateChoicesInner> mapFromJson(dynamic json) {
    final map = <String, ConsentStateChoicesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsentStateChoicesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsentStateChoicesInner-objects as value to a dart map
  static Map<String, List<ConsentStateChoicesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsentStateChoicesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsentStateChoicesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'purpose',
    'granted',
    'at',
  };
}

