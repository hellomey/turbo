//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TodayScreen {
  /// Returns a new [TodayScreen] instance.
  TodayScreen({
    required this.day,
    required this.rank,
    required this.todayCard,
    required this.relight,
    this.pocketSessions = const [],
    required this.stretch,
    required this.welcomeBack,
    required this.hasPlan,
    required this.serverNow,
  });

  DateTime day;

  Rank rank;

  PlanItem todayCard;

  TodayScreenRelight relight;

  List<int> pocketSessions;

  StretchPhase stretch;

  String? welcomeBack;

  bool hasPlan;

  DateTime serverNow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TodayScreen &&
    other.day == day &&
    other.rank == rank &&
    other.todayCard == todayCard &&
    other.relight == relight &&
    _deepEquality.equals(other.pocketSessions, pocketSessions) &&
    other.stretch == stretch &&
    other.welcomeBack == welcomeBack &&
    other.hasPlan == hasPlan &&
    other.serverNow == serverNow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (day.hashCode) +
    (rank.hashCode) +
    (todayCard.hashCode) +
    (relight.hashCode) +
    (pocketSessions.hashCode) +
    (stretch.hashCode) +
    (welcomeBack == null ? 0 : welcomeBack!.hashCode) +
    (hasPlan.hashCode) +
    (serverNow.hashCode);

  @override
  String toString() => 'TodayScreen[day=$day, rank=$rank, todayCard=$todayCard, relight=$relight, pocketSessions=$pocketSessions, stretch=$stretch, welcomeBack=$welcomeBack, hasPlan=$hasPlan, serverNow=$serverNow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'day'] = _dateFormatter.format(this.day.toUtc());
      json[r'rank'] = this.rank;
      json[r'todayCard'] = this.todayCard;
      json[r'relight'] = this.relight;
      json[r'pocketSessions'] = this.pocketSessions;
      json[r'stretch'] = this.stretch;
    if (this.welcomeBack != null) {
      json[r'welcomeBack'] = this.welcomeBack;
    } else {
      json[r'welcomeBack'] = null;
    }
      json[r'hasPlan'] = this.hasPlan;
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TodayScreen] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TodayScreen? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TodayScreen[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TodayScreen[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TodayScreen(
        day: mapDateTime(json, r'day', r'')!,
        rank: Rank.fromJson(json[r'rank'])!,
        todayCard: PlanItem.fromJson(json[r'todayCard'])!,
        relight: TodayScreenRelight.fromJson(json[r'relight'])!,
        pocketSessions: json[r'pocketSessions'] is Iterable
            ? (json[r'pocketSessions'] as Iterable).cast<int>().toList(growable: false)
            : const [],
        stretch: StretchPhase.fromJson(json[r'stretch'])!,
        welcomeBack: mapValueOfType<String>(json, r'welcomeBack'),
        hasPlan: mapValueOfType<bool>(json, r'hasPlan')!,
        serverNow: mapDateTime(json, r'serverNow', r'')!,
      );
    }
    return null;
  }

  static List<TodayScreen> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TodayScreen>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TodayScreen.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TodayScreen> mapFromJson(dynamic json) {
    final map = <String, TodayScreen>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TodayScreen.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TodayScreen-objects as value to a dart map
  static Map<String, List<TodayScreen>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TodayScreen>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TodayScreen.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'day',
    'rank',
    'todayCard',
    'relight',
    'pocketSessions',
    'stretch',
    'welcomeBack',
    'hasPlan',
    'serverNow',
  };
}

