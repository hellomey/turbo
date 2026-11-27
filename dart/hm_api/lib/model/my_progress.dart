//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MyProgress {
  /// Returns a new [MyProgress] instance.
  MyProgress({
    required this.xp,
    required this.level,
    required this.levelStartXp,
    required this.nextLevelXp,
    required this.points,
    required this.checkedInToday,
    this.trophies = const [],
  });

  /// Minimum value: 0
  int xp;

  /// Minimum value: 1
  int level;

  /// Minimum value: 0
  int levelStartXp;

  int nextLevelXp;

  int points;

  bool checkedInToday;

  List<EarnedTrophy> trophies;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MyProgress &&
    other.xp == xp &&
    other.level == level &&
    other.levelStartXp == levelStartXp &&
    other.nextLevelXp == nextLevelXp &&
    other.points == points &&
    other.checkedInToday == checkedInToday &&
    _deepEquality.equals(other.trophies, trophies);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (xp.hashCode) +
    (level.hashCode) +
    (levelStartXp.hashCode) +
    (nextLevelXp.hashCode) +
    (points.hashCode) +
    (checkedInToday.hashCode) +
    (trophies.hashCode);

  @override
  String toString() => 'MyProgress[xp=$xp, level=$level, levelStartXp=$levelStartXp, nextLevelXp=$nextLevelXp, points=$points, checkedInToday=$checkedInToday, trophies=$trophies]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'xp'] = this.xp;
      json[r'level'] = this.level;
      json[r'levelStartXp'] = this.levelStartXp;
      json[r'nextLevelXp'] = this.nextLevelXp;
      json[r'points'] = this.points;
      json[r'checkedInToday'] = this.checkedInToday;
      json[r'trophies'] = this.trophies;
    return json;
  }

  /// Returns a new [MyProgress] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MyProgress? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MyProgress[$key]" is missing from JSON.');
        });
        assert(json[r'xp'] != null, 'Required key "MyProgress[xp]" has a null value in JSON.');
        assert(json[r'level'] != null, 'Required key "MyProgress[level]" has a null value in JSON.');
        assert(json[r'levelStartXp'] != null, 'Required key "MyProgress[levelStartXp]" has a null value in JSON.');
        assert(json[r'nextLevelXp'] != null, 'Required key "MyProgress[nextLevelXp]" has a null value in JSON.');
        assert(json[r'points'] != null, 'Required key "MyProgress[points]" has a null value in JSON.');
        assert(json[r'checkedInToday'] != null, 'Required key "MyProgress[checkedInToday]" has a null value in JSON.');
        assert(json[r'trophies'] != null, 'Required key "MyProgress[trophies]" has a null value in JSON.');
        return true;
      }());

      return MyProgress(
        xp: mapValueOfType<int>(json, r'xp')!,
        level: mapValueOfType<int>(json, r'level')!,
        levelStartXp: mapValueOfType<int>(json, r'levelStartXp')!,
        nextLevelXp: mapValueOfType<int>(json, r'nextLevelXp')!,
        points: mapValueOfType<int>(json, r'points')!,
        checkedInToday: mapValueOfType<bool>(json, r'checkedInToday')!,
        trophies: EarnedTrophy.listFromJson(json[r'trophies']),
      );
    }
    return null;
  }

  static List<MyProgress> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MyProgress>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MyProgress.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MyProgress> mapFromJson(dynamic json) {
    final map = <String, MyProgress>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MyProgress.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MyProgress-objects as value to a dart map
  static Map<String, List<MyProgress>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MyProgress>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MyProgress.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'xp',
    'level',
    'levelStartXp',
    'nextLevelXp',
    'points',
    'checkedInToday',
    'trophies',
  };
}

