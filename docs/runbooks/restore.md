# Restore PostgreSQL

Drill: **monthly**, on staging, timed. Record the time and result in `aidlc/operations/`.

1. Pick the target: latest, or a time before the problem (IST, e.g. `"2026-10-20 13:00+05:30"`).
2. `infra/scripts/restore.sh ["<time>"]` stops app services, restores with pgBackRest (delta), promotes, restarts.
3. Verify:
   - [ ] `/v1/health` 200 on api; realtime and worker healthy
   - [ ] row counts of `User`, `SparksLedger`, `Purchase` are plausible vs. the previous day's metrics
   - [ ] latest `AuditLog` timestamp is close to the target time
   - [ ] a test sign-in works on staging
4. If a real incident: reconcile purchases after the restore point with the stores' server notifications (they are re-sent / re-queryable) so no paid user loses access.
