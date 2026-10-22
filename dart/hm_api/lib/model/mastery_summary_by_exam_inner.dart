//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MasterySummaryByExamInner {
  /// Returns a new [MasterySummaryByExamInner] instance.
  MasterySummaryByExamInner({
    required this.examCode,
    required this.counts,
  });

  String examCode;

  RingCounts counts;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MasterySummaryByExamInner &&
    other.examCode == examCode &&
    other.counts == counts;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (counts.hashCode);

  @override
  String toString() => 'MasterySummaryByExamInner[examCode=$examCode, counts=$counts]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'counts'] = this.counts;
    return json;
  }

  /// Returns a new [MasterySummaryByExamInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MasterySummaryByExamInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MasterySummaryByExamInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MasterySummaryByExamInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MasterySummaryByExamInner(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        counts: RingCounts.fromJson(json[r'counts'])!,
      );
    }
    return null;
  }

  static List<MasterySummaryByExamInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MasterySummaryByExamInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MasterySummaryByExamInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MasterySummaryByExamInner> mapFromJson(dynamic json) {
    final map = <String, MasterySummaryByExamInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MasterySummaryByExamInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MasterySummaryByExamInner-objects as value to a dart map
  static Map<String, List<MasterySummaryByExamInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MasterySummaryByExamInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MasterySummaryByExamInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'counts',
  };
}

