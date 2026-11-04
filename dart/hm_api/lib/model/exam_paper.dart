//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamPaper {
  /// Returns a new [ExamPaper] instance.
  ExamPaper({
    required this.code,
    required this.name,
    required this.order,
    required this.type,
    required this.mode,
    required this.language,
    required this.qualifyingOnly,
    required this.scheme,
  });

  String code;

  String name;

  int order;

  PaperType type;

  ExamPaperModeEnum mode;

  ExamPaperLanguageEnum language;

  bool qualifyingOnly;

  MarkingScheme scheme;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamPaper &&
    other.code == code &&
    other.name == name &&
    other.order == order &&
    other.type == type &&
    other.mode == mode &&
    other.language == language &&
    other.qualifyingOnly == qualifyingOnly &&
    other.scheme == scheme;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (order.hashCode) +
    (type.hashCode) +
    (mode.hashCode) +
    (language.hashCode) +
    (qualifyingOnly.hashCode) +
    (scheme.hashCode);

  @override
  String toString() => 'ExamPaper[code=$code, name=$name, order=$order, type=$type, mode=$mode, language=$language, qualifyingOnly=$qualifyingOnly, scheme=$scheme]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'order'] = this.order;
      json[r'type'] = this.type;
      json[r'mode'] = this.mode;
      json[r'language'] = this.language;
      json[r'qualifyingOnly'] = this.qualifyingOnly;
      json[r'scheme'] = this.scheme;
    return json;
  }

  /// Returns a new [ExamPaper] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamPaper? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamPaper[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "ExamPaper[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "ExamPaper[name]" has a null value in JSON.');
        assert(json[r'order'] != null, 'Required key "ExamPaper[order]" has a null value in JSON.');
        assert(json[r'type'] != null, 'Required key "ExamPaper[type]" has a null value in JSON.');
        assert(json[r'mode'] != null, 'Required key "ExamPaper[mode]" has a null value in JSON.');
        assert(json[r'language'] != null, 'Required key "ExamPaper[language]" has a null value in JSON.');
        assert(json[r'qualifyingOnly'] != null, 'Required key "ExamPaper[qualifyingOnly]" has a null value in JSON.');
        assert(json[r'scheme'] != null, 'Required key "ExamPaper[scheme]" has a null value in JSON.');
        return true;
      }());

      return ExamPaper(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        order: mapValueOfType<int>(json, r'order')!,
        type: PaperType.fromJson(json[r'type'])!,
        mode: ExamPaperModeEnum.fromJson(json[r'mode'])!,
        language: ExamPaperLanguageEnum.fromJson(json[r'language'])!,
        qualifyingOnly: mapValueOfType<bool>(json, r'qualifyingOnly')!,
        scheme: MarkingScheme.fromJson(json[r'scheme'])!,
      );
    }
    return null;
  }

  static List<ExamPaper> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamPaper>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamPaper.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamPaper> mapFromJson(dynamic json) {
    final map = <String, ExamPaper>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamPaper.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamPaper-objects as value to a dart map
  static Map<String, List<ExamPaper>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamPaper>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamPaper.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'order',
    'type',
    'mode',
    'language',
    'qualifyingOnly',
    'scheme',
  };
}


class ExamPaperModeEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamPaperModeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const omr = ExamPaperModeEnum._(r'omr');
  static const cbt = ExamPaperModeEnum._(r'cbt');
  static const written = ExamPaperModeEnum._(r'written');

  /// List of all possible values in this [enum][ExamPaperModeEnum].
  static const values = <ExamPaperModeEnum>[
    omr,
    cbt,
    written,
  ];

  static ExamPaperModeEnum? fromJson(dynamic value) => ExamPaperModeEnumTypeTransformer().decode(value);

  static List<ExamPaperModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamPaperModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamPaperModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamPaperModeEnum] to String,
/// and [decode] dynamic data back to [ExamPaperModeEnum].
class ExamPaperModeEnumTypeTransformer {
  factory ExamPaperModeEnumTypeTransformer() => _instance ??= const ExamPaperModeEnumTypeTransformer._();

  const ExamPaperModeEnumTypeTransformer._();

  String encode(ExamPaperModeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamPaperModeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamPaperModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'omr': return ExamPaperModeEnum.omr;
        case r'cbt': return ExamPaperModeEnum.cbt;
        case r'written': return ExamPaperModeEnum.written;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamPaperModeEnumTypeTransformer] instance.
  static ExamPaperModeEnumTypeTransformer? _instance;
}



class ExamPaperLanguageEnum {
  /// Instantiate a new enum with the provided [value].
  const ExamPaperLanguageEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const en = ExamPaperLanguageEnum._(r'en');
  static const ta = ExamPaperLanguageEnum._(r'ta');
  static const hi = ExamPaperLanguageEnum._(r'hi');
  static const bilingual = ExamPaperLanguageEnum._(r'bilingual');

  /// List of all possible values in this [enum][ExamPaperLanguageEnum].
  static const values = <ExamPaperLanguageEnum>[
    en,
    ta,
    hi,
    bilingual,
  ];

  static ExamPaperLanguageEnum? fromJson(dynamic value) => ExamPaperLanguageEnumTypeTransformer().decode(value);

  static List<ExamPaperLanguageEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamPaperLanguageEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamPaperLanguageEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExamPaperLanguageEnum] to String,
/// and [decode] dynamic data back to [ExamPaperLanguageEnum].
class ExamPaperLanguageEnumTypeTransformer {
  factory ExamPaperLanguageEnumTypeTransformer() => _instance ??= const ExamPaperLanguageEnumTypeTransformer._();

  const ExamPaperLanguageEnumTypeTransformer._();

  String encode(ExamPaperLanguageEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExamPaperLanguageEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExamPaperLanguageEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'en': return ExamPaperLanguageEnum.en;
        case r'ta': return ExamPaperLanguageEnum.ta;
        case r'hi': return ExamPaperLanguageEnum.hi;
        case r'bilingual': return ExamPaperLanguageEnum.bilingual;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExamPaperLanguageEnumTypeTransformer] instance.
  static ExamPaperLanguageEnumTypeTransformer? _instance;
}


