//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionSource {
  /// Returns a new [QuestionSource] instance.
  QuestionSource({
    required this.citation,
    required this.url,
    required this.pyq,
  });

  String citation;

  String? url;

  QuestionSourcePyq pyq;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionSource &&
    other.citation == citation &&
    other.url == url &&
    other.pyq == pyq;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (citation.hashCode) +
    (url == null ? 0 : url!.hashCode) +
    (pyq.hashCode);

  @override
  String toString() => 'QuestionSource[citation=$citation, url=$url, pyq=$pyq]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'citation'] = this.citation;
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
      json[r'pyq'] = this.pyq;
    return json;
  }

  /// Returns a new [QuestionSource] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionSource? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuestionSource[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "QuestionSource[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return QuestionSource(
        citation: mapValueOfType<String>(json, r'citation')!,
        url: mapValueOfType<String>(json, r'url'),
        pyq: QuestionSourcePyq.fromJson(json[r'pyq'])!,
      );
    }
    return null;
  }

  static List<QuestionSource> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionSource>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionSource.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionSource> mapFromJson(dynamic json) {
    final map = <String, QuestionSource>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionSource.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionSource-objects as value to a dart map
  static Map<String, List<QuestionSource>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuestionSource>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionSource.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'citation',
    'url',
    'pyq',
  };
}

