//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncActionResult {
  /// Returns a new [SyncActionResult] instance.
  SyncActionResult({
    required this.clientActionId,
    required this.status,
    required this.errorCode,
  });

  String clientActionId;

  SyncActionResultStatusEnum status;

  String? errorCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncActionResult &&
    other.clientActionId == clientActionId &&
    other.status == status &&
    other.errorCode == errorCode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (status.hashCode) +
    (errorCode == null ? 0 : errorCode!.hashCode);

  @override
  String toString() => 'SyncActionResult[clientActionId=$clientActionId, status=$status, errorCode=$errorCode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'status'] = this.status;
    if (this.errorCode != null) {
      json[r'errorCode'] = this.errorCode;
    } else {
      json[r'errorCode'] = null;
    }
    return json;
  }

  /// Returns a new [SyncActionResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncActionResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncActionResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SyncActionResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SyncActionResult(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        status: SyncActionResultStatusEnum.fromJson(json[r'status'])!,
        errorCode: mapValueOfType<String>(json, r'errorCode'),
      );
    }
    return null;
  }

  static List<SyncActionResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncActionResult> mapFromJson(dynamic json) {
    final map = <String, SyncActionResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncActionResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncActionResult-objects as value to a dart map
  static Map<String, List<SyncActionResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncActionResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncActionResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientActionId',
    'status',
    'errorCode',
  };
}


class SyncActionResultStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const SyncActionResultStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const accepted = SyncActionResultStatusEnum._(r'accepted');
  static const duplicate = SyncActionResultStatusEnum._(r'duplicate');
  static const studyLogOnly = SyncActionResultStatusEnum._(r'study_log_only');
  static const rejected = SyncActionResultStatusEnum._(r'rejected');

  /// List of all possible values in this [enum][SyncActionResultStatusEnum].
  static const values = <SyncActionResultStatusEnum>[
    accepted,
    duplicate,
    studyLogOnly,
    rejected,
  ];

  static SyncActionResultStatusEnum? fromJson(dynamic value) => SyncActionResultStatusEnumTypeTransformer().decode(value);

  static List<SyncActionResultStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncActionResultStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncActionResultStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SyncActionResultStatusEnum] to String,
/// and [decode] dynamic data back to [SyncActionResultStatusEnum].
class SyncActionResultStatusEnumTypeTransformer {
  factory SyncActionResultStatusEnumTypeTransformer() => _instance ??= const SyncActionResultStatusEnumTypeTransformer._();

  const SyncActionResultStatusEnumTypeTransformer._();

  String encode(SyncActionResultStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SyncActionResultStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SyncActionResultStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'accepted': return SyncActionResultStatusEnum.accepted;
        case r'duplicate': return SyncActionResultStatusEnum.duplicate;
        case r'study_log_only': return SyncActionResultStatusEnum.studyLogOnly;
        case r'rejected': return SyncActionResultStatusEnum.rejected;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SyncActionResultStatusEnumTypeTransformer] instance.
  static SyncActionResultStatusEnumTypeTransformer? _instance;
}


