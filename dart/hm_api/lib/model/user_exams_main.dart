//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserExamsMain {
  /// Returns a new [UserExamsMain] instance.
  UserExamsMain({
    required this.code,
    required this.name,
    required this.conductingBody,
    required this.level,
    required this.minQualification,
    required this.fullPrep,
  });

  String code;

  String name;

  String conductingBody;

  UserExamsMainLevelEnum level;

  Qualification minQualification;

  bool fullPrep;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserExamsMain &&
    other.code == code &&
    other.name == name &&
    other.conductingBody == conductingBody &&
    other.level == level &&
    other.minQualification == minQualification &&
    other.fullPrep == fullPrep;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (conductingBody.hashCode) +
    (level.hashCode) +
    (minQualification.hashCode) +
    (fullPrep.hashCode);

  @override
  String toString() => 'UserExamsMain[code=$code, name=$name, conductingBody=$conductingBody, level=$level, minQualification=$minQualification, fullPrep=$fullPrep]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'conductingBody'] = this.conductingBody;
      json[r'level'] = this.level;
      json[r'minQualification'] = this.minQualification;
      json[r'fullPrep'] = this.fullPrep;
    return json;
  }

  /// Returns a new [UserExamsMain] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserExamsMain? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserExamsMain[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "UserExamsMain[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "UserExamsMain[name]" has a null value in JSON.');
        assert(json[r'conductingBody'] != null, 'Required key "UserExamsMain[conductingBody]" has a null value in JSON.');
        assert(json[r'level'] != null, 'Required key "UserExamsMain[level]" has a null value in JSON.');
        assert(json[r'minQualification'] != null, 'Required key "UserExamsMain[minQualification]" has a null value in JSON.');
        assert(json[r'fullPrep'] != null, 'Required key "UserExamsMain[fullPrep]" has a null value in JSON.');
        return true;
      }());

      return UserExamsMain(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        conductingBody: mapValueOfType<String>(json, r'conductingBody')!,
        level: UserExamsMainLevelEnum.fromJson(json[r'level'])!,
        minQualification: Qualification.fromJson(json[r'minQualification'])!,
        fullPrep: mapValueOfType<bool>(json, r'fullPrep')!,
      );
    }
    return null;
  }

  static List<UserExamsMain> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserExamsMain>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserExamsMain.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserExamsMain> mapFromJson(dynamic json) {
    final map = <String, UserExamsMain>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserExamsMain.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserExamsMain-objects as value to a dart map
  static Map<String, List<UserExamsMain>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserExamsMain>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserExamsMain.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'conductingBody',
    'level',
    'minQualification',
    'fullPrep',
  };
}


class UserExamsMainLevelEnum {
  /// Instantiate a new enum with the provided [value].
  const UserExamsMainLevelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const state = UserExamsMainLevelEnum._(r'state');
  static const central = UserExamsMainLevelEnum._(r'central');

  /// List of all possible values in this [enum][UserExamsMainLevelEnum].
  static const values = <UserExamsMainLevelEnum>[
    state,
    central,
  ];

  static UserExamsMainLevelEnum? fromJson(dynamic value) => UserExamsMainLevelEnumTypeTransformer().decode(value);

  static List<UserExamsMainLevelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserExamsMainLevelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserExamsMainLevelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UserExamsMainLevelEnum] to String,
/// and [decode] dynamic data back to [UserExamsMainLevelEnum].
class UserExamsMainLevelEnumTypeTransformer {
  factory UserExamsMainLevelEnumTypeTransformer() => _instance ??= const UserExamsMainLevelEnumTypeTransformer._();

  const UserExamsMainLevelEnumTypeTransformer._();

  String encode(UserExamsMainLevelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UserExamsMainLevelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UserExamsMainLevelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'state': return UserExamsMainLevelEnum.state;
        case r'central': return UserExamsMainLevelEnum.central;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UserExamsMainLevelEnumTypeTransformer] instance.
  static UserExamsMainLevelEnumTypeTransformer? _instance;
}


