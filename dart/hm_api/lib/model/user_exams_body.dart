//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserExamsBody {
  /// Returns a new [UserExamsBody] instance.
  UserExamsBody({
    required this.mainExamCode,
    this.otherExamCodes = const [],
  });

  String mainExamCode;

  List<String> otherExamCodes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserExamsBody &&
    other.mainExamCode == mainExamCode &&
    _deepEquality.equals(other.otherExamCodes, otherExamCodes);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mainExamCode.hashCode) +
    (otherExamCodes.hashCode);

  @override
  String toString() => 'UserExamsBody[mainExamCode=$mainExamCode, otherExamCodes=$otherExamCodes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mainExamCode'] = this.mainExamCode;
      json[r'otherExamCodes'] = this.otherExamCodes;
    return json;
  }

  /// Returns a new [UserExamsBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserExamsBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserExamsBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UserExamsBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserExamsBody(
        mainExamCode: mapValueOfType<String>(json, r'mainExamCode')!,
        otherExamCodes: json[r'otherExamCodes'] is Iterable
            ? (json[r'otherExamCodes'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<UserExamsBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserExamsBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserExamsBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserExamsBody> mapFromJson(dynamic json) {
    final map = <String, UserExamsBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserExamsBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserExamsBody-objects as value to a dart map
  static Map<String, List<UserExamsBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserExamsBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserExamsBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mainExamCode',
  };
}

