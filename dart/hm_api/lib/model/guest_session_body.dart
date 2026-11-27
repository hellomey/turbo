//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GuestSessionBody {
  /// Returns a new [GuestSessionBody] instance.
  GuestSessionBody({
    required this.deviceId,
    required this.platform,
    required this.ageConfirmed18,
  });

  String deviceId;

  GuestSessionBodyPlatformEnum platform;

  bool ageConfirmed18;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestSessionBody &&
    other.deviceId == deviceId &&
    other.platform == platform &&
    other.ageConfirmed18 == ageConfirmed18;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (platform.hashCode) +
    (ageConfirmed18.hashCode);

  @override
  String toString() => 'GuestSessionBody[deviceId=$deviceId, platform=$platform, ageConfirmed18=$ageConfirmed18]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'platform'] = this.platform;
      json[r'ageConfirmed18'] = this.ageConfirmed18;
    return json;
  }

  /// Returns a new [GuestSessionBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestSessionBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestSessionBody[$key]" is missing from JSON.');
        });
        assert(json[r'deviceId'] != null, 'Required key "GuestSessionBody[deviceId]" has a null value in JSON.');
        assert(json[r'platform'] != null, 'Required key "GuestSessionBody[platform]" has a null value in JSON.');
        assert(json[r'ageConfirmed18'] != null, 'Required key "GuestSessionBody[ageConfirmed18]" has a null value in JSON.');
        return true;
      }());

      return GuestSessionBody(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        platform: GuestSessionBodyPlatformEnum.fromJson(json[r'platform'])!,
        ageConfirmed18: mapValueOfType<bool>(json, r'ageConfirmed18')!,
      );
    }
    return null;
  }

  static List<GuestSessionBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestSessionBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestSessionBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestSessionBody> mapFromJson(dynamic json) {
    final map = <String, GuestSessionBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestSessionBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestSessionBody-objects as value to a dart map
  static Map<String, List<GuestSessionBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestSessionBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestSessionBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'platform',
    'ageConfirmed18',
  };
}


class GuestSessionBodyPlatformEnum {
  /// Instantiate a new enum with the provided [value].
  const GuestSessionBodyPlatformEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const android = GuestSessionBodyPlatformEnum._(r'android');
  static const ios = GuestSessionBodyPlatformEnum._(r'ios');
  static const web = GuestSessionBodyPlatformEnum._(r'web');

  /// List of all possible values in this [enum][GuestSessionBodyPlatformEnum].
  static const values = <GuestSessionBodyPlatformEnum>[
    android,
    ios,
    web,
  ];

  static GuestSessionBodyPlatformEnum? fromJson(dynamic value) => GuestSessionBodyPlatformEnumTypeTransformer().decode(value);

  static List<GuestSessionBodyPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestSessionBodyPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestSessionBodyPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [GuestSessionBodyPlatformEnum] to String,
/// and [decode] dynamic data back to [GuestSessionBodyPlatformEnum].
class GuestSessionBodyPlatformEnumTypeTransformer {
  factory GuestSessionBodyPlatformEnumTypeTransformer() => _instance ??= const GuestSessionBodyPlatformEnumTypeTransformer._();

  const GuestSessionBodyPlatformEnumTypeTransformer._();

  String encode(GuestSessionBodyPlatformEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a GuestSessionBodyPlatformEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  GuestSessionBodyPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'android': return GuestSessionBodyPlatformEnum.android;
        case r'ios': return GuestSessionBodyPlatformEnum.ios;
        case r'web': return GuestSessionBodyPlatformEnum.web;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GuestSessionBodyPlatformEnumTypeTransformer] instance.
  static GuestSessionBodyPlatformEnumTypeTransformer? _instance;
}


