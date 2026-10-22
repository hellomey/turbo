//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PlanItemStatus {
  /// Instantiate a new enum with the provided [value].
  const PlanItemStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = PlanItemStatus._(r'pending');
  static const done = PlanItemStatus._(r'done');
  static const skipped = PlanItemStatus._(r'skipped');
  static const moved = PlanItemStatus._(r'moved');

  /// List of all possible values in this [enum][PlanItemStatus].
  static const values = <PlanItemStatus>[
    pending,
    done,
    skipped,
    moved,
  ];

  static PlanItemStatus? fromJson(dynamic value) => PlanItemStatusTypeTransformer().decode(value);

  static List<PlanItemStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanItemStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanItemStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PlanItemStatus] to String,
/// and [decode] dynamic data back to [PlanItemStatus].
class PlanItemStatusTypeTransformer {
  factory PlanItemStatusTypeTransformer() => _instance ??= const PlanItemStatusTypeTransformer._();

  const PlanItemStatusTypeTransformer._();

  String encode(PlanItemStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a PlanItemStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PlanItemStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return PlanItemStatus.pending;
        case r'done': return PlanItemStatus.done;
        case r'skipped': return PlanItemStatus.skipped;
        case r'moved': return PlanItemStatus.moved;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PlanItemStatusTypeTransformer] instance.
  static PlanItemStatusTypeTransformer? _instance;
}

