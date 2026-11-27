//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WeeklyLeaderboard {
  /// Returns a new [WeeklyLeaderboard] instance.
  WeeklyLeaderboard({
    required this.weekStart,
    required this.weekEnd,
    required this.optedIn,
    this.entries = const [],
  });

  DateTime weekStart;

  DateTime weekEnd;

  bool optedIn;

  List<LeaderboardEntry> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WeeklyLeaderboard &&
    other.weekStart == weekStart &&
    other.weekEnd == weekEnd &&
    other.optedIn == optedIn &&
    _deepEquality.equals(other.entries, entries);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (weekStart.hashCode) +
    (weekEnd.hashCode) +
    (optedIn.hashCode) +
    (entries.hashCode);

  @override
  String toString() => 'WeeklyLeaderboard[weekStart=$weekStart, weekEnd=$weekEnd, optedIn=$optedIn, entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'weekStart'] = this.weekStart.toUtc().toIso8601String();
      json[r'weekEnd'] = this.weekEnd.toUtc().toIso8601String();
      json[r'optedIn'] = this.optedIn;
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [WeeklyLeaderboard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WeeklyLeaderboard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WeeklyLeaderboard[$key]" is missing from JSON.');
        });
        assert(json[r'weekStart'] != null, 'Required key "WeeklyLeaderboard[weekStart]" has a null value in JSON.');
        assert(json[r'weekEnd'] != null, 'Required key "WeeklyLeaderboard[weekEnd]" has a null value in JSON.');
        assert(json[r'optedIn'] != null, 'Required key "WeeklyLeaderboard[optedIn]" has a null value in JSON.');
        assert(json[r'entries'] != null, 'Required key "WeeklyLeaderboard[entries]" has a null value in JSON.');
        return true;
      }());

      return WeeklyLeaderboard(
        weekStart: mapDateTime(json, r'weekStart', r'')!,
        weekEnd: mapDateTime(json, r'weekEnd', r'')!,
        optedIn: mapValueOfType<bool>(json, r'optedIn')!,
        entries: LeaderboardEntry.listFromJson(json[r'entries']),
      );
    }
    return null;
  }

  static List<WeeklyLeaderboard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WeeklyLeaderboard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WeeklyLeaderboard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WeeklyLeaderboard> mapFromJson(dynamic json) {
    final map = <String, WeeklyLeaderboard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WeeklyLeaderboard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WeeklyLeaderboard-objects as value to a dart map
  static Map<String, List<WeeklyLeaderboard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WeeklyLeaderboard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WeeklyLeaderboard.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'weekStart',
    'weekEnd',
    'optedIn',
    'entries',
  };
}

