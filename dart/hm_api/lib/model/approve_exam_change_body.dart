//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApproveExamChangeBody {
  /// Returns a new [ApproveExamChangeBody] instance.
  ApproveExamChangeBody({
    required this.examCode,
    required this.kind,
    required this.title,
    required this.summary,
    required this.officialUrl,
    this.newStageDate,
  });

  String examCode;

  ApproveExamChangeBodyKindEnum kind;

  String title;

  String summary;

  String officialUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ApproveExamChangeBodyNewStageDate? newStageDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApproveExamChangeBody &&
    other.examCode == examCode &&
    other.kind == kind &&
    other.title == title &&
    other.summary == summary &&
    other.officialUrl == officialUrl &&
    other.newStageDate == newStageDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (kind.hashCode) +
    (title.hashCode) +
    (summary.hashCode) +
    (officialUrl.hashCode) +
    (newStageDate == null ? 0 : newStageDate!.hashCode);

  @override
  String toString() => 'ApproveExamChangeBody[examCode=$examCode, kind=$kind, title=$title, summary=$summary, officialUrl=$officialUrl, newStageDate=$newStageDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'kind'] = this.kind;
      json[r'title'] = this.title;
      json[r'summary'] = this.summary;
      json[r'officialUrl'] = this.officialUrl;
    if (this.newStageDate != null) {
      json[r'newStageDate'] = this.newStageDate;
    } else {
      json[r'newStageDate'] = null;
    }
    return json;
  }

  /// Returns a new [ApproveExamChangeBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApproveExamChangeBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApproveExamChangeBody[$key]" is missing from JSON.');
        });
        assert(json[r'examCode'] != null, 'Required key "ApproveExamChangeBody[examCode]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "ApproveExamChangeBody[kind]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "ApproveExamChangeBody[title]" has a null value in JSON.');
        assert(json[r'summary'] != null, 'Required key "ApproveExamChangeBody[summary]" has a null value in JSON.');
        assert(json[r'officialUrl'] != null, 'Required key "ApproveExamChangeBody[officialUrl]" has a null value in JSON.');
        return true;
      }());

      return ApproveExamChangeBody(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        kind: ApproveExamChangeBodyKindEnum.fromJson(json[r'kind'])!,
        title: mapValueOfType<String>(json, r'title')!,
        summary: mapValueOfType<String>(json, r'summary')!,
        officialUrl: mapValueOfType<String>(json, r'officialUrl')!,
        newStageDate: ApproveExamChangeBodyNewStageDate.fromJson(json[r'newStageDate']),
      );
    }
    return null;
  }

  static List<ApproveExamChangeBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApproveExamChangeBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApproveExamChangeBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApproveExamChangeBody> mapFromJson(dynamic json) {
    final map = <String, ApproveExamChangeBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApproveExamChangeBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApproveExamChangeBody-objects as value to a dart map
  static Map<String, List<ApproveExamChangeBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApproveExamChangeBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApproveExamChangeBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'kind',
    'title',
    'summary',
    'officialUrl',
  };
}


class ApproveExamChangeBodyKindEnum {
  /// Instantiate a new enum with the provided [value].
  const ApproveExamChangeBodyKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const notification = ApproveExamChangeBodyKindEnum._(r'notification');
  static const dateChange = ApproveExamChangeBodyKindEnum._(r'date_change');
  static const admitCard = ApproveExamChangeBodyKindEnum._(r'admit_card');
  static const result = ApproveExamChangeBodyKindEnum._(r'result');
  static const answerKey = ApproveExamChangeBodyKindEnum._(r'answer_key');
  static const other = ApproveExamChangeBodyKindEnum._(r'other');

  /// List of all possible values in this [enum][ApproveExamChangeBodyKindEnum].
  static const values = <ApproveExamChangeBodyKindEnum>[
    notification,
    dateChange,
    admitCard,
    result,
    answerKey,
    other,
  ];

  static ApproveExamChangeBodyKindEnum? fromJson(dynamic value) => ApproveExamChangeBodyKindEnumTypeTransformer().decode(value);

  static List<ApproveExamChangeBodyKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApproveExamChangeBodyKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApproveExamChangeBodyKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ApproveExamChangeBodyKindEnum] to String,
/// and [decode] dynamic data back to [ApproveExamChangeBodyKindEnum].
class ApproveExamChangeBodyKindEnumTypeTransformer {
  factory ApproveExamChangeBodyKindEnumTypeTransformer() => _instance ??= const ApproveExamChangeBodyKindEnumTypeTransformer._();

  const ApproveExamChangeBodyKindEnumTypeTransformer._();

  String encode(ApproveExamChangeBodyKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ApproveExamChangeBodyKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ApproveExamChangeBodyKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'notification': return ApproveExamChangeBodyKindEnum.notification;
        case r'date_change': return ApproveExamChangeBodyKindEnum.dateChange;
        case r'admit_card': return ApproveExamChangeBodyKindEnum.admitCard;
        case r'result': return ApproveExamChangeBodyKindEnum.result;
        case r'answer_key': return ApproveExamChangeBodyKindEnum.answerKey;
        case r'other': return ApproveExamChangeBodyKindEnum.other;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ApproveExamChangeBodyKindEnumTypeTransformer] instance.
  static ApproveExamChangeBodyKindEnumTypeTransformer? _instance;
}


