import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../data/desk_auth_repository.dart';

enum DeskStep { starting, email, code, enroll, totp, home }

@immutable
class DeskSignInState {
  const DeskSignInState({
    this.step = DeskStep.starting,
    this.email = '',
    this.challengeToken,
    this.enrolment,
    this.me,
    this.busy = false,
    this.error,
  });

  final DeskStep step;
  final String email;
  final String? challengeToken;
  final DeskEnrolment? enrolment;
  final MeInfo? me;
  final bool busy;

  /// The server's simple-English message (e.g. DESK_NOT_ALLOWED for aspirants).
  final String? error;

  DeskSignInState copyWith({
    DeskStep? step,
    String? email,
    String? challengeToken,
    DeskEnrolment? enrolment,
    MeInfo? me,
    bool? busy,
    String? error,
    bool clearError = false,
  }) => DeskSignInState(
    step: step ?? this.step,
    email: email ?? this.email,
    challengeToken: challengeToken ?? this.challengeToken,
    enrolment: enrolment ?? this.enrolment,
    me: me ?? this.me,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
  );
}

final deskAuthRepositoryProvider = Provider<DeskAuthRepository>(
  (ref) => ApiDeskAuthRepository(
    ref.watch(hmApiProvider),
    ref.watch(deviceIdStoreProvider),
  ),
);

/// Desk sign-in state machine (U-desk domain model). The server decides who may enter; the UI only
/// shows what it says.
class DeskSignInController extends Notifier<DeskSignInState> {
  DeskAuthRepository get _repo => ref.read(deskAuthRepositoryProvider);

  @override
  DeskSignInState build() => const DeskSignInState();

  /// Restores a saved Desk session, or shows the email step.
  Future<void> start() async {
    try {
      if (await _repo.hasSession()) {
        final me = await _repo.me();
        state = DeskSignInState(step: DeskStep.home, me: me, email: me.email);
        return;
      }
    } on HmApiException {
      // Session expired or offline: sign in again.
    }
    state = const DeskSignInState(step: DeskStep.email);
  }

  Future<void> requestCode(String email) async {
    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      state = state.copyWith(error: 'Please enter a valid email address.');
      return;
    }
    await _run(() async {
      await _repo.requestCode(trimmed);
      state = state.copyWith(step: DeskStep.code, email: trimmed);
    });
  }

  Future<void> verifyCode(String code) => _run(() async {
    final outcome = await _repo.verifyCode(state.email, code);
    switch (outcome) {
      case OtpSessionOutcome():
        await _enterHome();
      case OtpDeskChallengeOutcome(:final challengeToken, :final totpEnrolled):
        if (totpEnrolled) {
          state = state.copyWith(
            step: DeskStep.totp,
            challengeToken: challengeToken,
          );
        } else {
          final enrolment = await _repo.enroll(challengeToken);
          state = state.copyWith(
            step: DeskStep.enroll,
            challengeToken: challengeToken,
            enrolment: enrolment,
          );
        }
    }
  });

  void continueToTotp() =>
      state = state.copyWith(step: DeskStep.totp, clearError: true);

  Future<void> verifyTotp(String code) => _run(() async {
    await _repo.verifyTotp(state.challengeToken!, code);
    await _enterHome();
  });

  Future<void> logout() async {
    try {
      await _repo.logout();
    } on HmApiException {
      // Forgotten locally anyway.
    }
    state = const DeskSignInState(step: DeskStep.email);
  }

  void startAgain() => state = const DeskSignInState(step: DeskStep.email);

  Future<void> _enterHome() async {
    final me = await _repo.me();
    state = state.copyWith(step: DeskStep.home, me: me);
  }

  Future<void> _run(Future<void> Function() body) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await body();
      state = state.copyWith(busy: false);
    } on HmApiException catch (e) {
      if (e.code == 'CHALLENGE_EXPIRED') {
        state = DeskSignInState(
          step: DeskStep.email,
          email: state.email,
          error: e.message,
        );
        return;
      }
      state = state.copyWith(busy: false, error: e.message);
    }
  }
}

final deskSignInProvider =
    NotifierProvider<DeskSignInController, DeskSignInState>(
      DeskSignInController.new,
    );
