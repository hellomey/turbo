//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// `descriptive` papers are listed but cannot be taken in the Exam Hall yet.
class PaperType {
  /// Instantiate a new enum with the provided [value].
  const PaperType._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const objective = PaperType._(r'objective');
  static const descriptive = PaperType._(r'descriptive');

  /// List of all possible values in this [enum][PaperType].
  static const values = <PaperType>[
    objective,
    descriptive,
  ];

  static PaperType? fromJson(dynamic value) => PaperTypeTypeTransformer().decode(value);

  static List<PaperType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaperType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaperType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaperType] to String,
/// and [decode] dynamic data back to [PaperType].
class PaperTypeTypeTransformer {
  factory PaperTypeTypeTransformer() => _instance ??= const PaperTypeTypeTransformer._();

  const PaperTypeTypeTransformer._();

  String encode(PaperType data) => data.value;

  /// Decodes a [dynamic value][data] to a PaperType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaperType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'objective': return PaperType.objective;
        case r'descriptive': return PaperType.descriptive;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PaperTypeTypeTransformer] instance.
  static PaperTypeTypeTransformer? _instance;
}

