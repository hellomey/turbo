//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class TrophyCode {
  /// Instantiate a new enum with the provided [value].
  const TrophyCode._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const firstLamp = TrophyCode._(r'first_lamp');
  static const firstGold = TrophyCode._(r'first_gold');
  static const subjectLit = TrophyCode._(r'subject_lit');
  static const firstMock = TrophyCode._(r'first_mock');
  static const fiveStudyDays = TrophyCode._(r'five_study_days');
  static const expoChallenge = TrophyCode._(r'expo_challenge');

  /// List of all possible values in this [enum][TrophyCode].
  static const values = <TrophyCode>[
    firstLamp,
    firstGold,
    subjectLit,
    firstMock,
    fiveStudyDays,
    expoChallenge,
  ];

  static TrophyCode? fromJson(dynamic value) => TrophyCodeTypeTransformer().decode(value);

  static List<TrophyCode> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TrophyCode>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TrophyCode.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TrophyCode] to String,
/// and [decode] dynamic data back to [TrophyCode].
class TrophyCodeTypeTransformer {
  factory TrophyCodeTypeTransformer() => _instance ??= const TrophyCodeTypeTransformer._();

  const TrophyCodeTypeTransformer._();

  String encode(TrophyCode data) => data.value;

  /// Decodes a [dynamic value][data] to a TrophyCode.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TrophyCode? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'first_lamp': return TrophyCode.firstLamp;
        case r'first_gold': return TrophyCode.firstGold;
        case r'subject_lit': return TrophyCode.subjectLit;
        case r'first_mock': return TrophyCode.firstMock;
        case r'five_study_days': return TrophyCode.fiveStudyDays;
        case r'expo_challenge': return TrophyCode.expoChallenge;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TrophyCodeTypeTransformer] instance.
  static TrophyCodeTypeTransformer? _instance;
}

