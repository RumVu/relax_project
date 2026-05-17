-- DropIndex
DROP INDEX "rate_limit_counters_ipAddress_endpoint_key";

-- DropIndex
DROP INDEX "rate_limit_counters_userId_endpoint_key";

-- AlterTable
ALTER TABLE "rate_limit_counters" ADD COLUMN     "identifier" TEXT NOT NULL;

-- CreateIndex
CREATE INDEX "rate_limit_counters_userId_idx" ON "rate_limit_counters"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "rate_limit_counters_identifier_endpoint_key" ON "rate_limit_counters"("identifier", "endpoint");

-- Prevent self-referential friend rows (A cannot befriend A).
-- Reciprocal-pair (A->B vs B->A) de-duplication stays in the application
-- layer because the row carries directional request state (status,
-- requestedAt, respondedAt) that an unordered unique index would break.
ALTER TABLE "friends" ADD CONSTRAINT "friends_no_self" CHECK ("userId" <> "friendId");
