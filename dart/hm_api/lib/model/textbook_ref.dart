//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TextbookRef {
  /// Returns a new [TextbookRef] instance.
  TextbookRef({
    required this.book,
    required this.classLevel,
    required this.chapter,
    required this.pages,
    required this.url,
  });

  String book;

  int? classLevel;

  String? chapter;

  String? pages;

  String? url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TextbookRef &&
    other.book == book &&
    other.classLevel == classLevel &&
    other.chapter == chapter &&
    other.pages == pages &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (book.hashCode) +
    (classLevel == null ? 0 : classLevel!.hashCode) +
    (chapter == null ? 0 : chapter!.hashCode) +
    (pages == null ? 0 : pages!.hashCode) +
    (url == null ? 0 : url!.hashCode);

  @override
  String toString() => 'TextbookRef[book=$book, classLevel=$classLevel, chapter=$chapter, pages=$pages, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'book'] = this.book;
    if (this.classLevel != null) {
      json[r'classLevel'] = this.classLevel;
    } else {
      json[r'classLevel'] = null;
    }
    if (this.chapter != null) {
      json[r'chapter'] = this.chapter;
    } else {
      json[r'chapter'] = null;
    }
    if (this.pages != null) {
      json[r'pages'] = this.pages;
    } else {
      json[r'pages'] = null;
    }
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    return json;
  }

  /// Returns a new [TextbookRef] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TextbookRef? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TextbookRef[$key]" is missing from JSON.');
        });
        assert(json[r'book'] != null, 'Required key "TextbookRef[book]" has a null value in JSON.');
        return true;
      }());

      return TextbookRef(
        book: mapValueOfType<String>(json, r'book')!,
        classLevel: mapValueOfType<int>(json, r'classLevel'),
        chapter: mapValueOfType<String>(json, r'chapter'),
        pages: mapValueOfType<String>(json, r'pages'),
        url: mapValueOfType<String>(json, r'url'),
      );
    }
    return null;
  }

  static List<TextbookRef> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TextbookRef>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TextbookRef.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TextbookRef> mapFromJson(dynamic json) {
    final map = <String, TextbookRef>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TextbookRef.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TextbookRef-objects as value to a dart map
  static Map<String, List<TextbookRef>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TextbookRef>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TextbookRef.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'book',
    'classLevel',
    'chapter',
    'pages',
    'url',
  };
}

