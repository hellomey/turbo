//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GameRulesDailySpin {
  /// Returns a new [GameRulesDailySpin] instance.
  GameRulesDailySpin({
    required this.oddsVersion,
    required this.spinsPerDay,
    this.prizes = const [],
  });

  int oddsVersion;

  int spinsPerDay;

  List<SpinPrize> prizes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GameRulesDailySpin &&
    other.oddsVersion == oddsVersion &&
    other.spinsPerDay == spinsPerDay &&
    _deepEquality.equals(other.prizes, prizes);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (oddsVersion.hashCode) +
    (spinsPerDay.hashCode) +
    (prizes.hashCode);

  @override
  String toString() => 'GameRulesDailySpin[oddsVersion=$oddsVersion, spinsPerDay=$spinsPerDay, prizes=$prizes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'oddsVersion'] = this.oddsVersion;
      json[r'spinsPerDay'] = this.spinsPerDay;
      json[r'prizes'] = this.prizes;
    return json;
  }

  /// Returns a new [GameRulesDailySpin] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GameRulesDailySpin? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GameRulesDailySpin[$key]" is missing from JSON.');
        });
        assert(json[r'oddsVersion'] != null, 'Required key "GameRulesDailySpin[oddsVersion]" has a null value in JSON.');
        assert(json[r'spinsPerDay'] != null, 'Required key "GameRulesDailySpin[spinsPerDay]" has a null value in JSON.');
        assert(json[r'prizes'] != null, 'Required key "GameRulesDailySpin[prizes]" has a null value in JSON.');
        return true;
      }());

      return GameRulesDailySpin(
        oddsVersion: mapValueOfType<int>(json, r'oddsVersion')!,
        spinsPerDay: mapValueOfType<int>(json, r'spinsPerDay')!,
        prizes: SpinPrize.listFromJson(json[r'prizes']),
      );
    }
    return null;
  }

  static List<GameRulesDailySpin> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GameRulesDailySpin>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GameRulesDailySpin.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GameRulesDailySpin> mapFromJson(dynamic json) {
    final map = <String, GameRulesDailySpin>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GameRulesDailySpin.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GameRulesDailySpin-objects as value to a dart map
  static Map<String, List<GameRulesDailySpin>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GameRulesDailySpin>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GameRulesDailySpin.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'oddsVersion',
    'spinsPerDay',
    'prizes',
  };
}

