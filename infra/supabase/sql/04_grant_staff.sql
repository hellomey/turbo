-- Make a real person Desk staff (staging). Run in the Supabase SQL editor.
-- Change the email and role in the "params" line, and the email in the check at the bottom. Roles: ADMIN, OPS,
-- SUPPORT_AGENT, MODERATOR, REVIEWER, PUBLISHER, CREATOR, INSTITUTION_ADMIN.
-- Creates the user if they have never signed in, grants the role if missing, and writes an audit row.
-- Safe to run twice. Then sign in at the Desk: it asks you to set up an authenticator app (TOTP) the first time.

with params as (
  select lower(trim('heymeyapp@gmail.com')) as email, 'ADMIN'::"Role" as role
), new_user as (
  insert into "User" ("id", "email", "createdAt", "updatedAt")
  select gen_random_uuid(), p.email, now(), now() from params p
  on conflict ("email") do nothing
  returning "id"
), target as (
  select id from new_user
  union
  select u.id from "User" u join params p on u.email = p.email where u."deletedAt" is null
), granted as (
  insert into "RoleAssignment" ("id", "userId", "role", "grantedBy", "grantedAt")
  select gen_random_uuid(), t.id, p.role, t.id, now()
  from target t, params p
  where not exists (
    select 1 from "RoleAssignment" r
    where r."userId" = t.id and r."role" = p.role and r."revokedAt" is null and r."scopeId" is null
  )
  returning "userId", "role"
)
insert into "AuditLog" ("actorId", "actorRole", "action", "target", "after")
select null, 'SYSTEM', 'role.grant', 'user:' || g."userId", jsonb_build_object('role', g."role", 'source', 'sql')
from granted g;

-- Check: must show one row with the role. If it shows nothing, the grant did not happen.
select u.email, r.role, r."grantedAt"
from "RoleAssignment" r join "User" u on u.id = r."userId"
where u.email = lower(trim('heymeyapp@gmail.com')) and r."revokedAt" is null;
