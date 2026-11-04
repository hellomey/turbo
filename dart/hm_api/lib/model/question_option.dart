//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionOption {
  /// Returns a new [QuestionOption] instance.
  QuestionOption({
    required this.id,
    required this.text,
  });

  String id;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionOption &&
    other.id == id &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'QuestionOption[id=$id, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [QuestionOption] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionOption? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuestionOption[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "QuestionOption[id]" has a null value in JSON.');
        assert(json[r'text'] != null, 'Required key "QuestionOption[text]" has a null value in JSON.');
        return true;
      }());

      return QuestionOption(
        id: mapValueOfType<String>(json, r'id')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<QuestionOption> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionOption>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionOption.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionOption> mapFromJson(dynamic json) {
    final map = <String, QuestionOption>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionOption.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionOption-objects as value to a dart map
  static Map<String, List<QuestionOption>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuestionOption>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionOption.listFromJson(entry.value, growable: growable,);
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

