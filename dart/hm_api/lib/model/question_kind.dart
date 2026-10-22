//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// `descriptive` is a future type: stored and listed, not yet answerable (ADR-0013).
class QuestionKind {
  /// Instantiate a new enum with the provided [value].
  const QuestionKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const singleChoice = QuestionKind._(r'single_choice');
  static const multiChoice = QuestionKind._(r'multi_choice');
  static const numeric = QuestionKind._(r'numeric');
  static const descriptive = QuestionKind._(r'descriptive');

  /// List of all possible values in this [enum][QuestionKind].
  static const values = <QuestionKind>[
    singleChoice,
    multiChoice,
    numeric,
    descriptive,
  ];

  static QuestionKind? fromJson(dynamic value) => QuestionKindTypeTransformer().decode(value);

  static List<QuestionKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [QuestionKind] to String,
/// and [decode] dynamic data back to [QuestionKind].
class QuestionKindTypeTransformer {
  factory QuestionKindTypeTransformer() => _instance ??= const QuestionKindTypeTransformer._();

  const QuestionKindTypeTransformer._();

  String encode(QuestionKind data) => data.value;

  /// Decodes a [dynamic value][data] to a QuestionKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  QuestionKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single_choice': return QuestionKind.singleChoice;
        case r'multi_choice': return QuestionKind.multiChoice;
        case r'numeric': return QuestionKind.numeric;
        case r'descriptive': return QuestionKind.descriptive;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [QuestionKindTypeTransformer] instance.
  static QuestionKindTypeTransformer? _instance;
}

