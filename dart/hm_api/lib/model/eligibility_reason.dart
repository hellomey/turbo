//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EligibilityReason {
  /// Returns a new [EligibilityReason] instance.
  EligibilityReason({
    required this.code,
    required this.text,
  });

  EligibilityReasonCodeEnum code;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EligibilityReason &&
    other.code == code &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'EligibilityReason[code=$code, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [EligibilityReason] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EligibilityReason? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EligibilityReason[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "EligibilityReason[code]" has a null value in JSON.');
        assert(json[r'text'] != null, 'Required key "EligibilityReason[text]" has a null value in JSON.');
        return true;
      }());

      return EligibilityReason(
        code: EligibilityReasonCodeEnum.fromJson(json[r'code'])!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<EligibilityReason> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EligibilityReason>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EligibilityReason.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EligibilityReason> mapFromJson(dynamic json) {
    final map = <String, EligibilityReason>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EligibilityReason.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EligibilityReason-objects as value to a dart map
  static Map<String, List<EligibilityReason>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EligibilityReason>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EligibilityReason.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'text',
  };
}


class EligibilityReasonCodeEnum {
  /// Instantiate a new enum with the provided [value].
  const EligibilityReasonCodeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const AGE_OK = EligibilityReasonCodeEnum._(r'AGE_OK');
  static const AGE_RELAXATION_APPLIED = EligibilityReasonCodeEnum._(r'AGE_RELAXATION_APPLIED');
  static const AGE_TOO_LOW = EligibilityReasonCodeEnum._(r'AGE_TOO_LOW');
  static const AGE_TOO_HIGH = EligibilityReasonCodeEnum._(r'AGE_TOO_HIGH');
  static const QUALIFICATION_OK = EligibilityReasonCodeEnum._(r'QUALIFICATION_OK');
  static const QUALIFICATION_TOO_LOW = EligibilityReasonCodeEnum._(r'QUALIFICATION_TOO_LOW');
  static const DEGREE_SUBJECT_REQUIRED = EligibilityReasonCodeEnum._(r'DEGREE_SUBJECT_REQUIRED');
  static const PSTM_PREFERENCE = EligibilityReasonCodeEnum._(r'PSTM_PREFERENCE');

  /// List of all possible values in this [enum][EligibilityReasonCodeEnum].
  static const values = <EligibilityReasonCodeEnum>[
    AGE_OK,
    AGE_RELAXATION_APPLIED,
    AGE_TOO_LOW,
    AGE_TOO_HIGH,
    QUALIFICATION_OK,
    QUALIFICATION_TOO_LOW,
    DEGREE_SUBJECT_REQUIRED,
    PSTM_PREFERENCE,
  ];

  static EligibilityReasonCodeEnum? fromJson(dynamic value) => EligibilityReasonCodeEnumTypeTransformer().decode(value);

  static List<EligibilityReasonCodeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EligibilityReasonCodeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EligibilityReasonCodeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EligibilityReasonCodeEnum] to String,
/// and [decode] dynamic data back to [EligibilityReasonCodeEnum].
class EligibilityReasonCodeEnumTypeTransformer {
  factory EligibilityReasonCodeEnumTypeTransformer() => _instance ??= const EligibilityReasonCodeEnumTypeTransformer._();

  const EligibilityReasonCodeEnumTypeTransformer._();

  String encode(EligibilityReasonCodeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a EligibilityReasonCodeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EligibilityReasonCodeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'AGE_OK': return EligibilityReasonCodeEnum.AGE_OK;
        case r'AGE_RELAXATION_APPLIED': return EligibilityReasonCodeEnum.AGE_RELAXATION_APPLIED;
        case r'AGE_TOO_LOW': return EligibilityReasonCodeEnum.AGE_TOO_LOW;
        case r'AGE_TOO_HIGH': return EligibilityReasonCodeEnum.AGE_TOO_HIGH;
        case r'QUALIFICATION_OK': return EligibilityReasonCodeEnum.QUALIFICATION_OK;
        case r'QUALIFICATION_TOO_LOW': return EligibilityReasonCodeEnum.QUALIFICATION_TOO_LOW;
        case r'DEGREE_SUBJECT_REQUIRED': return EligibilityReasonCodeEnum.DEGREE_SUBJECT_REQUIRED;
        case r'PSTM_PREFERENCE': return EligibilityReasonCodeEnum.PSTM_PREFERENCE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EligibilityReasonCodeEnumTypeTransformer] instance.
  static EligibilityReasonCodeEnumTypeTransformer? _instance;
}


