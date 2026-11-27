-- AlterTable (idempotent: the Supabase projects were created from hand-run SQL, so this may already exist)
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "isGuest" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ALTER COLUMN "email" DROP NOT NULL;
