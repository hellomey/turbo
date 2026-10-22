//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StateMockInfo {
  /// Returns a new [StateMockInfo] instance.
  StateMockInfo({
    required this.mock,
    required this.nextSunday,
    required this.rankPublishAt,
  });

  StateMockInfoMock mock;

  DateTime nextSunday;

  DateTime? rankPublishAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StateMockInfo &&
    other.mock == mock &&
    other.nextSunday == nextSunday &&
    other.rankPublishAt == rankPublishAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mock.hashCode) +
    (nextSunday.hashCode) +
    (rankPublishAt == null ? 0 : rankPublishAt!.hashCode);

  @override
  String toString() => 'StateMockInfo[mock=$mock, nextSunday=$nextSunday, rankPublishAt=$rankPublishAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mock'] = this.mock;
      json[r'nextSunday'] = _dateFormatter.format(this.nextSunday.toUtc());
    if (this.rankPublishAt != null) {
      json[r'rankPublishAt'] = this.rankPublishAt!.toUtc().toIso8601String();
    } else {
      json[r'rankPublishAt'] = null;
    }
    return json;
  }

  /// Returns a new [StateMockInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StateMockInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StateMockInfo[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StateMockInfo[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StateMockInfo(
        mock: StateMockInfoMock.fromJson(json[r'mock'])!,
        nextSunday: mapDateTime(json, r'nextSunday', r'')!,
        rankPublishAt: mapDateTime(json, r'rankPublishAt', r''),
      );
    }
    return null;
  }

  static List<StateMockInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StateMockInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StateMockInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StateMockInfo> mapFromJson(dynamic json) {
    final map = <String, StateMockInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StateMockInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StateMockInfo-objects as value to a dart map
  static Map<String, List<StateMockInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StateMockInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StateMockInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mock',
    'nextSunday',
    'rankPublishAt',
  };
}

