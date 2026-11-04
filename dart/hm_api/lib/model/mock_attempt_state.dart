//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockAttemptState {
  /// Returns a new [MockAttemptState] instance.
  MockAttemptState({
    required this.attemptId,
    required this.mock,
    required this.mode,
    required this.status,
    required this.startedAt,
    required this.deadlineAt,
    required this.serverNow,
    this.sections = const [],
    this.questions = const [],
    this.answers = const [],
    required this.ranked,
  });

  String attemptId;

  MockSummary mock;

  MockMode mode;

  MockAttemptStateStatusEnum status;

  DateTime startedAt;

  DateTime deadlineAt;

  DateTime serverNow;

  List<MockSectionView> sections;

  List<Question> questions;

  List<SavedMockAnswer> answers;

  bool ranked;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockAttemptState &&
    other.attemptId == attemptId &&
    other.mock == mock &&
    other.mode == mode &&
    other.status == status &&
    other.startedAt == startedAt &&
    other.deadlineAt == deadlineAt &&
    other.serverNow == serverNow &&
    _deepEquality.equals(other.sections, sections) &&
    _deepEquality.equals(other.questions, questions) &&
    _deepEquality.equals(other.answers, answers) &&
    other.ranked == ranked;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (attemptId.hashCode) +
    (mock.hashCode) +
    (mode.hashCode) +
    (status.hashCode) +
    (startedAt.hashCode) +
    (deadlineAt.hashCode) +
    (serverNow.hashCode) +
    (sections.hashCode) +
    (questions.hashCode) +
    (answers.hashCode) +
    (ranked.hashCode);

  @override
  String toString() => 'MockAttemptState[attemptId=$attemptId, mock=$mock, mode=$mode, status=$status, startedAt=$startedAt, deadlineAt=$deadlineAt, serverNow=$serverNow, sections=$sections, questions=$questions, answers=$answers, ranked=$ranked]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'attemptId'] = this.attemptId;
      json[r'mock'] = this.mock;
      json[r'mode'] = this.mode;
      json[r'status'] = this.status;
      json[r'startedAt'] = this.startedAt.toUtc().toIso8601String();
      json[r'deadlineAt'] = this.deadlineAt.toUtc().toIso8601String();
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
      json[r'sections'] = this.sections;
      json[r'questions'] = this.questions;
      json[r'answers'] = this.answers;
      json[r'ranked'] = this.ranked;
    return json;
  }

  /// Returns a new [MockAttemptState] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockAttemptState? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockAttemptState[$key]" is missing from JSON.');
        });
        assert(json[r'attemptId'] != null, 'Required key "MockAttemptState[attemptId]" has a null value in JSON.');
        assert(json[r'mock'] != null, 'Required key "MockAttemptState[mock]" has a null value in JSON.');
        assert(json[r'mode'] != null, 'Required key "MockAttemptState[mode]" has a null value in JSON.');
        assert(json[r'status'] != null, 'Required key "MockAttemptState[status]" has a null value in JSON.');
        assert(json[r'startedAt'] != null, 'Required key "MockAttemptState[startedAt]" has a null value in JSON.');
        assert(json[r'deadlineAt'] != null, 'Required key "MockAttemptState[deadlineAt]" has a null value in JSON.');
        assert(json[r'serverNow'] != null, 'Required key "MockAttemptState[serverNow]" has a null value in JSON.');
        assert(json[r'sections'] != null, 'Required key "MockAttemptState[sections]" has a null value in JSON.');
        assert(json[r'questions'] != null, 'Required key "MockAttemptState[questions]" has a null value in JSON.');
        assert(json[r'answers'] != null, 'Required key "MockAttemptState[answers]" has a null value in JSON.');
        assert(json[r'ranked'] != null, 'Required key "MockAttemptState[ranked]" has a null value in JSON.');
        return true;
      }());

      return MockAttemptState(
        attemptId: mapValueOfType<String>(json, r'attemptId')!,
        mock: MockSummary.fromJson(json[r'mock'])!,
        mode: MockMode.fromJson(json[r'mode'])!,
        status: MockAttemptStateStatusEnum.fromJson(json[r'status'])!,
        startedAt: mapDateTime(json, r'startedAt', r'')!,
        deadlineAt: mapDateTime(json, r'deadlineAt', r'')!,
        serverNow: mapDateTime(json, r'serverNow', r'')!,
        sections: MockSectionView.listFromJson(json[r'sections']),
        questions: Question.listFromJson(json[r'questions']),
        answers: SavedMockAnswer.listFromJson(json[r'answers']),
        ranked: mapValueOfType<bool>(json, r'ranked')!,
      );
    }
    return null;
  }

  static List<MockAttemptState> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAttemptState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAttemptState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockAttemptState> mapFromJson(dynamic json) {
    final map = <String, MockAttemptState>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockAttemptState.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockAttemptState-objects as value to a dart map
  static Map<String, List<MockAttemptState>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockAttemptState>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockAttemptState.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'attemptId',
    'mock',
    'mode',
    'status',
    'startedAt',
    'deadlineAt',
    'serverNow',
    'sections',
    'questions',
    'answers',
    'ranked',
  };
}


class MockAttemptStateStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MockAttemptStateStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const inProgress = MockAttemptStateStatusEnum._(r'in_progress');
  static const submitted = MockAttemptStateStatusEnum._(r'submitted');
  static const expired = MockAttemptStateStatusEnum._(r'expired');

  /// List of all possible values in this [enum][MockAttemptStateStatusEnum].
  static const values = <MockAttemptStateStatusEnum>[
    inProgress,
    submitted,
    expired,
  ];

  static MockAttemptStateStatusEnum? fromJson(dynamic value) => MockAttemptStateStatusEnumTypeTransformer().decode(value);

  static List<MockAttemptStateStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAttemptStateStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAttemptStateStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MockAttemptStateStatusEnum] to String,
/// and [decode] dynamic data back to [MockAttemptStateStatusEnum].
class MockAttemptStateStatusEnumTypeTransformer {
  factory MockAttemptStateStatusEnumTypeTransformer() => _instance ??= const MockAttemptStateStatusEnumTypeTransformer._();

  const MockAttemptStateStatusEnumTypeTransformer._();

  String encode(MockAttemptStateStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MockAttemptStateStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MockAttemptStateStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'in_progress': return MockAttemptStateStatusEnum.inProgress;
        case r'submitted': return MockAttemptStateStatusEnum.submitted;
        case r'expired': return MockAttemptStateStatusEnum.expired;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MockAttemptStateStatusEnumTypeTransformer] instance.
  static MockAttemptStateStatusEnumTypeTransformer? _instance;
}


