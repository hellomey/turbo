//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TodayScreenRelight {
  /// Returns a new [TodayScreenRelight] instance.
  TodayScreenRelight({
    required this.count,
    required this.minutes,
  });

  /// Minimum value: 0
  int count;

  /// Minimum value: 0
  int minutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TodayScreenRelight &&
    other.count == count &&
    other.minutes == minutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (count.hashCode) +
    (minutes.hashCode);

  @override
  String toString() => 'TodayScreenRelight[count=$count, minutes=$minutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'count'] = this.count;
      json[r'minutes'] = this.minutes;
    return json;
  }

  /// Returns a new [TodayScreenRelight] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TodayScreenRelight? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TodayScreenRelight[$key]" is missing from JSON.');
        });
        assert(json[r'count'] != null, 'Required key "TodayScreenRelight[count]" has a null value in JSON.');
        assert(json[r'minutes'] != null, 'Required key "TodayScreenRelight[minutes]" has a null value in JSON.');
        return true;
      }());

      return TodayScreenRelight(
        count: mapValueOfType<int>(json, r'count')!,
        minutes: mapValueOfType<int>(json, r'minutes')!,
      );
    }
    return null;
  }

  static List<TodayScreenRelight> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TodayScreenRelight>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TodayScreenRelight.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TodayScreenRelight> mapFromJson(dynamic json) {
    final map = <String, TodayScreenRelight>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TodayScreenRelight.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TodayScreenRelight-objects as value to a dart map
  static Map<String, List<TodayScreenRelight>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TodayScreenRelight>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TodayScreenRelight.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'count',
    'minutes',
  };
}

