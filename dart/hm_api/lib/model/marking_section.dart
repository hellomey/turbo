//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MarkingSection {
  /// Returns a new [MarkingSection] instance.
  MarkingSection({
    required this.code,
    required this.name,
    required this.order,
    required this.questionCount,
    required this.attemptLimit,
    required this.marksPerCorrect,
    required this.penaltyPerWrong,
    required this.minutes,
  });

  String code;

  String name;

  int order;

  /// Minimum value: 0
  int questionCount;

  int? attemptLimit;

  Marks marksPerCorrect;

  Marks penaltyPerWrong;

  int? minutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MarkingSection &&
    other.code == code &&
    other.name == name &&
    other.order == order &&
    other.questionCount == questionCount &&
    other.attemptLimit == attemptLimit &&
    other.marksPerCorrect == marksPerCorrect &&
    other.penaltyPerWrong == penaltyPerWrong &&
    other.minutes == minutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (order.hashCode) +
    (questionCount.hashCode) +
    (attemptLimit == null ? 0 : attemptLimit!.hashCode) +
    (marksPerCorrect.hashCode) +
    (penaltyPerWrong.hashCode) +
    (minutes == null ? 0 : minutes!.hashCode);

  @override
  String toString() => 'MarkingSection[code=$code, name=$name, order=$order, questionCount=$questionCount, attemptLimit=$attemptLimit, marksPerCorrect=$marksPerCorrect, penaltyPerWrong=$penaltyPerWrong, minutes=$minutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'order'] = this.order;
      json[r'questionCount'] = this.questionCount;
    if (this.attemptLimit != null) {
      json[r'attemptLimit'] = this.attemptLimit;
    } else {
      json[r'attemptLimit'] = null;
    }
      json[r'marksPerCorrect'] = this.marksPerCorrect;
      json[r'penaltyPerWrong'] = this.penaltyPerWrong;
    if (this.minutes != null) {
      json[r'minutes'] = this.minutes;
    } else {
      json[r'minutes'] = null;
    }
    return json;
  }

  /// Returns a new [MarkingSection] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MarkingSection? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MarkingSection[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "MarkingSection[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "MarkingSection[name]" has a null value in JSON.');
        assert(json[r'order'] != null, 'Required key "MarkingSection[order]" has a null value in JSON.');
        assert(json[r'questionCount'] != null, 'Required key "MarkingSection[questionCount]" has a null value in JSON.');
        assert(json[r'marksPerCorrect'] != null, 'Required key "MarkingSection[marksPerCorrect]" has a null value in JSON.');
        assert(json[r'penaltyPerWrong'] != null, 'Required key "MarkingSection[penaltyPerWrong]" has a null value in JSON.');
        return true;
      }());

      return MarkingSection(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        order: mapValueOfType<int>(json, r'order')!,
        questionCount: mapValueOfType<int>(json, r'questionCount')!,
        attemptLimit: mapValueOfType<int>(json, r'attemptLimit'),
        marksPerCorrect: Marks.fromJson(json[r'marksPerCorrect'])!,
        penaltyPerWrong: Marks.fromJson(json[r'penaltyPerWrong'])!,
        minutes: mapValueOfType<int>(json, r'minutes'),
      );
    }
    return null;
  }

  static List<MarkingSection> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MarkingSection>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MarkingSection.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MarkingSection> mapFromJson(dynamic json) {
    final map = <String, MarkingSection>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MarkingSection.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MarkingSection-objects as value to a dart map
  static Map<String, List<MarkingSection>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MarkingSection>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MarkingSection.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'order',
    'questionCount',
    'attemptLimit',
    'marksPerCorrect',
    'penaltyPerWrong',
    'minutes',
  };
}

