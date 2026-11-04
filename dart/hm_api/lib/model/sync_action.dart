//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncAction {
  /// Returns a new [SyncAction] instance.
  SyncAction({
    required this.clientActionId,
    required this.clientAt,
    required this.kind,
    required this.questionId,
    required this.questionVersion,
    this.chosenOptionIds = const [],
    required this.timeMs,
    required this.mode,
    required this.topicId,
    required this.via,
    required this.checkKind,
    this.answers = const [],
    required this.itemId,
    required this.status,
  });

  String clientActionId;

  DateTime clientAt;

  SyncActionKindEnum kind;

  String questionId;

  int questionVersion;

  List<String> chosenOptionIds;

  /// Minimum value: 0
  /// Maximum value: 3600000
  int timeMs;

  SyncActionModeEnum mode;

  String topicId;

  SyncActionViaEnum via;

  SyncActionCheckKindEnum checkKind;

  List<AnswerInput> answers;

  String itemId;

  SyncActionStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncAction &&
    other.clientActionId == clientActionId &&
    other.clientAt == clientAt &&
    other.kind == kind &&
    other.questionId == questionId &&
    other.questionVersion == questionVersion &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.timeMs == timeMs &&
    other.mode == mode &&
    other.topicId == topicId &&
    other.via == via &&
    other.checkKind == checkKind &&
    _deepEquality.equals(other.answers, answers) &&
    other.itemId == itemId &&
    other.status == status;

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
    (mode.hashCode) +
    (topicId.hashCode) +
    (via.hashCode) +
    (checkKind.hashCode) +
    (answers.hashCode) +
    (itemId.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'SyncAction[clientActionId=$clientActionId, clientAt=$clientAt, kind=$kind, questionId=$questionId, questionVersion=$questionVersion, chosenOptionIds=$chosenOptionIds, timeMs=$timeMs, mode=$mode, topicId=$topicId, via=$via, checkKind=$checkKind, answers=$answers, itemId=$itemId, status=$status]';

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
      json[r'topicId'] = this.topicId;
      json[r'via'] = this.via;
      json[r'checkKind'] = this.checkKind;
      json[r'answers'] = this.answers;
      json[r'itemId'] = this.itemId;
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [SyncAction] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncAction? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncAction[$key]" is missing from JSON.');
        });
        assert(json[r'clientActionId'] != null, 'Required key "SyncAction[clientActionId]" has a null value in JSON.');
        assert(json[r'clientAt'] != null, 'Required key "SyncAction[clientAt]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SyncAction[kind]" has a null value in JSON.');
        assert(json[r'questionId'] != null, 'Required key "SyncAction[questionId]" has a null value in JSON.');
        assert(json[r'questionVersion'] != null, 'Required key "SyncAction[questionVersion]" has a null value in JSON.');
        assert(json[r'chosenOptionIds'] != null, 'Required key "SyncAction[chosenOptionIds]" has a null value in JSON.');
        assert(json[r'timeMs'] != null, 'Required key "SyncAction[timeMs]" has a null value in JSON.');
        assert(json[r'mode'] != null, 'Required key "SyncAction[mode]" has a null value in JSON.');
        assert(json[r'topicId'] != null, 'Required key "SyncAction[topicId]" has a null value in JSON.');
        assert(json[r'via'] != null, 'Required key "SyncAction[via]" has a null value in JSON.');
        assert(json[r'checkKind'] != null, 'Required key "SyncAction[checkKind]" has a null value in JSON.');
        assert(json[r'answers'] != null, 'Required key "SyncAction[answers]" has a null value in JSON.');
        assert(json[r'itemId'] != null, 'Required key "SyncAction[itemId]" has a null value in JSON.');
        assert(json[r'status'] != null, 'Required key "SyncAction[status]" has a null value in JSON.');
        return true;
      }());

      return SyncAction(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
        kind: SyncActionKindEnum.fromJson(json[r'kind'])!,
        questionId: mapValueOfType<String>(json, r'questionId')!,
        questionVersion: mapValueOfType<int>(json, r'questionVersion')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        timeMs: mapValueOfType<int>(json, r'timeMs')!,
        mode: SyncActionModeEnum.fromJson(json[r'mode'])!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        via: SyncActionViaEnum.fromJson(json[r'via'])!,
        checkKind: SyncActionCheckKindEnum.fromJson(json[r'checkKind'])!,
        answers: AnswerInput.listFromJson(json[r'answers']),
        itemId: mapValueOfType<String>(json, r'itemId')!,
        status: SyncActionStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<SyncAction> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncAction>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncAction.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncAction> mapFromJson(dynamic json) {
    final map = <String, SyncAction>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncAction.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncAction-objects as value to a dart map
  static Map<String, List<SyncAction>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncAction>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncAction.listFromJson(entry.value, growable: growable,);
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
    'topicId',
    'via',
    'checkKind',
    'answers',
    'itemId',
    'status',
  };
}


class SyncActionKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const planItemStatus = SyncActionKindEnum._(r'plan_item_status');

  /// List of all possible values in this [enum][SyncActionKindEnum].
  static const values = <SyncActionKindEnum>[
    planItemStatus,
  ];

  static SyncActionKindEnum? fromJson(dynamic value) => SyncActionKindEnumTypeTransformer().decode(value);

  static List<SyncActionKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionKindEnum] to String,
