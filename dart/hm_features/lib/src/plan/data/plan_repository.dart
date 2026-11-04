import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';

import '../domain/plan_models.dart';

/// Today + My Plan data (INT-002-S12) over the plan routes. Item status is NOT sent from here: it goes
/// through the hm_data outbox as `plan_item_status` (§39).
abstract interface class PlanRepository {
  Future<TodayView> today();

  /// Days [from]..[to] inclusive (IST calendar days).
  Future<List<PlanDayView>> days(DateTime from, DateTime to);

  Future<void> rebalance({required String idempotencyKey});
}

const _unknown = HmApiException(
  HmApiException.unknownError,
  HmApiException.unknownMessage,
);

/// Generated `fromJson` returns null for a non-object and throws on a wrong-typed field.
T parseApi<T>(T? Function() read) {
  try {
    return read() ?? (throw _unknown);
  } on FormatException {
    throw _unknown;
  } on TypeError {
    throw _unknown;
  }
}

class ApiPlanRepository implements PlanRepository {
  ApiPlanRepository(this._api);

  final HmApi _api;

  @override
  Future<TodayView> today() async {
    final json = await _api.getToday();
    return todayFromApi(parseApi(() => api.TodayScreen.fromJson(json)));
  }

  @override
  Future<List<PlanDayView>> days(DateTime from, DateTime to) async {
    final json = await _api.getPlanDays(isoDay(from), isoDay(to));
    final days = parseApi(() => api.PlanDays.fromJson(json));
    return [
      for (final d in days.days)
        PlanDayView(
          day: dateOnly(d.day),
          minutes: d.minutes,
          items: [for (final i in d.items) planItemFromApi(i)],
        ),
    ];
  }

  @override
  Future<void> rebalance({required String idempotencyKey}) async {
    await _api.rebalancePlan(idempotencyKey: idempotencyKey);
  }
}

PlanItemKindView _kind(String v) => switch (v) {
  'lit_check' => PlanItemKindView.litCheck,
  'relight' => PlanItemKindView.relight,
  'practice' => PlanItemKindView.practice,
  'pyq' => PlanItemKindView.pyq,
  'gold' => PlanItemKindView.gold,
  'mock' => PlanItemKindView.mock,
  'mistake_review' => PlanItemKindView.mistakeReview,
  'checklist' => PlanItemKindView.checklist,
  _ => PlanItemKindView.lesson,
};

PlanItemStatusView _status(String v) => switch (v) {
  'done' => PlanItemStatusView.done,
  'skipped' => PlanItemStatusView.skipped,
  'moved' => PlanItemStatusView.moved,
  _ => PlanItemStatusView.pending,
};

StretchView _stretch(String v) => switch (v) {
  'd90' => StretchView.d90,
  'd60' => StretchView.d60,
  'd30' => StretchView.d30,
  'd7' => StretchView.d7,
  _ => StretchView.normal,
};

PlanItemView planItemFromApi(api.PlanItem i) => PlanItemView(
  id: i.id,
  day: dateOnly(i.day),
  kind: _kind(i.kind.value),
  examCode: i.examCode,
  topicId: i.topicId,
  title: i.title,
  minutes: i.minutes,
  status: _status(i.status.value),
);

RankView rankFromApi(api.Rank r) => RankView(
  level: r.level,
  title: r.title,
  xp: r.xp,
  xpForThisLevel: r.xpForThisLevel,
  xpForNextLevel: r.xpForNextLevel,
  note: r.note,
);

TodayView todayFromApi(api.TodayScreen t) => TodayView(
  day: dateOnly(t.day),
  rank: rankFromApi(t.rank),
  todayCard: planItemFromApi(t.todayCard),
  relightCount: t.relight.count,
  relightMinutes: t.relight.minutes,
  pocketSessions: t.pocketSessions,
  stretch: _stretch(t.stretch.value),
  welcomeBack: t.welcomeBack,
  hasPlan: t.hasPlan,
);
