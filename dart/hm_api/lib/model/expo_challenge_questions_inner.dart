//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpoChallengeQuestionsInner {
  /// Returns a new [ExpoChallengeQuestionsInner] instance.
  ExpoChallengeQuestionsInner({
    required this.id,
    required this.stem,
    this.options = const [],
  });

  String id;

  String stem;

  List<ExpoChallengeQuestionsInnerOptionsInner> options;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpoChallengeQuestionsInner &&
    other.id == id &&
    other.stem == stem &&
    _deepEquality.equals(other.options, options);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (stem.hashCode) +
    (options.hashCode);

  @override
  String toString() => 'ExpoChallengeQuestionsInner[id=$id, stem=$stem, options=$options]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'stem'] = this.stem;
      json[r'options'] = this.options;
    return json;
  }

  /// Returns a new [ExpoChallengeQuestionsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpoChallengeQuestionsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExpoChallengeQuestionsInner[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "ExpoChallengeQuestionsInner[id]" has a null value in JSON.');
        assert(json[r'stem'] != null, 'Required key "ExpoChallengeQuestionsInner[stem]" has a null value in JSON.');
        assert(json[r'options'] != null, 'Required key "ExpoChallengeQuestionsInner[options]" has a null value in JSON.');
        return true;
      }());

      return ExpoChallengeQuestionsInner(
        id: mapValueOfType<String>(json, r'id')!,
        stem: mapValueOfType<String>(json, r'stem')!,
        options: ExpoChallengeQuestionsInnerOptionsInner.listFromJson(json[r'options']),
      );
    }
    return null;
  }

  static List<ExpoChallengeQuestionsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpoChallengeQuestionsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpoChallengeQuestionsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpoChallengeQuestionsInner> mapFromJson(dynamic json) {
    final map = <String, ExpoChallengeQuestionsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpoChallengeQuestionsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpoChallengeQuestionsInner-objects as value to a dart map
  static Map<String, List<ExpoChallengeQuestionsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpoChallengeQuestionsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpoChallengeQuestionsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'stem',
    'options',
  };
}

