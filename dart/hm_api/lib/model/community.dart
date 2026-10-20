//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class Community {
  /// Instantiate a new enum with the provided [value].
  const Community._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const OC = Community._(r'OC');
  static const BC = Community._(r'BC');
  static const BCM = Community._(r'BCM');
  static const MBC_DNC = Community._(r'MBC_DNC');
  static const SC = Community._(r'SC');
  static const SCA = Community._(r'SCA');
  static const ST = Community._(r'ST');

  /// List of all possible values in this [enum][Community].
  static const values = <Community>[
    OC,
    BC,
    BCM,
    MBC_DNC,
    SC,
    SCA,
    ST,
  ];

  static Community? fromJson(dynamic value) => CommunityTypeTransformer().decode(value);

  static List<Community> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Community>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Community.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Community] to String,
/// and [decode] dynamic data back to [Community].
class CommunityTypeTransformer {
  factory CommunityTypeTransformer() => _instance ??= const CommunityTypeTransformer._();

  const CommunityTypeTransformer._();

  String encode(Community data) => data.value;

  /// Decodes a [dynamic value][data] to a Community.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Community? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'OC': return Community.OC;
        case r'BC': return Community.BC;
        case r'BCM': return Community.BCM;
        case r'MBC_DNC': return Community.MBC_DNC;
        case r'SC': return Community.SC;
        case r'SCA': return Community.SCA;
        case r'ST': return Community.ST;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CommunityTypeTransformer] instance.
  static CommunityTypeTransformer? _instance;
}

