//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockSectionView {
  /// Returns a new [MockSectionView] instance.
  MockSectionView({
    required this.code,
    required this.name,
    this.questionIds = const [],
    required this.minutes,
  });

  String code;

  String name;

  List<String> questionIds;

  int? minutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockSectionView &&
    other.code == code &&
    other.name == name &&
    _deepEquality.equals(other.questionIds, questionIds) &&
    other.minutes == minutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (questionIds.hashCode) +
    (minutes == null ? 0 : minutes!.hashCode);

  @override
  String toString() => 'MockSectionView[code=$code, name=$name, questionIds=$questionIds, minutes=$minutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'questionIds'] = this.questionIds;
    if (this.minutes != null) {
      json[r'minutes'] = this.minutes;
    } else {
      json[r'minutes'] = null;
    }
    return json;
  }

  /// Returns a new [MockSectionView] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockSectionView? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockSectionView[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MockSectionView[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MockSectionView(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        questionIds: json[r'questionIds'] is Iterable
            ? (json[r'questionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        minutes: mapValueOfType<int>(json, r'minutes'),
      );
    }
    return null;
  }

  static List<MockSectionView> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockSectionView>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockSectionView.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockSectionView> mapFromJson(dynamic json) {
    final map = <String, MockSectionView>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockSectionView.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockSectionView-objects as value to a dart map
  static Map<String, List<MockSectionView>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockSectionView>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockSectionView.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'questionIds',
    'minutes',
  };
}

