//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySpinState {
  /// Returns a new [DailySpinState] instance.
  DailySpinState({
    required this.oddsVersion,
    this.prizes = const [],
    required this.spunToday,
    required this.todaysPrize,
    required this.nextSpinAt,
    required this.asleep,
  });

  int oddsVersion;

  List<SpinPrize> prizes;

  bool spunToday;

  DailySpinStateTodaysPrize todaysPrize;

  DateTime nextSpinAt;

  bool asleep;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailySpinState &&
    other.oddsVersion == oddsVersion &&
    _deepEquality.equals(other.prizes, prizes) &&
    other.spunToday == spunToday &&
    other.todaysPrize == todaysPrize &&
    other.nextSpinAt == nextSpinAt &&
    other.asleep == asleep;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (oddsVersion.hashCode) +
    (prizes.hashCode) +
    (spunToday.hashCode) +
    (todaysPrize.hashCode) +
    (nextSpinAt.hashCode) +
    (asleep.hashCode);

  @override
  String toString() => 'DailySpinState[oddsVersion=$oddsVersion, prizes=$prizes, spunToday=$spunToday, todaysPrize=$todaysPrize, nextSpinAt=$nextSpinAt, asleep=$asleep]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'oddsVersion'] = this.oddsVersion;
      json[r'prizes'] = this.prizes;
      json[r'spunToday'] = this.spunToday;
      json[r'todaysPrize'] = this.todaysPrize;
      json[r'nextSpinAt'] = this.nextSpinAt.toUtc().toIso8601String();
      json[r'asleep'] = this.asleep;
    return json;
  }

  /// Returns a new [DailySpinState] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySpinState? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DailySpinState[$key]" is missing from JSON.');
        });
        assert(json[r'oddsVersion'] != null, 'Required key "DailySpinState[oddsVersion]" has a null value in JSON.');
        assert(json[r'prizes'] != null, 'Required key "DailySpinState[prizes]" has a null value in JSON.');
        assert(json[r'spunToday'] != null, 'Required key "DailySpinState[spunToday]" has a null value in JSON.');
        assert(json[r'todaysPrize'] != null, 'Required key "DailySpinState[todaysPrize]" has a null value in JSON.');
        assert(json[r'nextSpinAt'] != null, 'Required key "DailySpinState[nextSpinAt]" has a null value in JSON.');
        assert(json[r'asleep'] != null, 'Required key "DailySpinState[asleep]" has a null value in JSON.');
        return true;
      }());

      return DailySpinState(
        oddsVersion: mapValueOfType<int>(json, r'oddsVersion')!,
        prizes: SpinPrize.listFromJson(json[r'prizes']),
        spunToday: mapValueOfType<bool>(json, r'spunToday')!,
        todaysPrize: DailySpinStateTodaysPrize.fromJson(json[r'todaysPrize'])!,
        nextSpinAt: mapDateTime(json, r'nextSpinAt', r'')!,
        asleep: mapValueOfType<bool>(json, r'asleep')!,
      );
    }
    return null;
  }

  static List<DailySpinState> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpinState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpinState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySpinState> mapFromJson(dynamic json) {
    final map = <String, DailySpinState>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySpinState.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySpinState-objects as value to a dart map
  static Map<String, List<DailySpinState>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailySpinState>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySpinState.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'oddsVersion',
    'prizes',
    'spunToday',
    'todaysPrize',
    'nextSpinAt',
    'asleep',
  };
}

