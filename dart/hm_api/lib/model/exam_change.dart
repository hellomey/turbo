//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamChange {
  /// Returns a new [ExamChange] instance.
  ExamChange({
    required this.id,
    required this.watchUrl,
    required this.examCode,
    required this.title,
    required this.diffSummary,
    required this.receivedAt,
    required this.status,
    required this.reviewedAt,
    required this.alertId,
  });

  String id;

  String watchUrl;

  String examCode;

  String? title;

  String? diffSummary;

  DateTime receivedAt;

  ExamChangeStatus status;

  DateTime? reviewedAt;

  String? alertId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamChange &&
    other.id == id &&
    other.watchUrl == watchUrl &&
    other.examCode == examCode &&
    other.title == title &&
    other.diffSummary == diffSummary &&
    other.receivedAt == receivedAt &&
    other.status == status &&
    other.reviewedAt == reviewedAt &&
    other.alertId == alertId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (watchUrl.hashCode) +
    (examCode.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (diffSummary == null ? 0 : diffSummary!.hashCode) +
    (receivedAt.hashCode) +
    (status.hashCode) +
    (reviewedAt == null ? 0 : reviewedAt!.hashCode) +
    (alertId == null ? 0 : alertId!.hashCode);

  @override
  String toString() => 'ExamChange[id=$id, watchUrl=$watchUrl, examCode=$examCode, title=$title, diffSummary=$diffSummary, receivedAt=$receivedAt, status=$status, reviewedAt=$reviewedAt, alertId=$alertId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'watchUrl'] = this.watchUrl;
      json[r'examCode'] = this.examCode;
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.diffSummary != null) {
      json[r'diffSummary'] = this.diffSummary;
    } else {
      json[r'diffSummary'] = null;
    }
      json[r'receivedAt'] = this.receivedAt.toUtc().toIso8601String();
      json[r'status'] = this.status;
    if (this.reviewedAt != null) {
      json[r'reviewedAt'] = this.reviewedAt!.toUtc().toIso8601String();
    } else {
      json[r'reviewedAt'] = null;
    }
    if (this.alertId != null) {
      json[r'alertId'] = this.alertId;
    } else {
      json[r'alertId'] = null;
    }
    return json;
  }

  /// Returns a new [ExamChange] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamChange? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamChange[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExamChange[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExamChange(
        id: mapValueOfType<String>(json, r'id')!,
        watchUrl: mapValueOfType<String>(json, r'watchUrl')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        title: mapValueOfType<String>(json, r'title'),
        diffSummary: mapValueOfType<String>(json, r'diffSummary'),
        receivedAt: mapDateTime(json, r'receivedAt', r'')!,
        status: ExamChangeStatus.fromJson(json[r'status'])!,
        reviewedAt: mapDateTime(json, r'reviewedAt', r''),
        alertId: mapValueOfType<String>(json, r'alertId'),
      );
    }
    return null;
  }

  static List<ExamChange> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamChange>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamChange.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamChange> mapFromJson(dynamic json) {
    final map = <String, ExamChange>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamChange.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamChange-objects as value to a dart map
  static Map<String, List<ExamChange>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamChange>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamChange.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'watchUrl',
    'examCode',
    'title',
    'diffSummary',
    'receivedAt',
    'status',
    'reviewedAt',
    'alertId',
  };
}

