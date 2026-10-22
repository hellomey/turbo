//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PutPlanBody {
  /// Returns a new [PutPlanBody] instance.
  PutPlanBody({
    required this.weekdayMinutes,
    required this.weekendMinutes,
    this.pocketMinutes = 10,
    this.balance = 0,
  });

  /// Minimum value: 15
  /// Maximum value: 720
  int weekdayMinutes;

  /// Minimum value: 15
  /// Maximum value: 720
  int weekendMinutes;

  /// Minimum value: 5
  /// Maximum value: 15
  int pocketMinutes;

  /// Minimum value: -2
  /// Maximum value: 2
  int balance;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PutPlanBody &&
    other.weekdayMinutes == weekdayMinutes &&
    other.weekendMinutes == weekendMinutes &&
    other.pocketMinutes == pocketMinutes &&
    other.balance == balance;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (weekdayMinutes.hashCode) +
    (weekendMinutes.hashCode) +
    (pocketMinutes.hashCode) +
    (balance.hashCode);

  @override
  String toString() => 'PutPlanBody[weekdayMinutes=$weekdayMinutes, weekendMinutes=$weekendMinutes, pocketMinutes=$pocketMinutes, balance=$balance]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'weekdayMinutes'] = this.weekdayMinutes;
      json[r'weekendMinutes'] = this.weekendMinutes;
      json[r'pocketMinutes'] = this.pocketMinutes;
      json[r'balance'] = this.balance;
    return json;
  }

  /// Returns a new [PutPlanBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PutPlanBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PutPlanBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PutPlanBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PutPlanBody(
        weekdayMinutes: mapValueOfType<int>(json, r'weekdayMinutes')!,
        weekendMinutes: mapValueOfType<int>(json, r'weekendMinutes')!,
        pocketMinutes: mapValueOfType<int>(json, r'pocketMinutes') ?? 10,
        balance: mapValueOfType<int>(json, r'balance') ?? 0,
      );
    }
    return null;
  }

  static List<PutPlanBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PutPlanBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PutPlanBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PutPlanBody> mapFromJson(dynamic json) {
    final map = <String, PutPlanBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PutPlanBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PutPlanBody-objects as value to a dart map
  static Map<String, List<PutPlanBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PutPlanBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PutPlanBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'weekdayMinutes',
    'weekendMinutes',
  };
}

