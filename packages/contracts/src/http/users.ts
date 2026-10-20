import { z } from "../zod.js";
import { CalendarDate } from "./common.js";
import { Community, District, Qualification, Role, SpecialCategory } from "./reference.js";

/** Eligibility profile answers from onboarding (§17.1 step 2). Stored only after sign-in, with consent. */
export const ProfileAnswers = z
  .object({
    dateOfBirth: CalendarDate,
    qualification: Qualification,
    degreeSubject: z.string().max(80).optional(),
    community: Community,
    pstm: z.boolean().openapi({ description: "Studied in Tamil medium (PSTM)" }),
    specialCategories: z.array(SpecialCategory).max(3).default([]),
  })
  .openapi("ProfileAnswers");

export const Me = z
  .object({
    id: z.uuid(),
    email: z.email(),
    nickname: z.string().nullable(),
    district: District.nullable(),
    calmMode: z.boolean(),
    liteMode: z.boolean().nullable().openapi({ description: "null = automatic (3 GB RAM or less)" }),
    hideFromLeaderboards: z.boolean(),
    profile: ProfileAnswers.nullable(),
    roles: z.array(Role),
    deletionScheduledFor: z.iso.datetime().nullable(),
    createdAt: z.iso.datetime(),
  })
  .openapi("Me");

/** Nicknames: 3-24 letters, digits, spaces, dot, underscore. No phone numbers or links (§18). */
export const Nickname = z
  .string()
  .trim()
  .min(3)
  .max(24)
  .regex(/^[A-Za-z0-9 ._]+$/);

export const UpdateMeBody = z
  .object({
    nickname: Nickname.optional(),
    district: District.optional(),
    calmMode: z.boolean().optional(),
    liteMode: z.boolean().nullable().optional(),
    hideFromLeaderboards: z.boolean().optional(),
  })
  .openapi("UpdateMeBody");

export const ConsentPurpose = z
  .enum(["core_service", "offers_email", "product_research", "share_with_supporters", "share_with_institution"])
  .openapi("ConsentPurpose");

export const ConsentNotice = z
  .object({
    version: z.string(),
    purposes: z.array(
      z.object({
        purpose: ConsentPurpose,
        required: z.boolean(),
        title: z.string(),
        description: z.string(),
      }),
    ),
  })
  .openapi("ConsentNotice");

export const ConsentChoicesBody = z
  .object({
    noticeVersion: z.string(),
    choices: z.array(z.object({ purpose: ConsentPurpose, granted: z.boolean() })).min(1),
  })
  .openapi("ConsentChoicesBody");

export const ConsentState = z
  .object({
    noticeVersion: z.string().nullable(),
    choices: z.array(z.object({ purpose: ConsentPurpose, granted: z.boolean(), at: z.iso.datetime() })),
  })
  .openapi("ConsentState");
