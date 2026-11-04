//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeskTotpEnrollResponse {
  /// Returns a new [DeskTotpEnrollResponse] instance.
  DeskTotpEnrollResponse({
    required this.otpauthUri,
    required this.secret,
  });

  /// Show as a QR code. Shown only until the first successful verify.
  String otpauthUri;

  /// Base32, for manual entry
  String secret;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeskTotpEnrollResponse &&
    other.otpauthUri == otpauthUri &&
    other.secret == secret;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (otpauthUri.hashCode) +
    (secret.hashCode);

  @override
  String toString() => 'DeskTotpEnrollResponse[otpauthUri=$otpauthUri, secret=$secret]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'otpauthUri'] = this.otpauthUri;
      json[r'secret'] = this.secret;
    return json;
  }

  /// Returns a new [DeskTotpEnrollResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeskTotpEnrollResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeskTotpEnrollResponse[$key]" is missing from JSON.');
        });
        assert(json[r'otpauthUri'] != null, 'Required key "DeskTotpEnrollResponse[otpauthUri]" has a null value in JSON.');
        assert(json[r'secret'] != null, 'Required key "DeskTotpEnrollResponse[secret]" has a null value in JSON.');
        return true;
      }());

      return DeskTotpEnrollResponse(
        otpauthUri: mapValueOfType<String>(json, r'otpauthUri')!,
        secret: mapValueOfType<String>(json, r'secret')!,
      );
    }
    return null;
  }

  static List<DeskTotpEnrollResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeskTotpEnrollResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeskTotpEnrollResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeskTotpEnrollResponse> mapFromJson(dynamic json) {
    final map = <String, DeskTotpEnrollResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeskTotpEnrollResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeskTotpEnrollResponse-objects as value to a dart map
  static Map<String, List<DeskTotpEnrollResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeskTotpEnrollResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeskTotpEnrollResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'otpauthUri',
    'secret',
  };
}

