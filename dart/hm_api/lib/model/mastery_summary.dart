//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MasterySummary {
  /// Returns a new [MasterySummary] instance.
  MasterySummary({
    required this.rank,
    required this.counts,
    this.byExam = const [],
    required this.serverNow,
  });

  Rank rank;

  RingCounts counts;

  List<MasterySummaryByExamInner> byExam;

  DateTime serverNow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MasterySummary &&
    other.rank == rank &&
    other.counts == counts &&
    _deepEquality.equals(other.byExam, byExam) &&
    other.serverNow == serverNow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rank.hashCode) +
    (counts.hashCode) +
    (byExam.hashCode) +
    (serverNow.hashCode);

  @override
  String toString() => 'MasterySummary[rank=$rank, counts=$counts, byExam=$byExam, serverNow=$serverNow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'rank'] = this.rank;
      json[r'counts'] = this.counts;
      json[r'byExam'] = this.byExam;
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [MasterySummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MasterySummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MasterySummary[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MasterySummary[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MasterySummary(
        rank: Rank.fromJson(json[r'rank'])!,
        counts: RingCounts.fromJson(json[r'counts'])!,
        byExam: MasterySummaryByExamInner.listFromJson(json[r'byExam']),
        serverNow: mapDateTime(json, r'serverNow', r'')!,
      );
    }
    return null;
  }

  static List<MasterySummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MasterySummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MasterySummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MasterySummary> mapFromJson(dynamic json) {
    final map = <String, MasterySummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MasterySummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MasterySummary-objects as value to a dart map
  static Map<String, List<MasterySummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MasterySummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MasterySummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'rank',
    'counts',
    'byExam',
    'serverNow',
  };
}

