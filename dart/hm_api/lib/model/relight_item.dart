//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RelightItem {
  /// Returns a new [RelightItem] instance.
  RelightItem({
    required this.topicId,
    required this.topicName,
    required this.subjectCode,
    required this.dim,
    required this.overdueSince,
    required this.minutes,
  });

  String topicId;

  String topicName;

  String subjectCode;

  RelightItemDimEnum dim;

  DateTime overdueSince;

  int minutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RelightItem &&
    other.topicId == topicId &&
    other.topicName == topicName &&
    other.subjectCode == subjectCode &&
    other.dim == dim &&
    other.overdueSince == overdueSince &&
    other.minutes == minutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (topicId.hashCode) +
    (topicName.hashCode) +
    (subjectCode.hashCode) +
    (dim.hashCode) +
    (overdueSince.hashCode) +
    (minutes.hashCode);

  @override
  String toString() => 'RelightItem[topicId=$topicId, topicName=$topicName, subjectCode=$subjectCode, dim=$dim, overdueSince=$overdueSince, minutes=$minutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'topicId'] = this.topicId;
      json[r'topicName'] = this.topicName;
      json[r'subjectCode'] = this.subjectCode;
      json[r'dim'] = this.dim;
      json[r'overdueSince'] = this.overdueSince.toUtc().toIso8601String();
      json[r'minutes'] = this.minutes;
    return json;
  }

  /// Returns a new [RelightItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RelightItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RelightItem[$key]" is missing from JSON.');
        });
        assert(json[r'topicId'] != null, 'Required key "RelightItem[topicId]" has a null value in JSON.');
        assert(json[r'topicName'] != null, 'Required key "RelightItem[topicName]" has a null value in JSON.');
        assert(json[r'subjectCode'] != null, 'Required key "RelightItem[subjectCode]" has a null value in JSON.');
        assert(json[r'dim'] != null, 'Required key "RelightItem[dim]" has a null value in JSON.');
        assert(json[r'overdueSince'] != null, 'Required key "RelightItem[overdueSince]" has a null value in JSON.');
        assert(json[r'minutes'] != null, 'Required key "RelightItem[minutes]" has a null value in JSON.');
        return true;
      }());

      return RelightItem(
        topicId: mapValueOfType<String>(json, r'topicId')!,
        topicName: mapValueOfType<String>(json, r'topicName')!,
        subjectCode: mapValueOfType<String>(json, r'subjectCode')!,
        dim: RelightItemDimEnum.fromJson(json[r'dim'])!,
        overdueSince: mapDateTime(json, r'overdueSince', r'')!,
        minutes: mapValueOfType<int>(json, r'minutes')!,
      );
    }
    return null;
  }

  static List<RelightItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelightItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelightItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RelightItem> mapFromJson(dynamic json) {
    final map = <String, RelightItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RelightItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RelightItem-objects as value to a dart map
  static Map<String, List<RelightItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RelightItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RelightItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'topicId',
    'topicName',
    'subjectCode',
    'dim',
    'overdueSince',
    'minutes',
  };
}


class RelightItemDimEnum {
  /// Instantiate a new enum with the provided [value].
  const RelightItemDimEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const dimming = RelightItemDimEnum._(r'dimming');
  static const dim = RelightItemDimEnum._(r'dim');

  /// List of all possible values in this [enum][RelightItemDimEnum].
  static const values = <RelightItemDimEnum>[
    dimming,
    dim,
  ];

  static RelightItemDimEnum? fromJson(dynamic value) => RelightItemDimEnumTypeTransformer().decode(value);

  static List<RelightItemDimEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelightItemDimEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelightItemDimEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RelightItemDimEnum] to String,
/// and [decode] dynamic data back to [RelightItemDimEnum].
class RelightItemDimEnumTypeTransformer {
  factory RelightItemDimEnumTypeTransformer() => _instance ??= const RelightItemDimEnumTypeTransformer._();

  const RelightItemDimEnumTypeTransformer._();

  String encode(RelightItemDimEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RelightItemDimEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RelightItemDimEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'dimming': return RelightItemDimEnum.dimming;
        case r'dim': return RelightItemDimEnum.dim;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RelightItemDimEnumTypeTransformer] instance.
  static RelightItemDimEnumTypeTransformer? _instance;
}


