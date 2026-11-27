//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MyStickerCode {
  /// Returns a new [MyStickerCode] instance.
  MyStickerCode({
    required this.code,
    required this.redeemed,
  });

  String? code;

  bool redeemed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MyStickerCode &&
    other.code == code &&
    other.redeemed == redeemed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code == null ? 0 : code!.hashCode) +
    (redeemed.hashCode);

  @override
  String toString() => 'MyStickerCode[code=$code, redeemed=$redeemed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.code != null) {
      json[r'code'] = this.code;
    } else {
      json[r'code'] = null;
    }
      json[r'redeemed'] = this.redeemed;
    return json;
  }

  /// Returns a new [MyStickerCode] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MyStickerCode? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MyStickerCode[$key]" is missing from JSON.');
        });
        assert(json[r'redeemed'] != null, 'Required key "MyStickerCode[redeemed]" has a null value in JSON.');
        return true;
      }());

      return MyStickerCode(
        code: mapValueOfType<String>(json, r'code'),
        redeemed: mapValueOfType<bool>(json, r'redeemed')!,
      );
    }
    return null;
  }

  static List<MyStickerCode> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MyStickerCode>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MyStickerCode.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MyStickerCode> mapFromJson(dynamic json) {
    final map = <String, MyStickerCode>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MyStickerCode.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MyStickerCode-objects as value to a dart map
  static Map<String, List<MyStickerCode>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MyStickerCode>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MyStickerCode.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'redeemed',
  };
}

