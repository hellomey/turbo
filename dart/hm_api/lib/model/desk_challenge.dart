//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeskChallenge {
  /// Returns a new [DeskChallenge] instance.
  DeskChallenge({
    required this.kind,
    required this.challengeToken,
    required this.totpEnrolled,
  });

  DeskChallengeKindEnum kind;

  String challengeToken;

  bool totpEnrolled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeskChallenge &&
    other.kind == kind &&
    other.challengeToken == challengeToken &&
    other.totpEnrolled == totpEnrolled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (challengeToken.hashCode) +
    (totpEnrolled.hashCode);

  @override
  String toString() => 'DeskChallenge[kind=$kind, challengeToken=$challengeToken, totpEnrolled=$totpEnrolled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'challengeToken'] = this.challengeToken;
      json[r'totpEnrolled'] = this.totpEnrolled;
    return json;
  }

  /// Returns a new [DeskChallenge] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeskChallenge? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeskChallenge[$key]" is missing from JSON.');
        });
        assert(json[r'kind'] != null, 'Required key "DeskChallenge[kind]" has a null value in JSON.');
        assert(json[r'challengeToken'] != null, 'Required key "DeskChallenge[challengeToken]" has a null value in JSON.');
        assert(json[r'totpEnrolled'] != null, 'Required key "DeskChallenge[totpEnrolled]" has a null value in JSON.');
        return true;
      }());

      return DeskChallenge(
        kind: DeskChallengeKindEnum.fromJson(json[r'kind'])!,
        challengeToken: mapValueOfType<String>(json, r'challengeToken')!,
        totpEnrolled: mapValueOfType<bool>(json, r'totpEnrolled')!,
      );
    }
    return null;
  }

  static List<DeskChallenge> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeskChallenge>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeskChallenge.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeskChallenge> mapFromJson(dynamic json) {
    final map = <String, DeskChallenge>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeskChallenge.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeskChallenge-objects as value to a dart map
  static Map<String, List<DeskChallenge>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeskChallenge>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeskChallenge.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'challengeToken',
    'totpEnrolled',
  };
}


class DeskChallengeKindEnum {
  /// Instantiate a new enum with the provided [value].
  const DeskChallengeKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const desk2fa = DeskChallengeKindEnum._(r'desk_2fa');

  /// List of all possible values in this [enum][DeskChallengeKindEnum].
  static const values = <DeskChallengeKindEnum>[
    desk2fa,
  ];

  static DeskChallengeKindEnum? fromJson(dynamic value) => DeskChallengeKindEnumTypeTransformer().decode(value);

  static List<DeskChallengeKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeskChallengeKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeskChallengeKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DeskChallengeKindEnum] to String,
/// and [decode] dynamic data back to [DeskChallengeKindEnum].
class DeskChallengeKindEnumTypeTransformer {
  factory DeskChallengeKindEnumTypeTransformer() => _instance ??= const DeskChallengeKindEnumTypeTransformer._();

  const DeskChallengeKindEnumTypeTransformer._();

  String encode(DeskChallengeKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DeskChallengeKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DeskChallengeKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'desk_2fa': return DeskChallengeKindEnum.desk2fa;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DeskChallengeKindEnumTypeTransformer] instance.
  static DeskChallengeKindEnumTypeTransformer? _instance;
}


