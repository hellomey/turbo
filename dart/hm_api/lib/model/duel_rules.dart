//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DuelRules {
  /// Returns a new [DuelRules] instance.
  DuelRules({
    required this.questionsPerDuel,
    required this.timeLimitSeconds,
    required this.minSecondsForPoints,
    required this.graceSeconds,
    required this.dailyPointsCap,
    this.scoring = const [],
  });

  int questionsPerDuel;

  int timeLimitSeconds;

  /// Minimum value: 0
  int minSecondsForPoints;

  /// Minimum value: 0
  int graceSeconds;

  int dailyPointsCap;

  List<DuelScoringRow> scoring;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DuelRules &&
    other.questionsPerDuel == questionsPerDuel &&
    other.timeLimitSeconds == timeLimitSeconds &&
    other.minSecondsForPoints == minSecondsForPoints &&
    other.graceSeconds == graceSeconds &&
    other.dailyPointsCap == dailyPointsCap &&
    _deepEquality.equals(other.scoring, scoring);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionsPerDuel.hashCode) +
    (timeLimitSeconds.hashCode) +
    (minSecondsForPoints.hashCode) +
    (graceSeconds.hashCode) +
    (dailyPointsCap.hashCode) +
    (scoring.hashCode);

  @override
  String toString() => 'DuelRules[questionsPerDuel=$questionsPerDuel, timeLimitSeconds=$timeLimitSeconds, minSecondsForPoints=$minSecondsForPoints, graceSeconds=$graceSeconds, dailyPointsCap=$dailyPointsCap, scoring=$scoring]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionsPerDuel'] = this.questionsPerDuel;
      json[r'timeLimitSeconds'] = this.timeLimitSeconds;
      json[r'minSecondsForPoints'] = this.minSecondsForPoints;
      json[r'graceSeconds'] = this.graceSeconds;
      json[r'dailyPointsCap'] = this.dailyPointsCap;
      json[r'scoring'] = this.scoring;
    return json;
  }

  /// Returns a new [DuelRules] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DuelRules? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DuelRules[$key]" is missing from JSON.');
        });
        assert(json[r'questionsPerDuel'] != null, 'Required key "DuelRules[questionsPerDuel]" has a null value in JSON.');
        assert(json[r'timeLimitSeconds'] != null, 'Required key "DuelRules[timeLimitSeconds]" has a null value in JSON.');
        assert(json[r'minSecondsForPoints'] != null, 'Required key "DuelRules[minSecondsForPoints]" has a null value in JSON.');
        assert(json[r'graceSeconds'] != null, 'Required key "DuelRules[graceSeconds]" has a null value in JSON.');
        assert(json[r'dailyPointsCap'] != null, 'Required key "DuelRules[dailyPointsCap]" has a null value in JSON.');
        assert(json[r'scoring'] != null, 'Required key "DuelRules[scoring]" has a null value in JSON.');
        return true;
      }());

      return DuelRules(
        questionsPerDuel: mapValueOfType<int>(json, r'questionsPerDuel')!,
        timeLimitSeconds: mapValueOfType<int>(json, r'timeLimitSeconds')!,
        minSecondsForPoints: mapValueOfType<int>(json, r'minSecondsForPoints')!,
        graceSeconds: mapValueOfType<int>(json, r'graceSeconds')!,
        dailyPointsCap: mapValueOfType<int>(json, r'dailyPointsCap')!,
        scoring: DuelScoringRow.listFromJson(json[r'scoring']),
      );
    }
    return null;
  }

  static List<DuelRules> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DuelRules>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DuelRules.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DuelRules> mapFromJson(dynamic json) {
    final map = <String, DuelRules>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DuelRules.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DuelRules-objects as value to a dart map
  static Map<String, List<DuelRules>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DuelRules>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DuelRules.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionsPerDuel',
    'timeLimitSeconds',
    'minSecondsForPoints',
    'graceSeconds',
    'dailyPointsCap',
    'scoring',
  };
}

