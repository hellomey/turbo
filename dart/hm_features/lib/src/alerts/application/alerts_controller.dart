import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../common/ports.dart';
import '../data/alerts_repository.dart';
import '../domain/alert_models.dart';

/// Alerts wiring (INT-002-S16/S17). Tests override the repository.

final alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) => ApiAlertsRepository(ref.watch(hmApiProvider)),
);

class ExamAlertsState {
  const ExamAlertsState({
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
  });

  final List<ExamAlertView> items;
  final String? nextCursor;
  final bool loadingMore;

  bool get hasMore => nextCursor != null;
}

/// Exam Alerts list, cursor-paginated (§37).
class ExamAlertsController extends AsyncNotifier<ExamAlertsState> {
  @override
  Future<ExamAlertsState> build() async {
    final page = await ref.read(alertsRepositoryProvider).examAlerts();
    return ExamAlertsState(items: page.items, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      ExamAlertsState(
        items: current.items,
        nextCursor: current.nextCursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(alertsRepositoryProvider)
          .examAlerts(cursor: current.nextCursor);
      state = AsyncData(
        ExamAlertsState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } on Exception {
      state = AsyncData(current);
    }
  }
}

final examAlertsProvider =
    AsyncNotifierProvider<ExamAlertsController, ExamAlertsState>(
      ExamAlertsController.new,
    );

class AlertSettingsState {
  const AlertSettingsState({
    required this.settings,
    this.saving = false,
    this.message,
  });

  final AlertSettingsView settings;
  final bool saving;
  final String? message;
}

/// Alert settings: every change is saved to the server at once (needs a connection, U-notifications client).
/// On failure the last saved settings come back with a simple-English message.
class AlertSettingsController extends AsyncNotifier<AlertSettingsState> {
  @override
  Future<AlertSettingsState> build() async => AlertSettingsState(
    settings: await ref.read(alertsRepositoryProvider).settings(),
  );

  Future<bool> save(AlertSettingsView next) async {
    final current = state.value;
    if (current == null || current.saving) return false;
    state = AsyncData(AlertSettingsState(settings: next, saving: true));
    try {
      final saved = await ref.read(alertsRepositoryProvider).saveSettings(next);
      state = AsyncData(AlertSettingsState(settings: saved));
      return true;
    } on Exception catch (e) {
      state = AsyncData(
        AlertSettingsState(settings: current.settings, message: messageOf(e)),
      );
      return false;
    }
  }

  void clearMessage() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(AlertSettingsState(settings: current.settings));
  }
}

final alertSettingsProvider =
    AsyncNotifierProvider<AlertSettingsController, AlertSettingsState>(
      AlertSettingsController.new,
    );
