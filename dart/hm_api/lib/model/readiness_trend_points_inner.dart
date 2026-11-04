//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReadinessTrendPointsInner {
  /// Returns a new [ReadinessTrendPointsInner] instance.
  ReadinessTrendPointsInner({
    required this.day,
    required this.label,
    required this.coverage,
    required this.memory,
    required this.examPerformance,
    required this.speed,
  });

  DateTime day;

  ReadinessLabel label;

  int? coverage;

  int? memory;

  int? examPerformance;

  int? speed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReadinessTrendPointsInner &&
    other.day == day &&
    other.label == label &&
    other.coverage == coverage &&
    other.memory == memory &&
    other.examPerformance == examPerformance &&
    other.speed == speed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (day.hashCode) +
    (label.hashCode) +
    (coverage == null ? 0 : coverage!.hashCode) +
    (memory == null ? 0 : memory!.hashCode) +
    (examPerformance == null ? 0 : examPerformance!.hashCode) +
    (speed == null ? 0 : speed!.hashCode);

  @override
  String toString() => 'ReadinessTrendPointsInner[day=$day, label=$label, coverage=$coverage, memory=$memory, examPerformance=$examPerformance, speed=$speed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'day'] = _dateFormatter.format(this.day.toUtc());
      json[r'label'] = this.label;
    if (this.coverage != null) {
      json[r'coverage'] = this.coverage;
    } else {
      json[r'coverage'] = null;
    }
    if (this.memory != null) {
      json[r'memory'] = this.memory;
    } else {
      json[r'memory'] = null;
    }
    if (this.examPerformance != null) {
      json[r'examPerformance'] = this.examPerformance;
    } else {
      json[r'examPerformance'] = null;
    }
    if (this.speed != null) {
      json[r'speed'] = this.speed;
    } else {
      json[r'speed'] = null;
    }
    return json;
  }

  /// Returns a new [ReadinessTrendPointsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReadinessTrendPointsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReadinessTrendPointsInner[$key]" is missing from JSON.');
        });
        assert(json[r'day'] != null, 'Required key "ReadinessTrendPointsInner[day]" has a null value in JSON.');
        assert(json[r'label'] != null, 'Required key "ReadinessTrendPointsInner[label]" has a null value in JSON.');
        return true;
      }());

      return ReadinessTrendPointsInner(
        day: mapDateTime(json, r'day', r'')!,
        label: ReadinessLabel.fromJson(json[r'label'])!,
        coverage: mapValueOfType<int>(json, r'coverage'),
        memory: mapValueOfType<int>(json, r'memory'),
        examPerformance: mapValueOfType<int>(json, r'examPerformance'),
        speed: mapValueOfType<int>(json, r'speed'),
      );
    }
    return null;
  }

  static List<ReadinessTrendPointsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessTrendPointsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessTrendPointsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReadinessTrendPointsInner> mapFromJson(dynamic json) {
    final map = <String, ReadinessTrendPointsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReadinessTrendPointsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReadinessTrendPointsInner-objects as value to a dart map
  static Map<String, List<ReadinessTrendPointsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReadinessTrendPointsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReadinessTrendPointsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'label',
    'coverage',
    'memory',
    'examPerformance',
    'speed',
  };
}