/// and [decode] dynamic data back to [SyncActionKindEnum].
class SyncActionKindEnumTypeTransformer {
  factory SyncActionKindEnumTypeTransformer() => _instance ??= const SyncActionKindEnumTypeTransformer._();

  const SyncActionKindEnumTypeTransformer._();

  String encode(SyncActionKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'plan_item_status': return SyncActionKindEnum.planItemStatus;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionKindEnumTypeTransformer] instance.
  static SyncActionKindEnumTypeTransformer? _instance;
}



class SyncActionModeEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const practice = SyncActionModeEnum._(r'practice');
  static const pyq = SyncActionModeEnum._(r'pyq');
  static const mistakes = SyncActionModeEnum._(r'mistakes');
  static const drill = SyncActionModeEnum._(r'drill');

  /// List of all possible values in this [enum][SyncActionModeEnum].
  static const values = <SyncActionModeEnum>[
    practice,
    pyq,
    mistakes,
    drill,
  ];

  static SyncActionModeEnum? fromJson(dynamic value) => SyncActionModeEnumTypeTransformer().decode(value);

  static List<SyncActionModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionModeEnum] to String,
/// and [decode] dynamic data back to [SyncActionModeEnum].
class SyncActionModeEnumTypeTransformer {
  factory SyncActionModeEnumTypeTransformer() => _instance ??= const SyncActionModeEnumTypeTransformer._();

  const SyncActionModeEnumTypeTransformer._();

  String encode(SyncActionModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'practice': return SyncActionModeEnum.practice;
        case r'pyq': return SyncActionModeEnum.pyq;
        case r'mistakes': return SyncActionModeEnum.mistakes;
        case r'drill': return SyncActionModeEnum.drill;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionModeEnumTypeTransformer] instance.
  static SyncActionModeEnumTypeTransformer? _instance;
}



class SyncActionViaEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionViaEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lesson = SyncActionViaEnum._(r'lesson');
  static const textbook = SyncActionViaEnum._(r'textbook');

  /// List of all possible values in this [enum][SyncActionViaEnum].
  static const values = <SyncActionViaEnum>[
    lesson,
    textbook,
  ];

  static SyncActionViaEnum? fromJson(dynamic value) => SyncActionViaEnumTypeTransformer().decode(value);

  static List<SyncActionViaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionViaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionViaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionViaEnum] to String,
/// and [decode] dynamic data back to [SyncActionViaEnum].
class SyncActionViaEnumTypeTransformer {
  factory SyncActionViaEnumTypeTransformer() => _instance ??= const SyncActionViaEnumTypeTransformer._();

  const SyncActionViaEnumTypeTransformer._();

  String encode(SyncActionViaEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionViaEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionViaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson': return SyncActionViaEnum.lesson;
        case r'textbook': return SyncActionViaEnum.textbook;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionViaEnumTypeTransformer] instance.
  static SyncActionViaEnumTypeTransformer? _instance;
}



class SyncActionCheckKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionCheckKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lit = SyncActionCheckKindEnum._(r'lit');
  static const recall = SyncActionCheckKindEnum._(r'recall');
  static const relight = SyncActionCheckKindEnum._(r'relight');

  /// List of all possible values in this [enum][SyncActionCheckKindEnum].
  static const values = <SyncActionCheckKindEnum>[
    lit,
    recall,
    relight,
  ];

  static SyncActionCheckKindEnum? fromJson(dynamic value) => SyncActionCheckKindEnumTypeTransformer().decode(value);

  static List<SyncActionCheckKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionCheckKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionCheckKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionCheckKindEnum] to String,
/// and [decode] dynamic data back to [SyncActionCheckKindEnum].
class SyncActionCheckKindEnumTypeTransformer {
  factory SyncActionCheckKindEnumTypeTransformer() => _instance ??= const SyncActionCheckKindEnumTypeTransformer._();

  const SyncActionCheckKindEnumTypeTransformer._();

  String encode(SyncActionCheckKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionCheckKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionCheckKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lit': return SyncActionCheckKindEnum.lit;
        case r'recall': return SyncActionCheckKindEnum.recall;
        case r'relight': return SyncActionCheckKindEnum.relight;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionCheckKindEnumTypeTransformer] instance.
  static SyncActionCheckKindEnumTypeTransformer? _instance;
}



class SyncActionStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const done = SyncActionStatusEnum._(r'done');
  static const skipped = SyncActionStatusEnum._(r'skipped');

  /// List of all possible values in this [enum][SyncActionStatusEnum].
  static const values = <SyncActionStatusEnum>[
    done,
    skipped,
  ];

  static SyncActionStatusEnum? fromJson(dynamic value) => SyncActionStatusEnumTypeTransformer().decode(value);

  static List<SyncActionStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionStatusEnum] to String,
/// and [decode] dynamic data back to [SyncActionStatusEnum].
class SyncActionStatusEnumTypeTransformer {
  factory SyncActionStatusEnumTypeTransformer() => _instance ??= const SyncActionStatusEnumTypeTransformer._();

  const SyncActionStatusEnumTypeTransformer._();

  String encode(SyncActionStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'done': return SyncActionStatusEnum.done;
        case r'skipped': return SyncActionStatusEnum.skipped;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionStatusEnumTypeTransformer] instance.
  static SyncActionStatusEnumTypeTransformer? _instance;
}


