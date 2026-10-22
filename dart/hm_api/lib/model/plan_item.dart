//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlanItem {
  /// Returns a new [PlanItem] instance.
  PlanItem({
    required this.id,
    required this.day,
    required this.kind,
    required this.examCode,
    required this.topicId,
    required this.title,
    required this.minutes,
    required this.order,
    required this.status,
  });

  String id;

  DateTime day;

  PlanItemKind kind;

  String examCode;

  String? topicId;

  String title;

  int minutes;

  int order;

  PlanItemStatus status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlanItem &&
    other.id == id &&
    other.day == day &&
    other.kind == kind &&
    other.examCode == examCode &&
    other.topicId == topicId &&
    other.title == title &&
    other.minutes == minutes &&
    other.order == order &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (day.hashCode) +
    (kind.hashCode) +
    (examCode.hashCode) +
    (topicId == null ? 0 : topicId!.hashCode) +
    (title.hashCode) +
    (minutes.hashCode) +
    (order.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'PlanItem[id=$id, day=$day, kind=$kind, examCode=$examCode, topicId=$topicId, title=$title, minutes=$minutes, order=$order, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'day'] = _dateFormatter.format(this.day.toUtc());
      json[r'kind'] = this.kind;
      json[r'examCode'] = this.examCode;
    if (this.topicId != null) {
      json[r'topicId'] = this.topicId;
    } else {
      json[r'topicId'] = null;
    }
      json[r'title'] = this.title;
      json[r'minutes'] = this.minutes;
      json[r'order'] = this.order;
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [PlanItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlanItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PlanItem[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PlanItem[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PlanItem(
        id: mapValueOfType<String>(json, r'id')!,
        day: mapDateTime(json, r'day', r'')!,
        kind: PlanItemKind.fromJson(json[r'kind'])!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        topicId: mapValueOfType<String>(json, r'topicId'),
        title: mapValueOfType<String>(json, r'title')!,
        minutes: mapValueOfType<int>(json, r'minutes')!,
        order: mapValueOfType<int>(json, r'order')!,
        status: PlanItemStatus.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<PlanItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlanItem> mapFromJson(dynamic json) {
    final map = <String, PlanItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlanItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlanItem-objects as value to a dart map
  static Map<String, List<PlanItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlanItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlanItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'day',
    'kind',
    'examCode',
    'topicId',
    'title',
    'minutes',
    'order',
    'status',
  };
}

