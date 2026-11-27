//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EarnedTrophy {
  /// Returns a new [EarnedTrophy] instance.
  EarnedTrophy({
    required this.code,
    required this.title,
    required this.earnedAt,
  });

  TrophyCode code;

  String title;

  DateTime earnedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EarnedTrophy &&
    other.code == code &&
    other.title == title &&
    other.earnedAt == earnedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (title.hashCode) +
    (earnedAt.hashCode);

  @override
  String toString() => 'EarnedTrophy[code=$code, title=$title, earnedAt=$earnedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'title'] = this.title;
      json[r'earnedAt'] = this.earnedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [EarnedTrophy] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EarnedTrophy? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EarnedTrophy[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "EarnedTrophy[code]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "EarnedTrophy[title]" has a null value in JSON.');
        assert(json[r'earnedAt'] != null, 'Required key "EarnedTrophy[earnedAt]" has a null value in JSON.');
        return true;
      }());

      return EarnedTrophy(
        code: TrophyCode.fromJson(json[r'code'])!,
        title: mapValueOfType<String>(json, r'title')!,
        earnedAt: mapDateTime(json, r'earnedAt', r'')!,
      );
    }
    return null;
  }

  static List<EarnedTrophy> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EarnedTrophy>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EarnedTrophy.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EarnedTrophy> mapFromJson(dynamic json) {
    final map = <String, EarnedTrophy>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EarnedTrophy.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EarnedTrophy-objects as value to a dart map
  static Map<String, List<EarnedTrophy>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EarnedTrophy>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EarnedTrophy.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'title',
    'earnedAt',
  };
}

