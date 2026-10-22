//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TopicStatePage {
  /// Returns a new [TopicStatePage] instance.
  TopicStatePage({
    this.items = const [],
    required this.nextCursor,
    required this.serverNow,
  });

  List<TopicState> items;

  String? nextCursor;

  DateTime serverNow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TopicStatePage &&
    _deepEquality.equals(other.items, items) &&
    other.nextCursor == nextCursor &&
    other.serverNow == serverNow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextCursor == null ? 0 : nextCursor!.hashCode) +
    (serverNow.hashCode);

  @override
  String toString() => 'TopicStatePage[items=$items, nextCursor=$nextCursor, serverNow=$serverNow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextCursor != null) {
      json[r'nextCursor'] = this.nextCursor;
    } else {
      json[r'nextCursor'] = null;
    }
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TopicStatePage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TopicStatePage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TopicStatePage[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TopicStatePage[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TopicStatePage(
        items: TopicState.listFromJson(json[r'items']),
        nextCursor: mapValueOfType<String>(json, r'nextCursor'),
        serverNow: mapDateTime(json, r'serverNow', r'')!,
      );
    }
    return null;
  }

  static List<TopicStatePage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TopicStatePage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TopicStatePage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TopicStatePage> mapFromJson(dynamic json) {
    final map = <String, TopicStatePage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TopicStatePage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TopicStatePage-objects as value to a dart map
  static Map<String, List<TopicStatePage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TopicStatePage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TopicStatePage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'nextCursor',
    'serverNow',
  };
}

