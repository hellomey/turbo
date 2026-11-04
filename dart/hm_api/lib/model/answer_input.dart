//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AnswerInput {
  /// Returns a new [AnswerInput] instance.
  AnswerInput({
    required this.questionId,
    this.chosenOptionIds = const [],
  });

  String questionId;

  List<String> chosenOptionIds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AnswerInput &&
    other.questionId == questionId &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (chosenOptionIds.hashCode);

  @override
  String toString() => 'AnswerInput[questionId=$questionId, chosenOptionIds=$chosenOptionIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
    return json;
  }

  /// Returns a new [AnswerInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AnswerInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AnswerInput[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "AnswerInput[questionId]" has a null value in JSON.');
        assert(json[r'chosenOptionIds'] != null, 'Required key "AnswerInput[chosenOptionIds]" has a null value in JSON.');
        return true;
      }());

      return AnswerInput(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<AnswerInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AnswerInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AnswerInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AnswerInput> mapFromJson(dynamic json) {
    final map = <String, AnswerInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AnswerInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AnswerInput-objects as value to a dart map
  static Map<String, List<AnswerInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AnswerInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AnswerInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'chosenOptionIds',
  };
}

