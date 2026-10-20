import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(hmApiProvider)),
);

/// The signed-in user, with Calm Mode switching (§10.7).
class MeController extends AsyncNotifier<MeInfo> {
  @override
  Future<MeInfo> build() => ref.watch(profileRepositoryProvider).me();

  Future<void> setCalmMode(bool on) async {
    final updated = await ref.read(profileRepositoryProvider).setCalmMode(on);
    state = AsyncData(updated);
  }

  /// Log out (this device) or log out of all devices. Signed out locally even when offline.
  Future<void> logout({bool allDevices = false}) async {
    final repo = ref.read(profileRepositoryProvider);
    try {
      allDevices ? await repo.logoutAll() : await repo.logout();
    } on HmApiException {
      // The tokens are already forgotten on this phone.
    }
    ref.read(sessionProvider.notifier).markSignedOut();
  }
}

final meProvider = AsyncNotifierProvider<MeController, MeInfo>(
  MeController.new,
);

enum DeleteStep { explain, code, scheduled }

@immutable
class DeleteAccountState {
  const DeleteAccountState({
    this.step = DeleteStep.explain,
    this.busy = false,
    this.error,
    this.scheduledFor,
    this.resendAfterSeconds = 60,
  });

  final DeleteStep step;
  final bool busy;
  final String? error;
  final DateTime? scheduledFor;
  final int resendAfterSeconds;
}

/// Delete account (§38 step 7): explain the 7-day grace period → code → scheduled → signed out.
class DeleteAccountController extends Notifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  Future<void> sendCode(String email) async {
    state = const DeleteAccountState(busy: true);
    try {
      final seconds = await ref
          .read(profileRepositoryProvider)
          .requestDeleteCode(email);
      state = DeleteAccountState(
        step: DeleteStep.code,
        resendAfterSeconds: seconds,
      );
    } on HmApiException catch (e) {
      state = DeleteAccountState(error: e.message);
    }
  }

  Future<void> confirm(String code) async {
    if (state.busy) return;
    state = DeleteAccountState(
      step: DeleteStep.code,
      busy: true,
      resendAfterSeconds: state.resendAfterSeconds,
    );
    try {
      final when = await ref
          .read(profileRepositoryProvider)
          .deleteAccount(code);
      state = DeleteAccountState(
        step: DeleteStep.scheduled,
        scheduledFor: when,
      );
    } on HmApiException catch (e) {
      state = DeleteAccountState(
        step: DeleteStep.code,
        error: e.message,
        resendAfterSeconds: state.resendAfterSeconds,
      );
    }
  }

  void finish() => ref.read(sessionProvider.notifier).markSignedOut();
}

final deleteAccountProvider =
    NotifierProvider.autoDispose<DeleteAccountController, DeleteAccountState>(
      DeleteAccountController.new,
    );

/// The user's DPDP choices: the current notice and the latest choice per purpose (§23, §30).
@immutable
class DataChoices {
  const DataChoices({required this.notice, required this.choices});

  final ConsentNoticeInfo notice;

  /// Purpose wire value → granted.
  final Map<String, bool> choices;

  List<ConsentPurposeInfo> get optional =>
      notice.purposes.where((p) => !p.required).toList();

  bool granted(String purpose) => choices[purpose] == true;
}

/// "Your data choices" in Profile: optional purposes can be switched any time. Every save sends ALL
/// purposes with the CURRENT notice version (never hard-coded); required purposes stay granted.
class DataChoicesController extends AsyncNotifier<DataChoices> {
  @override
  Future<DataChoices> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final (notice, choices) = await (
      repo.consentNotice(),
      repo.myConsents(),
    ).wait;
    return DataChoices(notice: notice, choices: choices);
  }

  Future<void> setOptional(String purpose, bool granted) async {
    final current = state.value;
    if (current == null) return;
    final all = {
      for (final p in current.notice.purposes)
        p.purpose: p.required
            ? true
            : (p.purpose == purpose ? granted : current.granted(p.purpose)),
    };
    await ref
        .read(profileRepositoryProvider)
        .saveConsents(current.notice.version, all);
    state = AsyncData(DataChoices(notice: current.notice, choices: all));
  }
}

final dataChoicesProvider =
    AsyncNotifierProvider<DataChoicesController, DataChoices>(
      DataChoicesController.new,
    );
