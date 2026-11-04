//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GlossaryListItemsInner {
  /// Returns a new [GlossaryListItemsInner] instance.
  GlossaryListItemsInner({
    required this.term,
    required this.meaning,
  });

  String term;

  String meaning;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GlossaryListItemsInner &&
    other.term == term &&
    other.meaning == meaning;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (term.hashCode) +
    (meaning.hashCode);

  @override
  String toString() => 'GlossaryListItemsInner[term=$term, meaning=$meaning]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'term'] = this.term;
      json[r'meaning'] = this.meaning;
    return json;
  }

  /// Returns a new [GlossaryListItemsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GlossaryListItemsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GlossaryListItemsInner[$key]" is missing from JSON.');
        });
        assert(json[r'term'] != null, 'Required key "GlossaryListItemsInner[term]" has a null value in JSON.');
        assert(json[r'meaning'] != null, 'Required key "GlossaryListItemsInner[meaning]" has a null value in JSON.');
        return true;
      }());

      return GlossaryListItemsInner(
        term: mapValueOfType<String>(json, r'term')!,
        meaning: mapValueOfType<String>(json, r'meaning')!,
      );
    }
    return null;
  }

  static List<GlossaryListItemsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GlossaryListItemsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GlossaryListItemsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GlossaryListItemsInner> mapFromJson(dynamic json) {
    final map = <String, GlossaryListItemsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GlossaryListItemsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GlossaryListItemsInner-objects as value to a dart map
  static Map<String, List<GlossaryListItemsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GlossaryListItemsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GlossaryListItemsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'term',
    'meaning',
  };
}

