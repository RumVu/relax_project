-- AlterTable
ALTER TABLE "cozy_quotes" ADD COLUMN     "lang" TEXT NOT NULL DEFAULT 'vi';

-- CreateTable
CREATE TABLE "user_quests" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "templateCode" TEXT NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "user_quests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "user_quests_userId_idx" ON "user_quests"("userId");

-- CreateIndex
CREATE INDEX "user_quests_templateCode_idx" ON "user_quests"("templateCode");

-- CreateIndex
CREATE INDEX "cozy_quotes_lang_idx" ON "cozy_quotes"("lang");

-- AddForeignKey
ALTER TABLE "user_quests" ADD CONSTRAINT "user_quests_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
