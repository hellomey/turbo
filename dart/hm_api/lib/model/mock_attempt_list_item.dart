//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockAttemptListItem {
  /// Returns a new [MockAttemptListItem] instance.
  MockAttemptListItem({
    required this.attemptId,
    required this.mockId,
    required this.title,
    required this.kind,
    required this.status,
    required this.startedAt,
    required this.scoreDisplay,
  });

  String attemptId;

  String mockId;

  String title;

  MockKind kind;

  MockAttemptListItemStatusEnum status;

  DateTime startedAt;

  String? scoreDisplay;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockAttemptListItem &&
    other.attemptId == attemptId &&
    other.mockId == mockId &&
    other.title == title &&
    other.kind == kind &&
    other.status == status &&
    other.startedAt == startedAt &&
    other.scoreDisplay == scoreDisplay;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (attemptId.hashCode) +
    (mockId.hashCode) +
    (title.hashCode) +
    (kind.hashCode) +
    (status.hashCode) +
    (startedAt.hashCode) +
    (scoreDisplay == null ? 0 : scoreDisplay!.hashCode);

  @override
  String toString() => 'MockAttemptListItem[attemptId=$attemptId, mockId=$mockId, title=$title, kind=$kind, status=$status, startedAt=$startedAt, scoreDisplay=$scoreDisplay]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'attemptId'] = this.attemptId;
      json[r'mockId'] = this.mockId;
      json[r'title'] = this.title;
      json[r'kind'] = this.kind;
      json[r'status'] = this.status;
      json[r'startedAt'] = this.startedAt.toUtc().toIso8601String();
    if (this.scoreDisplay != null) {
      json[r'scoreDisplay'] = this.scoreDisplay;
    } else {
      json[r'scoreDisplay'] = null;
    }
    return json;
  }

  /// Returns a new [MockAttemptListItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockAttemptListItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockAttemptListItem[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MockAttemptListItem[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MockAttemptListItem(
        attemptId: mapValueOfType<String>(json, r'attemptId')!,
        mockId: mapValueOfType<String>(json, r'mockId')!,
        title: mapValueOfType<String>(json, r'title')!,
        kind: MockKind.fromJson(json[r'kind'])!,
        status: MockAttemptListItemStatusEnum.fromJson(json[r'status'])!,
        startedAt: mapDateTime(json, r'startedAt', r'')!,
        scoreDisplay: mapValueOfType<String>(json, r'scoreDisplay'),
      );
    }
    return null;
  }

  static List<MockAttemptListItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAttemptListItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAttemptListItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockAttemptListItem> mapFromJson(dynamic json) {
    final map = <String, MockAttemptListItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockAttemptListItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockAttemptListItem-objects as value to a dart map
  static Map<String, List<MockAttemptListItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockAttemptListItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockAttemptListItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'attemptId',
    'mockId',
    'title',
    'kind',
    'status',
    'startedAt',
    'scoreDisplay',
  };
}


class MockAttemptListItemStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MockAttemptListItemStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const inProgress = MockAttemptListItemStatusEnum._(r'in_progress');
  static const submitted = MockAttemptListItemStatusEnum._(r'submitted');
  static const expired = MockAttemptListItemStatusEnum._(r'expired');

  /// List of all possible values in this [enum][MockAttemptListItemStatusEnum].
  static const values = <MockAttemptListItemStatusEnum>[
    inProgress,
    submitted,
    expired,
  ];

  static MockAttemptListItemStatusEnum? fromJson(dynamic value) => MockAttemptListItemStatusEnumTypeTransformer().decode(value);

  static List<MockAttemptListItemStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAttemptListItemStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAttemptListItemStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MockAttemptListItemStatusEnum] to String,
/// and [decode] dynamic data back to [MockAttemptListItemStatusEnum].
class MockAttemptListItemStatusEnumTypeTransformer {
  factory MockAttemptListItemStatusEnumTypeTransformer() => _instance ??= const MockAttemptListItemStatusEnumTypeTransformer._();

  const MockAttemptListItemStatusEnumTypeTransformer._();

  String encode(MockAttemptListItemStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MockAttemptListItemStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MockAttemptListItemStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'in_progress': return MockAttemptListItemStatusEnum.inProgress;
        case r'submitted': return MockAttemptListItemStatusEnum.submitted;
        case r'expired': return MockAttemptListItemStatusEnum.expired;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MockAttemptListItemStatusEnumTypeTransformer] instance.
  static MockAttemptListItemStatusEnumTypeTransformer? _instance;
}


