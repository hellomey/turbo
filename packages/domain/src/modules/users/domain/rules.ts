import type { ConsentChoicesBody, ConsentNotice, ConsentPurpose } from "@heymey/contracts";
import type { z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";

type Notice = z.infer<typeof ConsentNotice>;
type Purpose = z.infer<typeof ConsentPurpose>;
type Choices = z.infer<typeof ConsentChoicesBody>;

/** Minimum age to use HeyMey (blueprint §17.1 step 1, §18 "Under-18 users"). */
export const MIN_AGE_YEARS = 18;
/** Grace period between a confirmed deletion request and erasure (§38.7). */
export const DELETION_GRACE_DAYS = 7;
const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * True if someone born on `dateOfBirth` (YYYY-MM-DD) is at least 18 on `today` (YYYY-MM-DD, Asia/Kolkata).
 * The 18th birthday is the same month-day 18 years later; a 29 Feb birthday becomes adult on 1 March in
 * non-leap years (plain string comparison does exactly that).
 */
export function isAdultOn(dateOfBirth: string, today: string): boolean {
  const [y, md] = [Number(dateOfBirth.slice(0, 4)), dateOfBirth.slice(4)];
  const eighteenth = `${String(y + MIN_AGE_YEARS).padStart(4, "0")}${md}`;
  return today >= eighteenth;
}

export function assertAdult(dateOfBirth: string, today: string): void {
  if (!isAdultOn(dateOfBirth, today)) throw new DomainError("UNDER_18");
}

export function deletionScheduledFor(requestedAt: Date): Date {
  return new Date(requestedAt.getTime() + DELETION_GRACE_DAYS * DAY_MS);
}

/** Users whose deletion was requested at or before this instant are due for erasure now. */
export function erasureCutoff(now: Date): Date {
  return new Date(now.getTime() - DELETION_GRACE_DAYS * DAY_MS);
}

/** The email an erased account keeps (unique, undeliverable, no personal data). */
export function erasedEmail(userId: string): string {
  return `deleted+${userId}@invalid.heymey.app`;
}

/** The current DPDP notice (§17.1 step 8, §23, §30). Simple English. Nothing is pre-ticked: the app starts unticked. */
export const CONSENT_NOTICE: Notice = {
  // v2 (BOLT-0006 compliance C2, M4, M5): every personal-data field is named with its purpose.
  version: "2026-10-v2",
  purposes: [
    {
      purpose: "core_service",
      required: true,
      title: "Run my HeyMey account",
      description:
        "We use your email, date of birth, qualification, community, special categories (if you chose any), exam choices, study progress and basic app usage. We use them to check which exams you can write, and to give you lessons, practice and your Study Map. HeyMey can't work without this.",
    },
    {
      purpose: "offers_email",
      required: false,
      title: "Emails about offers",
      description: "Sometimes we email you about Pro, Exam Pass or new features. You can stop this any time.",
    },
    {
      purpose: "product_research",
      required: false,
      title: "Help us improve HeyMey",
      description: "We may invite you to short surveys or calls to make HeyMey better.",
    },
    {
      purpose: "share_with_supporters",
      required: false,
      title: "Share progress with my supporters",
      description: "People you invite as supporters (parent, spouse, friend) can see your study progress. Never your messages.",
    },
    {
      purpose: "share_with_institution",
      required: false,
      title: "Share progress with my institution",
      description:
        "If you later join a coaching centre or college, we will ask you again before they can see your study progress and mock results.",
    },
  ],
};

/** Validates a consent submission against the current notice. Returns the choices to append. */
export function validateConsentChoices(body: Choices, notice: Notice = CONSENT_NOTICE): Choices["choices"] {
  if (body.noticeVersion !== notice.version) {
    throw new DomainError("VALIDATION_FAILED", { field: "noticeVersion", reason: "not the current notice" });
  }
  const seen = new Set<Purpose>();
  for (const c of body.choices) {
    if (seen.has(c.purpose)) throw new DomainError("VALIDATION_FAILED", { field: "choices", reason: "purpose listed twice" });
    seen.add(c.purpose);
  }
  for (const p of notice.purposes.filter((x) => x.required)) {
    const choice = body.choices.find((c) => c.purpose === p.purpose);
    if (!choice?.granted) throw new DomainError("CONSENT_REQUIRED", { purpose: p.purpose });
  }
  return body.choices;
}
