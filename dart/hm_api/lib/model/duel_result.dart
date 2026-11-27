//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DuelResult {
  /// Returns a new [DuelResult] instance.
  DuelResult({
    required this.duelId,
    this.results = const [],
    required this.score,
    required this.pointsAwarded,
    required this.pointsWithheld,
    required this.pointsToday,
    required this.dailyPointsCap,
  });

  String duelId;

  List<DuelAnswerResult> results;

  /// Minimum value: 0
  int score;

  /// Minimum value: 0
  int pointsAwarded;

  DuelResultPointsWithheldEnum? pointsWithheld;

  /// Minimum value: 0
  int pointsToday;

  int dailyPointsCap;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DuelResult &&
    other.duelId == duelId &&
    _deepEquality.equals(other.results, results) &&
    other.score == score &&
    other.pointsAwarded == pointsAwarded &&
    other.pointsWithheld == pointsWithheld &&
    other.pointsToday == pointsToday &&
    other.dailyPointsCap == dailyPointsCap;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (duelId.hashCode) +
    (results.hashCode) +
    (score.hashCode) +
    (pointsAwarded.hashCode) +
    (pointsWithheld == null ? 0 : pointsWithheld!.hashCode) +
    (pointsToday.hashCode) +
    (dailyPointsCap.hashCode);

  @override
  String toString() => 'DuelResult[duelId=$duelId, results=$results, score=$score, pointsAwarded=$pointsAwarded, pointsWithheld=$pointsWithheld, pointsToday=$pointsToday, dailyPointsCap=$dailyPointsCap]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'duelId'] = this.duelId;
      json[r'results'] = this.results;
      json[r'score'] = this.score;
      json[r'pointsAwarded'] = this.pointsAwarded;
    if (this.pointsWithheld != null) {
      json[r'pointsWithheld'] = this.pointsWithheld;
    } else {
      json[r'pointsWithheld'] = null;
    }
      json[r'pointsToday'] = this.pointsToday;
      json[r'dailyPointsCap'] = this.dailyPointsCap;
    return json;
  }

  /// Returns a new [DuelResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DuelResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DuelResult[$key]" is missing from JSON.');
        });
        assert(json[r'duelId'] != null, 'Required key "DuelResult[duelId]" has a null value in JSON.');
        assert(json[r'results'] != null, 'Required key "DuelResult[results]" has a null value in JSON.');
        assert(json[r'score'] != null, 'Required key "DuelResult[score]" has a null value in JSON.');
        assert(json[r'pointsAwarded'] != null, 'Required key "DuelResult[pointsAwarded]" has a null value in JSON.');
        assert(json[r'pointsToday'] != null, 'Required key "DuelResult[pointsToday]" has a null value in JSON.');
        assert(json[r'dailyPointsCap'] != null, 'Required key "DuelResult[dailyPointsCap]" has a null value in JSON.');
        return true;
      }());

      return DuelResult(
        duelId: mapValueOfType<String>(json, r'duelId')!,
        results: DuelAnswerResult.listFromJson(json[r'results']),
        score: mapValueOfType<int>(json, r'score')!,
        pointsAwarded: mapValueOfType<int>(json, r'pointsAwarded')!,
        pointsWithheld: DuelResultPointsWithheldEnum.fromJson(json[r'pointsWithheld']),
        pointsToday: mapValueOfType<int>(json, r'pointsToday')!,
        dailyPointsCap: mapValueOfType<int>(json, r'dailyPointsCap')!,
      );
    }
    return null;
  }

  static List<DuelResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DuelResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DuelResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DuelResult> mapFromJson(dynamic json) {
    final map = <String, DuelResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DuelResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DuelResult-objects as value to a dart map
  static Map<String, List<DuelResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DuelResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DuelResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'duelId',
    'results',
    'score',
    'pointsAwarded',
    'pointsWithheld',
    'pointsToday',
    'dailyPointsCap',
  };
}


class DuelResultPointsWithheldEnum {
  /// Instantiate a new enum with the provided [value].
  const DuelResultPointsWithheldEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const tooFast = DuelResultPointsWithheldEnum._(r'too_fast');
  static const tooLate = DuelResultPointsWithheldEnum._(r'too_late');
  static const dailyCap = DuelResultPointsWithheldEnum._(r'daily_cap');

  /// List of all possible values in this [enum][DuelResultPointsWithheldEnum].
  static const values = <DuelResultPointsWithheldEnum>[
    tooFast,
    tooLate,
    dailyCap,
  ];

  static DuelResultPointsWithheldEnum? fromJson(dynamic value) => DuelResultPointsWithheldEnumTypeTransformer().decode(value);

  static List<DuelResultPointsWithheldEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DuelResultPointsWithheldEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DuelResultPointsWithheldEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DuelResultPointsWithheldEnum] to String,
/// and [decode] dynamic data back to [DuelResultPointsWithheldEnum].
class DuelResultPointsWithheldEnumTypeTransformer {
  factory DuelResultPointsWithheldEnumTypeTransformer() => _instance ??= const DuelResultPointsWithheldEnumTypeTransformer._();

  const DuelResultPointsWithheldEnumTypeTransformer._();

  String encode(DuelResultPointsWithheldEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DuelResultPointsWithheldEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DuelResultPointsWithheldEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'too_fast': return DuelResultPointsWithheldEnum.tooFast;
        case r'too_late': return DuelResultPointsWithheldEnum.tooLate;
        case r'daily_cap': return DuelResultPointsWithheldEnum.dailyCap;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DuelResultPointsWithheldEnumTypeTransformer] instance.
  static DuelResultPointsWithheldEnumTypeTransformer? _instance;
}


