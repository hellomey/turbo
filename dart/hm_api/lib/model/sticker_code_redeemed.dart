//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StickerCodeRedeemed {
  /// Returns a new [StickerCodeRedeemed] instance.
  StickerCodeRedeemed({
    required this.redeemed,
    required this.redeemedAt,
  });

  StickerCodeRedeemedRedeemedEnum redeemed;

  DateTime redeemedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StickerCodeRedeemed &&
    other.redeemed == redeemed &&
    other.redeemedAt == redeemedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (redeemed.hashCode) +
    (redeemedAt.hashCode);

  @override
  String toString() => 'StickerCodeRedeemed[redeemed=$redeemed, redeemedAt=$redeemedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'redeemed'] = this.redeemed;
      json[r'redeemedAt'] = this.redeemedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [StickerCodeRedeemed] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StickerCodeRedeemed? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StickerCodeRedeemed[$key]" is missing from JSON.');
        });
        assert(json[r'redeemed'] != null, 'Required key "StickerCodeRedeemed[redeemed]" has a null value in JSON.');
        assert(json[r'redeemedAt'] != null, 'Required key "StickerCodeRedeemed[redeemedAt]" has a null value in JSON.');
        return true;
      }());

      return StickerCodeRedeemed(
        redeemed: StickerCodeRedeemedRedeemedEnum.fromJson(json[r'redeemed'])!,
        redeemedAt: mapDateTime(json, r'redeemedAt', r'')!,
      );
    }
    return null;
  }

  static List<StickerCodeRedeemed> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StickerCodeRedeemed>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StickerCodeRedeemed.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StickerCodeRedeemed> mapFromJson(dynamic json) {
    final map = <String, StickerCodeRedeemed>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StickerCodeRedeemed.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StickerCodeRedeemed-objects as value to a dart map
  static Map<String, List<StickerCodeRedeemed>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StickerCodeRedeemed>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StickerCodeRedeemed.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'redeemed',
    'redeemedAt',
  };
}


class StickerCodeRedeemedRedeemedEnum {
  /// Instantiate a new enum with the provided [value].
  const StickerCodeRedeemedRedeemedEnum._(this.value);

  /// The underlying value of this enum member.
  final bool value;

  @override
  String toString() => value.toString();

  bool toJson() => value;

  static const true_ = StickerCodeRedeemedRedeemedEnum._('true');

  /// List of all possible values in this [enum][StickerCodeRedeemedRedeemedEnum].
  static const values = <StickerCodeRedeemedRedeemedEnum>[
    true_,
  ];

  static StickerCodeRedeemedRedeemedEnum? fromJson(dynamic value) => StickerCodeRedeemedRedeemedEnumTypeTransformer().decode(value);

  static List<StickerCodeRedeemedRedeemedEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StickerCodeRedeemedRedeemedEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StickerCodeRedeemedRedeemedEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StickerCodeRedeemedRedeemedEnum] to bool,
/// and [decode] dynamic data back to [StickerCodeRedeemedRedeemedEnum].
class StickerCodeRedeemedRedeemedEnumTypeTransformer {
  factory StickerCodeRedeemedRedeemedEnumTypeTransformer() => _instance ??= const StickerCodeRedeemedRedeemedEnumTypeTransformer._();

  const StickerCodeRedeemedRedeemedEnumTypeTransformer._();

  bool encode(StickerCodeRedeemedRedeemedEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a StickerCodeRedeemedRedeemedEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StickerCodeRedeemedRedeemedEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case 'true': return StickerCodeRedeemedRedeemedEnum.true_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [StickerCodeRedeemedRedeemedEnumTypeTransformer] instance.
  static StickerCodeRedeemedRedeemedEnumTypeTransformer? _instance;
}


