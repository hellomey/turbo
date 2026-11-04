//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SiteChangeWebhookBody {
  /// Returns a new [SiteChangeWebhookBody] instance.
  SiteChangeWebhookBody({
    required this.watchUuid,
    required this.watchUrl,
    this.title,
    required this.changeId,
    this.diffSummary,
  });

  String watchUuid;

  String watchUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? title;

  String changeId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? diffSummary;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SiteChangeWebhookBody &&
    other.watchUuid == watchUuid &&
    other.watchUrl == watchUrl &&
    other.title == title &&
    other.changeId == changeId &&
    other.diffSummary == diffSummary;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (watchUuid.hashCode) +
    (watchUrl.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (changeId.hashCode) +
    (diffSummary == null ? 0 : diffSummary!.hashCode);

  @override
  String toString() => 'SiteChangeWebhookBody[watchUuid=$watchUuid, watchUrl=$watchUrl, title=$title, changeId=$changeId, diffSummary=$diffSummary]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'watchUuid'] = this.watchUuid;
      json[r'watchUrl'] = this.watchUrl;
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
      json[r'changeId'] = this.changeId;
    if (this.diffSummary != null) {
      json[r'diffSummary'] = this.diffSummary;
    } else {
      json[r'diffSummary'] = null;
    }
    return json;
  }

  /// Returns a new [SiteChangeWebhookBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SiteChangeWebhookBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SiteChangeWebhookBody[$key]" is missing from JSON.');
        });
        assert(json[r'watchUuid'] != null, 'Required key "SiteChangeWebhookBody[watchUuid]" has a null value in JSON.');
        assert(json[r'watchUrl'] != null, 'Required key "SiteChangeWebhookBody[watchUrl]" has a null value in JSON.');
        assert(json[r'changeId'] != null, 'Required key "SiteChangeWebhookBody[changeId]" has a null value in JSON.');
        return true;
      }());

      return SiteChangeWebhookBody(
        watchUuid: mapValueOfType<String>(json, r'watchUuid')!,
        watchUrl: mapValueOfType<String>(json, r'watchUrl')!,
        title: mapValueOfType<String>(json, r'title'),
        changeId: mapValueOfType<String>(json, r'changeId')!,
        diffSummary: mapValueOfType<String>(json, r'diffSummary'),
      );
    }
    return null;
  }

  static List<SiteChangeWebhookBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SiteChangeWebhookBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SiteChangeWebhookBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SiteChangeWebhookBody> mapFromJson(dynamic json) {
    final map = <String, SiteChangeWebhookBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SiteChangeWebhookBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SiteChangeWebhookBody-objects as value to a dart map
  static Map<String, List<SiteChangeWebhookBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SiteChangeWebhookBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SiteChangeWebhookBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'watchUuid',
    'watchUrl',
    'changeId',
  };
}

