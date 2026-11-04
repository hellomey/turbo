//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AlertSettings {
  /// Returns a new [AlertSettings] instance.
  AlertSettings({
    required this.studyReminders,
    required this.examAlerts,
    required this.offers,
    required this.quietHours,
    required this.morningAlertMinute,
    required this.dailyLimit,
  });

  bool studyReminders;

  bool examAlerts;

  bool offers;

  AlertSettingsQuietHours quietHours;

  /// Minimum value: 0
  /// Maximum value: 1439
  int morningAlertMinute;

  /// Minimum value: 0
  /// Maximum value: 3
  int dailyLimit;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AlertSettings &&
    other.studyReminders == studyReminders &&
    other.examAlerts == examAlerts &&
    other.offers == offers &&
    other.quietHours == quietHours &&
    other.morningAlertMinute == morningAlertMinute &&
    other.dailyLimit == dailyLimit;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studyReminders.hashCode) +
    (examAlerts.hashCode) +
    (offers.hashCode) +
    (quietHours.hashCode) +
    (morningAlertMinute.hashCode) +
    (dailyLimit.hashCode);

  @override
  String toString() => 'AlertSettings[studyReminders=$studyReminders, examAlerts=$examAlerts, offers=$offers, quietHours=$quietHours, morningAlertMinute=$morningAlertMinute, dailyLimit=$dailyLimit]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'studyReminders'] = this.studyReminders;
      json[r'examAlerts'] = this.examAlerts;
      json[r'offers'] = this.offers;
      json[r'quietHours'] = this.quietHours;
      json[r'morningAlertMinute'] = this.morningAlertMinute;
      json[r'dailyLimit'] = this.dailyLimit;
    return json;
  }

  /// Returns a new [AlertSettings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AlertSettings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AlertSettings[$key]" is missing from JSON.');
        });
        assert(json[r'studyReminders'] != null, 'Required key "AlertSettings[studyReminders]" has a null value in JSON.');
        assert(json[r'examAlerts'] != null, 'Required key "AlertSettings[examAlerts]" has a null value in JSON.');
        assert(json[r'offers'] != null, 'Required key "AlertSettings[offers]" has a null value in JSON.');
        assert(json[r'quietHours'] != null, 'Required key "AlertSettings[quietHours]" has a null value in JSON.');
        assert(json[r'morningAlertMinute'] != null, 'Required key "AlertSettings[morningAlertMinute]" has a null value in JSON.');
        assert(json[r'dailyLimit'] != null, 'Required key "AlertSettings[dailyLimit]" has a null value in JSON.');
        return true;
      }());

      return AlertSettings(
        studyReminders: mapValueOfType<bool>(json, r'studyReminders')!,
        examAlerts: mapValueOfType<bool>(json, r'examAlerts')!,
        offers: mapValueOfType<bool>(json, r'offers')!,
        quietHours: AlertSettingsQuietHours.fromJson(json[r'quietHours'])!,
        morningAlertMinute: mapValueOfType<int>(json, r'morningAlertMinute')!,
        dailyLimit: mapValueOfType<int>(json, r'dailyLimit')!,
      );
    }
    return null;
  }

  static List<AlertSettings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AlertSettings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AlertSettings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AlertSettings> mapFromJson(dynamic json) {
    final map = <String, AlertSettings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AlertSettings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AlertSettings-objects as value to a dart map
  static Map<String, List<AlertSettings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AlertSettings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AlertSettings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'studyReminders',
    'examAlerts',
    'offers',
    'quietHours',
    'morningAlertMinute',
    'dailyLimit',
  };
}

