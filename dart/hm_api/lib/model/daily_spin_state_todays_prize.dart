//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySpinStateTodaysPrize {
  /// Returns a new [DailySpinStateTodaysPrize] instance.
  DailySpinStateTodaysPrize({
    required this.id,
    required this.label,
    required this.kind,
    required this.amount,
    required this.percent,
  });

  String id;

  String label;

  DailySpinStateTodaysPrizeKindEnum kind;

  /// Minimum value: 0
  int amount;

  /// Minimum value: 0
  /// Maximum value: 100
  num percent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailySpinStateTodaysPrize &&
    other.id == id &&
    other.label == label &&
    other.kind == kind &&
    other.amount == amount &&
    other.percent == percent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (label.hashCode) +
    (kind.hashCode) +
    (amount.hashCode) +
    (percent.hashCode);

  @override
  String toString() => 'DailySpinStateTodaysPrize[id=$id, label=$label, kind=$kind, amount=$amount, percent=$percent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'label'] = this.label;
      json[r'kind'] = this.kind;
      json[r'amount'] = this.amount;
      json[r'percent'] = this.percent;
    return json;
  }

  /// Returns a new [DailySpinStateTodaysPrize] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySpinStateTodaysPrize? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DailySpinStateTodaysPrize[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "DailySpinStateTodaysPrize[id]" has a null value in JSON.');
        assert(json[r'label'] != null, 'Required key "DailySpinStateTodaysPrize[label]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "DailySpinStateTodaysPrize[kind]" has a null value in JSON.');
        assert(json[r'amount'] != null, 'Required key "DailySpinStateTodaysPrize[amount]" has a null value in JSON.');
        assert(json[r'percent'] != null, 'Required key "DailySpinStateTodaysPrize[percent]" has a null value in JSON.');
        return true;
      }());

      return DailySpinStateTodaysPrize(
        id: mapValueOfType<String>(json, r'id')!,
        label: mapValueOfType<String>(json, r'label')!,
        kind: DailySpinStateTodaysPrizeKindEnum.fromJson(json[r'kind'])!,
        amount: mapValueOfType<int>(json, r'amount')!,
        percent: num.parse('${json[r'percent']}'),
      );
    }
    return null;
  }

  static List<DailySpinStateTodaysPrize> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpinStateTodaysPrize>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpinStateTodaysPrize.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySpinStateTodaysPrize> mapFromJson(dynamic json) {
    final map = <String, DailySpinStateTodaysPrize>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySpinStateTodaysPrize.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySpinStateTodaysPrize-objects as value to a dart map
  static Map<String, List<DailySpinStateTodaysPrize>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailySpinStateTodaysPrize>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySpinStateTodaysPrize.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'label',
    'kind',
    'amount',
    'percent',
  };
}


class DailySpinStateTodaysPrizeKindEnum {
  /// Instantiate a new enum with the provided [value].
  const DailySpinStateTodaysPrizeKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const points = DailySpinStateTodaysPrizeKindEnum._(r'points');
  static const none = DailySpinStateTodaysPrizeKindEnum._(r'none');

  /// List of all possible values in this [enum][DailySpinStateTodaysPrizeKindEnum].
  static const values = <DailySpinStateTodaysPrizeKindEnum>[
    points,
    none,
  ];

  static DailySpinStateTodaysPrizeKindEnum? fromJson(dynamic value) => DailySpinStateTodaysPrizeKindEnumTypeTransformer().decode(value);

  static List<DailySpinStateTodaysPrizeKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpinStateTodaysPrizeKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpinStateTodaysPrizeKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DailySpinStateTodaysPrizeKindEnum] to String,
/// and [decode] dynamic data back to [DailySpinStateTodaysPrizeKindEnum].
class DailySpinStateTodaysPrizeKindEnumTypeTransformer {
  factory DailySpinStateTodaysPrizeKindEnumTypeTransformer() => _instance ??= const DailySpinStateTodaysPrizeKindEnumTypeTransformer._();

  const DailySpinStateTodaysPrizeKindEnumTypeTransformer._();

  String encode(DailySpinStateTodaysPrizeKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DailySpinStateTodaysPrizeKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DailySpinStateTodaysPrizeKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'points': return DailySpinStateTodaysPrizeKindEnum.points;
        case r'none': return DailySpinStateTodaysPrizeKindEnum.none;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DailySpinStateTodaysPrizeKindEnumTypeTransformer] instance.
  static DailySpinStateTodaysPrizeKindEnumTypeTransformer? _instance;
}


