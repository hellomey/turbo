-- SEC-P2-L2 follow-up: offline-sync dedupe on RingEvent and PracticeAnswer is per (userId, clientActionId), not global.
-- Pending architect approval (aidlc/decisions.md).

-- RingEvent: add the per-user unique index first, then drop the stronger global one (only relaxes a constraint).
CREATE UNIQUE INDEX "RingEvent_userId_clientActionId_key" ON "RingEvent"("userId", "clientActionId");
DROP INDEX "RingEvent_clientActionId_key";

-- PracticeAnswer: the row id WAS the clientActionId (a global primary key). Add a clientActionId column, backfill it
-- from id (so existing rows keep their dedupe key), then add the per-user unique index. The id stays the primary key
-- but new rows get a server-generated id, so a client UUID no longer collides across users.
ALTER TABLE "PracticeAnswer" ADD COLUMN "clientActionId" UUID;
UPDATE "PracticeAnswer" SET "clientActionId" = "id" WHERE "clientActionId" IS NULL;
ALTER TABLE "PracticeAnswer" ALTER COLUMN "clientActionId" SET NOT NULL;
CREATE UNIQUE INDEX "PracticeAnswer_userId_clientActionId_key" ON "PracticeAnswer"("userId", "clientActionId");
