//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamSummary {
  /// Returns a new [ExamSummary] instance.
  ExamSummary({
    required this.code,
    required this.name,
    required this.conductingBody,
    required this.level,
    required this.minQualification,
    required this.fullPrep,
  });

  String code;

  String name;

  String conductingBody;

  ExamSummaryLevelEnum level;

  Qualification minQualification;

  bool fullPrep;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamSummary &&
    other.code == code &&
    other.name == name &&
    other.conductingBody == conductingBody &&
    other.level == level &&
    other.minQualification == minQualification &&
    other.fullPrep == fullPrep;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (conductingBody.hashCode) +
    (level.hashCode) +
    (minQualification.hashCode) +
    (fullPrep.hashCode);

  @override
  String toString() => 'ExamSummary[code=$code, name=$name, conductingBody=$conductingBody, level=$level, minQualification=$minQualification, fullPrep=$fullPrep]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'conductingBody'] = this.conductingBody;
      json[r'level'] = this.level;
      json[r'minQualification'] = this.minQualification;
      json[r'fullPrep'] = this.fullPrep;
    return json;
  }

  /// Returns a new [ExamSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamSummary[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExamSummary[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExamSummary(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        conductingBody: mapValueOfType<String>(json, r'conductingBody')!,
        level: ExamSummaryLevelEnum.fromJson(json[r'level'])!,
        minQualification: Qualification.fromJson(json[r'minQualification'])!,
        fullPrep: mapValueOfType<bool>(json, r'fullPrep')!,
      );
    }
    return null;
  }

  static List<ExamSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamSummary> mapFromJson(dynamic json) {
    final map = <String, ExamSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamSummary-objects as value to a dart map
  static Map<String, List<ExamSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamSummary.listFromJson(entry.value, growable: growable,);
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
  };
}


class ExamSummaryLevelEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamSummaryLevelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const state = ExamSummaryLevelEnum._(r'state');
  static const central = ExamSummaryLevelEnum._(r'central');

  /// List of all possible values in this [enum][ExamSummaryLevelEnum].
  static const values = <ExamSummaryLevelEnum>[
    state,
    central,
  ];

  static ExamSummaryLevelEnum? fromJson(dynamic value) => ExamSummaryLevelEnumTypeTransformer().decode(value);

  static List<ExamSummaryLevelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamSummaryLevelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamSummaryLevelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamSummaryLevelEnum] to String,
/// and [decode] dynamic data back to [ExamSummaryLevelEnum].
class ExamSummaryLevelEnumTypeTransformer {
  factory ExamSummaryLevelEnumTypeTransformer() => _instance ??= const ExamSummaryLevelEnumTypeTransformer._();

  const ExamSummaryLevelEnumTypeTransformer._();

  String encode(ExamSummaryLevelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamSummaryLevelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamSummaryLevelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'state': return ExamSummaryLevelEnum.state;
        case r'central': return ExamSummaryLevelEnum.central;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamSummaryLevelEnumTypeTransformer] instance.
  static ExamSummaryLevelEnumTypeTransformer? _instance;
}


