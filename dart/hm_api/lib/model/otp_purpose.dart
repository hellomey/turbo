//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OtpPurpose {
  /// Instantiate a new enum with the provided [value].
  const OtpPurpose._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const login = OtpPurpose._(r'login');
  static const deleteAccount = OtpPurpose._(r'delete_account');

  /// List of all possible values in this [enum][OtpPurpose].
  static const values = <OtpPurpose>[
    login,
    deleteAccount,
  ];

  static OtpPurpose? fromJson(dynamic value) => OtpPurposeTypeTransformer().decode(value);

  static List<OtpPurpose> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OtpPurpose>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OtpPurpose.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OtpPurpose] to String,
/// and [decode] dynamic data back to [OtpPurpose].
class OtpPurposeTypeTransformer {
  factory OtpPurposeTypeTransformer() => _instance ??= const OtpPurposeTypeTransformer._();

  const OtpPurposeTypeTransformer._();

  String encode(OtpPurpose data) => data.value;

  /// Decodes a [dynamic value][data] to a OtpPurpose.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OtpPurpose? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'login': return OtpPurpose.login;
        case r'delete_account': return OtpPurpose.deleteAccount;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [OtpPurposeTypeTransformer] instance.
  static OtpPurposeTypeTransformer? _instance;
}

