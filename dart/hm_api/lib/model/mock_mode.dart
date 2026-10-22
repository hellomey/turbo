//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MockMode {
  /// Instantiate a new enum with the provided [value].
  const MockMode._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const omr = MockMode._(r'omr');
  static const cbt = MockMode._(r'cbt');

  /// List of all possible values in this [enum][MockMode].
  static const values = <MockMode>[
    omr,
    cbt,
  ];

  static MockMode? fromJson(dynamic value) => MockModeTypeTransformer().decode(value);

  static List<MockMode> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockMode>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockMode.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MockMode] to String,
/// and [decode] dynamic data back to [MockMode].
class MockModeTypeTransformer {
  factory MockModeTypeTransformer() => _instance ??= const MockModeTypeTransformer._();

  const MockModeTypeTransformer._();

  String encode(MockMode data) => data.value;

  /// Decodes a [dynamic value][data] to a MockMode.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MockMode? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'omr': return MockMode.omr;
        case r'cbt': return MockMode.cbt;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MockModeTypeTransformer] instance.
  static MockModeTypeTransformer? _instance;
}

