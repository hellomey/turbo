//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubmitExpoChallengeBodyAnswersInner {
  /// Returns a new [SubmitExpoChallengeBodyAnswersInner] instance.
  SubmitExpoChallengeBodyAnswersInner({
    required this.questionId,
    required this.optionId,
    required this.ms,
  });

  String questionId;

  String? optionId;

  /// Minimum value: 0
  /// Maximum value: 600000
  int ms;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubmitExpoChallengeBodyAnswersInner &&
    other.questionId == questionId &&
    other.optionId == optionId &&
    other.ms == ms;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (optionId == null ? 0 : optionId!.hashCode) +
    (ms.hashCode);

  @override
  String toString() => 'SubmitExpoChallengeBodyAnswersInner[questionId=$questionId, optionId=$optionId, ms=$ms]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
    if (this.optionId != null) {
      json[r'optionId'] = this.optionId;
    } else {
      json[r'optionId'] = null;
    }
      json[r'ms'] = this.ms;
    return json;
  }

  /// Returns a new [SubmitExpoChallengeBodyAnswersInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubmitExpoChallengeBodyAnswersInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SubmitExpoChallengeBodyAnswersInner[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "SubmitExpoChallengeBodyAnswersInner[questionId]" has a null value in JSON.');
        assert(json[r'ms'] != null, 'Required key "SubmitExpoChallengeBodyAnswersInner[ms]" has a null value in JSON.');
        return true;
      }());

      return SubmitExpoChallengeBodyAnswersInner(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        optionId: mapValueOfType<String>(json, r'optionId'),
        ms: mapValueOfType<int>(json, r'ms')!,
      );
    }
    return null;
  }

  static List<SubmitExpoChallengeBodyAnswersInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubmitExpoChallengeBodyAnswersInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubmitExpoChallengeBodyAnswersInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubmitExpoChallengeBodyAnswersInner> mapFromJson(dynamic json) {
    final map = <String, SubmitExpoChallengeBodyAnswersInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubmitExpoChallengeBodyAnswersInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubmitExpoChallengeBodyAnswersInner-objects as value to a dart map
  static Map<String, List<SubmitExpoChallengeBodyAnswersInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubmitExpoChallengeBodyAnswersInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubmitExpoChallengeBodyAnswersInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'optionId',
    'ms',
  };
}

