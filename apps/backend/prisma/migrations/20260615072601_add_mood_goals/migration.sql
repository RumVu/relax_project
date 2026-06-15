-- CreateEnum
CREATE TYPE "MoodGoalType" AS ENUM ('TARGET_MOOD', 'REDUCE_MOOD', 'STREAK', 'CHECKIN_COUNT');

-- CreateEnum
CREATE TYPE "MoodGoalStatus" AS ENUM ('ACTIVE', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateTable
CREATE TABLE "mood_goals" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "type" "MoodGoalType" NOT NULL,
    "status" "MoodGoalStatus" NOT NULL DEFAULT 'ACTIVE',
    "targetMood" "MoodType",
    "targetCount" INTEGER,
    "targetDays" INTEGER,
    "currentCount" INTEGER NOT NULL DEFAULT 0,
    "currentStreak" INTEGER NOT NULL DEFAULT 0,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "mood_goals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mood_goal_milestones" (
    "id" TEXT NOT NULL,
    "goalId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "target" INTEGER NOT NULL,
    "reached" BOOLEAN NOT NULL DEFAULT false,
    "reachedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mood_goal_milestones_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "mood_goals_userId_idx" ON "mood_goals"("userId");

-- CreateIndex
CREATE INDEX "mood_goals_status_idx" ON "mood_goals"("status");

-- CreateIndex
CREATE INDEX "mood_goals_type_idx" ON "mood_goals"("type");

-- CreateIndex
CREATE INDEX "mood_goals_startDate_idx" ON "mood_goals"("startDate");

-- CreateIndex
CREATE INDEX "mood_goal_milestones_goalId_idx" ON "mood_goal_milestones"("goalId");

-- AddForeignKey
ALTER TABLE "mood_goals" ADD CONSTRAINT "mood_goals_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mood_goal_milestones" ADD CONSTRAINT "mood_goal_milestones_goalId_fkey" FOREIGN KEY ("goalId") REFERENCES "mood_goals"("id") ON DELETE CASCADE ON UPDATE CASCADE;
