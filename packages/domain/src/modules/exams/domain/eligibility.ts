import {
  OFFICIAL_CONFIRM_LINE,
  QUALIFICATIONS,
  type Community,
  type EligibilityResult,
  type ExamEligibility,
  type ProfileAnswers,
  type Qualification,
  type SpecialCategory,
  type z,
} from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import type { ExamRecord } from "./exam.js";

/**
 * The Eligibility Checker (blueprint §17.1 steps 1-3, §19.1 Q1/Q4). PURE: no I/O, no clock.
 * Everything exam-specific is data (EligibilityRule); this file never names an exam.
 * Design: aidlc/construction/units/U-exams/domain-model.md (invariants 1-9).
 */

export type Answers = z.infer<typeof ProfileAnswers>;
export type EligibilityResultDto = z.infer<typeof EligibilityResult>;
type ExamEligibilityDto = z.infer<typeof ExamEligibility>;
type Reason = ExamEligibilityDto["reasons"][number];

export interface EligibilityRuleRecord {
  version: number;
  status: string;
  /** YYYY-MM-DD: the notification's "age as on" date. */
  ageAsOf: string;
  minAge: number;
  /** null = no upper age limit for that community. A missing community falls back to "OC". */
  maxAgeByCommunity: Partial<Record<Community, number | null>>;
  relaxationYears: Partial<Record<SpecialCategory, number>>;
  qualifications: Qualification[];
  degreeSubjects: string[];
  pstmNote: string | null;
}

export interface ExamWithRule {
  exam: ExamRecord;
  /** The latest published rule (the repository may pass any; the engine re-checks `status`). */
  rule: EligibilityRuleRecord | null;
}

export const ADULT_AGE = 18;
export const ELIGIBILITY_DISCLAIMER = `This list is a guide based on your answers. ${OFFICIAL_CONFIRM_LINE}`;

const CATEGORY_TEXT: Record<SpecialCategory, string> = {
  PWD: "persons with disability",
  EX_SERVICEMAN: "ex-servicemen",
  DESTITUTE_WIDOW: "destitute widows",
};

const QUALIFICATION_TEXT: Record<Qualification, string> = {
  sslc: "Class 10 (SSLC)",
  hsc: "Class 12 (HSC)",
  iti: "ITI",
  diploma: "a diploma",
  degree: "a degree",
  pg: "a postgraduate degree",
};

const MONTHS = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
];

/** "2026-07-01" -> "1 July 2026". */
export function formatDate(day: string): string {
  const [y, m, d] = day.split("-").map(Number) as [number, number, number];
  return `${d} ${MONTHS[m - 1]} ${y}`;
}

/** Completed years on `on` (both YYYY-MM-DD). A birthday exactly on `on` counts. */
export function completedYears(dateOfBirth: string, on: string): number {
  const years = Number(on.slice(0, 4)) - Number(dateOfBirth.slice(0, 4));
  return on.slice(5) < dateOfBirth.slice(5) ? years - 1 : years;
}

export const qualificationLevel = (q: Qualification): number => QUALIFICATIONS.indexOf(q);

/** Throws UNDER_18 if the person is under 18 on `todayIst` (Asia/Kolkata calendar day). */
export function assertAdult(dateOfBirth: string, todayIst: string): void {
  if (completedYears(dateOfBirth, todayIst) < ADULT_AGE) throw new DomainError("UNDER_18");
}

interface Evaluated {
  exam: ExamRecord;
  eligible: boolean;
  reasons: Reason[];
  ageLimit: ExamEligibilityDto["ageLimit"];
  /** Candidate level minus the exam's minimum level (0 = exact match). */
  qualificationGap: number;
  /** Years left before the upper limit; Infinity when there is none. */
  headroom: number;
}

