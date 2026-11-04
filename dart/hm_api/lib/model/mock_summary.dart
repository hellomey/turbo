//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockSummary {
  /// Returns a new [MockSummary] instance.
  MockSummary({
    required this.id,
    required this.code,
    required this.examCode,
    required this.paperCode,
    required this.title,
    required this.kind,
    required this.questionCount,
    required this.durationMinutes,
    required this.negativeMarking,
    required this.opensAt,
    required this.lateJoinUntil,
    required this.closesAt,
    required this.free,
    required this.locked,
    required this.myLastAttemptId,
  });

  String id;

  String code;

  String examCode;

  String paperCode;

  String title;

  MockKind kind;

  int questionCount;

  int durationMinutes;

  bool negativeMarking;

  DateTime? opensAt;

  DateTime? lateJoinUntil;

  DateTime? closesAt;

  bool free;

  bool locked;

  String? myLastAttemptId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockSummary &&
    other.id == id &&
    other.code == code &&
    other.examCode == examCode &&
    other.paperCode == paperCode &&
    other.title == title &&
    other.kind == kind &&
    other.questionCount == questionCount &&
    other.durationMinutes == durationMinutes &&
    other.negativeMarking == negativeMarking &&
    other.opensAt == opensAt &&
    other.lateJoinUntil == lateJoinUntil &&
    other.closesAt == closesAt &&
    other.free == free &&
    other.locked == locked &&
    other.myLastAttemptId == myLastAttemptId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (code.hashCode) +
    (examCode.hashCode) +
    (paperCode.hashCode) +
    (title.hashCode) +
    (kind.hashCode) +
    (questionCount.hashCode) +
    (durationMinutes.hashCode) +
    (negativeMarking.hashCode) +
    (opensAt == null ? 0 : opensAt!.hashCode) +
    (lateJoinUntil == null ? 0 : lateJoinUntil!.hashCode) +
    (closesAt == null ? 0 : closesAt!.hashCode) +
    (free.hashCode) +
    (locked.hashCode) +
    (myLastAttemptId == null ? 0 : myLastAttemptId!.hashCode);

  @override
  String toString() => 'MockSummary[id=$id, code=$code, examCode=$examCode, paperCode=$paperCode, title=$title, kind=$kind, questionCount=$questionCount, durationMinutes=$durationMinutes, negativeMarking=$negativeMarking, opensAt=$opensAt, lateJoinUntil=$lateJoinUntil, closesAt=$closesAt, free=$free, locked=$locked, myLastAttemptId=$myLastAttemptId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'code'] = this.code;
      json[r'examCode'] = this.examCode;
      json[r'paperCode'] = this.paperCode;
      json[r'title'] = this.title;
      json[r'kind'] = this.kind;
      json[r'questionCount'] = this.questionCount;
      json[r'durationMinutes'] = this.durationMinutes;
      json[r'negativeMarking'] = this.negativeMarking;
    if (this.opensAt != null) {
      json[r'opensAt'] = this.opensAt!.toUtc().toIso8601String();
    } else {
      json[r'opensAt'] = null;
    }
    if (this.lateJoinUntil != null) {
      json[r'lateJoinUntil'] = this.lateJoinUntil!.toUtc().toIso8601String();
    } else {
      json[r'lateJoinUntil'] = null;
    }
    if (this.closesAt != null) {
      json[r'closesAt'] = this.closesAt!.toUtc().toIso8601String();
    } else {
      json[r'closesAt'] = null;
    }
      json[r'free'] = this.free;
      json[r'locked'] = this.locked;
    if (this.myLastAttemptId != null) {
      json[r'myLastAttemptId'] = this.myLastAttemptId;
    } else {
      json[r'myLastAttemptId'] = null;
    }
    return json;
  }

  /// Returns a new [MockSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockSummary[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "MockSummary[id]" has a null value in JSON.');
        assert(json[r'code'] != null, 'Required key "MockSummary[code]" has a null value in JSON.');
        assert(json[r'examCode'] != null, 'Required key "MockSummary[examCode]" has a null value in JSON.');
        assert(json[r'paperCode'] != null, 'Required key "MockSummary[paperCode]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "MockSummary[title]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "MockSummary[kind]" has a null value in JSON.');
        assert(json[r'questionCount'] != null, 'Required key "MockSummary[questionCount]" has a null value in JSON.');
        assert(json[r'durationMinutes'] != null, 'Required key "MockSummary[durationMinutes]" has a null value in JSON.');
        assert(json[r'negativeMarking'] != null, 'Required key "MockSummary[negativeMarking]" has a null value in JSON.');
        assert(json[r'free'] != null, 'Required key "MockSummary[free]" has a null value in JSON.');
        assert(json[r'locked'] != null, 'Required key "MockSummary[locked]" has a null value in JSON.');
        return true;
      }());

      return MockSummary(
        id: mapValueOfType<String>(json, r'id')!,
        code: mapValueOfType<String>(json, r'code')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        paperCode: mapValueOfType<String>(json, r'paperCode')!,
        title: mapValueOfType<String>(json, r'title')!,
        kind: MockKind.fromJson(json[r'kind'])!,
        questionCount: mapValueOfType<int>(json, r'questionCount')!,
        durationMinutes: mapValueOfType<int>(json, r'durationMinutes')!,
        negativeMarking: mapValueOfType<bool>(json, r'negativeMarking')!,
        opensAt: mapDateTime(json, r'opensAt', r''),
        lateJoinUntil: mapDateTime(json, r'lateJoinUntil', r''),
        closesAt: mapDateTime(json, r'closesAt', r''),
        free: mapValueOfType<bool>(json, r'free')!,
        locked: mapValueOfType<bool>(json, r'locked')!,
        myLastAttemptId: mapValueOfType<String>(json, r'myLastAttemptId'),
      );
    }
    return null;
  }

  static List<MockSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockSummary> mapFromJson(dynamic json) {
    final map = <String, MockSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockSummary-objects as value to a dart map
  static Map<String, List<MockSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'code',
    'examCode',
    'paperCode',
    'title',
    'kind',
    'questionCount',
    'durationMinutes',
    'negativeMarking',
    'opensAt',
    'lateJoinUntil',
    'closesAt',
    'free',
    'locked',
    'myLastAttemptId',
  };
}

