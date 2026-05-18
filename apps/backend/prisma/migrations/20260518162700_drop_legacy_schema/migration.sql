-- Remove the imported legacy archive schema from the active development
-- database. The runtime Prisma schema only owns the public schema; any legacy
-- rows that were needed have already been merged into public by the baseline
-- import script.
DROP SCHEMA IF EXISTS "legacy" CASCADE;
