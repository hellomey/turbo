//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OtpRequestBody {
  /// Returns a new [OtpRequestBody] instance.
  OtpRequestBody({
    required this.email,
    this.purpose,
  });

  String email;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  OtpPurpose? purpose;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OtpRequestBody &&
    other.email == email &&
    other.purpose == purpose;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (email.hashCode) +
    (purpose == null ? 0 : purpose!.hashCode);

  @override
  String toString() => 'OtpRequestBody[email=$email, purpose=$purpose]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'email'] = this.email;
    if (this.purpose != null) {
      json[r'purpose'] = this.purpose;
    } else {
      json[r'purpose'] = null;
    }
    return json;
  }

  /// Returns a new [OtpRequestBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OtpRequestBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OtpRequestBody[$key]" is missing from JSON.');
        });
        assert(json[r'email'] != null, 'Required key "OtpRequestBody[email]" has a null value in JSON.');
        return true;
      }());

      return OtpRequestBody(
        email: mapValueOfType<String>(json, r'email')!,
        purpose: OtpPurpose.fromJson(json[r'purpose']),
      );
    }
    return null;
  }

  static List<OtpRequestBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpRequestBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpRequestBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OtpRequestBody> mapFromJson(dynamic json) {
    final map = <String, OtpRequestBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OtpRequestBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OtpRequestBody-objects as value to a dart map
  static Map<String, List<OtpRequestBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OtpRequestBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OtpRequestBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'email',
  };
}

