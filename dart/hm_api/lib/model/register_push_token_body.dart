//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterPushTokenBody {
  /// Returns a new [RegisterPushTokenBody] instance.
  RegisterPushTokenBody({
    required this.deviceId,
    required this.platform,
    required this.token,
  });

  String deviceId;

  RegisterPushTokenBodyPlatformEnum platform;

  String token;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterPushTokenBody &&
    other.deviceId == deviceId &&
    other.platform == platform &&
    other.token == token;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (platform.hashCode) +
    (token.hashCode);

  @override
  String toString() => 'RegisterPushTokenBody[deviceId=$deviceId, platform=$platform, token=$token]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'platform'] = this.platform;
      json[r'token'] = this.token;
    return json;
  }

  /// Returns a new [RegisterPushTokenBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterPushTokenBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RegisterPushTokenBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RegisterPushTokenBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RegisterPushTokenBody(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        platform: RegisterPushTokenBodyPlatformEnum.fromJson(json[r'platform'])!,
        token: mapValueOfType<String>(json, r'token')!,
      );
    }
    return null;
  }

  static List<RegisterPushTokenBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterPushTokenBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterPushTokenBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterPushTokenBody> mapFromJson(dynamic json) {
    final map = <String, RegisterPushTokenBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterPushTokenBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterPushTokenBody-objects as value to a dart map
  static Map<String, List<RegisterPushTokenBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterPushTokenBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterPushTokenBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'platform',
    'token',
  };
}


class RegisterPushTokenBodyPlatformEnum {
  /// Instantiate a new enum with the provided [value].
  const RegisterPushTokenBodyPlatformEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const android = RegisterPushTokenBodyPlatformEnum._(r'android');
  static const ios = RegisterPushTokenBodyPlatformEnum._(r'ios');

  /// List of all possible values in this [enum][RegisterPushTokenBodyPlatformEnum].
  static const values = <RegisterPushTokenBodyPlatformEnum>[
    android,
    ios,
  ];

  static RegisterPushTokenBodyPlatformEnum? fromJson(dynamic value) => RegisterPushTokenBodyPlatformEnumTypeTransformer().decode(value);

  static List<RegisterPushTokenBodyPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterPushTokenBodyPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterPushTokenBodyPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegisterPushTokenBodyPlatformEnum] to String,
/// and [decode] dynamic data back to [RegisterPushTokenBodyPlatformEnum].
class RegisterPushTokenBodyPlatformEnumTypeTransformer {
  factory RegisterPushTokenBodyPlatformEnumTypeTransformer() => _instance ??= const RegisterPushTokenBodyPlatformEnumTypeTransformer._();

  const RegisterPushTokenBodyPlatformEnumTypeTransformer._();

  String encode(RegisterPushTokenBodyPlatformEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RegisterPushTokenBodyPlatformEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegisterPushTokenBodyPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'android': return RegisterPushTokenBodyPlatformEnum.android;
        case r'ios': return RegisterPushTokenBodyPlatformEnum.ios;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RegisterPushTokenBodyPlatformEnumTypeTransformer] instance.
  static RegisterPushTokenBodyPlatformEnumTypeTransformer? _instance;
}


