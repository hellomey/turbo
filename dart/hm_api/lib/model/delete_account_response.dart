//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeleteAccountResponse {
  /// Returns a new [DeleteAccountResponse] instance.
  DeleteAccountResponse({
    required this.deletionScheduledFor,
  });

  DateTime deletionScheduledFor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeleteAccountResponse &&
    other.deletionScheduledFor == deletionScheduledFor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deletionScheduledFor.hashCode);

  @override
  String toString() => 'DeleteAccountResponse[deletionScheduledFor=$deletionScheduledFor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deletionScheduledFor'] = this.deletionScheduledFor.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DeleteAccountResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeleteAccountResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeleteAccountResponse[$key]" is missing from JSON.');
        });
        assert(json[r'deletionScheduledFor'] != null, 'Required key "DeleteAccountResponse[deletionScheduledFor]" has a null value in JSON.');
        return true;
      }());

      return DeleteAccountResponse(
        deletionScheduledFor: mapDateTime(json, r'deletionScheduledFor', r'')!,
      );
    }
    return null;
  }

  static List<DeleteAccountResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeleteAccountResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeleteAccountResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeleteAccountResponse> mapFromJson(dynamic json) {
    final map = <String, DeleteAccountResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeleteAccountResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeleteAccountResponse-objects as value to a dart map
  static Map<String, List<DeleteAccountResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeleteAccountResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeleteAccountResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deletionScheduledFor',
  };
}

