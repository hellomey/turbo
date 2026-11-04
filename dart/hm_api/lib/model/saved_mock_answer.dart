//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SavedMockAnswer {
  /// Returns a new [SavedMockAnswer] instance.
  SavedMockAnswer({
    required this.questionId,
    this.chosenOptionIds = const [],
    required this.markedForReview,
  });

  String questionId;

  List<String> chosenOptionIds;

  bool markedForReview;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SavedMockAnswer &&
    other.questionId == questionId &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.markedForReview == markedForReview;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (chosenOptionIds.hashCode) +
    (markedForReview.hashCode);

  @override
  String toString() => 'SavedMockAnswer[questionId=$questionId, chosenOptionIds=$chosenOptionIds, markedForReview=$markedForReview]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
      json[r'markedForReview'] = this.markedForReview;
    return json;
  }

  /// Returns a new [SavedMockAnswer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SavedMockAnswer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SavedMockAnswer[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "SavedMockAnswer[questionId]" has a null value in JSON.');
        assert(json[r'chosenOptionIds'] != null, 'Required key "SavedMockAnswer[chosenOptionIds]" has a null value in JSON.');
        assert(json[r'markedForReview'] != null, 'Required key "SavedMockAnswer[markedForReview]" has a null value in JSON.');
        return true;
      }());

      return SavedMockAnswer(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        markedForReview: mapValueOfType<bool>(json, r'markedForReview')!,
      );
    }
    return null;
  }

  static List<SavedMockAnswer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SavedMockAnswer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SavedMockAnswer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SavedMockAnswer> mapFromJson(dynamic json) {
    final map = <String, SavedMockAnswer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SavedMockAnswer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SavedMockAnswer-objects as value to a dart map
  static Map<String, List<SavedMockAnswer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SavedMockAnswer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SavedMockAnswer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'chosenOptionIds',
    'markedForReview',
  };
}

