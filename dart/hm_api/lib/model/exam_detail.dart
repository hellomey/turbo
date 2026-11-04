//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamDetail {
  /// Returns a new [ExamDetail] instance.
  ExamDetail({
    required this.code,
    required this.name,
    required this.conductingBody,
    required this.level,
    required this.minQualification,
    required this.fullPrep,
    required this.description,
    this.stages = const [],
    required this.pattern,
    required this.officialUrl,
    required this.notificationUrl,
    required this.lastCheckedAt,
    required this.disclaimer,
  });

  String code;

  String name;

  String conductingBody;

  ExamDetailLevelEnum level;

  Qualification minQualification;

  bool fullPrep;

  String description;

  List<String> stages;

  ExamDetailAllOfPattern pattern;

  String officialUrl;

  String? notificationUrl;

  DateTime? lastCheckedAt;

  String disclaimer;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamDetail &&
    other.code == code &&
    other.name == name &&
    other.conductingBody == conductingBody &&
    other.level == level &&
    other.minQualification == minQualification &&
    other.fullPrep == fullPrep &&
    other.description == description &&
    _deepEquality.equals(other.stages, stages) &&
    other.pattern == pattern &&
    other.officialUrl == officialUrl &&
    other.notificationUrl == notificationUrl &&
    other.lastCheckedAt == lastCheckedAt &&
    other.disclaimer == disclaimer;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (conductingBody.hashCode) +
    (level.hashCode) +
    (minQualification.hashCode) +
    (fullPrep.hashCode) +
    (description.hashCode) +
    (stages.hashCode) +
    (pattern.hashCode) +
    (officialUrl.hashCode) +
    (notificationUrl == null ? 0 : notificationUrl!.hashCode) +
    (lastCheckedAt == null ? 0 : lastCheckedAt!.hashCode) +
    (disclaimer.hashCode);

  @override
  String toString() => 'ExamDetail[code=$code, name=$name, conductingBody=$conductingBody, level=$level, minQualification=$minQualification, fullPrep=$fullPrep, description=$description, stages=$stages, pattern=$pattern, officialUrl=$officialUrl, notificationUrl=$notificationUrl, lastCheckedAt=$lastCheckedAt, disclaimer=$disclaimer]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'conductingBody'] = this.conductingBody;
      json[r'level'] = this.level;
      json[r'minQualification'] = this.minQualification;
      json[r'fullPrep'] = this.fullPrep;
      json[r'description'] = this.description;
      json[r'stages'] = this.stages;
      json[r'pattern'] = this.pattern;
      json[r'officialUrl'] = this.officialUrl;
    if (this.notificationUrl != null) {
      json[r'notificationUrl'] = this.notificationUrl;
    } else {
      json[r'notificationUrl'] = null;
    }
    if (this.lastCheckedAt != null) {
      json[r'lastCheckedAt'] = this.lastCheckedAt!.toUtc().toIso8601String();
    } else {
      json[r'lastCheckedAt'] = null;
    }
      json[r'disclaimer'] = this.disclaimer;
    return json;
  }

  /// Returns a new [ExamDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamDetail[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "ExamDetail[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "ExamDetail[name]" has a null value in JSON.');
        assert(json[r'conductingBody'] != null, 'Required key "ExamDetail[conductingBody]" has a null value in JSON.');
        assert(json[r'level'] != null, 'Required key "ExamDetail[level]" has a null value in JSON.');
        assert(json[r'minQualification'] != null, 'Required key "ExamDetail[minQualification]" has a null value in JSON.');
        assert(json[r'fullPrep'] != null, 'Required key "ExamDetail[fullPrep]" has a null value in JSON.');
        assert(json[r'description'] != null, 'Required key "ExamDetail[description]" has a null value in JSON.');
        assert(json[r'stages'] != null, 'Required key "ExamDetail[stages]" has a null value in JSON.');
        assert(json[r'pattern'] != null, 'Required key "ExamDetail[pattern]" has a null value in JSON.');
        assert(json[r'officialUrl'] != null, 'Required key "ExamDetail[officialUrl]" has a null value in JSON.');
        assert(json[r'disclaimer'] != null, 'Required key "ExamDetail[disclaimer]" has a null value in JSON.');
        return true;
      }());

      return ExamDetail(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        conductingBody: mapValueOfType<String>(json, r'conductingBody')!,
        level: ExamDetailLevelEnum.fromJson(json[r'level'])!,
        minQualification: Qualification.fromJson(json[r'minQualification'])!,
        fullPrep: mapValueOfType<bool>(json, r'fullPrep')!,
        description: mapValueOfType<String>(json, r'description')!,
        stages: json[r'stages'] is Iterable
            ? (json[r'stages'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        pattern: ExamDetailAllOfPattern.fromJson(json[r'pattern'])!,
        officialUrl: mapValueOfType<String>(json, r'officialUrl')!,
        notificationUrl: mapValueOfType<String>(json, r'notificationUrl'),
        lastCheckedAt: mapDateTime(json, r'lastCheckedAt', r''),
        disclaimer: mapValueOfType<String>(json, r'disclaimer')!,
      );
    }
    return null;
  }

  static List<ExamDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamDetail> mapFromJson(dynamic json) {
    final map = <String, ExamDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamDetail-objects as value to a dart map
  static Map<String, List<ExamDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'conductingBody',
    'level',
    'minQualification',
    'fullPrep',
    'description',
    'stages',
    'pattern',
    'officialUrl',
    'notificationUrl',
    'lastCheckedAt',
    'disclaimer',
  };
}


class ExamDetailLevelEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamDetailLevelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const state = ExamDetailLevelEnum._(r'state');
  static const central = ExamDetailLevelEnum._(r'central');

  /// List of all possible values in this [enum][ExamDetailLevelEnum].
  static const values = <ExamDetailLevelEnum>[
    state,
    central,
  ];

  static ExamDetailLevelEnum? fromJson(dynamic value) => ExamDetailLevelEnumTypeTransformer().decode(value);

  static List<ExamDetailLevelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamDetailLevelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamDetailLevelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamDetailLevelEnum] to String,
/// and [decode] dynamic data back to [ExamDetailLevelEnum].
class ExamDetailLevelEnumTypeTransformer {
  factory ExamDetailLevelEnumTypeTransformer() => _instance ??= const ExamDetailLevelEnumTypeTransformer._();

  const ExamDetailLevelEnumTypeTransformer._();

  String encode(ExamDetailLevelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamDetailLevelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamDetailLevelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'state': return ExamDetailLevelEnum.state;
        case r'central': return ExamDetailLevelEnum.central;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamDetailLevelEnumTypeTransformer] instance.
  static ExamDetailLevelEnumTypeTransformer? _instance;
}


