//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PracticeAnswerBody {
  /// Returns a new [PracticeAnswerBody] instance.
  PracticeAnswerBody({
    required this.clientActionId,
    required this.questionId,
    required this.questionVersion,
    this.chosenOptionIds = const [],
    required this.timeMs,
    this.confidence,
  });

  String clientActionId;

  String questionId;

  int questionVersion;

  List<String> chosenOptionIds;

  /// Minimum value: 0
  /// Maximum value: 3600000
  int timeMs;

  PracticeAnswerBodyConfidenceEnum? confidence;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PracticeAnswerBody &&
    other.clientActionId == clientActionId &&
    other.questionId == questionId &&
    other.questionVersion == questionVersion &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.timeMs == timeMs &&
    other.confidence == confidence;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientActionId.hashCode) +
    (questionId.hashCode) +
    (questionVersion.hashCode) +
    (chosenOptionIds.hashCode) +
    (timeMs.hashCode) +
    (confidence == null ? 0 : confidence!.hashCode);

  @override
  String toString() => 'PracticeAnswerBody[clientActionId=$clientActionId, questionId=$questionId, questionVersion=$questionVersion, chosenOptionIds=$chosenOptionIds, timeMs=$timeMs, confidence=$confidence]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clientActionId'] = this.clientActionId;
      json[r'questionId'] = this.questionId;
      json[r'questionVersion'] = this.questionVersion;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
      json[r'timeMs'] = this.timeMs;
    if (this.confidence != null) {
      json[r'confidence'] = this.confidence;
    } else {
      json[r'confidence'] = null;
    }
    return json;
  }

  /// Returns a new [PracticeAnswerBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PracticeAnswerBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PracticeAnswerBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PracticeAnswerBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PracticeAnswerBody(
        clientActionId: mapValueOfType<String>(json, r'clientActionId')!,
        questionId: mapValueOfType<String>(json, r'questionId')!,
        questionVersion: mapValueOfType<int>(json, r'questionVersion')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        timeMs: mapValueOfType<int>(json, r'timeMs')!,
        confidence: PracticeAnswerBodyConfidenceEnum.fromJson(json[r'confidence']),
      );
    }
    return null;
  }

  static List<PracticeAnswerBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PracticeAnswerBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PracticeAnswerBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PracticeAnswerBody> mapFromJson(dynamic json) {
    final map = <String, PracticeAnswerBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PracticeAnswerBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PracticeAnswerBody-objects as value to a dart map
  static Map<String, List<PracticeAnswerBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PracticeAnswerBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PracticeAnswerBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clientActionId',
    'questionId',
    'questionVersion',
    'chosenOptionIds',
    'timeMs',
  };
}


class PracticeAnswerBodyConfidenceEnum {
  /// Instantiate a new enum with the provided [value].
  const PracticeAnswerBodyConfidenceEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sure = PracticeAnswerBodyConfidenceEnum._(r'sure');
  static const thinkSo = PracticeAnswerBodyConfidenceEnum._(r'think_so');
  static const guessing = PracticeAnswerBodyConfidenceEnum._(r'guessing');

  /// List of all possible values in this [enum][PracticeAnswerBodyConfidenceEnum].
  static const values = <PracticeAnswerBodyConfidenceEnum>[
    sure,
    thinkSo,
    guessing,
  ];

  static PracticeAnswerBodyConfidenceEnum? fromJson(dynamic value) => PracticeAnswerBodyConfidenceEnumTypeTransformer().decode(value);

  static List<PracticeAnswerBodyConfidenceEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PracticeAnswerBodyConfidenceEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PracticeAnswerBodyConfidenceEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PracticeAnswerBodyConfidenceEnum] to String,
/// and [decode] dynamic data back to [PracticeAnswerBodyConfidenceEnum].
class PracticeAnswerBodyConfidenceEnumTypeTransformer {
  factory PracticeAnswerBodyConfidenceEnumTypeTransformer() => _instance ??= const PracticeAnswerBodyConfidenceEnumTypeTransformer._();

  const PracticeAnswerBodyConfidenceEnumTypeTransformer._();

  String encode(PracticeAnswerBodyConfidenceEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PracticeAnswerBodyConfidenceEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PracticeAnswerBodyConfidenceEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sure': return PracticeAnswerBodyConfidenceEnum.sure;
        case r'think_so': return PracticeAnswerBodyConfidenceEnum.thinkSo;
        case r'guessing': return PracticeAnswerBodyConfidenceEnum.guessing;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PracticeAnswerBodyConfidenceEnumTypeTransformer] instance.
  static PracticeAnswerBodyConfidenceEnumTypeTransformer? _instance;
}


