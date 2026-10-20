//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamDetailAllOfPattern {
  /// Returns a new [ExamDetailAllOfPattern] instance.
  ExamDetailAllOfPattern({
    required this.mode,
    required this.questions,
    required this.durationMinutes,
    required this.negativeMarking,
  });

  ExamDetailAllOfPatternModeEnum mode;

  int? questions;

  int? durationMinutes;

  bool negativeMarking;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamDetailAllOfPattern &&
    other.mode == mode &&
    other.questions == questions &&
    other.durationMinutes == durationMinutes &&
    other.negativeMarking == negativeMarking;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mode.hashCode) +
    (questions == null ? 0 : questions!.hashCode) +
    (durationMinutes == null ? 0 : durationMinutes!.hashCode) +
    (negativeMarking.hashCode);

  @override
  String toString() => 'ExamDetailAllOfPattern[mode=$mode, questions=$questions, durationMinutes=$durationMinutes, negativeMarking=$negativeMarking]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mode'] = this.mode;
    if (this.questions != null) {
      json[r'questions'] = this.questions;
    } else {
      json[r'questions'] = null;
    }
    if (this.durationMinutes != null) {
      json[r'durationMinutes'] = this.durationMinutes;
    } else {
      json[r'durationMinutes'] = null;
    }
      json[r'negativeMarking'] = this.negativeMarking;
    return json;
  }

  /// Returns a new [ExamDetailAllOfPattern] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamDetailAllOfPattern? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamDetailAllOfPattern[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExamDetailAllOfPattern[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExamDetailAllOfPattern(
        mode: ExamDetailAllOfPatternModeEnum.fromJson(json[r'mode'])!,
        questions: mapValueOfType<int>(json, r'questions'),
        durationMinutes: mapValueOfType<int>(json, r'durationMinutes'),
        negativeMarking: mapValueOfType<bool>(json, r'negativeMarking')!,
      );
    }
    return null;
  }

  static List<ExamDetailAllOfPattern> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamDetailAllOfPattern>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamDetailAllOfPattern.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamDetailAllOfPattern> mapFromJson(dynamic json) {
    final map = <String, ExamDetailAllOfPattern>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamDetailAllOfPattern.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamDetailAllOfPattern-objects as value to a dart map
  static Map<String, List<ExamDetailAllOfPattern>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamDetailAllOfPattern>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamDetailAllOfPattern.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mode',
    'questions',
    'durationMinutes',
    'negativeMarking',
  };
}


class ExamDetailAllOfPatternModeEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamDetailAllOfPatternModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const omr = ExamDetailAllOfPatternModeEnum._(r'omr');
  static const cbt = ExamDetailAllOfPatternModeEnum._(r'cbt');

  /// List of all possible values in this [enum][ExamDetailAllOfPatternModeEnum].
  static const values = <ExamDetailAllOfPatternModeEnum>[
    omr,
    cbt,
  ];

  static ExamDetailAllOfPatternModeEnum? fromJson(dynamic value) => ExamDetailAllOfPatternModeEnumTypeTransformer().decode(value);

  static List<ExamDetailAllOfPatternModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamDetailAllOfPatternModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamDetailAllOfPatternModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamDetailAllOfPatternModeEnum] to String,
/// and [decode] dynamic data back to [ExamDetailAllOfPatternModeEnum].
class ExamDetailAllOfPatternModeEnumTypeTransformer {
  factory ExamDetailAllOfPatternModeEnumTypeTransformer() => _instance ??= const ExamDetailAllOfPatternModeEnumTypeTransformer._();

  const ExamDetailAllOfPatternModeEnumTypeTransformer._();

  String encode(ExamDetailAllOfPatternModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamDetailAllOfPatternModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamDetailAllOfPatternModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'omr': return ExamDetailAllOfPatternModeEnum.omr;
        case r'cbt': return ExamDetailAllOfPatternModeEnum.cbt;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamDetailAllOfPatternModeEnumTypeTransformer] instance.
  static ExamDetailAllOfPatternModeEnumTypeTransformer? _instance;
}


