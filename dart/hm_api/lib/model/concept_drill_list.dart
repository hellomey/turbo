//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConceptDrillList {
  /// Returns a new [ConceptDrillList] instance.
  ConceptDrillList({
    this.items = const [],
    required this.locked,
  });

  List<ConceptDrill> items;

  bool locked;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConceptDrillList &&
    _deepEquality.equals(other.items, items) &&
    other.locked == locked;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (locked.hashCode);

  @override
  String toString() => 'ConceptDrillList[items=$items, locked=$locked]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
      json[r'locked'] = this.locked;
    return json;
  }

  /// Returns a new [ConceptDrillList] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConceptDrillList? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConceptDrillList[$key]" is missing from JSON.');
        });
        assert(json[r'items'] != null, 'Required key "ConceptDrillList[items]" has a null value in JSON.');
        assert(json[r'locked'] != null, 'Required key "ConceptDrillList[locked]" has a null value in JSON.');
        return true;
      }());

      return ConceptDrillList(
        items: ConceptDrill.listFromJson(json[r'items']),
        locked: mapValueOfType<bool>(json, r'locked')!,
      );
    }
    return null;
  }

  static List<ConceptDrillList> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConceptDrillList>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConceptDrillList.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConceptDrillList> mapFromJson(dynamic json) {
    final map = <String, ConceptDrillList>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConceptDrillList.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConceptDrillList-objects as value to a dart map
  static Map<String, List<ConceptDrillList>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConceptDrillList>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConceptDrillList.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'locked',
  };
}

