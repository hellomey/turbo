/**
 * Public API of the `users` module. Profile, settings, privacy controls, DPDP consent, data export and deletion.
 * Export use cases and types only. Never export repositories or Prisma models.
 */
import type { ConsentChoicesBody, ConsentNotice, z } from "@heymey/contracts";
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../shared/clock.js";
import type { Actor } from "../../shared/ports.js";
import type { AuditApi } from "../audit/index.js";
import type { ConsentRepository, ErasureHooks, Profile, RolesReader, SettingsPatch, UserRecord, UserRepository } from "./application/ports.js";
import * as svc from "./application/users-service.js";
import { PrismaConsentRepository, PrismaUserRepository } from "./infrastructure/prisma-users.js";

export const UsersModule = { name: "users" } as const;

export type {
  ConsentRepository,
  ConsentRow,
  ErasureHooks,
  Profile,
  RolesReader,
  SettingsPatch,
  UserRecord,
  UserRepository,
} from "./application/ports.js";
export type { ConsentStateView, MeView } from "./application/users-service.js";
export { CONSENT_NOTICE, DELETION_GRACE_DAYS, isAdultOn } from "./domain/rules.js";

export interface UsersApi {
  getMe(userId: string): Promise<svc.MeView>;
  updateMe(userId: string, patch: SettingsPatch): Promise<svc.MeView>;
  putProfile(userId: string, profile: Profile): Promise<svc.MeView>;
  consentNotice(): z.infer<typeof ConsentNotice>;
  getConsents(userId: string): Promise<svc.ConsentStateView>;
  recordConsents(userId: string, body: z.infer<typeof ConsentChoicesBody>): Promise<svc.ConsentStateView>;
  // used by auth
  getById(userId: string): Promise<UserRecord | null>;
  findByEmail(email: string): Promise<UserRecord | null>;
  findOrCreateByEmail(email: string): Promise<{ user: UserRecord; created: boolean }>;
  requestDeletion(userId: string, actor: Actor): Promise<Date>;
  cancelDeletion(userId: string): Promise<boolean>;
  // used by the worker
  /** Erases accounts past the 7-day grace; returns the ids actually erased. `hooks.beforeErase` runs before each. */
  eraseDueAccounts(hooks?: ErasureHooks): Promise<string[]>;
}

export type UsersModuleDeps = (
  | { prisma: PrismaClient }
  | { repositories: { users: UserRepository; consents: ConsentRepository } }
) & { audit: AuditApi; clock: Clock; roles: RolesReader };

export function createUsersModule(deps: UsersModuleDeps): UsersApi {
  const repos =
    "repositories" in deps
      ? deps.repositories
      : { users: new PrismaUserRepository(deps.prisma), consents: new PrismaConsentRepository(deps.prisma) };
  const d: svc.UsersDeps = { ...repos, roles: deps.roles, audit: deps.audit, clock: deps.clock };
  return {
    getMe: (id) => svc.getMe(d, id),
    updateMe: (id, patch) => svc.updateMe(d, id, patch),
    putProfile: (id, profile) => svc.putProfile(d, id, profile),
    consentNotice: () => svc.consentNotice(),
    getConsents: (id) => svc.getConsents(d, id),
    recordConsents: (id, body) => svc.recordConsents(d, id, body),
    getById: (id) => d.users.findById(id),
    findByEmail: (email) => d.users.findByEmail(email),
    findOrCreateByEmail: (email) => svc.findOrCreateByEmail(d, email),
    requestDeletion: (id, actor) => svc.requestDeletion(d, id, actor),
    cancelDeletion: (id) => svc.cancelDeletion(d, id),
    eraseDueAccounts: (hooks) => svc.eraseDueAccounts(d, hooks),
  };
}
