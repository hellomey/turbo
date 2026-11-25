-- Make a real person Desk staff (staging). Run in the Supabase SQL editor.
-- 1. Sign in once in the mobile app or Desk with the email below, so the user row exists.
-- 2. Replace you@example.com with that email (lower case) and choose the role: ADMIN, OPS, SUPPORT_AGENT, MODERATOR,
--    REVIEWER, PUBLISHER, CREATOR or INSTITUTION_ADMIN.
-- 3. Run. Then sign in at the Desk: it asks you to set up an authenticator app (TOTP) on first sign-in.
-- Safe to run twice: it skips a role the user already holds. Every grant is written to the audit log.

with target as (
  select id from "User" where email = lower(trim('you@example.com')) and "deletedAt" is null
), granted as (
  insert into "RoleAssignment" ("id", "userId", "role", "grantedBy", "grantedAt")
  select gen_random_uuid(), t.id, 'ADMIN'::"Role", t.id, now()
  from target t
  where not exists (
    select 1 from "RoleAssignment" r
    where r."userId" = t.id and r."role" = 'ADMIN'::"Role" and r."revokedAt" is null and r."scopeId" is null
  )
  returning "userId", "role"
)
insert into "AuditLog" ("actorId", "actorRole", "action", "target", "after")
select null, 'SYSTEM', 'role.grant', 'user:' || g."userId", jsonb_build_object('role', g."role", 'source', 'sql')
from granted g;

-- Check: should list the role.
select u.email, r.role, r."grantedAt" from "RoleAssignment" r join "User" u on u.id = r."userId"
where u.email = lower(trim('you@example.com')) and r."revokedAt" is null;
