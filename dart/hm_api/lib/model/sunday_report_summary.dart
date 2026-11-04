//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SundayReportSummary {
  /// Returns a new [SundayReportSummary] instance.
  SundayReportSummary({
    required this.id,
    required this.weekStart,
    required this.tier,
    required this.createdAt,
  });

  String id;

  DateTime weekStart;

  SundayReportSummaryTierEnum tier;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SundayReportSummary &&
    other.id == id &&
    other.weekStart == weekStart &&
    other.tier == tier &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (weekStart.hashCode) +
    (tier.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'SundayReportSummary[id=$id, weekStart=$weekStart, tier=$tier, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'weekStart'] = _dateFormatter.format(this.weekStart.toUtc());
      json[r'tier'] = this.tier;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [SundayReportSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SundayReportSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SundayReportSummary[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "SundayReportSummary[id]" has a null value in JSON.');
        assert(json[r'weekStart'] != null, 'Required key "SundayReportSummary[weekStart]" has a null value in JSON.');
        assert(json[r'tier'] != null, 'Required key "SundayReportSummary[tier]" has a null value in JSON.');
        assert(json[r'createdAt'] != null, 'Required key "SundayReportSummary[createdAt]" has a null value in JSON.');
        return true;
      }());

      return SundayReportSummary(
        id: mapValueOfType<String>(json, r'id')!,
        weekStart: mapDateTime(json, r'weekStart', r'')!,
        tier: SundayReportSummaryTierEnum.fromJson(json[r'tier'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<SundayReportSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SundayReportSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SundayReportSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SundayReportSummary> mapFromJson(dynamic json) {
    final map = <String, SundayReportSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SundayReportSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SundayReportSummary-objects as value to a dart map
  static Map<String, List<SundayReportSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SundayReportSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SundayReportSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'weekStart',
    'tier',
    'createdAt',
  };
}


class SundayReportSummaryTierEnum {
  /// Instantiate a new enum with the provided [value].
  const SundayReportSummaryTierEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const short = SundayReportSummaryTierEnum._(r'short');
  static const full = SundayReportSummaryTierEnum._(r'full');

  /// List of all possible values in this [enum][SundayReportSummaryTierEnum].
  static const values = <SundayReportSummaryTierEnum>[
    short,
    full,
  ];

  static SundayReportSummaryTierEnum? fromJson(dynamic value) => SundayReportSummaryTierEnumTypeTransformer().decode(value);

  static List<SundayReportSummaryTierEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SundayReportSummaryTierEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SundayReportSummaryTierEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SundayReportSummaryTierEnum] to String,
/// and [decode] dynamic data back to [SundayReportSummaryTierEnum].
class SundayReportSummaryTierEnumTypeTransformer {
  factory SundayReportSummaryTierEnumTypeTransformer() => _instance ??= const SundayReportSummaryTierEnumTypeTransformer._();

  const SundayReportSummaryTierEnumTypeTransformer._();

  String encode(SundayReportSummaryTierEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SundayReportSummaryTierEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SundayReportSummaryTierEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'short': return SundayReportSummaryTierEnum.short;
        case r'full': return SundayReportSummaryTierEnum.full;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SundayReportSummaryTierEnumTypeTransformer] instance.
  static SundayReportSummaryTierEnumTypeTransformer? _instance;
}


