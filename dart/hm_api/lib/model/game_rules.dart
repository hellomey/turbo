//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GameRules {
  /// Returns a new [GameRules] instance.
  GameRules({
    this.prizeCurrencies = const [],
    required this.stake,
    required this.sleep,
    required this.dailySpin,
    required this.confidenceDuel,
  });

  List<GameRulesPrizeCurrenciesEnum> prizeCurrencies;

  GameRulesStakeEnum stake;

  GameRulesSleep sleep;

  GameRulesDailySpin dailySpin;

  DuelRules confidenceDuel;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GameRules &&
    _deepEquality.equals(other.prizeCurrencies, prizeCurrencies) &&
    other.stake == stake &&
    other.sleep == sleep &&
    other.dailySpin == dailySpin &&
    other.confidenceDuel == confidenceDuel;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (prizeCurrencies.hashCode) +
    (stake.hashCode) +
    (sleep.hashCode) +
    (dailySpin.hashCode) +
    (confidenceDuel.hashCode);

  @override
  String toString() => 'GameRules[prizeCurrencies=$prizeCurrencies, stake=$stake, sleep=$sleep, dailySpin=$dailySpin, confidenceDuel=$confidenceDuel]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'prizeCurrencies'] = this.prizeCurrencies;
      json[r'stake'] = this.stake;
      json[r'sleep'] = this.sleep;
      json[r'dailySpin'] = this.dailySpin;
      json[r'confidenceDuel'] = this.confidenceDuel;
    return json;
  }

  /// Returns a new [GameRules] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GameRules? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GameRules[$key]" is missing from JSON.');
        });
        assert(json[r'prizeCurrencies'] != null, 'Required key "GameRules[prizeCurrencies]" has a null value in JSON.');
        assert(json[r'stake'] != null, 'Required key "GameRules[stake]" has a null value in JSON.');
        assert(json[r'sleep'] != null, 'Required key "GameRules[sleep]" has a null value in JSON.');
        assert(json[r'dailySpin'] != null, 'Required key "GameRules[dailySpin]" has a null value in JSON.');
        assert(json[r'confidenceDuel'] != null, 'Required key "GameRules[confidenceDuel]" has a null value in JSON.');
        return true;
      }());

      return GameRules(
        prizeCurrencies: GameRulesPrizeCurrenciesEnum.listFromJson(json[r'prizeCurrencies']),
        stake: GameRulesStakeEnum.fromJson(json[r'stake'])!,
        sleep: GameRulesSleep.fromJson(json[r'sleep'])!,
        dailySpin: GameRulesDailySpin.fromJson(json[r'dailySpin'])!,
        confidenceDuel: DuelRules.fromJson(json[r'confidenceDuel'])!,
      );
    }
    return null;
  }

  static List<GameRules> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GameRules>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GameRules.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GameRules> mapFromJson(dynamic json) {
    final map = <String, GameRules>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GameRules.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GameRules-objects as value to a dart map
  static Map<String, List<GameRules>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GameRules>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GameRules.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'prizeCurrencies',
    'stake',
    'sleep',
    'dailySpin',
    'confidenceDuel',
  };
}


class GameRulesPrizeCurrenciesEnum {
  /// Instantiate a new enum with the provided [value].
  const GameRulesPrizeCurrenciesEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const POINTS = GameRulesPrizeCurrenciesEnum._(r'POINTS');

  /// List of all possible values in this [enum][GameRulesPrizeCurrenciesEnum].
  static const values = <GameRulesPrizeCurrenciesEnum>[
    POINTS,
  ];

  static GameRulesPrizeCurrenciesEnum? fromJson(dynamic value) => GameRulesPrizeCurrenciesEnumTypeTransformer().decode(value);

  static List<GameRulesPrizeCurrenciesEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GameRulesPrizeCurrenciesEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GameRulesPrizeCurrenciesEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [GameRulesPrizeCurrenciesEnum] to String,
/// and [decode] dynamic data back to [GameRulesPrizeCurrenciesEnum].
class GameRulesPrizeCurrenciesEnumTypeTransformer {
  factory GameRulesPrizeCurrenciesEnumTypeTransformer() => _instance ??= const GameRulesPrizeCurrenciesEnumTypeTransformer._();

  const GameRulesPrizeCurrenciesEnumTypeTransformer._();

  String encode(GameRulesPrizeCurrenciesEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a GameRulesPrizeCurrenciesEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  GameRulesPrizeCurrenciesEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'POINTS': return GameRulesPrizeCurrenciesEnum.POINTS;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GameRulesPrizeCurrenciesEnumTypeTransformer] instance.
  static GameRulesPrizeCurrenciesEnumTypeTransformer? _instance;
}



class GameRulesStakeEnum {
  /// Instantiate a new enum with the provided [value].
  const GameRulesStakeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = GameRulesStakeEnum._(r'none');

  /// List of all possible values in this [enum][GameRulesStakeEnum].
  static const values = <GameRulesStakeEnum>[
    none,
  ];

  static GameRulesStakeEnum? fromJson(dynamic value) => GameRulesStakeEnumTypeTransformer().decode(value);

  static List<GameRulesStakeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GameRulesStakeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GameRulesStakeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [GameRulesStakeEnum] to String,
/// and [decode] dynamic data back to [GameRulesStakeEnum].
class GameRulesStakeEnumTypeTransformer {
  factory GameRulesStakeEnumTypeTransformer() => _instance ??= const GameRulesStakeEnumTypeTransformer._();

  const GameRulesStakeEnumTypeTransformer._();

  String encode(GameRulesStakeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a GameRulesStakeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  GameRulesStakeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return GameRulesStakeEnum.none;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GameRulesStakeEnumTypeTransformer] instance.
  static GameRulesStakeEnumTypeTransformer? _instance;
}


