//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConceptDrill {
  /// Returns a new [ConceptDrill] instance.
  ConceptDrill({
    required this.id,
    required this.topicId,
    required this.reason,
    required this.questionCount,
    required this.createdAt,
    required this.status,
  });

  String id;

  String topicId;

  String reason;

  int questionCount;

  DateTime createdAt;

  ConceptDrillStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConceptDrill &&
    other.id == id &&
    other.topicId == topicId &&
    other.reason == reason &&
    other.questionCount == questionCount &&
    other.createdAt == createdAt &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (topicId.hashCode) +
    (reason.hashCode) +
    (questionCount.hashCode) +
    (createdAt.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'ConceptDrill[id=$id, topicId=$topicId, reason=$reason, questionCount=$questionCount, createdAt=$createdAt, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'topicId'] = this.topicId;
      json[r'reason'] = this.reason;
      json[r'questionCount'] = this.questionCount;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [ConceptDrill] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConceptDrill? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConceptDrill[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ConceptDrill[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ConceptDrill(
        id: mapValueOfType<String>(json, r'id')!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        questionCount: mapValueOfType<int>(json, r'questionCount')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        status: ConceptDrillStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<ConceptDrill> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConceptDrill>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConceptDrill.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConceptDrill> mapFromJson(dynamic json) {
    final map = <String, ConceptDrill>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConceptDrill.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConceptDrill-objects as value to a dart map
  static Map<String, List<ConceptDrill>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConceptDrill>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConceptDrill.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'topicId',
    'reason',
    'questionCount',
    'createdAt',
    'status',
  };
}


class ConceptDrillStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ConceptDrillStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const open = ConceptDrillStatusEnum._(r'open');
  static const done = ConceptDrillStatusEnum._(r'done');

  /// List of all possible values in this [enum][ConceptDrillStatusEnum].
  static const values = <ConceptDrillStatusEnum>[
    open,
    done,
  ];

  static ConceptDrillStatusEnum? fromJson(dynamic value) => ConceptDrillStatusEnumTypeTransformer().decode(value);

  static List<ConceptDrillStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConceptDrillStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConceptDrillStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ConceptDrillStatusEnum] to String,
/// and [decode] dynamic data back to [ConceptDrillStatusEnum].
class ConceptDrillStatusEnumTypeTransformer {
  factory ConceptDrillStatusEnumTypeTransformer() => _instance ??= const ConceptDrillStatusEnumTypeTransformer._();

  const ConceptDrillStatusEnumTypeTransformer._();

  String encode(ConceptDrillStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ConceptDrillStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ConceptDrillStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'open': return ConceptDrillStatusEnum.open;
        case r'done': return ConceptDrillStatusEnum.done;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ConceptDrillStatusEnumTypeTransformer] instance.
  static ConceptDrillStatusEnumTypeTransformer? _instance;
}


