//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamAttemptCycle {
  /// Returns a new [ExamAttemptCycle] instance.
  ExamAttemptCycle({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    this.stageDates = const [],
  });

  String id;

  String code;

  String name;

  ExamAttemptCycleStatusEnum status;

  List<ExamAttemptCycleStageDatesInner> stageDates;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamAttemptCycle &&
    other.id == id &&
    other.code == code &&
    other.name == name &&
    other.status == status &&
    _deepEquality.equals(other.stageDates, stageDates);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (code.hashCode) +
    (name.hashCode) +
    (status.hashCode) +
    (stageDates.hashCode);

  @override
  String toString() => 'ExamAttemptCycle[id=$id, code=$code, name=$name, status=$status, stageDates=$stageDates]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'status'] = this.status;
      json[r'stageDates'] = this.stageDates;
    return json;
  }

  /// Returns a new [ExamAttemptCycle] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamAttemptCycle? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamAttemptCycle[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "ExamAttemptCycle[id]" has a null value in JSON.');
        assert(json[r'code'] != null, 'Required key "ExamAttemptCycle[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "ExamAttemptCycle[name]" has a null value in JSON.');
        assert(json[r'status'] != null, 'Required key "ExamAttemptCycle[status]" has a null value in JSON.');
        assert(json[r'stageDates'] != null, 'Required key "ExamAttemptCycle[stageDates]" has a null value in JSON.');
        return true;
      }());

      return ExamAttemptCycle(
        id: mapValueOfType<String>(json, r'id')!,
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        status: ExamAttemptCycleStatusEnum.fromJson(json[r'status'])!,
        stageDates: ExamAttemptCycleStageDatesInner.listFromJson(json[r'stageDates']),
      );
    }
    return null;
  }

  static List<ExamAttemptCycle> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAttemptCycle>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAttemptCycle.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamAttemptCycle> mapFromJson(dynamic json) {
    final map = <String, ExamAttemptCycle>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamAttemptCycle.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamAttemptCycle-objects as value to a dart map
  static Map<String, List<ExamAttemptCycle>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamAttemptCycle>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamAttemptCycle.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'code',
    'name',
    'status',
    'stageDates',
  };
}


class ExamAttemptCycleStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamAttemptCycleStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const announced = ExamAttemptCycleStatusEnum._(r'announced');
  static const expected = ExamAttemptCycleStatusEnum._(r'expected');
  static const closed = ExamAttemptCycleStatusEnum._(r'closed');

  /// List of all possible values in this [enum][ExamAttemptCycleStatusEnum].
  static const values = <ExamAttemptCycleStatusEnum>[
    announced,
    expected,
    closed,
  ];

  static ExamAttemptCycleStatusEnum? fromJson(dynamic value) => ExamAttemptCycleStatusEnumTypeTransformer().decode(value);

  static List<ExamAttemptCycleStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamAttemptCycleStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamAttemptCycleStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamAttemptCycleStatusEnum] to String,
/// and [decode] dynamic data back to [ExamAttemptCycleStatusEnum].
class ExamAttemptCycleStatusEnumTypeTransformer {
  factory ExamAttemptCycleStatusEnumTypeTransformer() => _instance ??= const ExamAttemptCycleStatusEnumTypeTransformer._();

  const ExamAttemptCycleStatusEnumTypeTransformer._();

  String encode(ExamAttemptCycleStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamAttemptCycleStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamAttemptCycleStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'announced': return ExamAttemptCycleStatusEnum.announced;
        case r'expected': return ExamAttemptCycleStatusEnum.expected;
        case r'closed': return ExamAttemptCycleStatusEnum.closed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamAttemptCycleStatusEnumTypeTransformer] instance.
  static ExamAttemptCycleStatusEnumTypeTransformer? _instance;
}


