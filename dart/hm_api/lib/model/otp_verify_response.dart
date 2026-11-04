//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OtpVerifyResponse {
  /// Returns a new [OtpVerifyResponse] instance.
  OtpVerifyResponse({
    required this.kind,
    required this.tokens,
    required this.isNewUser,
    required this.deletionCancelled,
    required this.challengeToken,
    required this.totpEnrolled,
  });

  OtpVerifyResponseKindEnum kind;

  TokenPair tokens;

  bool isNewUser;

  bool deletionCancelled;

  String challengeToken;

  bool totpEnrolled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OtpVerifyResponse &&
    other.kind == kind &&
    other.tokens == tokens &&
    other.isNewUser == isNewUser &&
    other.deletionCancelled == deletionCancelled &&
    other.challengeToken == challengeToken &&
    other.totpEnrolled == totpEnrolled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (tokens.hashCode) +
    (isNewUser.hashCode) +
    (deletionCancelled.hashCode) +
    (challengeToken.hashCode) +
    (totpEnrolled.hashCode);

  @override
  String toString() => 'OtpVerifyResponse[kind=$kind, tokens=$tokens, isNewUser=$isNewUser, deletionCancelled=$deletionCancelled, challengeToken=$challengeToken, totpEnrolled=$totpEnrolled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'tokens'] = this.tokens;
      json[r'isNewUser'] = this.isNewUser;
      json[r'deletionCancelled'] = this.deletionCancelled;
      json[r'challengeToken'] = this.challengeToken;
      json[r'totpEnrolled'] = this.totpEnrolled;
    return json;
  }

  /// Returns a new [OtpVerifyResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OtpVerifyResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OtpVerifyResponse[$key]" is missing from JSON.');
        });
        assert(json[r'kind'] != null, 'Required key "OtpVerifyResponse[kind]" has a null value in JSON.');
        assert(json[r'tokens'] != null, 'Required key "OtpVerifyResponse[tokens]" has a null value in JSON.');
        assert(json[r'isNewUser'] != null, 'Required key "OtpVerifyResponse[isNewUser]" has a null value in JSON.');
        assert(json[r'deletionCancelled'] != null, 'Required key "OtpVerifyResponse[deletionCancelled]" has a null value in JSON.');
        assert(json[r'challengeToken'] != null, 'Required key "OtpVerifyResponse[challengeToken]" has a null value in JSON.');
        assert(json[r'totpEnrolled'] != null, 'Required key "OtpVerifyResponse[totpEnrolled]" has a null value in JSON.');
        return true;
      }());

      return OtpVerifyResponse(
        kind: OtpVerifyResponseKindEnum.fromJson(json[r'kind'])!,
        tokens: TokenPair.fromJson(json[r'tokens'])!,
        isNewUser: mapValueOfType<bool>(json, r'isNewUser')!,
        deletionCancelled: mapValueOfType<bool>(json, r'deletionCancelled')!,
        challengeToken: mapValueOfType<String>(json, r'challengeToken')!,
        totpEnrolled: mapValueOfType<bool>(json, r'totpEnrolled')!,
      );
    }
    return null;
  }

  static List<OtpVerifyResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpVerifyResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpVerifyResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OtpVerifyResponse> mapFromJson(dynamic json) {
    final map = <String, OtpVerifyResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OtpVerifyResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OtpVerifyResponse-objects as value to a dart map
  static Map<String, List<OtpVerifyResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OtpVerifyResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OtpVerifyResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'tokens',
    'isNewUser',
    'deletionCancelled',
    'challengeToken',
    'totpEnrolled',
  };
}


class OtpVerifyResponseKindEnum {
  /// Instantiate a new enum with the provided [value].
  const OtpVerifyResponseKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const desk2fa = OtpVerifyResponseKindEnum._(r'desk_2fa');

  /// List of all possible values in this [enum][OtpVerifyResponseKindEnum].
  static const values = <OtpVerifyResponseKindEnum>[
    desk2fa,
  ];

  static OtpVerifyResponseKindEnum? fromJson(dynamic value) => OtpVerifyResponseKindEnumTypeTransformer().decode(value);

  static List<OtpVerifyResponseKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpVerifyResponseKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpVerifyResponseKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OtpVerifyResponseKindEnum] to String,
/// and [decode] dynamic data back to [OtpVerifyResponseKindEnum].
class OtpVerifyResponseKindEnumTypeTransformer {
  factory OtpVerifyResponseKindEnumTypeTransformer() => _instance ??= const OtpVerifyResponseKindEnumTypeTransformer._();

  const OtpVerifyResponseKindEnumTypeTransformer._();

  String encode(OtpVerifyResponseKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a OtpVerifyResponseKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OtpVerifyResponseKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'desk_2fa': return OtpVerifyResponseKindEnum.desk2fa;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [OtpVerifyResponseKindEnumTypeTransformer] instance.
  static OtpVerifyResponseKindEnumTypeTransformer? _instance;
}


