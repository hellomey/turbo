//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamEligibility {
  /// Returns a new [ExamEligibility] instance.
  ExamEligibility({
    required this.examCode,
    required this.examName,
    required this.conductingBody,
    required this.eligible,
    required this.fitRank,
    this.reasons = const [],
    required this.ageLimit,
    required this.officialNotificationUrl,
  });

  String examCode;

  String examName;

  String conductingBody;

  bool eligible;

  int fitRank;

  List<EligibilityReason> reasons;

  ExamEligibilityAgeLimit ageLimit;

  String officialNotificationUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamEligibility &&
    other.examCode == examCode &&
    other.examName == examName &&
    other.conductingBody == conductingBody &&
    other.eligible == eligible &&
    other.fitRank == fitRank &&
    _deepEquality.equals(other.reasons, reasons) &&
    other.ageLimit == ageLimit &&
    other.officialNotificationUrl == officialNotificationUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (examName.hashCode) +
    (conductingBody.hashCode) +
    (eligible.hashCode) +
    (fitRank.hashCode) +
    (reasons.hashCode) +
    (ageLimit.hashCode) +
    (officialNotificationUrl.hashCode);

  @override
  String toString() => 'ExamEligibility[examCode=$examCode, examName=$examName, conductingBody=$conductingBody, eligible=$eligible, fitRank=$fitRank, reasons=$reasons, ageLimit=$ageLimit, officialNotificationUrl=$officialNotificationUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'examName'] = this.examName;
      json[r'conductingBody'] = this.conductingBody;
      json[r'eligible'] = this.eligible;
      json[r'fitRank'] = this.fitRank;
      json[r'reasons'] = this.reasons;
      json[r'ageLimit'] = this.ageLimit;
      json[r'officialNotificationUrl'] = this.officialNotificationUrl;
    return json;
  }

  /// Returns a new [ExamEligibility] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamEligibility? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamEligibility[$key]" is missing from JSON.');
        });
        assert(json[r'examCode'] != null, 'Required key "ExamEligibility[examCode]" has a null value in JSON.');
        assert(json[r'examName'] != null, 'Required key "ExamEligibility[examName]" has a null value in JSON.');
        assert(json[r'conductingBody'] != null, 'Required key "ExamEligibility[conductingBody]" has a null value in JSON.');
        assert(json[r'eligible'] != null, 'Required key "ExamEligibility[eligible]" has a null value in JSON.');
        assert(json[r'fitRank'] != null, 'Required key "ExamEligibility[fitRank]" has a null value in JSON.');
        assert(json[r'reasons'] != null, 'Required key "ExamEligibility[reasons]" has a null value in JSON.');
        assert(json[r'ageLimit'] != null, 'Required key "ExamEligibility[ageLimit]" has a null value in JSON.');
        assert(json[r'officialNotificationUrl'] != null, 'Required key "ExamEligibility[officialNotificationUrl]" has a null value in JSON.');
        return true;
      }());

      return ExamEligibility(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        examName: mapValueOfType<String>(json, r'examName')!,
        conductingBody: mapValueOfType<String>(json, r'conductingBody')!,
        eligible: mapValueOfType<bool>(json, r'eligible')!,
        fitRank: mapValueOfType<int>(json, r'fitRank')!,
        reasons: EligibilityReason.listFromJson(json[r'reasons']),
        ageLimit: ExamEligibilityAgeLimit.fromJson(json[r'ageLimit'])!,
        officialNotificationUrl: mapValueOfType<String>(json, r'officialNotificationUrl')!,
      );
    }
    return null;
  }

  static List<ExamEligibility> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamEligibility>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamEligibility.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamEligibility> mapFromJson(dynamic json) {
    final map = <String, ExamEligibility>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamEligibility.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamEligibility-objects as value to a dart map
  static Map<String, List<ExamEligibility>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamEligibility>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamEligibility.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'examName',
    'conductingBody',
    'eligible',
    'fitRank',
    'reasons',
    'ageLimit',
    'officialNotificationUrl',
  };
}

