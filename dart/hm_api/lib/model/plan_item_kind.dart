//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PlanItemKind {
  /// Instantiate a new enum with the provided [value].
  const PlanItemKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lesson = PlanItemKind._(r'lesson');
  static const litCheck = PlanItemKind._(r'lit_check');
  static const relight = PlanItemKind._(r'relight');
  static const practice = PlanItemKind._(r'practice');
  static const pyq = PlanItemKind._(r'pyq');
  static const gold = PlanItemKind._(r'gold');
  static const mock = PlanItemKind._(r'mock');
  static const mistakeReview = PlanItemKind._(r'mistake_review');
  static const checklist = PlanItemKind._(r'checklist');

  /// List of all possible values in this [enum][PlanItemKind].
  static const values = <PlanItemKind>[
    lesson,
    litCheck,
    relight,
    practice,
    pyq,
    gold,
    mock,
    mistakeReview,
    checklist,
  ];

  static PlanItemKind? fromJson(dynamic value) => PlanItemKindTypeTransformer().decode(value);

  static List<PlanItemKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanItemKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanItemKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PlanItemKind] to String,
/// and [decode] dynamic data back to [PlanItemKind].
class PlanItemKindTypeTransformer {
  factory PlanItemKindTypeTransformer() => _instance ??= const PlanItemKindTypeTransformer._();

  const PlanItemKindTypeTransformer._();

  String encode(PlanItemKind data) => data.value;

  /// Decodes a [dynamic value][data] to a PlanItemKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PlanItemKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson': return PlanItemKind.lesson;
        case r'lit_check': return PlanItemKind.litCheck;
        case r'relight': return PlanItemKind.relight;
        case r'practice': return PlanItemKind.practice;
        case r'pyq': return PlanItemKind.pyq;
        case r'gold': return PlanItemKind.gold;
        case r'mock': return PlanItemKind.mock;
        case r'mistake_review': return PlanItemKind.mistakeReview;
        case r'checklist': return PlanItemKind.checklist;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PlanItemKindTypeTransformer] instance.
  static PlanItemKindTypeTransformer? _instance;
}

