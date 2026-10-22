//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamAlert {
  /// Returns a new [ExamAlert] instance.
  ExamAlert({
    required this.id,
    required this.examCode,
    required this.kind,
    required this.title,
    required this.summary,
    required this.officialUrl,
    required this.publishedAt,
    required this.confirmLine,
  });

  String id;

  String examCode;

  ExamAlertKindEnum kind;

  String title;

  String summary;

  String officialUrl;

  DateTime publishedAt;

  String confirmLine;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamAlert &&
    other.id == id &&
    other.examCode == examCode &&
    other.kind == kind &&
    other.title == title &&
    other.summary == summary &&
    other.officialUrl == officialUrl &&
    other.publishedAt == publishedAt &&
    other.confirmLine == confirmLine;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (examCode.hashCode) +
    (kind.hashCode) +
    (title.hashCode) +
    (summary.hashCode) +
    (officialUrl.hashCode) +
    (publishedAt.hashCode) +
    (confirmLine.hashCode);

  @override
  String toString() => 'ExamAlert[id=$id, examCode=$examCode, kind=$kind, title=$title, summary=$summary, officialUrl=$officialUrl, publishedAt=$publishedAt, confirmLine=$confirmLine]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'examCode'] = this.examCode;
      json[r'kind'] = this.kind;
      json[r'title'] = this.title;
      json[r'summary'] = this.summary;
      json[r'officialUrl'] = this.officialUrl;
      json[r'publishedAt'] = this.publishedAt.toUtc().toIso8601String();
      json[r'confirmLine'] = this.confirmLine;
    return json;
  }

  /// Returns a new [ExamAlert] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamAlert? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamAlert[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExamAlert[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExamAlert(
        id: mapValueOfType<String>(json, r'id')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        kind: ExamAlertKindEnum.fromJson(json[r'kind'])!,
        title: mapValueOfType<String>(json, r'title')!,
        summary: mapValueOfType<String>(json, r'summary')!,
        officialUrl: mapValueOfType<String>(json, r'officialUrl')!,
        publishedAt: mapDateTime(json, r'publishedAt', r'')!,
        confirmLine: mapValueOfType<String>(json, r'confirmLine')!,
      );
    }
    return null;
  }

  static List<ExamAlert> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAlert>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAlert.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamAlert> mapFromJson(dynamic json) {
    final map = <String, ExamAlert>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamAlert.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamAlert-objects as value to a dart map
  static Map<String, List<ExamAlert>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamAlert>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamAlert.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'examCode',
    'kind',
    'title',
    'summary',
    'officialUrl',
    'publishedAt',
    'confirmLine',
  };
}


class ExamAlertKindEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamAlertKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const notification = ExamAlertKindEnum._(r'notification');
  static const dateChange = ExamAlertKindEnum._(r'date_change');
  static const admitCard = ExamAlertKindEnum._(r'admit_card');
  static const result = ExamAlertKindEnum._(r'result');
  static const answerKey = ExamAlertKindEnum._(r'answer_key');
  static const other = ExamAlertKindEnum._(r'other');

  /// List of all possible values in this [enum][ExamAlertKindEnum].
  static const values = <ExamAlertKindEnum>[
    notification,
    dateChange,
    admitCard,
    result,
    answerKey,
    other,
  ];

  static ExamAlertKindEnum? fromJson(dynamic value) => ExamAlertKindEnumTypeTransformer().decode(value);

  static List<ExamAlertKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAlertKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAlertKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamAlertKindEnum] to String,
/// and [decode] dynamic data back to [ExamAlertKindEnum].
class ExamAlertKindEnumTypeTransformer {
  factory ExamAlertKindEnumTypeTransformer() => _instance ??= const ExamAlertKindEnumTypeTransformer._();

  const ExamAlertKindEnumTypeTransformer._();

  String encode(ExamAlertKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamAlertKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamAlertKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'notification': return ExamAlertKindEnum.notification;
        case r'date_change': return ExamAlertKindEnum.dateChange;
        case r'admit_card': return ExamAlertKindEnum.admitCard;
        case r'result': return ExamAlertKindEnum.result;
        case r'answer_key': return ExamAlertKindEnum.answerKey;
        case r'other': return ExamAlertKindEnum.other;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamAlertKindEnumTypeTransformer] instance.
  static ExamAlertKindEnumTypeTransformer? _instance;
}


