//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockAllowance {
  /// Returns a new [MockAllowance] instance.
  MockAllowance({
    required this.istMonth,
    required this.freeFullMocksUsed,
    required this.freeFullMocksLimit,
  });

  String istMonth;

  /// Minimum value: 0
  int freeFullMocksUsed;

  /// Minimum value: 0
  int? freeFullMocksLimit;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockAllowance &&
    other.istMonth == istMonth &&
    other.freeFullMocksUsed == freeFullMocksUsed &&
    other.freeFullMocksLimit == freeFullMocksLimit;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (istMonth.hashCode) +
    (freeFullMocksUsed.hashCode) +
    (freeFullMocksLimit == null ? 0 : freeFullMocksLimit!.hashCode);

  @override
  String toString() => 'MockAllowance[istMonth=$istMonth, freeFullMocksUsed=$freeFullMocksUsed, freeFullMocksLimit=$freeFullMocksLimit]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'istMonth'] = this.istMonth;
      json[r'freeFullMocksUsed'] = this.freeFullMocksUsed;
    if (this.freeFullMocksLimit != null) {
      json[r'freeFullMocksLimit'] = this.freeFullMocksLimit;
    } else {
      json[r'freeFullMocksLimit'] = null;
    }
    return json;
  }

  /// Returns a new [MockAllowance] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockAllowance? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockAllowance[$key]" is missing from JSON.');
        });
        assert(json[r'istMonth'] != null, 'Required key "MockAllowance[istMonth]" has a null value in JSON.');
        assert(json[r'freeFullMocksUsed'] != null, 'Required key "MockAllowance[freeFullMocksUsed]" has a null value in JSON.');
        return true;
      }());

      return MockAllowance(
        istMonth: mapValueOfType<String>(json, r'istMonth')!,
        freeFullMocksUsed: mapValueOfType<int>(json, r'freeFullMocksUsed')!,
        freeFullMocksLimit: mapValueOfType<int>(json, r'freeFullMocksLimit'),
      );
    }
    return null;
  }

  static List<MockAllowance> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAllowance>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAllowance.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockAllowance> mapFromJson(dynamic json) {
    final map = <String, MockAllowance>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockAllowance.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockAllowance-objects as value to a dart map
  static Map<String, List<MockAllowance>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockAllowance>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockAllowance.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'istMonth',
    'freeFullMocksUsed',
    'freeFullMocksLimit',
  };
}

