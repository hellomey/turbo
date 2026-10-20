-- Runs once on an empty data directory (local + fresh VPS). Prisma migrations also create these idempotently.
CREATE EXTENSION IF NOT EXISTS pg_trgm;           -- duplicate detection + search (blueprint §20.2)
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Separate databases for internal tools, so they never touch product tables.
CREATE DATABASE glitchtip;
CREATE DATABASE metabase_app;
