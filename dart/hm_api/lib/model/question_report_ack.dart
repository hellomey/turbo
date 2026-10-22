//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionReportAck {
  /// Returns a new [QuestionReportAck] instance.
  QuestionReportAck({
    required this.reportId,
    required this.status,
  });

  String reportId;

  QuestionReportAckStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionReportAck &&
    other.reportId == reportId &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reportId.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'QuestionReportAck[reportId=$reportId, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'reportId'] = this.reportId;
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [QuestionReportAck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionReportAck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuestionReportAck[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "QuestionReportAck[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return QuestionReportAck(
        reportId: mapValueOfType<String>(json, r'reportId')!,
        status: QuestionReportAckStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<QuestionReportAck> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionReportAck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionReportAck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionReportAck> mapFromJson(dynamic json) {
    final map = <String, QuestionReportAck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionReportAck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionReportAck-objects as value to a dart map
  static Map<String, List<QuestionReportAck>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuestionReportAck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionReportAck.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'reportId',
    'status',
  };
}


class QuestionReportAckStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const QuestionReportAckStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const received = QuestionReportAckStatusEnum._(r'received');

  /// List of all possible values in this [enum][QuestionReportAckStatusEnum].
  static const values = <QuestionReportAckStatusEnum>[
    received,
  ];

  static QuestionReportAckStatusEnum? fromJson(dynamic value) => QuestionReportAckStatusEnumTypeTransformer().decode(value);

  static List<QuestionReportAckStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionReportAckStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionReportAckStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [QuestionReportAckStatusEnum] to String,
/// and [decode] dynamic data back to [QuestionReportAckStatusEnum].
class QuestionReportAckStatusEnumTypeTransformer {
  factory QuestionReportAckStatusEnumTypeTransformer() => _instance ??= const QuestionReportAckStatusEnumTypeTransformer._();

  const QuestionReportAckStatusEnumTypeTransformer._();

  String encode(QuestionReportAckStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a QuestionReportAckStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  QuestionReportAckStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'received': return QuestionReportAckStatusEnum.received;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [QuestionReportAckStatusEnumTypeTransformer] instance.
  static QuestionReportAckStatusEnumTypeTransformer? _instance;
}


