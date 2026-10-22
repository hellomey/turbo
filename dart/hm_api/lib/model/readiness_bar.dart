//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReadinessBar {
  /// Returns a new [ReadinessBar] instance.
  ReadinessBar({
    required this.key,
    required this.value,
    required this.locked,
    required this.evidence,
  });

  ReadinessBarKeyEnum key;

  /// Minimum value: 0
  /// Maximum value: 100
  int? value;

  bool locked;

  String evidence;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReadinessBar &&
    other.key == key &&
    other.value == value &&
    other.locked == locked &&
    other.evidence == evidence;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (value == null ? 0 : value!.hashCode) +
    (locked.hashCode) +
    (evidence.hashCode);

  @override
  String toString() => 'ReadinessBar[key=$key, value=$value, locked=$locked, evidence=$evidence]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
    if (this.value != null) {
      json[r'value'] = this.value;
    } else {
      json[r'value'] = null;
    }
      json[r'locked'] = this.locked;
      json[r'evidence'] = this.evidence;
    return json;
  }

  /// Returns a new [ReadinessBar] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReadinessBar? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReadinessBar[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReadinessBar[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReadinessBar(
        key: ReadinessBarKeyEnum.fromJson(json[r'key'])!,
        value: mapValueOfType<int>(json, r'value'),
        locked: mapValueOfType<bool>(json, r'locked')!,
        evidence: mapValueOfType<String>(json, r'evidence')!,
      );
    }
    return null;
  }

  static List<ReadinessBar> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessBar>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessBar.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReadinessBar> mapFromJson(dynamic json) {
    final map = <String, ReadinessBar>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReadinessBar.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReadinessBar-objects as value to a dart map
  static Map<String, List<ReadinessBar>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReadinessBar>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReadinessBar.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'value',
    'locked',
    'evidence',
  };
}


class ReadinessBarKeyEnum {
  /// Instantiate a new enum with the provided [value].
  const ReadinessBarKeyEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const coverage = ReadinessBarKeyEnum._(r'coverage');
  static const memory = ReadinessBarKeyEnum._(r'memory');
  static const examPerformance = ReadinessBarKeyEnum._(r'exam_performance');
  static const speed = ReadinessBarKeyEnum._(r'speed');

  /// List of all possible values in this [enum][ReadinessBarKeyEnum].
  static const values = <ReadinessBarKeyEnum>[
    coverage,
    memory,
    examPerformance,
    speed,
  ];

  static ReadinessBarKeyEnum? fromJson(dynamic value) => ReadinessBarKeyEnumTypeTransformer().decode(value);

  static List<ReadinessBarKeyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessBarKeyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessBarKeyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReadinessBarKeyEnum] to String,
/// and [decode] dynamic data back to [ReadinessBarKeyEnum].
class ReadinessBarKeyEnumTypeTransformer {
  factory ReadinessBarKeyEnumTypeTransformer() => _instance ??= const ReadinessBarKeyEnumTypeTransformer._();

  const ReadinessBarKeyEnumTypeTransformer._();

  String encode(ReadinessBarKeyEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ReadinessBarKeyEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReadinessBarKeyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'coverage': return ReadinessBarKeyEnum.coverage;
        case r'memory': return ReadinessBarKeyEnum.memory;
        case r'exam_performance': return ReadinessBarKeyEnum.examPerformance;
        case r'speed': return ReadinessBarKeyEnum.speed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ReadinessBarKeyEnumTypeTransformer] instance.
  static ReadinessBarKeyEnumTypeTransformer? _instance;
}


