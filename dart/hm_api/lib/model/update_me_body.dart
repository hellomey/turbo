//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateMeBody {
  /// Returns a new [UpdateMeBody] instance.
  UpdateMeBody({
    this.nickname,
    this.district,
    this.calmMode,
    this.liteMode,
    this.hideFromLeaderboards,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nickname;

  District? district;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? calmMode;

  bool? liteMode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? hideFromLeaderboards;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateMeBody &&
    other.nickname == nickname &&
    other.district == district &&
    other.calmMode == calmMode &&
    other.liteMode == liteMode &&
    other.hideFromLeaderboards == hideFromLeaderboards;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nickname == null ? 0 : nickname!.hashCode) +
    (district == null ? 0 : district!.hashCode) +
    (calmMode == null ? 0 : calmMode!.hashCode) +
    (liteMode == null ? 0 : liteMode!.hashCode) +
    (hideFromLeaderboards == null ? 0 : hideFromLeaderboards!.hashCode);

  @override
  String toString() => 'UpdateMeBody[nickname=$nickname, district=$district, calmMode=$calmMode, liteMode=$liteMode, hideFromLeaderboards=$hideFromLeaderboards]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.nickname != null) {
      json[r'nickname'] = this.nickname;
    } else {
      json[r'nickname'] = null;
    }
    if (this.district != null) {
      json[r'district'] = this.district;
    } else {
      json[r'district'] = null;
    }
    if (this.calmMode != null) {
      json[r'calmMode'] = this.calmMode;
    } else {
      json[r'calmMode'] = null;
    }
    if (this.liteMode != null) {
      json[r'liteMode'] = this.liteMode;
    } else {
      json[r'liteMode'] = null;
    }
    if (this.hideFromLeaderboards != null) {
      json[r'hideFromLeaderboards'] = this.hideFromLeaderboards;
    } else {
      json[r'hideFromLeaderboards'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateMeBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateMeBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateMeBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateMeBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateMeBody(
        nickname: mapValueOfType<String>(json, r'nickname'),
        district: District.fromJson(json[r'district']),
        calmMode: mapValueOfType<bool>(json, r'calmMode'),
        liteMode: mapValueOfType<bool>(json, r'liteMode'),
        hideFromLeaderboards: mapValueOfType<bool>(json, r'hideFromLeaderboards'),
      );
    }
    return null;
  }

  static List<UpdateMeBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMeBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMeBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateMeBody> mapFromJson(dynamic json) {
    final map = <String, UpdateMeBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateMeBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateMeBody-objects as value to a dart map
  static Map<String, List<UpdateMeBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateMeBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateMeBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

