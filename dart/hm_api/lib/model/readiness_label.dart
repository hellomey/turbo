//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ReadinessLabel {
  /// Instantiate a new enum with the provided [value].
  const ReadinessLabel._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const notYet = ReadinessLabel._(r'not_yet');
  static const building = ReadinessLabel._(r'building');
  static const close = ReadinessLabel._(r'close');
  static const mockReady = ReadinessLabel._(r'mock_ready');

  /// List of all possible values in this [enum][ReadinessLabel].
  static const values = <ReadinessLabel>[
    notYet,
    building,
    close,
    mockReady,
  ];

  static ReadinessLabel? fromJson(dynamic value) => ReadinessLabelTypeTransformer().decode(value);

  static List<ReadinessLabel> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessLabel>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessLabel.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReadinessLabel] to String,
/// and [decode] dynamic data back to [ReadinessLabel].
class ReadinessLabelTypeTransformer {
  factory ReadinessLabelTypeTransformer() => _instance ??= const ReadinessLabelTypeTransformer._();

  const ReadinessLabelTypeTransformer._();

  String encode(ReadinessLabel data) => data.value;

  /// Decodes a [dynamic value][data] to a ReadinessLabel.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReadinessLabel? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'not_yet': return ReadinessLabel.notYet;
        case r'building': return ReadinessLabel.building;
        case r'close': return ReadinessLabel.close;
        case r'mock_ready': return ReadinessLabel.mockReady;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ReadinessLabelTypeTransformer] instance.
  static ReadinessLabelTypeTransformer? _instance;
}

