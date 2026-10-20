//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class Role {
  /// Instantiate a new enum with the provided [value].
  const Role._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const VISITOR = Role._(r'VISITOR');
  static const ASPIRANT = Role._(r'ASPIRANT');
  static const SUPPORTER = Role._(r'SUPPORTER');
  static const MENTOR = Role._(r'MENTOR');
  static const CREATOR = Role._(r'CREATOR');
  static const REVIEWER = Role._(r'REVIEWER');
  static const PUBLISHER = Role._(r'PUBLISHER');
  static const INSTITUTION_ADMIN = Role._(r'INSTITUTION_ADMIN');
  static const SUPPORT_AGENT = Role._(r'SUPPORT_AGENT');
  static const MODERATOR = Role._(r'MODERATOR');
  static const OPS = Role._(r'OPS');
  static const ADMIN = Role._(r'ADMIN');
  static const SYSTEM = Role._(r'SYSTEM');

  /// List of all possible values in this [enum][Role].
  static const values = <Role>[
    VISITOR,
    ASPIRANT,
    SUPPORTER,
    MENTOR,
    CREATOR,
    REVIEWER,
    PUBLISHER,
    INSTITUTION_ADMIN,
    SUPPORT_AGENT,
    MODERATOR,
    OPS,
    ADMIN,
    SYSTEM,
  ];

  static Role? fromJson(dynamic value) => RoleTypeTransformer().decode(value);

  static List<Role> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Role>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Role.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Role] to String,
/// and [decode] dynamic data back to [Role].
class RoleTypeTransformer {
  factory RoleTypeTransformer() => _instance ??= const RoleTypeTransformer._();

  const RoleTypeTransformer._();

  String encode(Role data) => data.value;

  /// Decodes a [dynamic value][data] to a Role.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Role? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'VISITOR': return Role.VISITOR;
        case r'ASPIRANT': return Role.ASPIRANT;
        case r'SUPPORTER': return Role.SUPPORTER;
        case r'MENTOR': return Role.MENTOR;
        case r'CREATOR': return Role.CREATOR;
        case r'REVIEWER': return Role.REVIEWER;
        case r'PUBLISHER': return Role.PUBLISHER;
        case r'INSTITUTION_ADMIN': return Role.INSTITUTION_ADMIN;
        case r'SUPPORT_AGENT': return Role.SUPPORT_AGENT;
        case r'MODERATOR': return Role.MODERATOR;
        case r'OPS': return Role.OPS;
        case r'ADMIN': return Role.ADMIN;
        case r'SYSTEM': return Role.SYSTEM;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RoleTypeTransformer] instance.
  static RoleTypeTransformer? _instance;
}

