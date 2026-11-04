# Restore PostgreSQL

Drill: **monthly**, on staging, timed. Record the time and result in `aidlc/operations/`.

Setup (ADR-0014, BOLT-0023): Postgres is on **Supabase**. Backups are `pg_dump` (custom format) files, encrypted
with age and stored in Cloudflare R2 `heymey-backups` under `pg/<stack>/YYYY/MM/DD/HHMMSS.dump.age`: one nightly
(02:30 IST, compose service `backup`) and one before every production migration. Retention 35 days (R2 lifecycle).
There is **no point-in-time recovery** on Supabase Free: the restore point is the newest dump before the problem
(Supabase Pro adds daily backups on their side). The age **private** key is kept offline by the founder.

1. Pick the dump: the newest one before the problem (R2 → `heymey-backups` → `pg/production/…`; times are IST).
2. Bring the age private key to the VM for this restore only.
   - **Drill (monthly):** create a throwaway Supabase project, then
     `RESTORE_TARGET_URL=<its direct URL> infra/scripts/restore.sh drill ~/backup-age.key [key]`. No app service is
     touched; delete the throwaway project afterwards. Staging never receives real data.
   - **Incident:** `infra/scripts/restore.sh production ~/backup-age.key <key>` stops api/realtime/worker/scheduler,
     restores into production via `DIRECT_URL` (`pg_restore --clean`), then starts them again.
3. `shred -u ~/backup-age.key` when done.
3. Verify:
   - [ ] `/v1/health` 200 on api; realtime and worker healthy
   - [ ] row counts of `User`, `SparksLedger`, `Purchase` are plausible vs. the previous day's metrics
   - [ ] latest `AuditLog` timestamp is close to the target time
   - [ ] a test sign-in works on staging
4. Verify for the drill too (run the row-count and `AuditLog` checks against the throwaway project).
5. If a real incident: reconcile purchases after the restore point with the stores' server notifications (they are re-sent / re-queryable) so no paid user loses access.
