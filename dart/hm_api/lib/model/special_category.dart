//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SpecialCategory {
  /// Instantiate a new enum with the provided [value].
  const SpecialCategory._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const PWD = SpecialCategory._(r'PWD');
  static const EX_SERVICEMAN = SpecialCategory._(r'EX_SERVICEMAN');
  static const DESTITUTE_WIDOW = SpecialCategory._(r'DESTITUTE_WIDOW');

  /// List of all possible values in this [enum][SpecialCategory].
  static const values = <SpecialCategory>[
    PWD,
    EX_SERVICEMAN,
    DESTITUTE_WIDOW,
  ];

  static SpecialCategory? fromJson(dynamic value) => SpecialCategoryTypeTransformer().decode(value);

  static List<SpecialCategory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SpecialCategory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SpecialCategory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SpecialCategory] to String,
/// and [decode] dynamic data back to [SpecialCategory].
class SpecialCategoryTypeTransformer {
  factory SpecialCategoryTypeTransformer() => _instance ??= const SpecialCategoryTypeTransformer._();

  const SpecialCategoryTypeTransformer._();

  String encode(SpecialCategory data) => data.value;

  /// Decodes a [dynamic value][data] to a SpecialCategory.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SpecialCategory? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'PWD': return SpecialCategory.PWD;
        case r'EX_SERVICEMAN': return SpecialCategory.EX_SERVICEMAN;
        case r'DESTITUTE_WIDOW': return SpecialCategory.DESTITUTE_WIDOW;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SpecialCategoryTypeTransformer] instance.
  static SpecialCategoryTypeTransformer? _instance;
}

