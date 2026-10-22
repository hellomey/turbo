//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MockKind {
  /// Instantiate a new enum with the provided [value].
  const MockKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const full = MockKind._(r'full');
  static const sectional = MockKind._(r'sectional');
  static const stateMockSunday = MockKind._(r'state_mock_sunday');

  /// List of all possible values in this [enum][MockKind].
  static const values = <MockKind>[
    full,
    sectional,
    stateMockSunday,
  ];

  static MockKind? fromJson(dynamic value) => MockKindTypeTransformer().decode(value);

  static List<MockKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MockKind] to String,
/// and [decode] dynamic data back to [MockKind].
class MockKindTypeTransformer {
  factory MockKindTypeTransformer() => _instance ??= const MockKindTypeTransformer._();

  const MockKindTypeTransformer._();

  String encode(MockKind data) => data.value;

  /// Decodes a [dynamic value][data] to a MockKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MockKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'full': return MockKind.full;
        case r'sectional': return MockKind.sectional;
        case r'state_mock_sunday': return MockKind.stateMockSunday;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MockKindTypeTransformer] instance.
  static MockKindTypeTransformer? _instance;
}

