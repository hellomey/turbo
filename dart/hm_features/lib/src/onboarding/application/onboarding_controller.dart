import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';

import '../../eligibility/domain/eligibility_view.dart';
import '../data/onboarding_repository.dart';
import '../domain/age_gate.dart';
import '../domain/profile_draft.dart';

/// §17.1 steps in Phase 1. Steps 6 (first lamp), 9–11 (plan, squad, alerts) arrive in Phase 2/3
/// (D-2026-10-20-14) and are skipped.
enum OnboardingStep {
  dob,
  under18,
  answers,
  result,
  pickExams,
  mapPreview,
  email,
  code,
  consent,
  done,
}

@immutable
class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.dob,
    this.draft = const ProfileDraft(),
    this.result,
    this.mainExam,
    this.otherExams = const [],
    this.email = '',
    this.resendAfterSeconds = 60,
    this.notice,
    this.consents = const {},
    this.signInOnly = false,
    this.busy = false,
    this.error,
  });

  static const maxOtherExams = 2;

  final OnboardingStep step;
  final ProfileDraft draft;
  final EligibilityView? result;
  final String? mainExam;
  final List<String> otherExams;
  final String email;
  final int resendAfterSeconds;
  final ConsentNoticeInfo? notice;

  /// Purpose wire value → ticked. Starts EMPTY: nothing is pre-ticked (§17.1 step 8).
  final Map<String, bool> consents;

  /// "I already have an account": email + code only.
  final bool signInOnly;
  final bool busy;

  /// Simple-English message to show on the current step.
  final String? error;

  bool get requiredConsentsGiven =>
      notice != null &&
      notice!.purposes
          .where((p) => p.required)
          .every((p) => consents[p.purpose] == true);

  OnboardingState copyWith({
    OnboardingStep? step,
    ProfileDraft? draft,
    EligibilityView? result,
    String? mainExam,
    List<String>? otherExams,
    String? email,
    int? resendAfterSeconds,
    ConsentNoticeInfo? notice,
    Map<String, bool>? consents,
    bool? signInOnly,
    bool? busy,
    String? error,
    bool clearError = false,
    bool clearMainExam = false,
  }) => OnboardingState(
    step: step ?? this.step,
    draft: draft ?? this.draft,
    result: result ?? this.result,
    mainExam: clearMainExam ? null : (mainExam ?? this.mainExam),
    otherExams: otherExams ?? this.otherExams,
    email: email ?? this.email,
    resendAfterSeconds: resendAfterSeconds ?? this.resendAfterSeconds,
    notice: notice ?? this.notice,
    consents: consents ?? this.consents,
    signInOnly: signInOnly ?? this.signInOnly,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
  );
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => ApiOnboardingRepository(
    ref.watch(hmApiProvider),
    ref.watch(deviceIdStoreProvider),
  ),
);

/// Drives onboarding. Holds every answer in memory only; nothing is stored or sent before the age check
/// passes, and the profile is saved only after sign-in and consent.
class OnboardingController extends Notifier<OnboardingState> {
  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  @override
  OnboardingState build() => const OnboardingState();

  /// Step 1. Under 18: the draft is wiped and the 18+ screen is shown.
  void submitDateOfBirth(DateTime dateOfBirth) {
    final now = ref.read(clockProvider)();
    if (!AgeGate.isAdult(dateOfBirth, now)) {
      state = const OnboardingState(step: OnboardingStep.under18);
      return;
    }
    state = state.copyWith(
      step: OnboardingStep.answers,
      draft: state.draft.copyWith(dateOfBirth: dateOfBirth),
      clearError: true,
    );
  }

  void restart() => state = const OnboardingState();

  void startSignIn() => state = const OnboardingState(
    step: OnboardingStep.email,
    signInOnly: true,
  );

  void back() {
    final s = state.step;
    final previous = switch (s) {
      OnboardingStep.answers => OnboardingStep.dob,
      OnboardingStep.result => OnboardingStep.answers,
      OnboardingStep.pickExams => OnboardingStep.result,
      OnboardingStep.mapPreview => OnboardingStep.pickExams,
      OnboardingStep.email =>
        state.signInOnly ? OnboardingStep.dob : OnboardingStep.mapPreview,
      OnboardingStep.code => OnboardingStep.email,
      _ => s,
    };
    if (previous == OnboardingStep.dob && state.signInOnly) {
      restart();
      return;
    }
    state = state.copyWith(step: previous, clearError: true);
  }

  // ---------------------------------------------------------------- step 2

