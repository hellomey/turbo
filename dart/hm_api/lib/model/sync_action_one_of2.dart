//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncActionOneOf2 {
  /// Returns a new [SyncActionOneOf2] instance.
  SyncActionOneOf2({
    required this.clientActionId,
    required this.clientAt,
    required this.kind,
    required this.topicId,
    required this.checkKind,
    this.answers = const [],
  });

  String clientActionId;

  DateTime clientAt;

  SyncActionOneOf2KindEnum kind;

  String topicId;

  SyncActionOneOf2CheckKindEnum checkKind;

  List<AnswerInput> answers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncActionOneOf2 &&
    other.clientActionId == clientActionId &&
    other.clientAt == clientAt &&
    other.kind == kind &&
    other.topicId == topicId &&
    other.checkKind == checkKind &&
    _deepEquality.equals(other.answers, answers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (clientAt.hashCode) +
    (kind.hashCode) +
    (topicId.hashCode) +
    (checkKind.hashCode) +
    (answers.hashCode);

  @override
  String toString() => 'SyncActionOneOf2[clientActionId=$clientActionId, clientAt=$clientAt, kind=$kind, topicId=$topicId, checkKind=$checkKind, answers=$answers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'clientAt'] = this.clientAt.toUtc().toIso8601String();
      json[r'kind'] = this.kind;
      json[r'topicId'] = this.topicId;
      json[r'checkKind'] = this.checkKind;
      json[r'answers'] = this.answers;
    return json;
  }

  /// Returns a new [SyncActionOneOf2] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncActionOneOf2? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncActionOneOf2[$key]" is missing from JSON.');
        });
        assert(json[r'clientActionId'] != null, 'Required key "SyncActionOneOf2[clientActionId]" has a null value in JSON.');
        assert(json[r'clientAt'] != null, 'Required key "SyncActionOneOf2[clientAt]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SyncActionOneOf2[kind]" has a null value in JSON.');
        assert(json[r'topicId'] != null, 'Required key "SyncActionOneOf2[topicId]" has a null value in JSON.');
        assert(json[r'checkKind'] != null, 'Required key "SyncActionOneOf2[checkKind]" has a null value in JSON.');
        assert(json[r'answers'] != null, 'Required key "SyncActionOneOf2[answers]" has a null value in JSON.');
        return true;
      }());

      return SyncActionOneOf2(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
        kind: SyncActionOneOf2KindEnum.fromJson(json[r'kind'])!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        checkKind: SyncActionOneOf2CheckKindEnum.fromJson(json[r'checkKind'])!,
        answers: AnswerInput.listFromJson(json[r'answers']),
      );
    }
    return null;
  }

  static List<SyncActionOneOf2> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf2>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf2.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncActionOneOf2> mapFromJson(dynamic json) {
    final map = <String, SyncActionOneOf2>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncActionOneOf2.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncActionOneOf2-objects as value to a dart map
  static Map<String, List<SyncActionOneOf2>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncActionOneOf2>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncActionOneOf2.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientActionId',
    'clientAt',
    'kind',
    'topicId',
    'checkKind',
    'answers',
  };
}


class SyncActionOneOf2KindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf2KindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const topicCheck = SyncActionOneOf2KindEnum._(r'topic_check');

  /// List of all possible values in this [enum][SyncActionOneOf2KindEnum].
  static const values = <SyncActionOneOf2KindEnum>[
    topicCheck,
  ];

  static SyncActionOneOf2KindEnum? fromJson(dynamic value) => SyncActionOneOf2KindEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf2KindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf2KindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf2KindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf2KindEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf2KindEnum].
class SyncActionOneOf2KindEnumTypeTransformer {
  factory SyncActionOneOf2KindEnumTypeTransformer() => _instance ??= const SyncActionOneOf2KindEnumTypeTransformer._();

  const SyncActionOneOf2KindEnumTypeTransformer._();

  String encode(SyncActionOneOf2KindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf2KindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf2KindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'topic_check': return SyncActionOneOf2KindEnum.topicCheck;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf2KindEnumTypeTransformer] instance.
  static SyncActionOneOf2KindEnumTypeTransformer? _instance;
}



class SyncActionOneOf2CheckKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf2CheckKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lit = SyncActionOneOf2CheckKindEnum._(r'lit');
  static const recall = SyncActionOneOf2CheckKindEnum._(r'recall');
  static const relight = SyncActionOneOf2CheckKindEnum._(r'relight');

  /// List of all possible values in this [enum][SyncActionOneOf2CheckKindEnum].
  static const values = <SyncActionOneOf2CheckKindEnum>[
    lit,
    recall,
    relight,
  ];

  static SyncActionOneOf2CheckKindEnum? fromJson(dynamic value) => SyncActionOneOf2CheckKindEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf2CheckKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf2CheckKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf2CheckKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf2CheckKindEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf2CheckKindEnum].
class SyncActionOneOf2CheckKindEnumTypeTransformer {
  factory SyncActionOneOf2CheckKindEnumTypeTransformer() => _instance ??= const SyncActionOneOf2CheckKindEnumTypeTransformer._();

  const SyncActionOneOf2CheckKindEnumTypeTransformer._();

  String encode(SyncActionOneOf2CheckKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf2CheckKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf2CheckKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lit': return SyncActionOneOf2CheckKindEnum.lit;
        case r'recall': return SyncActionOneOf2CheckKindEnum.recall;
        case r'relight': return SyncActionOneOf2CheckKindEnum.relight;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf2CheckKindEnumTypeTransformer] instance.
  static SyncActionOneOf2CheckKindEnumTypeTransformer? _instance;
}


