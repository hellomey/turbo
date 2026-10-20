import type { ConsentPurpose, District, ProfileAnswers, Role, z } from "@heymey/contracts";

export type Profile = z.infer<typeof ProfileAnswers>;
export type Purpose = z.infer<typeof ConsentPurpose>;

export interface UserRecord {
  id: string;
  email: string;
  nickname: string | null;
  district: District | null;
  calmMode: boolean;
  liteMode: boolean | null;
  hideFromLeaderboards: boolean;
  createdAt: Date;
  deletionRequestedAt: Date | null;
  deletedAt: Date | null;
}

export interface SettingsPatch {
  nickname?: string;
  district?: District;
  calmMode?: boolean;
  liteMode?: boolean | null;
  hideFromLeaderboards?: boolean;
}

export interface ConsentRow {
  purpose: Purpose;
  granted: boolean;
  noticeVersion: string;
  at: Date;
}

/** Port: the users table + profile (Prisma in production, in-memory in unit tests). */
export interface UserRepository {
  findById(id: string): Promise<UserRecord | null>;
  findByEmail(email: string): Promise<UserRecord | null>;
  /** Creates the user; if the email already exists (race), returns the existing one with created=false. */
  create(email: string): Promise<{ user: UserRecord; created: boolean }>;
  update(id: string, patch: SettingsPatch): Promise<UserRecord>;
  getProfile(userId: string): Promise<Profile | null>;
  saveProfile(userId: string, profile: Profile): Promise<void>;
  setDeletionRequestedAt(id: string, at: Date | null): Promise<void>;
  /** Users with a deletion request at or before `cutoff` and not yet erased. */
  dueForErasure(cutoff: Date, limit: number): Promise<string[]>;
  /**
   * Erases personal data (email, nickname, district, profile, consents) and sets deletedAt, atomically and ONLY if
   * the user is still due (deletion requested at or before `cutoff`, not erased). False = skipped (SEC-M3).
   */
  erase(id: string, erasedEmail: string, at: Date, cutoff: Date): Promise<boolean>;
}

/**
 * Called for each due account just before its email is replaced (filled by the composition root; users does not
 * depend on auth). The worker purges the account's OTP rows here (SEC-M3, §38.7).
 */
export interface ErasureHooks {
  beforeErase?(user: { id: string; email: string }): Promise<void>;
}

/** Port: append-only consent rows. */
export interface ConsentRepository {
  append(userId: string, rows: ConsentRow[]): Promise<void>;
  /** Latest row per purpose. */
  latest(userId: string): Promise<ConsentRow[]>;
}

/** Port filled by the composition root with the roles API (users does not depend on roles). */
export interface RolesReader {
  rolesOf(userId: string): Promise<Role[]>;
}
