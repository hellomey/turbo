//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CheckKind {
  /// Instantiate a new enum with the provided [value].
  const CheckKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lit = CheckKind._(r'lit');
  static const recall = CheckKind._(r'recall');
  static const relight = CheckKind._(r'relight');
  static const gold = CheckKind._(r'gold');

  /// List of all possible values in this [enum][CheckKind].
  static const values = <CheckKind>[
    lit,
    recall,
    relight,
    gold,
  ];

  static CheckKind? fromJson(dynamic value) => CheckKindTypeTransformer().decode(value);

  static List<CheckKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CheckKind] to String,
/// and [decode] dynamic data back to [CheckKind].
class CheckKindTypeTransformer {
  factory CheckKindTypeTransformer() => _instance ??= const CheckKindTypeTransformer._();

  const CheckKindTypeTransformer._();

  String encode(CheckKind data) => data.value;

  /// Decodes a [dynamic value][data] to a CheckKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CheckKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lit': return CheckKind.lit;
        case r'recall': return CheckKind.recall;
        case r'relight': return CheckKind.relight;
        case r'gold': return CheckKind.gold;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CheckKindTypeTransformer] instance.
  static CheckKindTypeTransformer? _instance;
}

