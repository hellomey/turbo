import type { ConsentChoicesBody, ConsentNotice, ConsentState, Me, z } from "@heymey/contracts";
import { istDayKey, type Clock } from "../../../shared/clock.js";
import { DomainError } from "../../../shared/errors.js";
import type { Actor } from "../../../shared/ports.js";
import type { AuditApi } from "../../audit/index.js";
import {
  CONSENT_NOTICE,
  assertAdult,
  deletionScheduledFor,
  erasedEmail,
  erasureCutoff,
  validateConsentChoices,
} from "../domain/rules.js";
import type { ConsentRepository, ErasureHooks, Profile, RolesReader, SettingsPatch, UserRecord, UserRepository } from "./ports.js";

export type MeView = z.infer<typeof Me>;
export type ConsentStateView = z.infer<typeof ConsentState>;

export interface UsersDeps {
  users: UserRepository;
  consents: ConsentRepository;
  roles: RolesReader;
  audit: AuditApi;
  clock: Clock;
}

const SYSTEM: Actor = { userId: null, role: "SYSTEM" };

async function load(deps: UsersDeps, userId: string): Promise<UserRecord> {
  const user = await deps.users.findById(userId);
  if (!user || user.deletedAt) throw new DomainError("NOT_FOUND");
  return user;
}

export async function getMe(deps: UsersDeps, userId: string): Promise<MeView> {
  const user = await load(deps, userId);
  const [profile, roles] = await Promise.all([deps.users.getProfile(userId), deps.roles.rolesOf(userId)]);
  return {
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    district: user.district,
    calmMode: user.calmMode,
    liteMode: user.liteMode,
    hideFromLeaderboards: user.hideFromLeaderboards,
    profile,
    roles,
    deletionScheduledFor: user.deletionRequestedAt ? deletionScheduledFor(user.deletionRequestedAt).toISOString() : null,
    createdAt: user.createdAt.toISOString(),
  };
}

export async function updateMe(deps: UsersDeps, userId: string, patch: SettingsPatch): Promise<MeView> {
  await load(deps, userId);
  const clean: SettingsPatch = {};
  for (const k of ["nickname", "district", "calmMode", "liteMode", "hideFromLeaderboards"] as const) {
    if (patch[k] !== undefined) (clean as Record<string, unknown>)[k] = patch[k];
  }
  if (Object.keys(clean).length) await deps.users.update(userId, clean);
  return getMe(deps, userId);
}

/** §17.1 step 1-2: answers saved after sign-in; 18+ on today's IST date or UNDER_18 and nothing is stored. */
export async function putProfile(deps: UsersDeps, userId: string, profile: Profile): Promise<MeView> {
  await load(deps, userId);
  assertAdult(profile.dateOfBirth, istDayKey(deps.clock.now()));
  await deps.users.saveProfile(userId, { ...profile, specialCategories: profile.specialCategories ?? [] });
  return getMe(deps, userId);
}

export function consentNotice(): z.infer<typeof ConsentNotice> {
  return CONSENT_NOTICE;
}

export async function getConsents(deps: UsersDeps, userId: string): Promise<ConsentStateView> {
  const rows = await deps.consents.latest(userId);
  const newest = rows.reduce<(typeof rows)[number] | null>((a, r) => (!a || r.at > a.at ? r : a), null);
  return {
    noticeVersion: newest?.noticeVersion ?? null,
    choices: rows.map((r) => ({ purpose: r.purpose, granted: r.granted, at: r.at.toISOString() })),
  };
}

export async function recordConsents(
  deps: UsersDeps,
  userId: string,
  body: z.infer<typeof ConsentChoicesBody>,
): Promise<ConsentStateView> {
  await load(deps, userId);
  const choices = validateConsentChoices(body);
  const at = deps.clock.now();
  await deps.consents.append(
    userId,
    choices.map((c) => ({ purpose: c.purpose, granted: c.granted, noticeVersion: body.noticeVersion, at })),
  );
  return getConsents(deps, userId);
}

// ---------------------------------------------------------------- used by auth

export async function findOrCreateByEmail(deps: UsersDeps, email: string): Promise<{ user: UserRecord; created: boolean }> {
  const existing = await deps.users.findByEmail(email);
  if (existing) return { user: existing, created: false };
  return deps.users.create(email);
}

/** §38.7: confirmed by OTP (auth). Keeps the first request date if asked again. */
export async function requestDeletion(deps: UsersDeps, userId: string, actor: Actor): Promise<Date> {
  const user = await load(deps, userId);
  if (user.deletionRequestedAt) return deletionScheduledFor(user.deletionRequestedAt);
  const now = deps.clock.now();
  await deps.users.setDeletionRequestedAt(userId, now);
  const scheduledFor = deletionScheduledFor(now);
  await deps.audit.record({
    actor,
    action: "users.deletion_requested",
    target: `user:${userId}`,
    after: { scheduledFor: scheduledFor.toISOString() },
  });
  return scheduledFor;
}

/** Signing in during the grace period cancels the deletion. Returns true if one was pending. */
export async function cancelDeletion(deps: UsersDeps, userId: string): Promise<boolean> {
  const user = await deps.users.findById(userId);
  if (!user?.deletionRequestedAt || user.deletedAt) return false;
  await deps.users.setDeletionRequestedAt(userId, null);
  await deps.audit.record({ actor: { userId, role: "ASPIRANT" }, action: "users.deletion_cancelled", target: `user:${userId}` });
  return true;
}

/** Daily job (`users.deletion`): erase accounts past the 7-day grace. Idempotent. Returns erased ids. */
export async function eraseDueAccounts(deps: UsersDeps, hooks: ErasureHooks = {}, batch = 500): Promise<string[]> {
  const now = deps.clock.now();
  const cutoff = erasureCutoff(now);
  const ids = await deps.users.dueForErasure(cutoff, batch);
  const erased: string[] = [];
  for (const id of ids) {
    const user = await deps.users.findById(id);
    if (!user || user.deletedAt) continue;
    // Other modules' copies of the email (OTP rows) go BEFORE the email itself is replaced (SEC-M3a).
    await hooks.beforeErase?.({ id, email: user.email });
    // Re-checked atomically: a user who signed in (cancelled) since dueForErasure is skipped (SEC-M3b).
    if (!(await deps.users.erase(id, erasedEmail(id), now, cutoff))) continue;
    await deps.audit.record({ actor: SYSTEM, action: "users.erased", target: `user:${id}` });
    erased.push(id);
  }
  return erased;
}
