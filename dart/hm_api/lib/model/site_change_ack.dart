//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SiteChangeAck {
  /// Returns a new [SiteChangeAck] instance.
  SiteChangeAck({
    required this.received,
  });

  bool received;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SiteChangeAck &&
    other.received == received;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (received.hashCode);

  @override
  String toString() => 'SiteChangeAck[received=$received]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'received'] = this.received;
    return json;
  }

  /// Returns a new [SiteChangeAck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SiteChangeAck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SiteChangeAck[$key]" is missing from JSON.');
        });
        assert(json[r'received'] != null, 'Required key "SiteChangeAck[received]" has a null value in JSON.');
        return true;
      }());

      return SiteChangeAck(
        received: mapValueOfType<bool>(json, r'received')!,
      );
    }
    return null;
  }

  static List<SiteChangeAck> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SiteChangeAck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SiteChangeAck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SiteChangeAck> mapFromJson(dynamic json) {
    final map = <String, SiteChangeAck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SiteChangeAck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SiteChangeAck-objects as value to a dart map
  static Map<String, List<SiteChangeAck>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SiteChangeAck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SiteChangeAck.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'received',
  };
}

