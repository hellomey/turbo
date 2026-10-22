//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RelightQueue {
  /// Returns a new [RelightQueue] instance.
  RelightQueue({
    this.items = const [],
    required this.totalMinutes,
  });

  List<RelightItem> items;

  /// Minimum value: 0
  int totalMinutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RelightQueue &&
    _deepEquality.equals(other.items, items) &&
    other.totalMinutes == totalMinutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (totalMinutes.hashCode);

  @override
  String toString() => 'RelightQueue[items=$items, totalMinutes=$totalMinutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
      json[r'totalMinutes'] = this.totalMinutes;
    return json;
  }

  /// Returns a new [RelightQueue] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RelightQueue? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RelightQueue[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RelightQueue[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RelightQueue(
        items: RelightItem.listFromJson(json[r'items']),
        totalMinutes: mapValueOfType<int>(json, r'totalMinutes')!,
      );
    }
    return null;
  }

  static List<RelightQueue> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelightQueue>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelightQueue.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RelightQueue> mapFromJson(dynamic json) {
    final map = <String, RelightQueue>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RelightQueue.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RelightQueue-objects as value to a dart map
  static Map<String, List<RelightQueue>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RelightQueue>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RelightQueue.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'totalMinutes',
  };
}

