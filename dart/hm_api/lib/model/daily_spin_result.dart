//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailySpinResult {
  /// Returns a new [DailySpinResult] instance.
  DailySpinResult({
    required this.prize,
    required this.oddsVersion,
    this.odds = const [],
    required this.nextSpinAt,
    required this.alreadySpun,
  });

  SpinPrize prize;

  int oddsVersion;

  List<SpinPrize> odds;

  DateTime nextSpinAt;

  bool alreadySpun;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailySpinResult &&
    other.prize == prize &&
    other.oddsVersion == oddsVersion &&
    _deepEquality.equals(other.odds, odds) &&
    other.nextSpinAt == nextSpinAt &&
    other.alreadySpun == alreadySpun;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (prize.hashCode) +
    (oddsVersion.hashCode) +
    (odds.hashCode) +
    (nextSpinAt.hashCode) +
    (alreadySpun.hashCode);

  @override
  String toString() => 'DailySpinResult[prize=$prize, oddsVersion=$oddsVersion, odds=$odds, nextSpinAt=$nextSpinAt, alreadySpun=$alreadySpun]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'prize'] = this.prize;
      json[r'oddsVersion'] = this.oddsVersion;
      json[r'odds'] = this.odds;
      json[r'nextSpinAt'] = this.nextSpinAt.toUtc().toIso8601String();
      json[r'alreadySpun'] = this.alreadySpun;
    return json;
  }

  /// Returns a new [DailySpinResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailySpinResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DailySpinResult[$key]" is missing from JSON.');
        });
        assert(json[r'prize'] != null, 'Required key "DailySpinResult[prize]" has a null value in JSON.');
        assert(json[r'oddsVersion'] != null, 'Required key "DailySpinResult[oddsVersion]" has a null value in JSON.');
        assert(json[r'odds'] != null, 'Required key "DailySpinResult[odds]" has a null value in JSON.');
        assert(json[r'nextSpinAt'] != null, 'Required key "DailySpinResult[nextSpinAt]" has a null value in JSON.');
        assert(json[r'alreadySpun'] != null, 'Required key "DailySpinResult[alreadySpun]" has a null value in JSON.');
        return true;
      }());

      return DailySpinResult(
        prize: SpinPrize.fromJson(json[r'prize'])!,
        oddsVersion: mapValueOfType<int>(json, r'oddsVersion')!,
        odds: SpinPrize.listFromJson(json[r'odds']),
        nextSpinAt: mapDateTime(json, r'nextSpinAt', r'')!,
        alreadySpun: mapValueOfType<bool>(json, r'alreadySpun')!,
      );
    }
    return null;
  }

  static List<DailySpinResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailySpinResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailySpinResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailySpinResult> mapFromJson(dynamic json) {
    final map = <String, DailySpinResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailySpinResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailySpinResult-objects as value to a dart map
  static Map<String, List<DailySpinResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailySpinResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailySpinResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'prize',
    'oddsVersion',
    'odds',
    'nextSpinAt',
    'alreadySpun',
  };
}

