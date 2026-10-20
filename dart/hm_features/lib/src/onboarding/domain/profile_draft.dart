import 'package:flutter/foundation.dart';
import 'package:hm_core/hm_core.dart';

/// Highest completed qualification (contract `Qualification`, lowest to highest).
enum QualificationChoice {
  sslc('sslc', 'SSLC (10th)'),
  hsc('hsc', 'HSC (12th)'),
  iti('iti', 'ITI'),
  diploma('diploma', 'Diploma'),
  degree('degree', 'Degree'),
  pg('pg', 'Postgraduate (PG)');

  const QualificationChoice(this.wire, this.label);
  final String wire;
  final String label;

  /// Only degree holders are asked for a subject (optional).
  bool get asksDegreeSubject =>
      this == QualificationChoice.degree || this == QualificationChoice.pg;
}

/// Tamil Nadu community categories used in TNPSC notifications (contract `Community`).
enum CommunityChoice {
  oc('OC', 'OC', 'Open Competition'),
  bc('BC', 'BC', 'Backward Class'),
  bcm('BCM', 'BCM', 'Backward Class (Muslim)'),
  mbcDnc('MBC_DNC', 'MBC / DNC', 'Most Backward Class / Denotified Community'),
  sc('SC', 'SC', 'Scheduled Caste'),
  sca('SCA', 'SCA', 'Scheduled Caste (Arunthathiyar)'),
  st('ST', 'ST', 'Scheduled Tribe');

  const CommunityChoice(this.wire, this.label, this.meaning);
  final String wire;
  final String label;

  /// Tap-to-see meaning (§10.2).
  final String meaning;
}

/// Optional special categories (contract `SpecialCategory`).
enum SpecialCategoryChoice {
  pwd('PWD', 'Person with disability'),
  exServiceman('EX_SERVICEMAN', 'Ex-serviceman'),
  destituteWidow('DESTITUTE_WIDOW', 'Destitute widow');

  const SpecialCategoryChoice(this.wire, this.label);
  final String wire;
  final String label;
}

/// The onboarding answers (§17.1 step 2). Lives only in memory until the user signs in and consents.
@immutable
class ProfileDraft {
  const ProfileDraft({
    this.dateOfBirth,
    this.qualification,
    this.degreeSubject = '',
    this.community,
    this.pstm,
    this.specialCategories = const {},
  });

  final DateTime? dateOfBirth;
  final QualificationChoice? qualification;
  final String degreeSubject;
  final CommunityChoice? community;

  /// Studied in Tamil medium (PSTM).
  final bool? pstm;
  final Set<SpecialCategoryChoice> specialCategories;

  bool get isComplete =>
      dateOfBirth != null &&
      qualification != null &&
      community != null &&
      pstm != null;

  ProfileDraft copyWith({
    DateTime? dateOfBirth,
    QualificationChoice? qualification,
    String? degreeSubject,
    CommunityChoice? community,
    bool? pstm,
    Set<SpecialCategoryChoice>? specialCategories,
  }) => ProfileDraft(
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    qualification: qualification ?? this.qualification,
    degreeSubject: degreeSubject ?? this.degreeSubject,
    community: community ?? this.community,
    pstm: pstm ?? this.pstm,
    specialCategories: specialCategories ?? this.specialCategories,
  );

  /// The contract body. Call only when [isComplete].
  ProfileAnswersInput toInput() {
    final q = qualification!;
    return ProfileAnswersInput(
      dateOfBirth: dateOfBirth!,
      qualification: q.wire,
      degreeSubject: q.asksDegreeSubject ? degreeSubject : null,
      community: community!.wire,
      pstm: pstm!,
      specialCategories: [
        for (final c in SpecialCategoryChoice.values)
          if (specialCategories.contains(c)) c.wire,
      ],
    );
  }
}
