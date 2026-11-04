//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LampRing {
  /// Returns a new [LampRing] instance.
  LampRing({
    required this.lit,
    required this.steadyLevel,
    required this.gold,
    required this.dim,
  });

  bool lit;

  /// Minimum value: 0
  /// Maximum value: 4
  int steadyLevel;

  bool gold;

  LampRingDimEnum dim;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LampRing &&
    other.lit == lit &&
    other.steadyLevel == steadyLevel &&
    other.gold == gold &&
    other.dim == dim;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (lit.hashCode) +
    (steadyLevel.hashCode) +
    (gold.hashCode) +
    (dim.hashCode);

  @override
  String toString() => 'LampRing[lit=$lit, steadyLevel=$steadyLevel, gold=$gold, dim=$dim]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'lit'] = this.lit;
      json[r'steadyLevel'] = this.steadyLevel;
      json[r'gold'] = this.gold;
      json[r'dim'] = this.dim;
    return json;
  }

  /// Returns a new [LampRing] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LampRing? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LampRing[$key]" is missing from JSON.');
        });
        assert(json[r'lit'] != null, 'Required key "LampRing[lit]" has a null value in JSON.');
        assert(json[r'steadyLevel'] != null, 'Required key "LampRing[steadyLevel]" has a null value in JSON.');
        assert(json[r'gold'] != null, 'Required key "LampRing[gold]" has a null value in JSON.');
        assert(json[r'dim'] != null, 'Required key "LampRing[dim]" has a null value in JSON.');
        return true;
      }());

      return LampRing(
        lit: mapValueOfType<bool>(json, r'lit')!,
        steadyLevel: mapValueOfType<int>(json, r'steadyLevel')!,
        gold: mapValueOfType<bool>(json, r'gold')!,
        dim: LampRingDimEnum.fromJson(json[r'dim'])!,
      );
    }
    return null;
  }

  static List<LampRing> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LampRing>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LampRing.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LampRing> mapFromJson(dynamic json) {
    final map = <String, LampRing>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LampRing.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LampRing-objects as value to a dart map
  static Map<String, List<LampRing>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LampRing>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LampRing.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'lit',
    'steadyLevel',
    'gold',
    'dim',
  };
}


class LampRingDimEnum {
  /// Instantiate a new enum with the provided [value].
  const LampRingDimEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const bright = LampRingDimEnum._(r'bright');
  static const dimming = LampRingDimEnum._(r'dimming');
  static const dim = LampRingDimEnum._(r'dim');

  /// List of all possible values in this [enum][LampRingDimEnum].
  static const values = <LampRingDimEnum>[
    bright,
    dimming,
    dim,
  ];

  static LampRingDimEnum? fromJson(dynamic value) => LampRingDimEnumTypeTransformer().decode(value);

  static List<LampRingDimEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LampRingDimEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LampRingDimEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [LampRingDimEnum] to String,
/// and [decode] dynamic data back to [LampRingDimEnum].
class LampRingDimEnumTypeTransformer {
  factory LampRingDimEnumTypeTransformer() => _instance ??= const LampRingDimEnumTypeTransformer._();

  const LampRingDimEnumTypeTransformer._();

  String encode(LampRingDimEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a LampRingDimEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  LampRingDimEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'bright': return LampRingDimEnum.bright;
        case r'dimming': return LampRingDimEnum.dimming;
        case r'dim': return LampRingDimEnum.dim;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [LampRingDimEnumTypeTransformer] instance.
  static LampRingDimEnumTypeTransformer? _instance;
}


