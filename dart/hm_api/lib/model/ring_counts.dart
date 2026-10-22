//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RingCounts {
  /// Returns a new [RingCounts] instance.
  RingCounts({
    required this.totalLamps,
    required this.lit,
    required this.steady,
    required this.gold,
    required this.dimming,
    required this.dim,
  });

  /// Minimum value: 0
  int totalLamps;

  /// Minimum value: 0
  int lit;

  /// Minimum value: 0
  int steady;

  /// Minimum value: 0
  int gold;

  /// Minimum value: 0
  int dimming;

  /// Minimum value: 0
  int dim;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RingCounts &&
    other.totalLamps == totalLamps &&
    other.lit == lit &&
    other.steady == steady &&
    other.gold == gold &&
    other.dimming == dimming &&
    other.dim == dim;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (totalLamps.hashCode) +
    (lit.hashCode) +
    (steady.hashCode) +
    (gold.hashCode) +
    (dimming.hashCode) +
    (dim.hashCode);

  @override
  String toString() => 'RingCounts[totalLamps=$totalLamps, lit=$lit, steady=$steady, gold=$gold, dimming=$dimming, dim=$dim]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'totalLamps'] = this.totalLamps;
      json[r'lit'] = this.lit;
      json[r'steady'] = this.steady;
      json[r'gold'] = this.gold;
      json[r'dimming'] = this.dimming;
      json[r'dim'] = this.dim;
    return json;
  }

  /// Returns a new [RingCounts] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RingCounts? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RingCounts[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RingCounts[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RingCounts(
        totalLamps: mapValueOfType<int>(json, r'totalLamps')!,
        lit: mapValueOfType<int>(json, r'lit')!,
        steady: mapValueOfType<int>(json, r'steady')!,
        gold: mapValueOfType<int>(json, r'gold')!,
        dimming: mapValueOfType<int>(json, r'dimming')!,
        dim: mapValueOfType<int>(json, r'dim')!,
      );
    }
    return null;
  }

  static List<RingCounts> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RingCounts>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RingCounts.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RingCounts> mapFromJson(dynamic json) {
    final map = <String, RingCounts>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RingCounts.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RingCounts-objects as value to a dart map
  static Map<String, List<RingCounts>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RingCounts>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RingCounts.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'totalLamps',
    'lit',
    'steady',
    'gold',
    'dimming',
    'dim',
  };
}

