//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RankChange {
  /// Returns a new [RankChange] instance.
  RankChange({
    required this.from,
    required this.to,
    required this.title,
    required this.note,
  });

  /// Minimum value: 1
  /// Maximum value: 11
  int from;

  /// Minimum value: 1
  /// Maximum value: 11
  int to;

  String title;

  String note;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RankChange &&
    other.from == from &&
    other.to == to &&
    other.title == title &&
    other.note == note;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (title.hashCode) +
    (note.hashCode);

  @override
  String toString() => 'RankChange[from=$from, to=$to, title=$title, note=$note]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = this.from;
      json[r'to'] = this.to;
      json[r'title'] = this.title;
      json[r'note'] = this.note;
    return json;
  }

  /// Returns a new [RankChange] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RankChange? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RankChange[$key]" is missing from JSON.');
        });
        assert(json[r'from'] != null, 'Required key "RankChange[from]" has a null value in JSON.');
        assert(json[r'to'] != null, 'Required key "RankChange[to]" has a null value in JSON.');
        assert(json[r'title'] != null, 'Required key "RankChange[title]" has a null value in JSON.');
        assert(json[r'note'] != null, 'Required key "RankChange[note]" has a null value in JSON.');
        return true;
      }());

      return RankChange(
        from: mapValueOfType<int>(json, r'from')!,
        to: mapValueOfType<int>(json, r'to')!,
        title: mapValueOfType<String>(json, r'title')!,
        note: mapValueOfType<String>(json, r'note')!,
      );
    }
    return null;
  }

  static List<RankChange> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RankChange>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RankChange.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RankChange> mapFromJson(dynamic json) {
    final map = <String, RankChange>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RankChange.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RankChange-objects as value to a dart map
  static Map<String, List<RankChange>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RankChange>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RankChange.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'title',
    'note',
  };
}

