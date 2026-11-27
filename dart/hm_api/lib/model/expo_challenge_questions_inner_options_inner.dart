//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpoChallengeQuestionsInnerOptionsInner {
  /// Returns a new [ExpoChallengeQuestionsInnerOptionsInner] instance.
  ExpoChallengeQuestionsInnerOptionsInner({
    required this.id,
    required this.text,
  });

  String id;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpoChallengeQuestionsInnerOptionsInner &&
    other.id == id &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'ExpoChallengeQuestionsInnerOptionsInner[id=$id, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [ExpoChallengeQuestionsInnerOptionsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpoChallengeQuestionsInnerOptionsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExpoChallengeQuestionsInnerOptionsInner[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "ExpoChallengeQuestionsInnerOptionsInner[id]" has a null value in JSON.');
        assert(json[r'text'] != null, 'Required key "ExpoChallengeQuestionsInnerOptionsInner[text]" has a null value in JSON.');
        return true;
      }());

      return ExpoChallengeQuestionsInnerOptionsInner(
        id: mapValueOfType<String>(json, r'id')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<ExpoChallengeQuestionsInnerOptionsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpoChallengeQuestionsInnerOptionsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpoChallengeQuestionsInnerOptionsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpoChallengeQuestionsInnerOptionsInner> mapFromJson(dynamic json) {
    final map = <String, ExpoChallengeQuestionsInnerOptionsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpoChallengeQuestionsInnerOptionsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpoChallengeQuestionsInnerOptionsInner-objects as value to a dart map
  static Map<String, List<ExpoChallengeQuestionsInnerOptionsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpoChallengeQuestionsInnerOptionsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpoChallengeQuestionsInnerOptionsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'text',
  };
}