function evaluate(answers: Answers, exam: ExamRecord, rule: EligibilityRuleRecord): Evaluated {
  const reasons: Reason[] = [];
  const asOf = formatDate(rule.ageAsOf);
  const age = completedYears(answers.dateOfBirth, rule.ageAsOf);

  // ---- age (invariants 2, 3)
  const community = answers.community;
  const baseMax = community in rule.maxAgeByCommunity ? rule.maxAgeByCommunity[community] : rule.maxAgeByCommunity.OC;
  const base = baseMax ?? null;
  let relaxation = 0;
  let relaxedFor: SpecialCategory | null = null;
  if (base !== null) {
    // The LARGEST single relaxation applies; relaxations do not add up (documented choice, U-exams Q-E2).
    for (const cat of answers.specialCategories ?? []) {
      const years = rule.relaxationYears[cat] ?? 0;
      if (years > relaxation) {
        relaxation = years;
        relaxedFor = cat;
      }
    }
  }
  const max = base === null ? null : base + relaxation;
  let ageOk = true;
  if (age < rule.minAge) {
    ageOk = false;
    reasons.push({ code: "AGE_TOO_LOW", text: `You must be at least ${rule.minAge} on ${asOf}. Your age on that date: ${age}.` });
  } else if (max !== null && age > max) {
    ageOk = false;
    reasons.push({ code: "AGE_TOO_HIGH", text: `The age limit is ${max} on ${asOf}. Your age on that date: ${age}.` });
  } else if (max === null) {
    reasons.push({ code: "AGE_OK", text: `Your age fits: ${rule.minAge} or older on ${asOf}. There is no upper age limit for you.` });
  } else {
    reasons.push({ code: "AGE_OK", text: `Your age fits: ${rule.minAge} to ${max} on ${asOf}.` });
  }
  if (relaxedFor && relaxation > 0) {
    reasons.push({
      code: "AGE_RELAXATION_APPLIED",
      text: `Age limit raised by ${relaxation} years for ${CATEGORY_TEXT[relaxedFor]}.`,
    });
  }

  // ---- qualification (invariants 4, 5)
  const accepted = rule.qualifications.length ? rule.qualifications : [exam.minQualification];
  const minLevel = Math.min(...accepted.map(qualificationLevel));
  const minQualification = QUALIFICATIONS[minLevel] as Qualification;
  const level = qualificationLevel(answers.qualification);
  let qualificationOk = level >= minLevel;
  if (qualificationOk) {
    reasons.push({ code: "QUALIFICATION_OK", text: `Your qualification fits: ${QUALIFICATION_TEXT[minQualification]} or higher is needed.` });
  } else {
    reasons.push({ code: "QUALIFICATION_TOO_LOW", text: `This exam needs ${QUALIFICATION_TEXT[minQualification]} or higher.` });
  }
  if (qualificationOk && rule.degreeSubjects.length && level >= qualificationLevel("degree")) {
    const subject = answers.degreeSubject?.trim().toLowerCase() ?? "";
    if (!rule.degreeSubjects.some((s) => s.trim().toLowerCase() === subject)) {
      qualificationOk = false;
      reasons.push({
        code: "DEGREE_SUBJECT_REQUIRED",
        text: `This exam needs a degree in one of these subjects: ${rule.degreeSubjects.join(", ")}.`,
      });
    }
  }

  // ---- PSTM (invariant 6): information only
  if (answers.pstm && rule.pstmNote) reasons.push({ code: "PSTM_PREFERENCE", text: rule.pstmNote });

  return {
    exam,
    eligible: ageOk && qualificationOk,
    reasons,
    ageLimit: { min: rule.minAge, max, asOf: rule.ageAsOf },
    qualificationGap: level - minLevel,
    headroom: max === null ? Number.POSITIVE_INFINITY : max - age,
  };
}

/** Invariant 8: launch exams first, closest qualification, more age headroom, then name. */
function byFit(a: Evaluated, b: Evaluated): number {
  if (a.exam.fullPrep !== b.exam.fullPrep) return a.exam.fullPrep ? -1 : 1;
  const gap = Math.abs(a.qualificationGap) - Math.abs(b.qualificationGap);
  if (gap !== 0) return gap;
  if (a.headroom !== b.headroom) return a.headroom > b.headroom ? -1 : 1;
  return a.exam.name.localeCompare(b.exam.name);
}

const toDto = (e: Evaluated, index: number): ExamEligibilityDto => ({
  examCode: e.exam.code,
  examName: e.exam.name,
  conductingBody: e.exam.conductingBody,
  eligible: e.eligible,
  fitRank: index + 1,
  reasons: e.reasons,
  ageLimit: e.ageLimit,
  officialNotificationUrl: e.exam.notificationUrl ?? e.exam.officialUrl,
});

/**
 * Check every published exam that has a published rule. `todayIst` is the Asia/Kolkata calendar day
 * (`istDayKey(clock.now())`). Throws DomainError("UNDER_18") before looking at any exam.
 */
export function checkEligibility(answers: Answers, todayIst: string, exams: readonly ExamWithRule[]): EligibilityResultDto {
  assertAdult(answers.dateOfBirth, todayIst);
  const evaluated = exams
    .filter((x): x is { exam: ExamRecord; rule: EligibilityRuleRecord } => x.exam.status === "published" && x.rule?.status === "published")
    .map((x) => evaluate(answers, x.exam, x.rule));
  const eligible = evaluated.filter((e) => e.eligible).sort(byFit).map(toDto);
  const notEligible = evaluated.filter((e) => !e.eligible).sort(byFit).map(toDto);
  return { eligibleCount: eligible.length, eligible, notEligible, disclaimer: ELIGIBILITY_DISCLAIMER };
}
