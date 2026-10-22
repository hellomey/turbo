//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PracticeMode {
  /// Instantiate a new enum with the provided [value].
  const PracticeMode._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const practice = PracticeMode._(r'practice');
  static const pyq = PracticeMode._(r'pyq');
  static const mistakes = PracticeMode._(r'mistakes');
  static const drill = PracticeMode._(r'drill');

  /// List of all possible values in this [enum][PracticeMode].
  static const values = <PracticeMode>[
    practice,
    pyq,
    mistakes,
    drill,
  ];

  static PracticeMode? fromJson(dynamic value) => PracticeModeTypeTransformer().decode(value);

  static List<PracticeMode> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PracticeMode>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PracticeMode.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PracticeMode] to String,
/// and [decode] dynamic data back to [PracticeMode].
class PracticeModeTypeTransformer {
  factory PracticeModeTypeTransformer() => _instance ??= const PracticeModeTypeTransformer._();

  const PracticeModeTypeTransformer._();

  String encode(PracticeMode data) => data.value;

  /// Decodes a [dynamic value][data] to a PracticeMode.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PracticeMode? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'practice': return PracticeMode.practice;
        case r'pyq': return PracticeMode.pyq;
        case r'mistakes': return PracticeMode.mistakes;
        case r'drill': return PracticeMode.drill;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PracticeModeTypeTransformer] instance.
  static PracticeModeTypeTransformer? _instance;
}

