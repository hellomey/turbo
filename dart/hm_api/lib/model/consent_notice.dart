//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsentNotice {
  /// Returns a new [ConsentNotice] instance.
  ConsentNotice({
    required this.version,
    this.purposes = const [],
  });

  String version;

  List<ConsentNoticePurposesInner> purposes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsentNotice &&
    other.version == version &&
    _deepEquality.equals(other.purposes, purposes);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (purposes.hashCode);

  @override
  String toString() => 'ConsentNotice[version=$version, purposes=$purposes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'purposes'] = this.purposes;
    return json;
  }

  /// Returns a new [ConsentNotice] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsentNotice? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConsentNotice[$key]" is missing from JSON.');
        });
        assert(json[r'version'] != null, 'Required key "ConsentNotice[version]" has a null value in JSON.');
        assert(json[r'purposes'] != null, 'Required key "ConsentNotice[purposes]" has a null value in JSON.');
        return true;
      }());

      return ConsentNotice(
        version: mapValueOfType<String>(json, r'version')!,
        purposes: ConsentNoticePurposesInner.listFromJson(json[r'purposes']),
      );
    }
    return null;
  }

  static List<ConsentNotice> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsentNotice>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsentNotice.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsentNotice> mapFromJson(dynamic json) {
    final map = <String, ConsentNotice>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsentNotice.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsentNotice-objects as value to a dart map
  static Map<String, List<ConsentNotice>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsentNotice>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsentNotice.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'purposes',
  };
}

