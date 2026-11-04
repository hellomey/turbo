//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamStage {
  /// Returns a new [ExamStage] instance.
  ExamStage({
    required this.code,
    required this.name,
    required this.order,
    required this.scheduledDate,
    required this.dateStatus,
    this.papers = const [],
  });

  String code;

  String name;

  int order;

  DateTime? scheduledDate;

  ExamStageDateStatusEnum dateStatus;

  List<ExamPaper> papers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamStage &&
    other.code == code &&
    other.name == name &&
    other.order == order &&
    other.scheduledDate == scheduledDate &&
    other.dateStatus == dateStatus &&
    _deepEquality.equals(other.papers, papers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (order.hashCode) +
    (scheduledDate == null ? 0 : scheduledDate!.hashCode) +
    (dateStatus.hashCode) +
    (papers.hashCode);

  @override
  String toString() => 'ExamStage[code=$code, name=$name, order=$order, scheduledDate=$scheduledDate, dateStatus=$dateStatus, papers=$papers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'order'] = this.order;
    if (this.scheduledDate != null) {
      json[r'scheduledDate'] = _dateFormatter.format(this.scheduledDate!.toUtc());
    } else {
      json[r'scheduledDate'] = null;
    }
      json[r'dateStatus'] = this.dateStatus;
      json[r'papers'] = this.papers;
    return json;
  }

  /// Returns a new [ExamStage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamStage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamStage[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "ExamStage[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "ExamStage[name]" has a null value in JSON.');
        assert(json[r'order'] != null, 'Required key "ExamStage[order]" has a null value in JSON.');
        assert(json[r'dateStatus'] != null, 'Required key "ExamStage[dateStatus]" has a null value in JSON.');
        assert(json[r'papers'] != null, 'Required key "ExamStage[papers]" has a null value in JSON.');
        return true;
      }());

      return ExamStage(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        order: mapValueOfType<int>(json, r'order')!,
        scheduledDate: mapDateTime(json, r'scheduledDate', r''),
        dateStatus: ExamStageDateStatusEnum.fromJson(json[r'dateStatus'])!,
        papers: ExamPaper.listFromJson(json[r'papers']),
      );
    }
    return null;
  }

  static List<ExamStage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamStage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamStage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamStage> mapFromJson(dynamic json) {
    final map = <String, ExamStage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamStage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamStage-objects as value to a dart map
  static Map<String, List<ExamStage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamStage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamStage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'order',
    'scheduledDate',
    'dateStatus',
    'papers',
  };
}


class ExamStageDateStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamStageDateStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const unknown = ExamStageDateStatusEnum._(r'unknown');
  static const tentative = ExamStageDateStatusEnum._(r'tentative');
  static const confirmed = ExamStageDateStatusEnum._(r'confirmed');

  /// List of all possible values in this [enum][ExamStageDateStatusEnum].
  static const values = <ExamStageDateStatusEnum>[
    unknown,
    tentative,
    confirmed,
  ];

  static ExamStageDateStatusEnum? fromJson(dynamic value) => ExamStageDateStatusEnumTypeTransformer().decode(value);

  static List<ExamStageDateStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamStageDateStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamStageDateStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamStageDateStatusEnum] to String,
/// and [decode] dynamic data back to [ExamStageDateStatusEnum].
class ExamStageDateStatusEnumTypeTransformer {
  factory ExamStageDateStatusEnumTypeTransformer() => _instance ??= const ExamStageDateStatusEnumTypeTransformer._();

  const ExamStageDateStatusEnumTypeTransformer._();

  String encode(ExamStageDateStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamStageDateStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamStageDateStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'unknown': return ExamStageDateStatusEnum.unknown;
        case r'tentative': return ExamStageDateStatusEnum.tentative;
        case r'confirmed': return ExamStageDateStatusEnum.confirmed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamStageDateStatusEnumTypeTransformer] instance.
  static ExamStageDateStatusEnumTypeTransformer? _instance;
}


