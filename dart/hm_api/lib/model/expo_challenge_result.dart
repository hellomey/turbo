//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpoChallengeResult {
  /// Returns a new [ExpoChallengeResult] instance.
  ExpoChallengeResult({
    required this.score,
    required this.total,
    this.results = const [],
    required this.stickerCode,
  });

  /// Minimum value: 0
  int score;

  /// Minimum value: 0
  int total;

  List<ExpoChallengeResultResultsInner> results;

  String? stickerCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpoChallengeResult &&
    other.score == score &&
    other.total == total &&
    _deepEquality.equals(other.results, results) &&
    other.stickerCode == stickerCode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (score.hashCode) +
    (total.hashCode) +
    (results.hashCode) +
    (stickerCode == null ? 0 : stickerCode!.hashCode);

  @override
  String toString() => 'ExpoChallengeResult[score=$score, total=$total, results=$results, stickerCode=$stickerCode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'score'] = this.score;
      json[r'total'] = this.total;
      json[r'results'] = this.results;
    if (this.stickerCode != null) {
      json[r'stickerCode'] = this.stickerCode;
    } else {
      json[r'stickerCode'] = null;
    }
    return json;
  }

  /// Returns a new [ExpoChallengeResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpoChallengeResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExpoChallengeResult[$key]" is missing from JSON.');
        });
        assert(json[r'score'] != null, 'Required key "ExpoChallengeResult[score]" has a null value in JSON.');
        assert(json[r'total'] != null, 'Required key "ExpoChallengeResult[total]" has a null value in JSON.');
        assert(json[r'results'] != null, 'Required key "ExpoChallengeResult[results]" has a null value in JSON.');
        return true;
      }());

      return ExpoChallengeResult(
        score: mapValueOfType<int>(json, r'score')!,
        total: mapValueOfType<int>(json, r'total')!,
        results: ExpoChallengeResultResultsInner.listFromJson(json[r'results']),
        stickerCode: mapValueOfType<String>(json, r'stickerCode'),
      );
    }
    return null;
  }

  static List<ExpoChallengeResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpoChallengeResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpoChallengeResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpoChallengeResult> mapFromJson(dynamic json) {
    final map = <String, ExpoChallengeResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpoChallengeResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpoChallengeResult-objects as value to a dart map
  static Map<String, List<ExpoChallengeResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpoChallengeResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpoChallengeResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'score',
    'total',
    'results',
    'stickerCode',
  };
}

