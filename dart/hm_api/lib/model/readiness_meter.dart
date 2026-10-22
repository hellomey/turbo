//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReadinessMeter {
  /// Returns a new [ReadinessMeter] instance.
  ReadinessMeter({
    required this.examCode,
    required this.label,
    this.bars = const [],
    required this.coverage,
    required this.readyForFullMocks,
    required this.suggestion,
    required this.computedAt,
  });

  String examCode;

  ReadinessLabel label;

  List<ReadinessBar> bars;

  ReadinessMeterCoverage coverage;

  bool readyForFullMocks;

  String? suggestion;

  DateTime computedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReadinessMeter &&
    other.examCode == examCode &&
    other.label == label &&
    _deepEquality.equals(other.bars, bars) &&
    other.coverage == coverage &&
    other.readyForFullMocks == readyForFullMocks &&
    other.suggestion == suggestion &&
    other.computedAt == computedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (label.hashCode) +
    (bars.hashCode) +
    (coverage.hashCode) +
    (readyForFullMocks.hashCode) +
    (suggestion == null ? 0 : suggestion!.hashCode) +
    (computedAt.hashCode);

  @override
  String toString() => 'ReadinessMeter[examCode=$examCode, label=$label, bars=$bars, coverage=$coverage, readyForFullMocks=$readyForFullMocks, suggestion=$suggestion, computedAt=$computedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'label'] = this.label;
      json[r'bars'] = this.bars;
      json[r'coverage'] = this.coverage;
      json[r'readyForFullMocks'] = this.readyForFullMocks;
    if (this.suggestion != null) {
      json[r'suggestion'] = this.suggestion;
    } else {
      json[r'suggestion'] = null;
    }
      json[r'computedAt'] = this.computedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ReadinessMeter] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReadinessMeter? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReadinessMeter[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReadinessMeter[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReadinessMeter(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        label: ReadinessLabel.fromJson(json[r'label'])!,
        bars: ReadinessBar.listFromJson(json[r'bars']),
        coverage: ReadinessMeterCoverage.fromJson(json[r'coverage'])!,
        readyForFullMocks: mapValueOfType<bool>(json, r'readyForFullMocks')!,
        suggestion: mapValueOfType<String>(json, r'suggestion'),
        computedAt: mapDateTime(json, r'computedAt', r'')!,
      );
    }
    return null;
  }

  static List<ReadinessMeter> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessMeter>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessMeter.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReadinessMeter> mapFromJson(dynamic json) {
    final map = <String, ReadinessMeter>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReadinessMeter.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReadinessMeter-objects as value to a dart map
  static Map<String, List<ReadinessMeter>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReadinessMeter>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReadinessMeter.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'label',
    'bars',
    'coverage',
    'readyForFullMocks',
    'suggestion',
    'computedAt',
  };
}

