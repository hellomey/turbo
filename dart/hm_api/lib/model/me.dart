//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.id,
    required this.email,
    required this.nickname,
    required this.district,
    required this.calmMode,
    required this.liteMode,
    required this.hideFromLeaderboards,
    required this.profile,
    this.roles = const [],
    required this.deletionScheduledFor,
    required this.createdAt,
  });

  String id;

  String email;

  String? nickname;

  District? district;

  bool calmMode;

  /// null = automatic (3 GB RAM or less)
  bool? liteMode;

  bool hideFromLeaderboards;

  ProfileAnswers profile;

  List<Role> roles;

  DateTime? deletionScheduledFor;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Me &&
    other.id == id &&
    other.email == email &&
    other.nickname == nickname &&
    other.district == district &&
    other.calmMode == calmMode &&
    other.liteMode == liteMode &&
    other.hideFromLeaderboards == hideFromLeaderboards &&
    other.profile == profile &&
    _deepEquality.equals(other.roles, roles) &&
    other.deletionScheduledFor == deletionScheduledFor &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (email.hashCode) +
    (nickname == null ? 0 : nickname!.hashCode) +
    (district == null ? 0 : district!.hashCode) +
    (calmMode.hashCode) +
    (liteMode == null ? 0 : liteMode!.hashCode) +
    (hideFromLeaderboards.hashCode) +
    (profile.hashCode) +
    (roles.hashCode) +
    (deletionScheduledFor == null ? 0 : deletionScheduledFor!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Me[id=$id, email=$email, nickname=$nickname, district=$district, calmMode=$calmMode, liteMode=$liteMode, hideFromLeaderboards=$hideFromLeaderboards, profile=$profile, roles=$roles, deletionScheduledFor=$deletionScheduledFor, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'email'] = this.email;
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
      json[r'calmMode'] = this.calmMode;
    if (this.liteMode != null) {
      json[r'liteMode'] = this.liteMode;
    } else {
      json[r'liteMode'] = null;
    }
      json[r'hideFromLeaderboards'] = this.hideFromLeaderboards;
      json[r'profile'] = this.profile;
      json[r'roles'] = this.roles;
    if (this.deletionScheduledFor != null) {
      json[r'deletionScheduledFor'] = this.deletionScheduledFor!.toUtc().toIso8601String();
    } else {
      json[r'deletionScheduledFor'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Me] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Me? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Me[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "Me[id]" has a null value in JSON.');
        assert(json[r'email'] != null, 'Required key "Me[email]" has a null value in JSON.');
        assert(json[r'calmMode'] != null, 'Required key "Me[calmMode]" has a null value in JSON.');
        assert(json[r'hideFromLeaderboards'] != null, 'Required key "Me[hideFromLeaderboards]" has a null value in JSON.');
        assert(json[r'profile'] != null, 'Required key "Me[profile]" has a null value in JSON.');
        assert(json[r'roles'] != null, 'Required key "Me[roles]" has a null value in JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Me[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Me(
        id: mapValueOfType<String>(json, r'id')!,
        email: mapValueOfType<String>(json, r'email')!,
        nickname: mapValueOfType<String>(json, r'nickname'),
        district: District.fromJson(json[r'district']),
        calmMode: mapValueOfType<bool>(json, r'calmMode')!,
        liteMode: mapValueOfType<bool>(json, r'liteMode'),
        hideFromLeaderboards: mapValueOfType<bool>(json, r'hideFromLeaderboards')!,
        profile: ProfileAnswers.fromJson(json[r'profile'])!,
        roles: Role.listFromJson(json[r'roles']),
        deletionScheduledFor: mapDateTime(json, r'deletionScheduledFor', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Me> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Me>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Me.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Me> mapFromJson(dynamic json) {
    final map = <String, Me>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Me.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Me-objects as value to a dart map
  static Map<String, List<Me>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Me>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Me.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'email',
    'nickname',
    'district',
    'calmMode',
    'liteMode',
    'hideFromLeaderboards',
    'profile',
    'roles',
    'deletionScheduledFor',
    'createdAt',
  };
}

