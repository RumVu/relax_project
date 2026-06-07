-- AddColumns: SubscriptionTier display title + sale window
-- Schema có sẵn nhưng initial_schema migration thiếu các cột này, làm
-- seed.cjs upsert fail với P2022 (column subscription_tiers.title không
-- tồn tại). Migration này thêm bù cho clean DB (CI) và DB cũ chưa có.

ALTER TABLE "subscription_tiers"
  ADD COLUMN IF NOT EXISTS "title" TEXT,
  ADD COLUMN IF NOT EXISTS "salePrice" DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS "saleLabel" TEXT,
  ADD COLUMN IF NOT EXISTS "saleStartsAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "saleEndsAt" TIMESTAMP(3);
