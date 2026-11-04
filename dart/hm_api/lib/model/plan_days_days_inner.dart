//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlanDaysDaysInner {
  /// Returns a new [PlanDaysDaysInner] instance.
  PlanDaysDaysInner({
    required this.day,
    required this.minutes,
    this.items = const [],
  });

  DateTime day;

  int minutes;

  List<PlanItem> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlanDaysDaysInner &&
    other.day == day &&
    other.minutes == minutes &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (day.hashCode) +
    (minutes.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'PlanDaysDaysInner[day=$day, minutes=$minutes, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'day'] = _dateFormatter.format(this.day.toUtc());
      json[r'minutes'] = this.minutes;
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [PlanDaysDaysInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlanDaysDaysInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PlanDaysDaysInner[$key]" is missing from JSON.');
        });
        assert(json[r'day'] != null, 'Required key "PlanDaysDaysInner[day]" has a null value in JSON.');
        assert(json[r'minutes'] != null, 'Required key "PlanDaysDaysInner[minutes]" has a null value in JSON.');
        assert(json[r'items'] != null, 'Required key "PlanDaysDaysInner[items]" has a null value in JSON.');
        return true;
      }());

      return PlanDaysDaysInner(
        day: mapDateTime(json, r'day', r'')!,
        minutes: mapValueOfType<int>(json, r'minutes')!,
        items: PlanItem.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<PlanDaysDaysInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanDaysDaysInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanDaysDaysInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlanDaysDaysInner> mapFromJson(dynamic json) {
    final map = <String, PlanDaysDaysInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlanDaysDaysInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlanDaysDaysInner-objects as value to a dart map
  static Map<String, List<PlanDaysDaysInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlanDaysDaysInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlanDaysDaysInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'minutes',
    'items',
  };
}

