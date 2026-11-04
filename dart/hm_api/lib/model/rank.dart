//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Rank {
  /// Returns a new [Rank] instance.
  Rank({
    required this.level,
    required this.title,
    required this.familyCode,
    required this.xp,
    required this.xpForThisLevel,
    required this.xpForNextLevel,
    required this.note,
  });

  /// Minimum value: 1
  /// Maximum value: 11
  int level;

  String title;

  String? familyCode;

  /// Minimum value: 0
  int xp;

  /// Minimum value: 0
  int xpForThisLevel;

  /// Minimum value: 0
  int? xpForNextLevel;

  String note;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Rank &&
    other.level == level &&
    other.title == title &&
    other.familyCode == familyCode &&
    other.xp == xp &&
    other.xpForThisLevel == xpForThisLevel &&
    other.xpForNextLevel == xpForNextLevel &&
    other.note == note;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (level.hashCode) +
    (title.hashCode) +
    (familyCode == null ? 0 : familyCode!.hashCode) +
    (xp.hashCode) +
    (xpForThisLevel.hashCode) +
    (xpForNextLevel == null ? 0 : xpForNextLevel!.hashCode) +
    (note.hashCode);

  @override
  String toString() => 'Rank[level=$level, title=$title, familyCode=$familyCode, xp=$xp, xpForThisLevel=$xpForThisLevel, xpForNextLevel=$xpForNextLevel, note=$note]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'level'] = this.level;
      json[r'title'] = this.title;
    if (this.familyCode != null) {
      json[r'familyCode'] = this.familyCode;
    } else {
      json[r'familyCode'] = null;
    }
      json[r'xp'] = this.xp;
      json[r'xpForThisLevel'] = this.xpForThisLevel;
    if (this.xpForNextLevel != null) {
      json[r'xpForNextLevel'] = this.xpForNextLevel;
    } else {
      json[r'xpForNextLevel'] = null;
    }
      json[r'note'] = this.note;
    return json;
  }

  /// Returns a new [Rank] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Rank? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Rank[$key]" is missing from JSON.');
        });
        assert(json[r'level'] != null, 'Required key "Rank[level]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "Rank[title]" has a null value in JSON.');
        assert(json[r'xp'] != null, 'Required key "Rank[xp]" has a null value in JSON.');
        assert(json[r'xpForThisLevel'] != null, 'Required key "Rank[xpForThisLevel]" has a null value in JSON.');
        assert(json[r'note'] != null, 'Required key "Rank[note]" has a null value in JSON.');
        return true;
      }());

      return Rank(
        level: mapValueOfType<int>(json, r'level')!,
        title: mapValueOfType<String>(json, r'title')!,
        familyCode: mapValueOfType<String>(json, r'familyCode'),
        xp: mapValueOfType<int>(json, r'xp')!,
        xpForThisLevel: mapValueOfType<int>(json, r'xpForThisLevel')!,
        xpForNextLevel: mapValueOfType<int>(json, r'xpForNextLevel'),
        note: mapValueOfType<String>(json, r'note')!,
      );
    }
    return null;
  }

  static List<Rank> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Rank>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Rank.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Rank> mapFromJson(dynamic json) {
    final map = <String, Rank>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Rank.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Rank-objects as value to a dart map
  static Map<String, List<Rank>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Rank>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Rank.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'level',
    'title',
    'familyCode',
    'xp',
    'xpForThisLevel',
    'xpForNextLevel',
    'note',
  };
}

