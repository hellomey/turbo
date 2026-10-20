//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OtpVerifyBody {
  /// Returns a new [OtpVerifyBody] instance.
  OtpVerifyBody({
    required this.email,
    required this.code,
    required this.deviceId,
    required this.platform,
    this.client,
  });

  String email;

  String code;

  String deviceId;

  OtpVerifyBodyPlatformEnum platform;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ClientKind? client;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OtpVerifyBody &&
    other.email == email &&
    other.code == code &&
    other.deviceId == deviceId &&
    other.platform == platform &&
    other.client == client;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (email.hashCode) +
    (code.hashCode) +
    (deviceId.hashCode) +
    (platform.hashCode) +
    (client == null ? 0 : client!.hashCode);

  @override
  String toString() => 'OtpVerifyBody[email=$email, code=$code, deviceId=$deviceId, platform=$platform, client=$client]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'email'] = this.email;
      json[r'code'] = this.code;
      json[r'deviceId'] = this.deviceId;
      json[r'platform'] = this.platform;
    if (this.client != null) {
      json[r'client'] = this.client;
    } else {
      json[r'client'] = null;
    }
    return json;
  }

  /// Returns a new [OtpVerifyBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OtpVerifyBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OtpVerifyBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OtpVerifyBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OtpVerifyBody(
        email: mapValueOfType<String>(json, r'email')!,
        code: mapValueOfType<String>(json, r'code')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        platform: OtpVerifyBodyPlatformEnum.fromJson(json[r'platform'])!,
        client: ClientKind.fromJson(json[r'client']),
      );
    }
    return null;
  }

  static List<OtpVerifyBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpVerifyBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpVerifyBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OtpVerifyBody> mapFromJson(dynamic json) {
    final map = <String, OtpVerifyBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OtpVerifyBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OtpVerifyBody-objects as value to a dart map
  static Map<String, List<OtpVerifyBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OtpVerifyBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OtpVerifyBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'email',
    'code',
    'deviceId',
    'platform',
  };
}


class OtpVerifyBodyPlatformEnum {
  /// Instantiate a new enum with the provided [value].
  const OtpVerifyBodyPlatformEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const android = OtpVerifyBodyPlatformEnum._(r'android');
  static const ios = OtpVerifyBodyPlatformEnum._(r'ios');
  static const web = OtpVerifyBodyPlatformEnum._(r'web');

  /// List of all possible values in this [enum][OtpVerifyBodyPlatformEnum].
  static const values = <OtpVerifyBodyPlatformEnum>[
    android,
    ios,
    web,
  ];

  static OtpVerifyBodyPlatformEnum? fromJson(dynamic value) => OtpVerifyBodyPlatformEnumTypeTransformer().decode(value);

  static List<OtpVerifyBodyPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpVerifyBodyPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpVerifyBodyPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OtpVerifyBodyPlatformEnum] to String,
/// and [decode] dynamic data back to [OtpVerifyBodyPlatformEnum].
class OtpVerifyBodyPlatformEnumTypeTransformer {
  factory OtpVerifyBodyPlatformEnumTypeTransformer() => _instance ??= const OtpVerifyBodyPlatformEnumTypeTransformer._();

  const OtpVerifyBodyPlatformEnumTypeTransformer._();

  String encode(OtpVerifyBodyPlatformEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a OtpVerifyBodyPlatformEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OtpVerifyBodyPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'android': return OtpVerifyBodyPlatformEnum.android;
        case r'ios': return OtpVerifyBodyPlatformEnum.ios;
        case r'web': return OtpVerifyBodyPlatformEnum.web;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [OtpVerifyBodyPlatformEnumTypeTransformer] instance.
  static OtpVerifyBodyPlatformEnumTypeTransformer? _instance;
}


