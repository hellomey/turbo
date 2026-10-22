//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockList {
  /// Returns a new [MockList] instance.
  MockList({
    this.items = const [],
    required this.allowance,
  });

  List<MockSummary> items;

  MockAllowance allowance;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockList &&
    _deepEquality.equals(other.items, items) &&
    other.allowance == allowance;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (allowance.hashCode);

  @override
  String toString() => 'MockList[items=$items, allowance=$allowance]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
      json[r'allowance'] = this.allowance;
    return json;
  }

  /// Returns a new [MockList] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockList? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockList[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MockList[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MockList(
        items: MockSummary.listFromJson(json[r'items']),
        allowance: MockAllowance.fromJson(json[r'allowance'])!,
      );
    }
    return null;
  }

  static List<MockList> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockList>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockList.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockList> mapFromJson(dynamic json) {
    final map = <String, MockList>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockList.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockList-objects as value to a dart map
  static Map<String, List<MockList>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockList>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockList.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'allowance',
  };
}

