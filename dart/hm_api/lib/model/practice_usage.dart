//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PracticeUsage {
  /// Returns a new [PracticeUsage] instance.
  PracticeUsage({
    required this.istDay,
    required this.used,
    required this.limit,
    required this.resetsAt,
    required this.limitSheetShownToday,
  });

  DateTime istDay;

  /// Minimum value: 0
  int used;

  int? limit;

  DateTime resetsAt;

  bool limitSheetShownToday;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PracticeUsage &&
    other.istDay == istDay &&
    other.used == used &&
    other.limit == limit &&
    other.resetsAt == resetsAt &&
    other.limitSheetShownToday == limitSheetShownToday;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (istDay.hashCode) +
    (used.hashCode) +
    (limit == null ? 0 : limit!.hashCode) +
    (resetsAt.hashCode) +
    (limitSheetShownToday.hashCode);

  @override
  String toString() => 'PracticeUsage[istDay=$istDay, used=$used, limit=$limit, resetsAt=$resetsAt, limitSheetShownToday=$limitSheetShownToday]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'istDay'] = _dateFormatter.format(this.istDay.toUtc());
      json[r'used'] = this.used;
    if (this.limit != null) {
      json[r'limit'] = this.limit;
    } else {
      json[r'limit'] = null;
    }
      json[r'resetsAt'] = this.resetsAt.toUtc().toIso8601String();
      json[r'limitSheetShownToday'] = this.limitSheetShownToday;
    return json;
  }

  /// Returns a new [PracticeUsage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PracticeUsage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PracticeUsage[$key]" is missing from JSON.');
        });
        assert(json[r'istDay'] != null, 'Required key "PracticeUsage[istDay]" has a null value in JSON.');
        assert(json[r'used'] != null, 'Required key "PracticeUsage[used]" has a null value in JSON.');
        assert(json[r'resetsAt'] != null, 'Required key "PracticeUsage[resetsAt]" has a null value in JSON.');
        assert(json[r'limitSheetShownToday'] != null, 'Required key "PracticeUsage[limitSheetShownToday]" has a null value in JSON.');
        return true;
      }());

      return PracticeUsage(
        istDay: mapDateTime(json, r'istDay', r'')!,
        used: mapValueOfType<int>(json, r'used')!,
        limit: mapValueOfType<int>(json, r'limit'),
        resetsAt: mapDateTime(json, r'resetsAt', r'')!,
        limitSheetShownToday: mapValueOfType<bool>(json, r'limitSheetShownToday')!,
      );
    }
    return null;
  }

  static List<PracticeUsage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PracticeUsage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PracticeUsage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PracticeUsage> mapFromJson(dynamic json) {
    final map = <String, PracticeUsage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PracticeUsage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PracticeUsage-objects as value to a dart map
  static Map<String, List<PracticeUsage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PracticeUsage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PracticeUsage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'istDay',
    'used',
    'limit',
    'resetsAt',
    'limitSheetShownToday',
  };
}

