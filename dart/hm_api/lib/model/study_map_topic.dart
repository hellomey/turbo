//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudyMapTopic {
  /// Returns a new [StudyMapTopic] instance.
  StudyMapTopic({
    required this.id,
    required this.code,
    required this.name,
    required this.order,
    this.examCodes = const [],
    required this.hasLesson,
    required this.ring,
  });

  String id;

  String code;

  String name;

  int order;

  List<String> examCodes;

  bool hasLesson;

  LampRing ring;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudyMapTopic &&
    other.id == id &&
    other.code == code &&
    other.name == name &&
    other.order == order &&
    _deepEquality.equals(other.examCodes, examCodes) &&
    other.hasLesson == hasLesson &&
    other.ring == ring;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (code.hashCode) +
    (name.hashCode) +
    (order.hashCode) +
    (examCodes.hashCode) +
    (hasLesson.hashCode) +
    (ring.hashCode);

  @override
  String toString() => 'StudyMapTopic[id=$id, code=$code, name=$name, order=$order, examCodes=$examCodes, hasLesson=$hasLesson, ring=$ring]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'order'] = this.order;
      json[r'examCodes'] = this.examCodes;
      json[r'hasLesson'] = this.hasLesson;
      json[r'ring'] = this.ring;
    return json;
  }

  /// Returns a new [StudyMapTopic] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudyMapTopic? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StudyMapTopic[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StudyMapTopic[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StudyMapTopic(
        id: mapValueOfType<String>(json, r'id')!,
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        order: mapValueOfType<int>(json, r'order')!,
        examCodes: json[r'examCodes'] is Iterable
            ? (json[r'examCodes'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        hasLesson: mapValueOfType<bool>(json, r'hasLesson')!,
        ring: LampRing.fromJson(json[r'ring'])!,
      );
    }
    return null;
  }

  static List<StudyMapTopic> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudyMapTopic>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudyMapTopic.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudyMapTopic> mapFromJson(dynamic json) {
    final map = <String, StudyMapTopic>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudyMapTopic.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudyMapTopic-objects as value to a dart map
  static Map<String, List<StudyMapTopic>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudyMapTopic>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudyMapTopic.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'code',
    'name',
    'order',
    'examCodes',
    'hasLesson',
    'ring',
  };
}

