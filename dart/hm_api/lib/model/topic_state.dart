//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TopicState {
  /// Returns a new [TopicState] instance.
  TopicState({
    required this.topicId,
    required this.ring,
    required this.litAt,
    required this.goldAt,
    required this.lessonCompletedAt,
    required this.nextDueAt,
    required this.nextCheck,
    required this.updatedAt,
  });

  String topicId;

  LampRing ring;

  DateTime? litAt;

  DateTime? goldAt;

  DateTime? lessonCompletedAt;

  DateTime? nextDueAt;

  TopicStateNextCheckEnum nextCheck;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TopicState &&
    other.topicId == topicId &&
    other.ring == ring &&
    other.litAt == litAt &&
    other.goldAt == goldAt &&
    other.lessonCompletedAt == lessonCompletedAt &&
    other.nextDueAt == nextDueAt &&
    other.nextCheck == nextCheck &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (topicId.hashCode) +
    (ring.hashCode) +
    (litAt == null ? 0 : litAt!.hashCode) +
    (goldAt == null ? 0 : goldAt!.hashCode) +
    (lessonCompletedAt == null ? 0 : lessonCompletedAt!.hashCode) +
    (nextDueAt == null ? 0 : nextDueAt!.hashCode) +
    (nextCheck.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'TopicState[topicId=$topicId, ring=$ring, litAt=$litAt, goldAt=$goldAt, lessonCompletedAt=$lessonCompletedAt, nextDueAt=$nextDueAt, nextCheck=$nextCheck, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'topicId'] = this.topicId;
      json[r'ring'] = this.ring;
    if (this.litAt != null) {
      json[r'litAt'] = this.litAt!.toUtc().toIso8601String();
    } else {
      json[r'litAt'] = null;
    }
    if (this.goldAt != null) {
      json[r'goldAt'] = this.goldAt!.toUtc().toIso8601String();
    } else {
      json[r'goldAt'] = null;
    }
    if (this.lessonCompletedAt != null) {
      json[r'lessonCompletedAt'] = this.lessonCompletedAt!.toUtc().toIso8601String();
    } else {
      json[r'lessonCompletedAt'] = null;
    }
    if (this.nextDueAt != null) {
      json[r'nextDueAt'] = this.nextDueAt!.toUtc().toIso8601String();
    } else {
      json[r'nextDueAt'] = null;
    }
      json[r'nextCheck'] = this.nextCheck;
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TopicState] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TopicState? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TopicState[$key]" is missing from JSON.');
        });
        assert(json[r'topicId'] != null, 'Required key "TopicState[topicId]" has a null value in JSON.');
        assert(json[r'ring'] != null, 'Required key "TopicState[ring]" has a null value in JSON.');
        assert(json[r'nextCheck'] != null, 'Required key "TopicState[nextCheck]" has a null value in JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "TopicState[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return TopicState(
        topicId: mapValueOfType<String>(json, r'topicId')!,
        ring: LampRing.fromJson(json[r'ring'])!,
        litAt: mapDateTime(json, r'litAt', r''),
        goldAt: mapDateTime(json, r'goldAt', r''),
        lessonCompletedAt: mapDateTime(json, r'lessonCompletedAt', r''),
        nextDueAt: mapDateTime(json, r'nextDueAt', r''),
        nextCheck: TopicStateNextCheckEnum.fromJson(json[r'nextCheck'])!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<TopicState> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TopicState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TopicState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TopicState> mapFromJson(dynamic json) {
    final map = <String, TopicState>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TopicState.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TopicState-objects as value to a dart map
  static Map<String, List<TopicState>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TopicState>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TopicState.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'topicId',
    'ring',
    'litAt',
    'goldAt',
    'lessonCompletedAt',
    'nextDueAt',
    'nextCheck',
    'updatedAt',
  };
}


class TopicStateNextCheckEnum {
  /// Instantiate a new enum with the provided [value].
  const TopicStateNextCheckEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lesson = TopicStateNextCheckEnum._(r'lesson');
  static const lit = TopicStateNextCheckEnum._(r'lit');
  static const recall = TopicStateNextCheckEnum._(r'recall');
  static const relight = TopicStateNextCheckEnum._(r'relight');
  static const gold = TopicStateNextCheckEnum._(r'gold');
  static const none = TopicStateNextCheckEnum._(r'none');

  /// List of all possible values in this [enum][TopicStateNextCheckEnum].
  static const values = <TopicStateNextCheckEnum>[
    lesson,
    lit,
    recall,
    relight,
    gold,
    none,
  ];

  static TopicStateNextCheckEnum? fromJson(dynamic value) => TopicStateNextCheckEnumTypeTransformer().decode(value);

  static List<TopicStateNextCheckEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TopicStateNextCheckEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TopicStateNextCheckEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TopicStateNextCheckEnum] to String,
/// and [decode] dynamic data back to [TopicStateNextCheckEnum].
class TopicStateNextCheckEnumTypeTransformer {
  factory TopicStateNextCheckEnumTypeTransformer() => _instance ??= const TopicStateNextCheckEnumTypeTransformer._();

  const TopicStateNextCheckEnumTypeTransformer._();

  String encode(TopicStateNextCheckEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TopicStateNextCheckEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TopicStateNextCheckEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson': return TopicStateNextCheckEnum.lesson;
        case r'lit': return TopicStateNextCheckEnum.lit;
        case r'recall': return TopicStateNextCheckEnum.recall;
        case r'relight': return TopicStateNextCheckEnum.relight;
        case r'gold': return TopicStateNextCheckEnum.gold;
        case r'none': return TopicStateNextCheckEnum.none;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TopicStateNextCheckEnumTypeTransformer] instance.
  static TopicStateNextCheckEnumTypeTransformer? _instance;
}


