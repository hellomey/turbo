//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SpinPrize {
  /// Returns a new [SpinPrize] instance.
  SpinPrize({
    required this.id,
    required this.label,
    required this.kind,
    required this.amount,
    required this.percent,
  });

  String id;

  String label;

  SpinPrizeKindEnum kind;

  /// Minimum value: 0
  int amount;

  /// Minimum value: 0
  /// Maximum value: 100
  num percent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SpinPrize &&
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
  String toString() => 'SpinPrize[id=$id, label=$label, kind=$kind, amount=$amount, percent=$percent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'label'] = this.label;
      json[r'kind'] = this.kind;
      json[r'amount'] = this.amount;
      json[r'percent'] = this.percent;
    return json;
  }

  /// Returns a new [SpinPrize] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SpinPrize? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SpinPrize[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "SpinPrize[id]" has a null value in JSON.');
        assert(json[r'label'] != null, 'Required key "SpinPrize[label]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "SpinPrize[kind]" has a null value in JSON.');
        assert(json[r'amount'] != null, 'Required key "SpinPrize[amount]" has a null value in JSON.');
        assert(json[r'percent'] != null, 'Required key "SpinPrize[percent]" has a null value in JSON.');
        return true;
      }());

      return SpinPrize(
        id: mapValueOfType<String>(json, r'id')!,
        label: mapValueOfType<String>(json, r'label')!,
        kind: SpinPrizeKindEnum.fromJson(json[r'kind'])!,
        amount: mapValueOfType<int>(json, r'amount')!,
        percent: num.parse('${json[r'percent']}'),
      );
    }
    return null;
  }

  static List<SpinPrize> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SpinPrize>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SpinPrize.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SpinPrize> mapFromJson(dynamic json) {
    final map = <String, SpinPrize>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SpinPrize.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SpinPrize-objects as value to a dart map
  static Map<String, List<SpinPrize>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SpinPrize>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SpinPrize.listFromJson(entry.value, growable: growable,);
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


class SpinPrizeKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SpinPrizeKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const points = SpinPrizeKindEnum._(r'points');
  static const none = SpinPrizeKindEnum._(r'none');

  /// List of all possible values in this [enum][SpinPrizeKindEnum].
  static const values = <SpinPrizeKindEnum>[
    points,
    none,
  ];

  static SpinPrizeKindEnum? fromJson(dynamic value) => SpinPrizeKindEnumTypeTransformer().decode(value);

  static List<SpinPrizeKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SpinPrizeKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SpinPrizeKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SpinPrizeKindEnum] to String,
/// and [decode] dynamic data back to [SpinPrizeKindEnum].
class SpinPrizeKindEnumTypeTransformer {
  factory SpinPrizeKindEnumTypeTransformer() => _instance ??= const SpinPrizeKindEnumTypeTransformer._();

  const SpinPrizeKindEnumTypeTransformer._();

  String encode(SpinPrizeKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SpinPrizeKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SpinPrizeKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'points': return SpinPrizeKindEnum.points;
        case r'none': return SpinPrizeKindEnum.none;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SpinPrizeKindEnumTypeTransformer] instance.
  static SpinPrizeKindEnumTypeTransformer? _instance;
}


