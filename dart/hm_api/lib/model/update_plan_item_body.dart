//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdatePlanItemBody {
  /// Returns a new [UpdatePlanItemBody] instance.
  UpdatePlanItemBody({
    required this.status,
  });

  UpdatePlanItemBodyStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdatePlanItemBody &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode);

  @override
  String toString() => 'UpdatePlanItemBody[status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [UpdatePlanItemBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdatePlanItemBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdatePlanItemBody[$key]" is missing from JSON.');
        });
        assert(json[r'status'] != null, 'Required key "UpdatePlanItemBody[status]" has a null value in JSON.');
        return true;
      }());

      return UpdatePlanItemBody(
        status: UpdatePlanItemBodyStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<UpdatePlanItemBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdatePlanItemBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdatePlanItemBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdatePlanItemBody> mapFromJson(dynamic json) {
    final map = <String, UpdatePlanItemBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdatePlanItemBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdatePlanItemBody-objects as value to a dart map
  static Map<String, List<UpdatePlanItemBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdatePlanItemBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdatePlanItemBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
  };
}


class UpdatePlanItemBodyStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const UpdatePlanItemBodyStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const done = UpdatePlanItemBodyStatusEnum._(r'done');
  static const skipped = UpdatePlanItemBodyStatusEnum._(r'skipped');

  /// List of all possible values in this [enum][UpdatePlanItemBodyStatusEnum].
  static const values = <UpdatePlanItemBodyStatusEnum>[
    done,
    skipped,
  ];

  static UpdatePlanItemBodyStatusEnum? fromJson(dynamic value) => UpdatePlanItemBodyStatusEnumTypeTransformer().decode(value);

  static List<UpdatePlanItemBodyStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdatePlanItemBodyStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdatePlanItemBodyStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UpdatePlanItemBodyStatusEnum] to String,
/// and [decode] dynamic data back to [UpdatePlanItemBodyStatusEnum].
class UpdatePlanItemBodyStatusEnumTypeTransformer {
  factory UpdatePlanItemBodyStatusEnumTypeTransformer() => _instance ??= const UpdatePlanItemBodyStatusEnumTypeTransformer._();

  const UpdatePlanItemBodyStatusEnumTypeTransformer._();

  String encode(UpdatePlanItemBodyStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UpdatePlanItemBodyStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UpdatePlanItemBodyStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'done': return UpdatePlanItemBodyStatusEnum.done;
        case r'skipped': return UpdatePlanItemBodyStatusEnum.skipped;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UpdatePlanItemBodyStatusEnumTypeTransformer] instance.
  static UpdatePlanItemBodyStatusEnumTypeTransformer? _instance;
}


