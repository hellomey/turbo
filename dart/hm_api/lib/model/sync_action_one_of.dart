//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncActionOneOf {
  /// Returns a new [SyncActionOneOf] instance.
  SyncActionOneOf({
    required this.clientActionId,
    required this.clientAt,
    required this.kind,
    required this.questionId,
    required this.questionVersion,
    this.chosenOptionIds = const [],
    required this.timeMs,
    required this.mode,
  });

  String clientActionId;

  DateTime clientAt;

  SyncActionOneOfKindEnum kind;

  String questionId;

  int questionVersion;

  List<String> chosenOptionIds;

  /// Minimum value: 0
  /// Maximum value: 3600000
  int timeMs;

  SyncActionOneOfModeEnum mode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncActionOneOf &&
    other.clientActionId == clientActionId &&
    other.clientAt == clientAt &&
    other.kind == kind &&
    other.questionId == questionId &&
    other.questionVersion == questionVersion &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.timeMs == timeMs &&
    other.mode == mode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (clientAt.hashCode) +
    (kind.hashCode) +
    (questionId.hashCode) +
    (questionVersion.hashCode) +
    (chosenOptionIds.hashCode) +
    (timeMs.hashCode) +
    (mode.hashCode);

  @override
  String toString() => 'SyncActionOneOf[clientActionId=$clientActionId, clientAt=$clientAt, kind=$kind, questionId=$questionId, questionVersion=$questionVersion, chosenOptionIds=$chosenOptionIds, timeMs=$timeMs, mode=$mode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'clientAt'] = this.clientAt.toUtc().toIso8601String();
      json[r'kind'] = this.kind;
      json[r'questionId'] = this.questionId;
      json[r'questionVersion'] = this.questionVersion;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
      json[r'timeMs'] = this.timeMs;
      json[r'mode'] = this.mode;
    return json;
  }

  /// Returns a new [SyncActionOneOf] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncActionOneOf? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncActionOneOf[$key]" is missing from JSON.');
        });
        assert(json[r'clientActionId'] != null, 'Required key "SyncActionOneOf[clientActionId]" has a null value in JSON.');
        assert(json[r'clientAt'] != null, 'Required key "SyncActionOneOf[clientAt]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SyncActionOneOf[kind]" has a null value in JSON.');
        assert(json[r'questionId'] != null, 'Required key "SyncActionOneOf[questionId]" has a null value in JSON.');
        assert(json[r'questionVersion'] != null, 'Required key "SyncActionOneOf[questionVersion]" has a null value in JSON.');
        assert(json[r'chosenOptionIds'] != null, 'Required key "SyncActionOneOf[chosenOptionIds]" has a null value in JSON.');
        assert(json[r'timeMs'] != null, 'Required key "SyncActionOneOf[timeMs]" has a null value in JSON.');
        assert(json[r'mode'] != null, 'Required key "SyncActionOneOf[mode]" has a null value in JSON.');
        return true;
      }());

      return SyncActionOneOf(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
        kind: SyncActionOneOfKindEnum.fromJson(json[r'kind'])!,
        questionId: mapValueOfType<String>(json, r'questionId')!,
        questionVersion: mapValueOfType<int>(json, r'questionVersion')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        timeMs: mapValueOfType<int>(json, r'timeMs')!,
        mode: SyncActionOneOfModeEnum.fromJson(json[r'mode'])!,
      );
    }
    return null;
  }

  static List<SyncActionOneOf> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncActionOneOf> mapFromJson(dynamic json) {
    final map = <String, SyncActionOneOf>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncActionOneOf.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncActionOneOf-objects as value to a dart map
  static Map<String, List<SyncActionOneOf>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncActionOneOf>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncActionOneOf.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientActionId',
    'clientAt',
    'kind',
    'questionId',
    'questionVersion',
    'chosenOptionIds',
    'timeMs',
    'mode',
  };
}


class SyncActionOneOfKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOfKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const practiceAnswer = SyncActionOneOfKindEnum._(r'practice_answer');

  /// List of all possible values in this [enum][SyncActionOneOfKindEnum].
  static const values = <SyncActionOneOfKindEnum>[
    practiceAnswer,
  ];

  static SyncActionOneOfKindEnum? fromJson(dynamic value) => SyncActionOneOfKindEnumTypeTransformer().decode(value);

  static List<SyncActionOneOfKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOfKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOfKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOfKindEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOfKindEnum].
class SyncActionOneOfKindEnumTypeTransformer {
  factory SyncActionOneOfKindEnumTypeTransformer() => _instance ??= const SyncActionOneOfKindEnumTypeTransformer._();

  const SyncActionOneOfKindEnumTypeTransformer._();

  String encode(SyncActionOneOfKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOfKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOfKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'practice_answer': return SyncActionOneOfKindEnum.practiceAnswer;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOfKindEnumTypeTransformer] instance.
  static SyncActionOneOfKindEnumTypeTransformer? _instance;
}



class SyncActionOneOfModeEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOfModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const practice = SyncActionOneOfModeEnum._(r'practice');
  static const pyq = SyncActionOneOfModeEnum._(r'pyq');
  static const mistakes = SyncActionOneOfModeEnum._(r'mistakes');
  static const drill = SyncActionOneOfModeEnum._(r'drill');

  /// List of all possible values in this [enum][SyncActionOneOfModeEnum].
  static const values = <SyncActionOneOfModeEnum>[
    practice,
    pyq,
    mistakes,
    drill,
  ];

  static SyncActionOneOfModeEnum? fromJson(dynamic value) => SyncActionOneOfModeEnumTypeTransformer().decode(value);

  static List<SyncActionOneOfModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOfModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOfModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOfModeEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOfModeEnum].
class SyncActionOneOfModeEnumTypeTransformer {
  factory SyncActionOneOfModeEnumTypeTransformer() => _instance ??= const SyncActionOneOfModeEnumTypeTransformer._();

  const SyncActionOneOfModeEnumTypeTransformer._();

  String encode(SyncActionOneOfModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOfModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOfModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'practice': return SyncActionOneOfModeEnum.practice;
        case r'pyq': return SyncActionOneOfModeEnum.pyq;
        case r'mistakes': return SyncActionOneOfModeEnum.mistakes;
        case r'drill': return SyncActionOneOfModeEnum.drill;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOfModeEnumTypeTransformer] instance.
  static SyncActionOneOfModeEnumTypeTransformer? _instance;
}


