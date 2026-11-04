//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncActionOneOf1 {
  /// Returns a new [SyncActionOneOf1] instance.
  SyncActionOneOf1({
    required this.clientActionId,
    required this.clientAt,
    required this.kind,
    required this.topicId,
    required this.via,
  });

  String clientActionId;

  DateTime clientAt;

  SyncActionOneOf1KindEnum kind;

  String topicId;

  SyncActionOneOf1ViaEnum via;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncActionOneOf1 &&
    other.clientActionId == clientActionId &&
    other.clientAt == clientAt &&
    other.kind == kind &&
    other.topicId == topicId &&
    other.via == via;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (clientAt.hashCode) +
    (kind.hashCode) +
    (topicId.hashCode) +
    (via.hashCode);

  @override
  String toString() => 'SyncActionOneOf1[clientActionId=$clientActionId, clientAt=$clientAt, kind=$kind, topicId=$topicId, via=$via]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'clientAt'] = this.clientAt.toUtc().toIso8601String();
      json[r'kind'] = this.kind;
      json[r'topicId'] = this.topicId;
      json[r'via'] = this.via;
    return json;
  }

  /// Returns a new [SyncActionOneOf1] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncActionOneOf1? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncActionOneOf1[$key]" is missing from JSON.');
        });
        assert(json[r'clientActionId'] != null, 'Required key "SyncActionOneOf1[clientActionId]" has a null value in JSON.');
        assert(json[r'clientAt'] != null, 'Required key "SyncActionOneOf1[clientAt]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SyncActionOneOf1[kind]" has a null value in JSON.');
        assert(json[r'topicId'] != null, 'Required key "SyncActionOneOf1[topicId]" has a null value in JSON.');
        assert(json[r'via'] != null, 'Required key "SyncActionOneOf1[via]" has a null value in JSON.');
        return true;
      }());

      return SyncActionOneOf1(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
        kind: SyncActionOneOf1KindEnum.fromJson(json[r'kind'])!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        via: SyncActionOneOf1ViaEnum.fromJson(json[r'via'])!,
      );
    }
    return null;
  }

  static List<SyncActionOneOf1> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf1>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf1.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncActionOneOf1> mapFromJson(dynamic json) {
    final map = <String, SyncActionOneOf1>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncActionOneOf1.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncActionOneOf1-objects as value to a dart map
  static Map<String, List<SyncActionOneOf1>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncActionOneOf1>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncActionOneOf1.listFromJson(entry.value, growable: growable,);
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
    'via',
  };
}


class SyncActionOneOf1KindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf1KindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lessonComplete = SyncActionOneOf1KindEnum._(r'lesson_complete');

  /// List of all possible values in this [enum][SyncActionOneOf1KindEnum].
  static const values = <SyncActionOneOf1KindEnum>[
    lessonComplete,
  ];

  static SyncActionOneOf1KindEnum? fromJson(dynamic value) => SyncActionOneOf1KindEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf1KindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf1KindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf1KindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf1KindEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf1KindEnum].
class SyncActionOneOf1KindEnumTypeTransformer {
  factory SyncActionOneOf1KindEnumTypeTransformer() => _instance ??= const SyncActionOneOf1KindEnumTypeTransformer._();

  const SyncActionOneOf1KindEnumTypeTransformer._();

  String encode(SyncActionOneOf1KindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf1KindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf1KindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson_complete': return SyncActionOneOf1KindEnum.lessonComplete;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf1KindEnumTypeTransformer] instance.
  static SyncActionOneOf1KindEnumTypeTransformer? _instance;
}



class SyncActionOneOf1ViaEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf1ViaEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lesson = SyncActionOneOf1ViaEnum._(r'lesson');
  static const textbook = SyncActionOneOf1ViaEnum._(r'textbook');

  /// List of all possible values in this [enum][SyncActionOneOf1ViaEnum].
  static const values = <SyncActionOneOf1ViaEnum>[
    lesson,
    textbook,
  ];

  static SyncActionOneOf1ViaEnum? fromJson(dynamic value) => SyncActionOneOf1ViaEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf1ViaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf1ViaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf1ViaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf1ViaEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf1ViaEnum].
class SyncActionOneOf1ViaEnumTypeTransformer {
  factory SyncActionOneOf1ViaEnumTypeTransformer() => _instance ??= const SyncActionOneOf1ViaEnumTypeTransformer._();

  const SyncActionOneOf1ViaEnumTypeTransformer._();

  String encode(SyncActionOneOf1ViaEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf1ViaEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf1ViaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson': return SyncActionOneOf1ViaEnum.lesson;
        case r'textbook': return SyncActionOneOf1ViaEnum.textbook;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf1ViaEnumTypeTransformer] instance.
  static SyncActionOneOf1ViaEnumTypeTransformer? _instance;
}


