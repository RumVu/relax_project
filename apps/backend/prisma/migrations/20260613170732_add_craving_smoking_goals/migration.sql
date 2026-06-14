-- CreateEnum
CREATE TYPE "CravingReason" AS ENUM ('SMOKE_CRAVING', 'STRESS', 'BOREDOM', 'SLEEPY', 'OVERWHELMED', 'LONELY', 'HABIT', 'SOCIAL', 'OTHER');

-- CreateTable
CREATE TABLE "craving_logs" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "reason" "CravingReason" NOT NULL,
    "intensityBefore" INTEGER NOT NULL,
    "intensityAfter" INTEGER,
    "duration" INTEGER,
    "activityUsed" TEXT,
    "resisted" BOOLEAN NOT NULL DEFAULT true,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "craving_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "smoking_goals" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "dailyTarget" INTEGER NOT NULL,
    "currentDaily" INTEGER NOT NULL,
    "replacementGoal" INTEGER NOT NULL DEFAULT 1,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "smoking_goals_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "craving_logs_userId_idx" ON "craving_logs"("userId");

-- CreateIndex
CREATE INDEX "craving_logs_reason_idx" ON "craving_logs"("reason");

-- CreateIndex
CREATE INDEX "craving_logs_createdAt_idx" ON "craving_logs"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "smoking_goals_userId_key" ON "smoking_goals"("userId");

-- AddForeignKey
ALTER TABLE "craving_logs" ADD CONSTRAINT "craving_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "smoking_goals" ADD CONSTRAINT "smoking_goals_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
