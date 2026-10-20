//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ConsentPurpose {
  /// Instantiate a new enum with the provided [value].
  const ConsentPurpose._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const coreService = ConsentPurpose._(r'core_service');
  static const offersEmail = ConsentPurpose._(r'offers_email');
  static const productResearch = ConsentPurpose._(r'product_research');
  static const shareWithSupporters = ConsentPurpose._(r'share_with_supporters');
  static const shareWithInstitution = ConsentPurpose._(r'share_with_institution');

  /// List of all possible values in this [enum][ConsentPurpose].
  static const values = <ConsentPurpose>[
    coreService,
    offersEmail,
    productResearch,
    shareWithSupporters,
    shareWithInstitution,
  ];

  static ConsentPurpose? fromJson(dynamic value) => ConsentPurposeTypeTransformer().decode(value);

  static List<ConsentPurpose> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsentPurpose>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsentPurpose.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ConsentPurpose] to String,
/// and [decode] dynamic data back to [ConsentPurpose].
class ConsentPurposeTypeTransformer {
  factory ConsentPurposeTypeTransformer() => _instance ??= const ConsentPurposeTypeTransformer._();

  const ConsentPurposeTypeTransformer._();

  String encode(ConsentPurpose data) => data.value;

  /// Decodes a [dynamic value][data] to a ConsentPurpose.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ConsentPurpose? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'core_service': return ConsentPurpose.coreService;
        case r'offers_email': return ConsentPurpose.offersEmail;
        case r'product_research': return ConsentPurpose.productResearch;
        case r'share_with_supporters': return ConsentPurpose.shareWithSupporters;
        case r'share_with_institution': return ConsentPurpose.shareWithInstitution;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ConsentPurposeTypeTransformer] instance.
  static ConsentPurposeTypeTransformer? _instance;
}

