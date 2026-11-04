//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StatewideRank {
  /// Returns a new [StatewideRank] instance.
  StatewideRank({
    required this.mockId,
    required this.scopeLabel,
    required this.rank,
    required this.rankedCandidates,
    required this.percentile,
    required this.score,
    required this.publishedAt,
  });

  String mockId;

  String scopeLabel;

  int rank;

  int rankedCandidates;

  /// Minimum value: 0
  /// Maximum value: 100
  int percentile;

  Marks score;

  DateTime publishedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StatewideRank &&
    other.mockId == mockId &&
    other.scopeLabel == scopeLabel &&
    other.rank == rank &&
    other.rankedCandidates == rankedCandidates &&
    other.percentile == percentile &&
    other.score == score &&
    other.publishedAt == publishedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mockId.hashCode) +
    (scopeLabel.hashCode) +
    (rank.hashCode) +
    (rankedCandidates.hashCode) +
    (percentile.hashCode) +
    (score.hashCode) +
    (publishedAt.hashCode);

  @override
  String toString() => 'StatewideRank[mockId=$mockId, scopeLabel=$scopeLabel, rank=$rank, rankedCandidates=$rankedCandidates, percentile=$percentile, score=$score, publishedAt=$publishedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mockId'] = this.mockId;
      json[r'scopeLabel'] = this.scopeLabel;
      json[r'rank'] = this.rank;
      json[r'rankedCandidates'] = this.rankedCandidates;
      json[r'percentile'] = this.percentile;
      json[r'score'] = this.score;
      json[r'publishedAt'] = this.publishedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [StatewideRank] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StatewideRank? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StatewideRank[$key]" is missing from JSON.');
        });
        assert(json[r'mockId'] != null, 'Required key "StatewideRank[mockId]" has a null value in JSON.');
        assert(json[r'scopeLabel'] != null, 'Required key "StatewideRank[scopeLabel]" has a null value in JSON.');
        assert(json[r'rank'] != null, 'Required key "StatewideRank[rank]" has a null value in JSON.');
        assert(json[r'rankedCandidates'] != null, 'Required key "StatewideRank[rankedCandidates]" has a null value in JSON.');
        assert(json[r'percentile'] != null, 'Required key "StatewideRank[percentile]" has a null value in JSON.');
        assert(json[r'score'] != null, 'Required key "StatewideRank[score]" has a null value in JSON.');
        assert(json[r'publishedAt'] != null, 'Required key "StatewideRank[publishedAt]" has a null value in JSON.');
        return true;
      }());

      return StatewideRank(
        mockId: mapValueOfType<String>(json, r'mockId')!,
        scopeLabel: mapValueOfType<String>(json, r'scopeLabel')!,
        rank: mapValueOfType<int>(json, r'rank')!,
        rankedCandidates: mapValueOfType<int>(json, r'rankedCandidates')!,
        percentile: mapValueOfType<int>(json, r'percentile')!,
        score: Marks.fromJson(json[r'score'])!,
        publishedAt: mapDateTime(json, r'publishedAt', r'')!,
      );
    }
    return null;
  }

  static List<StatewideRank> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StatewideRank>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StatewideRank.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StatewideRank> mapFromJson(dynamic json) {
    final map = <String, StatewideRank>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StatewideRank.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StatewideRank-objects as value to a dart map
  static Map<String, List<StatewideRank>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StatewideRank>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StatewideRank.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mockId',
    'scopeLabel',
    'rank',
    'rankedCandidates',
    'percentile',
    'score',
    'publishedAt',
  };
}

