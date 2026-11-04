-- SEC-P2-L2 (BOLT-0020): offline-sync dedupe on StudyLog.clientActionId is per user, not global.
-- Additive-safe: the new composite unique index is created first; the old global one is a strictly stronger
-- constraint, so every existing row already satisfies the new one. Dropping it only relaxes a constraint.
CREATE UNIQUE INDEX "StudyLog_userId_clientActionId_key" ON "StudyLog"("userId", "clientActionId");
DROP INDEX "StudyLog_clientActionId_key";
