//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SaveMockAnswersBodyAnswersInner {
  /// Returns a new [SaveMockAnswersBodyAnswersInner] instance.
  SaveMockAnswersBodyAnswersInner({
    required this.questionId,
    this.chosenOptionIds = const [],
    required this.markedForReview,
    required this.clientAt,
  });

  String questionId;

  List<String> chosenOptionIds;

  bool markedForReview;

  DateTime clientAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SaveMockAnswersBodyAnswersInner &&
    other.questionId == questionId &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.markedForReview == markedForReview &&
    other.clientAt == clientAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (chosenOptionIds.hashCode) +
    (markedForReview.hashCode) +
    (clientAt.hashCode);

  @override
  String toString() => 'SaveMockAnswersBodyAnswersInner[questionId=$questionId, chosenOptionIds=$chosenOptionIds, markedForReview=$markedForReview, clientAt=$clientAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
      json[r'markedForReview'] = this.markedForReview;
      json[r'clientAt'] = this.clientAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [SaveMockAnswersBodyAnswersInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SaveMockAnswersBodyAnswersInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SaveMockAnswersBodyAnswersInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SaveMockAnswersBodyAnswersInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SaveMockAnswersBodyAnswersInner(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        markedForReview: mapValueOfType<bool>(json, r'markedForReview')!,
        clientAt: mapDateTime(json, r'clientAt', r'')!,
      );
    }
    return null;
  }

  static List<SaveMockAnswersBodyAnswersInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaveMockAnswersBodyAnswersInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaveMockAnswersBodyAnswersInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SaveMockAnswersBodyAnswersInner> mapFromJson(dynamic json) {
    final map = <String, SaveMockAnswersBodyAnswersInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SaveMockAnswersBodyAnswersInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SaveMockAnswersBodyAnswersInner-objects as value to a dart map
  static Map<String, List<SaveMockAnswersBodyAnswersInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SaveMockAnswersBodyAnswersInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SaveMockAnswersBodyAnswersInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'chosenOptionIds',
    'markedForReview',
    'clientAt',
  };
}

