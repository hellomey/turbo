//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DuelScoringRow {
  /// Returns a new [DuelScoringRow] instance.
  DuelScoringRow({
    required this.confidence,
    required this.label,
    required this.correctPoints,
    required this.wrongPoints,
  });

  /// Minimum value: 1
  /// Maximum value: 3
  int confidence;

  String label;

  /// Minimum value: 0
  int correctPoints;

  /// Minimum value: 0
  int wrongPoints;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DuelScoringRow &&
    other.confidence == confidence &&
    other.label == label &&
    other.correctPoints == correctPoints &&
    other.wrongPoints == wrongPoints;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (confidence.hashCode) +
    (label.hashCode) +
    (correctPoints.hashCode) +
    (wrongPoints.hashCode);

  @override
  String toString() => 'DuelScoringRow[confidence=$confidence, label=$label, correctPoints=$correctPoints, wrongPoints=$wrongPoints]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'confidence'] = this.confidence;
      json[r'label'] = this.label;
      json[r'correctPoints'] = this.correctPoints;
      json[r'wrongPoints'] = this.wrongPoints;
    return json;
  }

  /// Returns a new [DuelScoringRow] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DuelScoringRow? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DuelScoringRow[$key]" is missing from JSON.');
        });
        assert(json[r'confidence'] != null, 'Required key "DuelScoringRow[confidence]" has a null value in JSON.');
        assert(json[r'label'] != null, 'Required key "DuelScoringRow[label]" has a null value in JSON.');
        assert(json[r'correctPoints'] != null, 'Required key "DuelScoringRow[correctPoints]" has a null value in JSON.');
        assert(json[r'wrongPoints'] != null, 'Required key "DuelScoringRow[wrongPoints]" has a null value in JSON.');
        return true;
      }());

      return DuelScoringRow(
        confidence: mapValueOfType<int>(json, r'confidence')!,
        label: mapValueOfType<String>(json, r'label')!,
        correctPoints: mapValueOfType<int>(json, r'correctPoints')!,
        wrongPoints: mapValueOfType<int>(json, r'wrongPoints')!,
      );
    }
    return null;
  }

  static List<DuelScoringRow> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DuelScoringRow>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DuelScoringRow.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DuelScoringRow> mapFromJson(dynamic json) {
    final map = <String, DuelScoringRow>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DuelScoringRow.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DuelScoringRow-objects as value to a dart map
  static Map<String, List<DuelScoringRow>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DuelScoringRow>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DuelScoringRow.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'confidence',
    'label',
    'correctPoints',
    'wrongPoints',
  };
}

