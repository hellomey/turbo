//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamAttemptCycleStageDatesInner {
  /// Returns a new [ExamAttemptCycleStageDatesInner] instance.
  ExamAttemptCycleStageDatesInner({
    required this.stageCode,
    required this.date,
    required this.dateStatus,
  });

  String stageCode;

  DateTime? date;

  ExamAttemptCycleStageDatesInnerDateStatusEnum dateStatus;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamAttemptCycleStageDatesInner &&
    other.stageCode == stageCode &&
    other.date == date &&
    other.dateStatus == dateStatus;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stageCode.hashCode) +
    (date == null ? 0 : date!.hashCode) +
    (dateStatus.hashCode);

  @override
  String toString() => 'ExamAttemptCycleStageDatesInner[stageCode=$stageCode, date=$date, dateStatus=$dateStatus]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stageCode'] = this.stageCode;
    if (this.date != null) {
      json[r'date'] = _dateFormatter.format(this.date!.toUtc());
    } else {
      json[r'date'] = null;
    }
      json[r'dateStatus'] = this.dateStatus;
    return json;
  }

  /// Returns a new [ExamAttemptCycleStageDatesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamAttemptCycleStageDatesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamAttemptCycleStageDatesInner[$key]" is missing from JSON.');
        });
        assert(json[r'stageCode'] != null, 'Required key "ExamAttemptCycleStageDatesInner[stageCode]" has a null value in JSON.');
        assert(json[r'dateStatus'] != null, 'Required key "ExamAttemptCycleStageDatesInner[dateStatus]" has a null value in JSON.');
        return true;
      }());

      return ExamAttemptCycleStageDatesInner(
        stageCode: mapValueOfType<String>(json, r'stageCode')!,
        date: mapDateTime(json, r'date', r''),
        dateStatus: ExamAttemptCycleStageDatesInnerDateStatusEnum.fromJson(json[r'dateStatus'])!,
      );
    }
    return null;
  }

  static List<ExamAttemptCycleStageDatesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAttemptCycleStageDatesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAttemptCycleStageDatesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamAttemptCycleStageDatesInner> mapFromJson(dynamic json) {
    final map = <String, ExamAttemptCycleStageDatesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamAttemptCycleStageDatesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamAttemptCycleStageDatesInner-objects as value to a dart map
  static Map<String, List<ExamAttemptCycleStageDatesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamAttemptCycleStageDatesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamAttemptCycleStageDatesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stageCode',
    'date',
    'dateStatus',
  };
}


class ExamAttemptCycleStageDatesInnerDateStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamAttemptCycleStageDatesInnerDateStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const unknown = ExamAttemptCycleStageDatesInnerDateStatusEnum._(r'unknown');
  static const tentative = ExamAttemptCycleStageDatesInnerDateStatusEnum._(r'tentative');
  static const confirmed = ExamAttemptCycleStageDatesInnerDateStatusEnum._(r'confirmed');

  /// List of all possible values in this [enum][ExamAttemptCycleStageDatesInnerDateStatusEnum].
  static const values = <ExamAttemptCycleStageDatesInnerDateStatusEnum>[
    unknown,
    tentative,
    confirmed,
  ];

  static ExamAttemptCycleStageDatesInnerDateStatusEnum? fromJson(dynamic value) => ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer().decode(value);

  static List<ExamAttemptCycleStageDatesInnerDateStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAttemptCycleStageDatesInnerDateStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAttemptCycleStageDatesInnerDateStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamAttemptCycleStageDatesInnerDateStatusEnum] to String,
/// and [decode] dynamic data back to [ExamAttemptCycleStageDatesInnerDateStatusEnum].
class ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer {
  factory ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer() => _instance ??= const ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer._();

  const ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer._();

  String encode(ExamAttemptCycleStageDatesInnerDateStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamAttemptCycleStageDatesInnerDateStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamAttemptCycleStageDatesInnerDateStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'unknown': return ExamAttemptCycleStageDatesInnerDateStatusEnum.unknown;
        case r'tentative': return ExamAttemptCycleStageDatesInnerDateStatusEnum.tentative;
        case r'confirmed': return ExamAttemptCycleStageDatesInnerDateStatusEnum.confirmed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer] instance.
  static ExamAttemptCycleStageDatesInnerDateStatusEnumTypeTransformer? _instance;
}


