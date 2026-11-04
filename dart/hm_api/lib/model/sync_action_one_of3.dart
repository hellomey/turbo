//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncActionOneOf3 {
  /// Returns a new [SyncActionOneOf3] instance.
  SyncActionOneOf3({
    required this.clientActionId,
    required this.clientAt,
    required this.kind,
    required this.itemId,
    required this.status,
  });

  String clientActionId;

  DateTime clientAt;

  SyncActionOneOf3KindEnum kind;

  String itemId;

  SyncActionOneOf3StatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncActionOneOf3 &&
    other.clientActionId == clientActionId &&
    other.clientAt == clientAt &&
    other.kind == kind &&
    other.itemId == itemId &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (clientAt.hashCode) +
    (kind.hashCode) +
    (itemId.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'SyncActionOneOf3[clientActionId=$clientActionId, clientAt=$clientAt, kind=$kind, itemId=$itemId, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'clientAt'] = this.clientAt.toUtc().toIso8601String();
      json[r'kind'] = this.kind;
      json[r'itemId'] = this.itemId;
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [SyncActionOneOf3] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncActionOneOf3? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncActionOneOf3[$key]" is missing from JSON.');
        });
        assert(json[r'clientActionId'] != null, 'Required key "SyncActionOneOf3[clientActionId]" has a null value in JSON.');
        assert(json[r'clientAt'] != null, 'Required key "SyncActionOneOf3[clientAt]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SyncActionOneOf3[kind]" has a null value in JSON.');
        assert(json[r'itemId'] != null, 'Required key "SyncActionOneOf3[itemId]" has a null value in JSON.');
        assert(json[r'status'] != null, 'Required key "SyncActionOneOf3[status]" has a null value in JSON.');
        return true;
      }());

      return SyncActionOneOf3(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
        kind: SyncActionOneOf3KindEnum.fromJson(json[r'kind'])!,
        itemId: mapValueOfType<String>(json, r'itemId')!,
        status: SyncActionOneOf3StatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<SyncActionOneOf3> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf3>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf3.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncActionOneOf3> mapFromJson(dynamic json) {
    final map = <String, SyncActionOneOf3>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncActionOneOf3.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncActionOneOf3-objects as value to a dart map
  static Map<String, List<SyncActionOneOf3>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncActionOneOf3>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncActionOneOf3.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientActionId',
    'clientAt',
    'kind',
    'itemId',
    'status',
  };
}


class SyncActionOneOf3KindEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf3KindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const planItemStatus = SyncActionOneOf3KindEnum._(r'plan_item_status');

  /// List of all possible values in this [enum][SyncActionOneOf3KindEnum].
  static const values = <SyncActionOneOf3KindEnum>[
    planItemStatus,
  ];

  static SyncActionOneOf3KindEnum? fromJson(dynamic value) => SyncActionOneOf3KindEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf3KindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf3KindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf3KindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf3KindEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf3KindEnum].
class SyncActionOneOf3KindEnumTypeTransformer {
  factory SyncActionOneOf3KindEnumTypeTransformer() => _instance ??= const SyncActionOneOf3KindEnumTypeTransformer._();

  const SyncActionOneOf3KindEnumTypeTransformer._();

  String encode(SyncActionOneOf3KindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf3KindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf3KindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'plan_item_status': return SyncActionOneOf3KindEnum.planItemStatus;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf3KindEnumTypeTransformer] instance.
  static SyncActionOneOf3KindEnumTypeTransformer? _instance;
}



class SyncActionOneOf3StatusEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionOneOf3StatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const done = SyncActionOneOf3StatusEnum._(r'done');
  static const skipped = SyncActionOneOf3StatusEnum._(r'skipped');

  /// List of all possible values in this [enum][SyncActionOneOf3StatusEnum].
  static const values = <SyncActionOneOf3StatusEnum>[
    done,
    skipped,
  ];

  static SyncActionOneOf3StatusEnum? fromJson(dynamic value) => SyncActionOneOf3StatusEnumTypeTransformer().decode(value);

  static List<SyncActionOneOf3StatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionOneOf3StatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionOneOf3StatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionOneOf3StatusEnum] to String,
/// and [decode] dynamic data back to [SyncActionOneOf3StatusEnum].
class SyncActionOneOf3StatusEnumTypeTransformer {
  factory SyncActionOneOf3StatusEnumTypeTransformer() => _instance ??= const SyncActionOneOf3StatusEnumTypeTransformer._();

  const SyncActionOneOf3StatusEnumTypeTransformer._();

  String encode(SyncActionOneOf3StatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionOneOf3StatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionOneOf3StatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'done': return SyncActionOneOf3StatusEnum.done;
        case r'skipped': return SyncActionOneOf3StatusEnum.skipped;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionOneOf3StatusEnumTypeTransformer] instance.
  static SyncActionOneOf3StatusEnumTypeTransformer? _instance;
}


