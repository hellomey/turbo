//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ContentPack {
  /// Returns a new [ContentPack] instance.
  ContentPack({
    required this.id,
    required this.code,
    required this.examCode,
    required this.subjectCode,
    required this.version,
    required this.url,
    required this.sha256,
    required this.sizeBytes,
    required this.tier,
    required this.locked,
    required this.publishedAt,
  });

  String id;

  String code;

  String examCode;

  String? subjectCode;

  int version;

  String url;

  String sha256;

  int sizeBytes;

  ContentPackTierEnum tier;

  bool locked;

  DateTime publishedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ContentPack &&
    other.id == id &&
    other.code == code &&
    other.examCode == examCode &&
    other.subjectCode == subjectCode &&
    other.version == version &&
    other.url == url &&
    other.sha256 == sha256 &&
    other.sizeBytes == sizeBytes &&
    other.tier == tier &&
    other.locked == locked &&
    other.publishedAt == publishedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (code.hashCode) +
    (examCode.hashCode) +
    (subjectCode == null ? 0 : subjectCode!.hashCode) +
    (version.hashCode) +
    (url.hashCode) +
    (sha256.hashCode) +
    (sizeBytes.hashCode) +
    (tier.hashCode) +
    (locked.hashCode) +
    (publishedAt.hashCode);

  @override
  String toString() => 'ContentPack[id=$id, code=$code, examCode=$examCode, subjectCode=$subjectCode, version=$version, url=$url, sha256=$sha256, sizeBytes=$sizeBytes, tier=$tier, locked=$locked, publishedAt=$publishedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'code'] = this.code;
      json[r'examCode'] = this.examCode;
    if (this.subjectCode != null) {
      json[r'subjectCode'] = this.subjectCode;
    } else {
      json[r'subjectCode'] = null;
    }
      json[r'version'] = this.version;
      json[r'url'] = this.url;
      json[r'sha256'] = this.sha256;
      json[r'sizeBytes'] = this.sizeBytes;
      json[r'tier'] = this.tier;
      json[r'locked'] = this.locked;
      json[r'publishedAt'] = this.publishedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ContentPack] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ContentPack? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ContentPack[$key]" is missing from JSON.');
        });
        assert(json[r'id'] != null, 'Required key "ContentPack[id]" has a null value in JSON.');
        assert(json[r'code'] != null, 'Required key "ContentPack[code]" has a null value in JSON.');
        assert(json[r'examCode'] != null, 'Required key "ContentPack[examCode]" has a null value in JSON.');
        assert(json[r'version'] != null, 'Required key "ContentPack[version]" has a null value in JSON.');
        assert(json[r'url'] != null, 'Required key "ContentPack[url]" has a null value in JSON.');
        assert(json[r'sha256'] != null, 'Required key "ContentPack[sha256]" has a null value in JSON.');
        assert(json[r'sizeBytes'] != null, 'Required key "ContentPack[sizeBytes]" has a null value in JSON.');
        assert(json[r'tier'] != null, 'Required key "ContentPack[tier]" has a null value in JSON.');
        assert(json[r'locked'] != null, 'Required key "ContentPack[locked]" has a null value in JSON.');
        assert(json[r'publishedAt'] != null, 'Required key "ContentPack[publishedAt]" has a null value in JSON.');
        return true;
      }());

      return ContentPack(
        id: mapValueOfType<String>(json, r'id')!,
        code: mapValueOfType<String>(json, r'code')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        subjectCode: mapValueOfType<String>(json, r'subjectCode'),
        version: mapValueOfType<int>(json, r'version')!,
        url: mapValueOfType<String>(json, r'url')!,
        sha256: mapValueOfType<String>(json, r'sha256')!,
        sizeBytes: mapValueOfType<int>(json, r'sizeBytes')!,
        tier: ContentPackTierEnum.fromJson(json[r'tier'])!,
        locked: mapValueOfType<bool>(json, r'locked')!,
        publishedAt: mapDateTime(json, r'publishedAt', r'')!,
      );
    }
    return null;
  }

  static List<ContentPack> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ContentPack>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContentPack.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ContentPack> mapFromJson(dynamic json) {
    final map = <String, ContentPack>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ContentPack.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ContentPack-objects as value to a dart map
  static Map<String, List<ContentPack>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ContentPack>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ContentPack.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'code',
    'examCode',
    'subjectCode',
    'version',
    'url',
    'sha256',
    'sizeBytes',
    'tier',
    'locked',
    'publishedAt',
  };
}


class ContentPackTierEnum {
  /// Instantiate a new enum with the provided [value].
  const ContentPackTierEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const free = ContentPackTierEnum._(r'free');
  static const pro = ContentPackTierEnum._(r'pro');

  /// List of all possible values in this [enum][ContentPackTierEnum].
  static const values = <ContentPackTierEnum>[
    free,
    pro,
  ];

  static ContentPackTierEnum? fromJson(dynamic value) => ContentPackTierEnumTypeTransformer().decode(value);

  static List<ContentPackTierEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ContentPackTierEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContentPackTierEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ContentPackTierEnum] to String,
/// and [decode] dynamic data back to [ContentPackTierEnum].
class ContentPackTierEnumTypeTransformer {
  factory ContentPackTierEnumTypeTransformer() => _instance ??= const ContentPackTierEnumTypeTransformer._();

  const ContentPackTierEnumTypeTransformer._();

  String encode(ContentPackTierEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ContentPackTierEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ContentPackTierEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'free': return ContentPackTierEnum.free;
        case r'pro': return ContentPackTierEnum.pro;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ContentPackTierEnumTypeTransformer] instance.
  static ContentPackTierEnumTypeTransformer? _instance;
}


