//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SundayReport {
  /// Returns a new [SundayReport] instance.
  SundayReport({
    required this.id,
    required this.weekStart,
    required this.tier,
    required this.createdAt,
    required this.lampsLit,
    required this.steadyEarned,
    required this.goldEarned,
    required this.relit,
    required this.dimmedNow,
    required this.questionsAnswered,
    required this.accuracyPct,
    required this.mocksTaken,
    required this.studyMinutes,
    this.lines = const [],
    this.nextWeek = const [],
  });

  String id;

  DateTime weekStart;

  SundayReportTierEnum tier;

  DateTime createdAt;

  int lampsLit;

  int steadyEarned;

  int goldEarned;

  int relit;

  int dimmedNow;

  int questionsAnswered;

  /// Minimum value: 0
  /// Maximum value: 100
  int? accuracyPct;

  int mocksTaken;

  int studyMinutes;

  List<String> lines;

  List<String>? nextWeek;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SundayReport &&
    other.id == id &&
    other.weekStart == weekStart &&
    other.tier == tier &&
    other.createdAt == createdAt &&
    other.lampsLit == lampsLit &&
    other.steadyEarned == steadyEarned &&
    other.goldEarned == goldEarned &&
    other.relit == relit &&
    other.dimmedNow == dimmedNow &&
    other.questionsAnswered == questionsAnswered &&
    other.accuracyPct == accuracyPct &&
    other.mocksTaken == mocksTaken &&
    other.studyMinutes == studyMinutes &&
    _deepEquality.equals(other.lines, lines) &&
    _deepEquality.equals(other.nextWeek, nextWeek);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (weekStart.hashCode) +
    (tier.hashCode) +
    (createdAt.hashCode) +
    (lampsLit.hashCode) +
    (steadyEarned.hashCode) +
    (goldEarned.hashCode) +
    (relit.hashCode) +
    (dimmedNow.hashCode) +
    (questionsAnswered.hashCode) +
    (accuracyPct == null ? 0 : accuracyPct!.hashCode) +
    (mocksTaken.hashCode) +
    (studyMinutes.hashCode) +
    (lines.hashCode) +
    (nextWeek == null ? 0 : nextWeek!.hashCode);

  @override
  String toString() => 'SundayReport[id=$id, weekStart=$weekStart, tier=$tier, createdAt=$createdAt, lampsLit=$lampsLit, steadyEarned=$steadyEarned, goldEarned=$goldEarned, relit=$relit, dimmedNow=$dimmedNow, questionsAnswered=$questionsAnswered, accuracyPct=$accuracyPct, mocksTaken=$mocksTaken, studyMinutes=$studyMinutes, lines=$lines, nextWeek=$nextWeek]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'weekStart'] = _dateFormatter.format(this.weekStart.toUtc());
      json[r'tier'] = this.tier;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'lampsLit'] = this.lampsLit;
      json[r'steadyEarned'] = this.steadyEarned;
      json[r'goldEarned'] = this.goldEarned;
      json[r'relit'] = this.relit;
      json[r'dimmedNow'] = this.dimmedNow;
      json[r'questionsAnswered'] = this.questionsAnswered;
    if (this.accuracyPct != null) {
      json[r'accuracyPct'] = this.accuracyPct;
    } else {
      json[r'accuracyPct'] = null;
    }
      json[r'mocksTaken'] = this.mocksTaken;
      json[r'studyMinutes'] = this.studyMinutes;
      json[r'lines'] = this.lines;
    if (this.nextWeek != null) {
      json[r'nextWeek'] = this.nextWeek;
    } else {
      json[r'nextWeek'] = null;
    }
    return json;
  }

  /// Returns a new [SundayReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SundayReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SundayReport[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "SundayReport[id]" has a null value in JSON.');
        assert(json[r'weekStart'] != null, 'Required key "SundayReport[weekStart]" has a null value in JSON.');
        assert(json[r'tier'] != null, 'Required key "SundayReport[tier]" has a null value in JSON.');
        assert(json[r'createdAt'] != null, 'Required key "SundayReport[createdAt]" has a null value in JSON.');
        assert(json[r'lampsLit'] != null, 'Required key "SundayReport[lampsLit]" has a null value in JSON.');
        assert(json[r'steadyEarned'] != null, 'Required key "SundayReport[steadyEarned]" has a null value in JSON.');
        assert(json[r'goldEarned'] != null, 'Required key "SundayReport[goldEarned]" has a null value in JSON.');
        assert(json[r'relit'] != null, 'Required key "SundayReport[relit]" has a null value in JSON.');
        assert(json[r'dimmedNow'] != null, 'Required key "SundayReport[dimmedNow]" has a null value in JSON.');
        assert(json[r'questionsAnswered'] != null, 'Required key "SundayReport[questionsAnswered]" has a null value in JSON.');
        assert(json[r'mocksTaken'] != null, 'Required key "SundayReport[mocksTaken]" has a null value in JSON.');
        assert(json[r'studyMinutes'] != null, 'Required key "SundayReport[studyMinutes]" has a null value in JSON.');
        assert(json[r'lines'] != null, 'Required key "SundayReport[lines]" has a null value in JSON.');
        return true;
      }());

      return SundayReport(
        id: mapValueOfType<String>(json, r'id')!,
        weekStart: mapDateTime(json, r'weekStart', r'')!,
        tier: SundayReportTierEnum.fromJson(json[r'tier'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        lampsLit: mapValueOfType<int>(json, r'lampsLit')!,
        steadyEarned: mapValueOfType<int>(json, r'steadyEarned')!,
        goldEarned: mapValueOfType<int>(json, r'goldEarned')!,
        relit: mapValueOfType<int>(json, r'relit')!,
        dimmedNow: mapValueOfType<int>(json, r'dimmedNow')!,
        questionsAnswered: mapValueOfType<int>(json, r'questionsAnswered')!,
        accuracyPct: mapValueOfType<int>(json, r'accuracyPct'),
        mocksTaken: mapValueOfType<int>(json, r'mocksTaken')!,
        studyMinutes: mapValueOfType<int>(json, r'studyMinutes')!,
        lines: json[r'lines'] is Iterable
            ? (json[r'lines'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        nextWeek: json[r'nextWeek'] is Iterable
            ? (json[r'nextWeek'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<SundayReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SundayReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SundayReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SundayReport> mapFromJson(dynamic json) {
    final map = <String, SundayReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SundayReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SundayReport-objects as value to a dart map
  static Map<String, List<SundayReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SundayReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SundayReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'weekStart',
    'tier',
    'createdAt',
    'lampsLit',
    'steadyEarned',
    'goldEarned',
    'relit',
    'dimmedNow',
    'questionsAnswered',
    'accuracyPct',
    'mocksTaken',
    'studyMinutes',
    'lines',
    'nextWeek',
  };
}


class SundayReportTierEnum {
  /// Instantiate a new enum with the provided [value].
  const SundayReportTierEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const short = SundayReportTierEnum._(r'short');
  static const full = SundayReportTierEnum._(r'full');

  /// List of all possible values in this [enum][SundayReportTierEnum].
  static const values = <SundayReportTierEnum>[
    short,
    full,
  ];

  static SundayReportTierEnum? fromJson(dynamic value) => SundayReportTierEnumTypeTransformer().decode(value);

  static List<SundayReportTierEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SundayReportTierEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SundayReportTierEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SundayReportTierEnum] to String,
/// and [decode] dynamic data back to [SundayReportTierEnum].
class SundayReportTierEnumTypeTransformer {
  factory SundayReportTierEnumTypeTransformer() => _instance ??= const SundayReportTierEnumTypeTransformer._();

  const SundayReportTierEnumTypeTransformer._();

  String encode(SundayReportTierEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SundayReportTierEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SundayReportTierEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'short': return SundayReportTierEnum.short;
        case r'full': return SundayReportTierEnum.full;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SundayReportTierEnumTypeTransformer] instance.
  static SundayReportTierEnumTypeTransformer? _instance;
}


