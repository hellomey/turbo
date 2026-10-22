//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LessonCompleteBody {
  /// Returns a new [LessonCompleteBody] instance.
  LessonCompleteBody({
    required this.via,
  });

  LessonCompleteBodyViaEnum via;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LessonCompleteBody &&
    other.via == via;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (via.hashCode);

  @override
  String toString() => 'LessonCompleteBody[via=$via]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'via'] = this.via;
    return json;
  }

  /// Returns a new [LessonCompleteBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LessonCompleteBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LessonCompleteBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LessonCompleteBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LessonCompleteBody(
        via: LessonCompleteBodyViaEnum.fromJson(json[r'via'])!,
      );
    }
    return null;
  }

  static List<LessonCompleteBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LessonCompleteBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LessonCompleteBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LessonCompleteBody> mapFromJson(dynamic json) {
    final map = <String, LessonCompleteBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LessonCompleteBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LessonCompleteBody-objects as value to a dart map
  static Map<String, List<LessonCompleteBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LessonCompleteBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LessonCompleteBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'via',
  };
}


class LessonCompleteBodyViaEnum {
  /// Instantiate a new enum with the provided [value].
  const LessonCompleteBodyViaEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const lesson = LessonCompleteBodyViaEnum._(r'lesson');
  static const textbook = LessonCompleteBodyViaEnum._(r'textbook');

  /// List of all possible values in this [enum][LessonCompleteBodyViaEnum].
  static const values = <LessonCompleteBodyViaEnum>[
    lesson,
    textbook,
  ];

  static LessonCompleteBodyViaEnum? fromJson(dynamic value) => LessonCompleteBodyViaEnumTypeTransformer().decode(value);

  static List<LessonCompleteBodyViaEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LessonCompleteBodyViaEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LessonCompleteBodyViaEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [LessonCompleteBodyViaEnum] to String,
/// and [decode] dynamic data back to [LessonCompleteBodyViaEnum].
class LessonCompleteBodyViaEnumTypeTransformer {
  factory LessonCompleteBodyViaEnumTypeTransformer() => _instance ??= const LessonCompleteBodyViaEnumTypeTransformer._();

  const LessonCompleteBodyViaEnumTypeTransformer._();

  String encode(LessonCompleteBodyViaEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a LessonCompleteBodyViaEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  LessonCompleteBodyViaEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'lesson': return LessonCompleteBodyViaEnum.lesson;
        case r'textbook': return LessonCompleteBodyViaEnum.textbook;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [LessonCompleteBodyViaEnumTypeTransformer] instance.
  static LessonCompleteBodyViaEnumTypeTransformer? _instance;
}


