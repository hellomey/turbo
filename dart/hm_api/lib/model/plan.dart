//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Plan {
  /// Returns a new [Plan] instance.
  Plan({
    required this.id,
    required this.weekdayMinutes,
    required this.weekendMinutes,
    required this.pocketMinutes,
    required this.balance,
    this.exams = const [],
    required this.stretch,
    required this.starterPathUntil,
    required this.lastRebalancedAt,
    required this.configVersion,
  });

  String id;

  int weekdayMinutes;

  int weekendMinutes;

  /// Minimum value: 5
  /// Maximum value: 15
  int pocketMinutes;

  /// Minimum value: -2
  /// Maximum value: 2
  int balance;

  List<PlanExam> exams;

  StretchPhase stretch;

  DateTime? starterPathUntil;

  DateTime? lastRebalancedAt;

  String configVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Plan &&
    other.id == id &&
    other.weekdayMinutes == weekdayMinutes &&
    other.weekendMinutes == weekendMinutes &&
    other.pocketMinutes == pocketMinutes &&
    other.balance == balance &&
    _deepEquality.equals(other.exams, exams) &&
    other.stretch == stretch &&
    other.starterPathUntil == starterPathUntil &&
    other.lastRebalancedAt == lastRebalancedAt &&
    other.configVersion == configVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (weekdayMinutes.hashCode) +
    (weekendMinutes.hashCode) +
    (pocketMinutes.hashCode) +
    (balance.hashCode) +
    (exams.hashCode) +
    (stretch.hashCode) +
    (starterPathUntil == null ? 0 : starterPathUntil!.hashCode) +
    (lastRebalancedAt == null ? 0 : lastRebalancedAt!.hashCode) +
    (configVersion.hashCode);

  @override
  String toString() => 'Plan[id=$id, weekdayMinutes=$weekdayMinutes, weekendMinutes=$weekendMinutes, pocketMinutes=$pocketMinutes, balance=$balance, exams=$exams, stretch=$stretch, starterPathUntil=$starterPathUntil, lastRebalancedAt=$lastRebalancedAt, configVersion=$configVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'weekdayMinutes'] = this.weekdayMinutes;
      json[r'weekendMinutes'] = this.weekendMinutes;
      json[r'pocketMinutes'] = this.pocketMinutes;
      json[r'balance'] = this.balance;
      json[r'exams'] = this.exams;
      json[r'stretch'] = this.stretch;
    if (this.starterPathUntil != null) {
      json[r'starterPathUntil'] = _dateFormatter.format(this.starterPathUntil!.toUtc());
    } else {
      json[r'starterPathUntil'] = null;
    }
    if (this.lastRebalancedAt != null) {
      json[r'lastRebalancedAt'] = this.lastRebalancedAt!.toUtc().toIso8601String();
    } else {
      json[r'lastRebalancedAt'] = null;
    }
      json[r'configVersion'] = this.configVersion;
    return json;
  }

  /// Returns a new [Plan] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Plan? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Plan[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "Plan[id]" has a null value in JSON.');
        assert(json[r'weekdayMinutes'] != null, 'Required key "Plan[weekdayMinutes]" has a null value in JSON.');
        assert(json[r'weekendMinutes'] != null, 'Required key "Plan[weekendMinutes]" has a null value in JSON.');
        assert(json[r'pocketMinutes'] != null, 'Required key "Plan[pocketMinutes]" has a null value in JSON.');
        assert(json[r'balance'] != null, 'Required key "Plan[balance]" has a null value in JSON.');
        assert(json[r'exams'] != null, 'Required key "Plan[exams]" has a null value in JSON.');
        assert(json[r'stretch'] != null, 'Required key "Plan[stretch]" has a null value in JSON.');
        assert(json[r'configVersion'] != null, 'Required key "Plan[configVersion]" has a null value in JSON.');
        return true;
      }());

      return Plan(
        id: mapValueOfType<String>(json, r'id')!,
        weekdayMinutes: mapValueOfType<int>(json, r'weekdayMinutes')!,
        weekendMinutes: mapValueOfType<int>(json, r'weekendMinutes')!,
        pocketMinutes: mapValueOfType<int>(json, r'pocketMinutes')!,
        balance: mapValueOfType<int>(json, r'balance')!,
        exams: PlanExam.listFromJson(json[r'exams']),
        stretch: StretchPhase.fromJson(json[r'stretch'])!,
        starterPathUntil: mapDateTime(json, r'starterPathUntil', r''),
        lastRebalancedAt: mapDateTime(json, r'lastRebalancedAt', r''),
        configVersion: mapValueOfType<String>(json, r'configVersion')!,
      );
    }
    return null;
  }

  static List<Plan> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Plan>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Plan.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Plan> mapFromJson(dynamic json) {
    final map = <String, Plan>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Plan.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Plan-objects as value to a dart map
  static Map<String, List<Plan>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Plan>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Plan.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'weekdayMinutes',
    'weekendMinutes',
    'pocketMinutes',
    'balance',
    'exams',
    'stretch',
    'starterPathUntil',
    'lastRebalancedAt',
    'configVersion',
  };
}

