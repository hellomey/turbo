//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class Qualification {
  /// Instantiate a new enum with the provided [value].
  const Qualification._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sslc = Qualification._(r'sslc');
  static const hsc = Qualification._(r'hsc');
  static const iti = Qualification._(r'iti');
  static const diploma = Qualification._(r'diploma');
  static const degree = Qualification._(r'degree');
  static const pg = Qualification._(r'pg');

  /// List of all possible values in this [enum][Qualification].
  static const values = <Qualification>[
    sslc,
    hsc,
    iti,
    diploma,
    degree,
    pg,
  ];

  static Qualification? fromJson(dynamic value) => QualificationTypeTransformer().decode(value);

  static List<Qualification> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Qualification>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Qualification.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Qualification] to String,
/// and [decode] dynamic data back to [Qualification].
class QualificationTypeTransformer {
  factory QualificationTypeTransformer() => _instance ??= const QualificationTypeTransformer._();

  const QualificationTypeTransformer._();

  String encode(Qualification data) => data.value;

  /// Decodes a [dynamic value][data] to a Qualification.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Qualification? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sslc': return Qualification.sslc;
        case r'hsc': return Qualification.hsc;
        case r'iti': return Qualification.iti;
        case r'diploma': return Qualification.diploma;
        case r'degree': return Qualification.degree;
        case r'pg': return Qualification.pg;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [QualificationTypeTransformer] instance.
  static QualificationTypeTransformer? _instance;
}

