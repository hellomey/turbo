//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubmitDuelBodyAnswersInner {
  /// Returns a new [SubmitDuelBodyAnswersInner] instance.
  SubmitDuelBodyAnswersInner({
    required this.questionId,
    required this.optionId,
    required this.confidence,
  });

  String questionId;

  String optionId;

  /// Minimum value: 1
  /// Maximum value: 3
  int confidence;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubmitDuelBodyAnswersInner &&
    other.questionId == questionId &&
    other.optionId == optionId &&
    other.confidence == confidence;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (optionId.hashCode) +
    (confidence.hashCode);

  @override
  String toString() => 'SubmitDuelBodyAnswersInner[questionId=$questionId, optionId=$optionId, confidence=$confidence]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'optionId'] = this.optionId;
      json[r'confidence'] = this.confidence;
    return json;
  }

  /// Returns a new [SubmitDuelBodyAnswersInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubmitDuelBodyAnswersInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SubmitDuelBodyAnswersInner[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "SubmitDuelBodyAnswersInner[questionId]" has a null value in JSON.');
        assert(json[r'optionId'] != null, 'Required key "SubmitDuelBodyAnswersInner[optionId]" has a null value in JSON.');
        assert(json[r'confidence'] != null, 'Required key "SubmitDuelBodyAnswersInner[confidence]" has a null value in JSON.');
        return true;
      }());

      return SubmitDuelBodyAnswersInner(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        optionId: mapValueOfType<String>(json, r'optionId')!,
        confidence: mapValueOfType<int>(json, r'confidence')!,
      );
    }
    return null;
  }

  static List<SubmitDuelBodyAnswersInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubmitDuelBodyAnswersInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubmitDuelBodyAnswersInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubmitDuelBodyAnswersInner> mapFromJson(dynamic json) {
    final map = <String, SubmitDuelBodyAnswersInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubmitDuelBodyAnswersInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubmitDuelBodyAnswersInner-objects as value to a dart map
  static Map<String, List<SubmitDuelBodyAnswersInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubmitDuelBodyAnswersInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubmitDuelBodyAnswersInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'optionId',
    'confidence',
  };
}

