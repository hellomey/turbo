//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// Final Stretch phase from days left to the nearest exam (§17.3).
class StretchPhase {
  /// Instantiate a new enum with the provided [value].
  const StretchPhase._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const normal = StretchPhase._(r'normal');
  static const d90 = StretchPhase._(r'd90');
  static const d60 = StretchPhase._(r'd60');
  static const d30 = StretchPhase._(r'd30');
  static const d7 = StretchPhase._(r'd7');

  /// List of all possible values in this [enum][StretchPhase].
  static const values = <StretchPhase>[
    normal,
    d90,
    d60,
    d30,
    d7,
  ];

  static StretchPhase? fromJson(dynamic value) => StretchPhaseTypeTransformer().decode(value);

  static List<StretchPhase> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StretchPhase>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StretchPhase.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StretchPhase] to String,
/// and [decode] dynamic data back to [StretchPhase].
class StretchPhaseTypeTransformer {
  factory StretchPhaseTypeTransformer() => _instance ??= const StretchPhaseTypeTransformer._();

  const StretchPhaseTypeTransformer._();

  String encode(StretchPhase data) => data.value;

  /// Decodes a [dynamic value][data] to a StretchPhase.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StretchPhase? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'normal': return StretchPhase.normal;
        case r'd90': return StretchPhase.d90;
        case r'd60': return StretchPhase.d60;
        case r'd30': return StretchPhase.d30;
        case r'd7': return StretchPhase.d7;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [StretchPhaseTypeTransformer] instance.
  static StretchPhaseTypeTransformer? _instance;
}