  void setQualification(QualificationChoice q) =>
      state = state.copyWith(draft: state.draft.copyWith(qualification: q));

  void setDegreeSubject(String subject) => state = state.copyWith(
    draft: state.draft.copyWith(degreeSubject: subject),
  );

  void setCommunity(CommunityChoice c) =>
      state = state.copyWith(draft: state.draft.copyWith(community: c));

  void setPstm(bool pstm) =>
      state = state.copyWith(draft: state.draft.copyWith(pstm: pstm));

  void toggleSpecialCategory(SpecialCategoryChoice c) {
    final next = {...state.draft.specialCategories};
    next.contains(c) ? next.remove(c) : next.add(c);
    state = state.copyWith(
      draft: state.draft.copyWith(specialCategories: next),
    );
  }

  /// Step 3: ask the server. `UNDER_18` from the server shows the same 18+ screen.
  Future<void> checkEligibility() async {
    if (!state.draft.isComplete || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final result = await _repo.checkEligibility(state.draft);
      final keepMain =
          state.mainExam != null &&
          result.eligible.any((e) => e.code == state.mainExam);
      state = state.copyWith(
        step: OnboardingStep.result,
        result: result,
        busy: false,
        mainExam: keepMain ? state.mainExam : null,
        clearMainExam: !keepMain,
        otherExams: keepMain ? state.otherExams : const [],
      );
    } on HmApiException catch (e) {
      if (e.code == 'UNDER_18') {
        state = const OnboardingState(step: OnboardingStep.under18);
        return;
      }
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  // ---------------------------------------------------------------- step 4

  void continueToPickExams() {
    final result = state.result;
    if (result == null || result.eligible.isEmpty) return;
    state = state.copyWith(
      step: OnboardingStep.pickExams,
      mainExam: state.mainExam ?? result.eligible.first.code,
      clearError: true,
    );
  }

  void chooseMainExam(String code) => state = state.copyWith(
    mainExam: code,
    otherExams: state.otherExams.where((c) => c != code).toList(),
  );

  /// Up to 2 more exams besides the main one.
  void toggleOtherExam(String code) {
    if (code == state.mainExam) return;
    final others = [...state.otherExams];
    if (others.contains(code)) {
      others.remove(code);
    } else if (others.length < OnboardingState.maxOtherExams) {
      others.add(code);
    }
    state = state.copyWith(otherExams: others);
  }

  // ---------------------------------------------------------------- step 5

  void continueToMapPreview() {
    if (state.mainExam == null) return;
    state = state.copyWith(step: OnboardingStep.mapPreview);
  }

  void continueToSave() =>
      state = state.copyWith(step: OnboardingStep.email, clearError: true);

  // ---------------------------------------------------------------- step 7

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  Future<void> requestCode(String email) async {
    final trimmed = email.trim();
    if (!_email.hasMatch(trimmed)) {
      state = state.copyWith(error: 'Please enter a valid email address.');
      return;
    }
    state = state.copyWith(email: trimmed, busy: true, clearError: true);
    try {
      final seconds = await _repo.requestCode(trimmed);
      state = state.copyWith(
        step: OnboardingStep.code,
        resendAfterSeconds: seconds,
        busy: false,
      );
    } on HmApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  Future<void> resendCode() async {
    try {
      await _repo.requestCode(state.email);
      state = state.copyWith(clearError: true);
    } on HmApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> verifyCode(String code) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repo.verifyCode(state.email, code);
      if (state.signInOnly) {
        state = state.copyWith(step: OnboardingStep.done, busy: false);
        return;
      }
      final notice = await _repo.consentNotice();
      state = state.copyWith(
        step: OnboardingStep.consent,
        notice: notice,
        consents: const {},
        busy: false,
      );
    } on HmApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  // ---------------------------------------------------------------- step 8

  void setConsent(String purpose, bool granted) =>
      state = state.copyWith(consents: {...state.consents, purpose: granted});

  /// Records consent (every purpose: ticked = true, untouched = false), then saves answers and exams.
  Future<void> acceptConsents() async {
    final notice = state.notice;
    if (notice == null || !state.requiredConsentsGiven || state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repo.recordConsents(notice.version, {
        for (final p in notice.purposes)
          p.purpose: state.consents[p.purpose] == true,
      });
      await _repo.saveProfile(state.draft);
      await _repo.saveExams(state.mainExam!, state.otherExams);
      state = state.copyWith(step: OnboardingStep.done, busy: false);
    } on HmApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
