//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionSourcePyq {
  /// Returns a new [QuestionSourcePyq] instance.
  QuestionSourcePyq({
    required this.examCode,
    required this.paperCode,
    required this.year,
    required this.questionNumber,
  });

  String examCode;

  String? paperCode;

  int year;

  int? questionNumber;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionSourcePyq &&
    other.examCode == examCode &&
    other.paperCode == paperCode &&
    other.year == year &&
    other.questionNumber == questionNumber;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (paperCode == null ? 0 : paperCode!.hashCode) +
    (year.hashCode) +
    (questionNumber == null ? 0 : questionNumber!.hashCode);

  @override
  String toString() => 'QuestionSourcePyq[examCode=$examCode, paperCode=$paperCode, year=$year, questionNumber=$questionNumber]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
    if (this.paperCode != null) {
      json[r'paperCode'] = this.paperCode;
    } else {
      json[r'paperCode'] = null;
    }
      json[r'year'] = this.year;
    if (this.questionNumber != null) {
      json[r'questionNumber'] = this.questionNumber;
    } else {
      json[r'questionNumber'] = null;
    }
    return json;
  }

  /// Returns a new [QuestionSourcePyq] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionSourcePyq? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuestionSourcePyq[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "QuestionSourcePyq[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return QuestionSourcePyq(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        paperCode: mapValueOfType<String>(json, r'paperCode'),
        year: mapValueOfType<int>(json, r'year')!,
        questionNumber: mapValueOfType<int>(json, r'questionNumber'),
      );
    }
    return null;
  }

  static List<QuestionSourcePyq> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionSourcePyq>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionSourcePyq.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionSourcePyq> mapFromJson(dynamic json) {
    final map = <String, QuestionSourcePyq>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionSourcePyq.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionSourcePyq-objects as value to a dart map
  static Map<String, List<QuestionSourcePyq>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuestionSourcePyq>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionSourcePyq.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'paperCode',
    'year',
    'questionNumber',
  };
}

