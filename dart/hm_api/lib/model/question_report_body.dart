//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuestionReportBody {
  /// Returns a new [QuestionReportBody] instance.
  QuestionReportBody({
    required this.questionVersion,
    required this.reason,
    this.note,
  });

  int questionVersion;

  QuestionReportBodyReasonEnum reason;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionReportBody &&
    other.questionVersion == questionVersion &&
    other.reason == reason &&
    other.note == note;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionVersion.hashCode) +
    (reason.hashCode) +
    (note == null ? 0 : note!.hashCode);

  @override
  String toString() => 'QuestionReportBody[questionVersion=$questionVersion, reason=$reason, note=$note]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionVersion'] = this.questionVersion;
      json[r'reason'] = this.reason;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    return json;
  }

  /// Returns a new [QuestionReportBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuestionReportBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuestionReportBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "QuestionReportBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return QuestionReportBody(
        questionVersion: mapValueOfType<int>(json, r'questionVersion')!,
        reason: QuestionReportBodyReasonEnum.fromJson(json[r'reason'])!,
        note: mapValueOfType<String>(json, r'note'),
      );
    }
    return null;
  }

  static List<QuestionReportBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionReportBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionReportBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuestionReportBody> mapFromJson(dynamic json) {
    final map = <String, QuestionReportBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuestionReportBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuestionReportBody-objects as value to a dart map
  static Map<String, List<QuestionReportBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuestionReportBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuestionReportBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionVersion',
    'reason',
  };
}


class QuestionReportBodyReasonEnum {
  /// Instantiate a new enum with the provided [value].
  const QuestionReportBodyReasonEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const wrongAnswer = QuestionReportBodyReasonEnum._(r'wrong_answer');
  static const unclear = QuestionReportBodyReasonEnum._(r'unclear');
  static const outdated = QuestionReportBodyReasonEnum._(r'outdated');
  static const typo = QuestionReportBodyReasonEnum._(r'typo');
  static const other = QuestionReportBodyReasonEnum._(r'other');

  /// List of all possible values in this [enum][QuestionReportBodyReasonEnum].
  static const values = <QuestionReportBodyReasonEnum>[
    wrongAnswer,
    unclear,
    outdated,
    typo,
    other,
  ];

  static QuestionReportBodyReasonEnum? fromJson(dynamic value) => QuestionReportBodyReasonEnumTypeTransformer().decode(value);

  static List<QuestionReportBodyReasonEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuestionReportBodyReasonEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuestionReportBodyReasonEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [QuestionReportBodyReasonEnum] to String,
/// and [decode] dynamic data back to [QuestionReportBodyReasonEnum].
class QuestionReportBodyReasonEnumTypeTransformer {
  factory QuestionReportBodyReasonEnumTypeTransformer() => _instance ??= const QuestionReportBodyReasonEnumTypeTransformer._();

  const QuestionReportBodyReasonEnumTypeTransformer._();

  String encode(QuestionReportBodyReasonEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a QuestionReportBodyReasonEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  QuestionReportBodyReasonEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'wrong_answer': return QuestionReportBodyReasonEnum.wrongAnswer;
        case r'unclear': return QuestionReportBodyReasonEnum.unclear;
        case r'outdated': return QuestionReportBodyReasonEnum.outdated;
        case r'typo': return QuestionReportBodyReasonEnum.typo;
        case r'other': return QuestionReportBodyReasonEnum.other;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [QuestionReportBodyReasonEnumTypeTransformer] instance.
  static QuestionReportBodyReasonEnumTypeTransformer? _instance;
}


