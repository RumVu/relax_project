-- Merge the archived legacy schema into the current Prisma-owned public schema.
-- Run against digital_cigarette_break after the legacy schema has been restored.
-- Idempotent by primary key / unique keys so it is safe to rerun.

BEGIN;

INSERT INTO public.users (
  id,
  email,
  name,
  avatar,
  password,
  role,
  "authProvider",
  "emailVerified",
  "isActive",
  "lastLoginAt",
  "deletedAt",
  "createdAt",
  "updatedAt"
)
SELECT
  u.id,
  u.email,
  u.name,
  u.avatar,
  u.password,
  CASE WHEN u.role::text = 'ADMIN' THEN 'ADMIN' ELSE 'USER' END::public."UserRole",
  'LOCAL'::public."AuthProvider",
  u."emailVerified",
  (u."isActive" AND NOT u."isBanned"),
  u."lastLoginAt",
  CASE WHEN u."isBanned" THEN u."updatedAt" ELSE NULL END,
  u."createdAt",
  u."updatedAt"
FROM legacy.users u
ON CONFLICT (email) DO NOTHING;

INSERT INTO public.user_profiles (
  id,
  "userId",
  "displayName",
  bio,
  "totalMoodCheckins",
  "totalJournalPosts",
  "currentStreak",
  "longestStreak",
  "createdAt",
  "updatedAt"
)
SELECT
  'legacy_profile_' || u.id,
  u.id,
  u.name,
  u.bio,
  COALESCE(u."totalMoods", 0),
  COALESCE(journal_counts.total, 0),
  0,
  0,
  u."createdAt",
  u."updatedAt"
FROM legacy.users u
JOIN public.users pu ON pu.id = u.id
LEFT JOIN (
  SELECT "userId", count(*)::int AS total
  FROM legacy.journals
  GROUP BY "userId"
) journal_counts ON journal_counts."userId" = u.id
ON CONFLICT ("userId") DO UPDATE SET
  "displayName" = EXCLUDED."displayName",
  bio = COALESCE(public.user_profiles.bio, EXCLUDED.bio),
  "totalMoodCheckins" = GREATEST(public.user_profiles."totalMoodCheckins", EXCLUDED."totalMoodCheckins"),
  "totalJournalPosts" = GREATEST(public.user_profiles."totalJournalPosts", EXCLUDED."totalJournalPosts"),
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.user_preferences (
  id,
  "userId",
  language,
  timezone,
  "weatherEnabled",
  "themeMode",
  "enableCompanionBubble",
  "bubbleIntervalSeconds",
  "enableSound",
  "enableHaptics",
  "pushNotificationsEnabled",
  "emailNotificationsEnabled",
  "createdAt",
  "updatedAt"
)
SELECT
  COALESCE(lp.id, 'legacy_pref_' || u.id),
  u.id,
  COALESCE(NULLIF(lp.language, ''), 'vi'),
  COALESCE(NULLIF(lp.timezone, ''), 'Asia/Ho_Chi_Minh'),
  true,
  'SYSTEM'::public."ThemeMode",
  true,
  30,
  true,
  true,
  COALESCE(lp."pushNotificationsEnabled", true),
  COALESCE(lp."emailNotificationsEnabled", false),
  COALESCE(lp."createdAt", u."createdAt"),
  COALESCE(lp."updatedAt", u."updatedAt")
FROM legacy.users u
JOIN public.users pu ON pu.id = u.id
LEFT JOIN legacy.user_preferences lp ON lp."userId" = u.id
ON CONFLICT ("userId") DO UPDATE SET
  language = EXCLUDED.language,
  timezone = EXCLUDED.timezone,
  "pushNotificationsEnabled" = EXCLUDED."pushNotificationsEnabled",
  "emailNotificationsEnabled" = EXCLUDED."emailNotificationsEnabled",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.user_companions (
  id,
  "userId",
  "assetId",
  name,
  type,
  "personalizationMode",
  mood,
  action,
  level,
  affection,
  energy,
  "lastSeenAt",
  "createdAt",
  "updatedAt"
)
SELECT
  'legacy_companion_' || u.id,
  u.id,
  default_asset.id,
  COALESCE(NULLIF(split_part(u.name, ' ', 1), ''), 'Mon Leo'),
  COALESCE(default_asset.type, 'CAT'::public."CompanionType"),
  'DEFAULT'::public."CompanionPersonalizationMode",
  'CHILL'::public."CompanionMood",
  'IDLE'::public."CompanionAction",
  1,
  0,
  100,
  u."lastLoginAt",
  u."createdAt",
  u."updatedAt"
FROM legacy.users u
JOIN public.users pu ON pu.id = u.id
LEFT JOIN LATERAL (
  SELECT id, type
  FROM public.companion_assets
  WHERE "isDefault" = true AND "isActive" = true
  ORDER BY "createdAt" ASC
  LIMIT 1
) default_asset ON true
ON CONFLICT ("userId") DO NOTHING;

WITH normalized AS (
  SELECT
    m.*,
    CASE m.type::text
      WHEN 'FRUSTRATED' THEN 'STRESSED'
      WHEN 'ENERGIZED' THEN 'EXCITED'
      ELSE m.type::text
    END AS normalized_mood
  FROM legacy.moods m
)
INSERT INTO public.mood_checkins (
  id,
  "userId",
  mood,
  intensity,
  "rawScore",
  "finalScore",
  "scoredAt",
  note,
  tags,
  "createdAt",
  "updatedAt"
)
SELECT
  n.id,
  n."userId",
  n.normalized_mood::public."MoodType",
  LEAST(5, GREATEST(1, CEIL(n.intensity::numeric / 2.0)::int)),
  CASE n.normalized_mood
    WHEN 'HAPPY' THEN 15
    WHEN 'CALM' THEN 20
    WHEN 'GRATEFUL' THEN 15
    WHEN 'EXCITED' THEN 30
    WHEN 'NEUTRAL' THEN 50
    WHEN 'TIRED' THEN 65
    WHEN 'SAD' THEN 75
    WHEN 'LONELY' THEN 80
    WHEN 'ANXIOUS' THEN 85
    WHEN 'STRESSED' THEN 90
    ELSE 50
  END,
  CASE n.normalized_mood
    WHEN 'HAPPY' THEN 15
    WHEN 'CALM' THEN 20
    WHEN 'GRATEFUL' THEN 15
    WHEN 'EXCITED' THEN 30
    WHEN 'NEUTRAL' THEN 50
    WHEN 'TIRED' THEN 65
    WHEN 'SAD' THEN 75
    WHEN 'LONELY' THEN 80
    WHEN 'ANXIOUS' THEN 85
    WHEN 'STRESSED' THEN 90
    ELSE 50
  END,
  n."createdAt",
  n.notes,
  COALESCE(n.tags, ARRAY[]::text[]),
  n."createdAt",
  n."updatedAt"
FROM normalized n
JOIN public.users u ON u.id = n."userId"
WHERE n.normalized_mood IN (
  'HAPPY',
  'CALM',
  'TIRED',
  'SAD',
  'ANXIOUS',
  'STRESSED',
  'EXCITED',
  'NEUTRAL',
  'LONELY',
  'GRATEFUL'
)
ON CONFLICT (id) DO NOTHING;

WITH normalized AS (
  SELECT
    j.*,
    CASE j.mood::text
      WHEN 'FRUSTRATED' THEN 'STRESSED'
      WHEN 'ENERGIZED' THEN 'EXCITED'
      ELSE j.mood::text
    END AS normalized_mood
  FROM legacy.journals j
)
INSERT INTO public.journals (
  id,
  "userId",
  title,
  content,
  mood,
  tags,
  "isPrivate",
  "isFavorite",
  "createdAt",
  "updatedAt"
)
SELECT
  n.id,
  n."userId",
  n.title,
  n.content,
  n.normalized_mood::public."MoodType",
  COALESCE(n.tags, ARRAY[]::text[]),
  n."isPrivate",
  n."isFavorite",
  n."createdAt",
  n."updatedAt"
FROM normalized n
JOIN public.users u ON u.id = n."userId"
WHERE n.normalized_mood IN (
  'HAPPY',
  'CALM',
  'TIRED',
  'SAD',
  'ANXIOUS',
  'STRESSED',
  'EXCITED',
  'NEUTRAL',
  'LONELY',
  'GRATEFUL'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.relax_sessions (
  id,
  "userId",
  "activityType",
  status,
  "resourceId",
  title,
  "startedAt",
  "endedAt",
  duration,
  note,
  "createdAt",
  "updatedAt"
)
SELECT
  b.id,
  b."userId",
  CASE b.mode::text
    WHEN 'SHORT_BREAK' THEN 'BREATHING'
    WHEN 'LONG_BREAK' THEN 'MEDITATION'
    ELSE 'MYSTERY'
  END::public."RelaxActivityType",
  CASE b.status
    WHEN 'COMPLETED' THEN 'FINISHED'
    WHEN 'CANCELLED' THEN 'CANCELLED'
    ELSE 'STARTED'
  END::public."RelaxSessionStatus",
  NULL,
  'Legacy ' || b.mode::text || ' break',
  b."startedAt",
  COALESCE(b."endedAt", b."completedAt", b."startedAt" + make_interval(secs => b.duration)),
  b.duration,
  b.notes,
  b."createdAt",
  b."updatedAt"
FROM legacy.break_sessions b
JOIN public.users u ON u.id = b."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.cozy_quotes (
  id,
  content,
  author,
  mood,
  "imageUrl",
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  q.id,
  q.text,
  q.author,
  CASE lower(COALESCE(q.category, ''))
    WHEN 'motivation' THEN 'EXCITED'::public."MoodType"
    WHEN 'mindfulness' THEN 'CALM'::public."MoodType"
    WHEN 'wisdom' THEN 'NEUTRAL'::public."MoodType"
    ELSE NULL
  END,
  q."imageUrl",
  q."isActive",
  q."createdAt",
  q."updatedAt"
FROM legacy.quotes q
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.achievements (
  id,
  title,
  description,
  type,
  icon,
  points,
  condition,
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  a.id,
  a.title,
  a.description,
  a.type::text::public."AchievementType",
  a.icon,
  a.points,
  a.condition::jsonb,
  a."isActive",
  a."createdAt",
  a."updatedAt"
FROM legacy.achievements a
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  type = EXCLUDED.type,
  icon = EXCLUDED.icon,
  points = EXCLUDED.points,
  condition = EXCLUDED.condition,
  "isActive" = EXCLUDED."isActive",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.badges (
  id,
  title,
  description,
  icon,
  category,
  rarity,
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  b.id,
  b.title,
  b.description,
  b.icon,
  b.category,
  b.rarity,
  b."isActive",
  b."createdAt",
  b."createdAt"
FROM legacy.badges b
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  category = EXCLUDED.category,
  rarity = EXCLUDED.rarity,
  "isActive" = EXCLUDED."isActive",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.subscription_tiers (
  id,
  name,
  description,
  price,
  currency,
  "billingCycle",
  "displayOrder",
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  st.id,
  upper(regexp_replace(st.name, '\s+', '_', 'g')),
  st.description,
  st.price,
  'USD',
  st."billingCycle"::text::public."BillingCycle",
  st."displayOrder",
  st."isActive",
  st."createdAt",
  st."updatedAt"
FROM legacy.subscription_tiers st
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  price = EXCLUDED.price,
  currency = EXCLUDED.currency,
  "billingCycle" = EXCLUDED."billingCycle",
  "displayOrder" = EXCLUDED."displayOrder",
  "isActive" = EXCLUDED."isActive",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.tier_features (
  id,
  "tierId",
  name,
  included,
  description,
  "createdAt"
)
SELECT
  tf.id,
  tf."tierId",
  tf.name,
  tf.included,
  tf.description,
  tf."createdAt"
FROM legacy.tier_features tf
JOIN public.subscription_tiers st ON st.id = tf."tierId"
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  included = EXCLUDED.included,
  description = EXCLUDED.description;

INSERT INTO public.tier_limits (
  id,
  "tierId",
  name,
  value,
  unit,
  "createdAt"
)
SELECT
  tl.id,
  tl."tierId",
  tl.name,
  tl.value,
  tl.unit,
  tl."createdAt"
FROM legacy.tier_limits tl
JOIN public.subscription_tiers st ON st.id = tl."tierId"
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  value = EXCLUDED.value,
  unit = EXCLUDED.unit;

INSERT INTO public.sessions (
  id,
  "userId",
  "refreshToken",
  "userAgent",
  "ipAddress",
  "expiresAt",
  "createdAt"
)
SELECT
  s.id,
  s."userId",
  s.token,
  s."userAgent",
  s."ipAddress",
  s."expiresAt",
  s."createdAt"
FROM legacy.sessions s
JOIN public.users u ON u.id = s."userId"
ON CONFLICT ("refreshToken") DO NOTHING;

INSERT INTO public.user_streaks (
  id,
  "userId",
  "currentStreak",
  "longestStreak",
  "streakType",
  "lastActivityDate",
  "startDate",
  "updatedAt"
)
SELECT
  us.id,
  us."userId",
  us."currentStreak",
  us."longestStreak",
  us."streakType",
  us."lastActivityDate",
  us."startDate",
  us."updatedAt"
FROM legacy.user_streaks us
JOIN public.users u ON u.id = us."userId"
ON CONFLICT ("userId") DO UPDATE SET
  "currentStreak" = EXCLUDED."currentStreak",
  "longestStreak" = EXCLUDED."longestStreak",
  "streakType" = EXCLUDED."streakType",
  "lastActivityDate" = EXCLUDED."lastActivityDate",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.user_points (
  id,
  "userId",
  "totalPoints",
  "updatedAt"
)
SELECT
  up.id,
  up."userId",
  up."totalPoints",
  up."updatedAt"
FROM legacy.user_points up
JOIN public.users u ON u.id = up."userId"
ON CONFLICT ("userId") DO UPDATE SET
  "totalPoints" = EXCLUDED."totalPoints",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.points_transactions (
  id,
  "userPointsId",
  amount,
  reason,
  "createdAt"
)
SELECT
  pt.id,
  pt."userPointsId",
  pt.amount,
  pt.reason,
  pt."createdAt"
FROM legacy.points_transactions pt
JOIN public.user_points up ON up.id = pt."userPointsId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.user_levels (
  id,
  "userId",
  level,
  experience,
  "nextLevelExp",
  "updatedAt"
)
SELECT
  ul.id,
  ul."userId",
  ul.level,
  ul.experience,
  ul."nextLevelExp",
  ul."updatedAt"
FROM legacy.user_levels ul
JOIN public.users u ON u.id = ul."userId"
ON CONFLICT ("userId") DO UPDATE SET
  level = EXCLUDED.level,
  experience = EXCLUDED.experience,
  "nextLevelExp" = EXCLUDED."nextLevelExp",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.friends (
  id,
  "userId",
  "friendId",
  status,
  "requestedAt",
  "respondedAt"
)
SELECT
  f.id,
  f."userId",
  f."friendId",
  f.status::text::public."FriendRequestStatus",
  f."requestedAt",
  f."respondedAt"
FROM legacy.friends f
JOIN public.users u ON u.id = f."userId"
JOIN public.users friend_user ON friend_user.id = f."friendId"
ON CONFLICT ("userId", "friendId") DO UPDATE SET
  status = EXCLUDED.status,
  "respondedAt" = EXCLUDED."respondedAt";

INSERT INTO public.challenges (
  id,
  title,
  description,
  type,
  difficulty,
  "durationDays",
  goal,
  reward,
  "createdBy",
  "startDate",
  "endDate",
  "isActive",
  "createdAt"
)
SELECT
  c.id,
  c.title,
  c.description,
  c.type,
  c.difficulty,
  c."durationDays",
  c.goal,
  c.reward,
  c."createdBy",
  c."startDate",
  c."endDate",
  c."isActive",
  c."createdAt"
FROM legacy.challenges c
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.user_challenges (
  id,
  "userId",
  "challengeId",
  progress,
  completed,
  "completedAt",
  "joinedAt"
)
SELECT
  uc.id,
  uc."userId",
  uc."challengeId",
  uc.progress,
  uc.completed,
  uc."completedAt",
  uc."joinedAt"
FROM legacy.user_challenges uc
JOIN public.users u ON u.id = uc."userId"
JOIN public.challenges c ON c.id = uc."challengeId"
ON CONFLICT ("userId", "challengeId") DO UPDATE SET
  progress = EXCLUDED.progress,
  completed = EXCLUDED.completed,
  "completedAt" = EXCLUDED."completedAt";

INSERT INTO public.leaderboard_entries (
  id,
  "userId",
  rank,
  score,
  period,
  "updatedAt"
)
SELECT
  le.id,
  le."userId",
  le.rank,
  le.score,
  le.period,
  le."updatedAt"
FROM legacy.leaderboard_entries le
JOIN public.users u ON u.id = le."userId"
ON CONFLICT ("userId", period) DO UPDATE SET
  rank = EXCLUDED.rank,
  score = EXCLUDED.score,
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.feed_entries (
  id,
  "userId",
  type,
  title,
  description,
  "relatedId",
  visibility,
  likes,
  "createdAt"
)
SELECT
  fe.id,
  fe."userId",
  fe.type,
  fe.title,
  fe.description,
  fe."relatedId",
  fe.visibility,
  fe.likes,
  fe."createdAt"
FROM legacy.feed_entries fe
JOIN public.users u ON u.id = fe."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.meditation_guides (
  id,
  title,
  description,
  duration,
  "focusArea",
  difficulty,
  "audioUrl",
  "imageUrl",
  instructor,
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  mg.id,
  mg.title,
  mg.description,
  mg.duration,
  mg."focusArea",
  mg.difficulty,
  mg."audioUrl",
  mg."imageUrl",
  mg.instructor,
  mg."isActive",
  mg."createdAt",
  mg."updatedAt"
FROM legacy.meditation_guides mg
ON CONFLICT (id) DO NOTHING;

WITH normalized AS (
  SELECT
    ms.*,
    CASE ms.mood::text
      WHEN 'FRUSTRATED' THEN 'STRESSED'
      WHEN 'ENERGIZED' THEN 'EXCITED'
      ELSE ms.mood::text
    END AS normalized_mood
  FROM legacy.meditation_sessions ms
)
INSERT INTO public.meditation_sessions (
  id,
  "userId",
  "guideId",
  duration,
  "startedAt",
  "endedAt",
  "focusArea",
  mood,
  quality,
  notes,
  "createdAt",
  "updatedAt"
)
SELECT
  n.id,
  n."userId",
  n."guideId",
  n.duration,
  n."startedAt",
  n."endedAt",
  n."focusArea",
  n.normalized_mood::public."MoodType",
  n.quality,
  n.notes,
  n."createdAt",
  n."updatedAt"
FROM normalized n
JOIN public.users u ON u.id = n."userId"
LEFT JOIN public.meditation_guides mg ON mg.id = n."guideId"
WHERE n."guideId" IS NULL OR mg.id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.notifications (
  id,
  "userId",
  title,
  message,
  type,
  "relatedEntity",
  "relatedId",
  "isRead",
  "readAt",
  "createdAt"
)
SELECT
  n.id,
  n."userId",
  n.title,
  n.message,
  n.type::text::public."NotificationType",
  n."relatedEntity",
  n."relatedId",
  n."isRead",
  n."readAt",
  n."createdAt"
FROM legacy.notifications n
JOIN public.users u ON u.id = n."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.reminders (
  id,
  "userId",
  title,
  message,
  type,
  "scheduledAt",
  "repeatRule",
  "isActive",
  "createdAt",
  "updatedAt"
)
SELECT
  r.id,
  r."userId",
  r.title,
  r.message,
  CASE upper(COALESCE(r.type, 'CUSTOM'))
    WHEN 'WATER' THEN 'WATER'
    WHEN 'REST' THEN 'REST'
    WHEN 'BREATHING' THEN 'BREATHING'
    WHEN 'JOURNAL' THEN 'JOURNAL'
    WHEN 'SLEEP' THEN 'SLEEP'
    ELSE 'CUSTOM'
  END::public."ReminderType",
  r."scheduledTime",
  r.frequency,
  r."isActive",
  r."createdAt",
  r."updatedAt"
FROM legacy.reminders r
JOIN public.users u ON u.id = r."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.payments (
  id,
  "userId",
  amount,
  currency,
  status,
  provider,
  method,
  "externalPaymentId",
  "stripePaymentId",
  "paypalPaymentId",
  description,
  "createdAt",
  "updatedAt"
)
SELECT
  p.id,
  p."userId",
  p.amount,
  p.currency,
  p.status::text::public."PaymentStatus",
  p.method::text,
  p.method::text,
  COALESCE(p."stripePaymentId", p."paypalPaymentId"),
  p."stripePaymentId",
  p."paypalPaymentId",
  p.description,
  p."createdAt",
  p."updatedAt"
FROM legacy.payments p
JOIN public.users u ON u.id = p."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.feedbacks (
  id,
  "userId",
  subject,
  message,
  status,
  "createdAt",
  "updatedAt"
)
SELECT
  f.id,
  f."userId",
  f.subject,
  f.message,
  f.status,
  f."createdAt",
  f."updatedAt"
FROM legacy.feedback f
LEFT JOIN public.users u ON u.id = f."userId"
WHERE f."userId" IS NULL OR u.id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.storage_files (
  id,
  "userId",
  filename,
  mimetype,
  size,
  provider,
  url,
  "publicUrl",
  "createdAt"
)
SELECT
  sf.id,
  sf."userId",
  sf.filename,
  sf.mimetype,
  sf.size,
  sf.provider,
  sf.url,
  sf."publicUrl",
  sf."createdAt"
FROM legacy.storage_files sf
LEFT JOIN public.users u ON u.id = sf."userId"
WHERE sf."userId" IS NULL OR u.id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.content_ratings (
  id,
  "userId",
  "contentType",
  "contentId",
  rating,
  review,
  "createdAt",
  "updatedAt"
)
SELECT
  cr.id,
  cr."userId",
  cr."contentType",
  cr."contentId",
  cr.rating,
  cr.review,
  cr."createdAt",
  cr."updatedAt"
FROM legacy.content_ratings cr
JOIN public.users u ON u.id = cr."userId"
ON CONFLICT ("userId", "contentType", "contentId") DO UPDATE SET
  rating = EXCLUDED.rating,
  review = EXCLUDED.review,
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.analytics (
  id,
  "userId",
  date,
  "moodCount",
  "avgMoodIntensity",
  "topMood",
  "sessionCount",
  "totalSessionTime",
  "meditationCount",
  "journalCount",
  "createdAt"
)
SELECT
  a.id,
  a."userId",
  a.date,
  a."moodCount",
  a."avgMoodIntensity",
  a."topMood",
  a."sessionCount",
  a."totalSessionTime",
  a."meditationCount",
  a."journalCount",
  a."createdAt"
FROM legacy.analytics a
JOIN public.users u ON u.id = a."userId"
ON CONFLICT ("userId", date) DO UPDATE SET
  "moodCount" = EXCLUDED."moodCount",
  "avgMoodIntensity" = EXCLUDED."avgMoodIntensity",
  "topMood" = EXCLUDED."topMood",
  "sessionCount" = EXCLUDED."sessionCount",
  "totalSessionTime" = EXCLUDED."totalSessionTime",
  "meditationCount" = EXCLUDED."meditationCount",
  "journalCount" = EXCLUDED."journalCount";

INSERT INTO public.insights (
  id,
  "userId",
  type,
  title,
  content,
  confidence,
  "createdAt"
)
SELECT
  i.id,
  i."userId",
  i.type,
  i.title,
  i.content,
  i.confidence,
  i."createdAt"
FROM legacy.insights i
JOIN public.users u ON u.id = i."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.ai_insights (
  id,
  "userId",
  type,
  title,
  content,
  "aiProvider",
  "isUseful",
  "createdAt"
)
SELECT
  ai.id,
  ai."userId",
  ai.type,
  ai.title,
  ai.content,
  ai."aiProvider",
  ai."isUseful",
  ai."createdAt"
FROM legacy.ai_insights ai
JOIN public.users u ON u.id = ai."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.recommendations (
  id,
  "userId",
  "contentType",
  "contentId",
  reason,
  score,
  "createdAt"
)
SELECT
  rec.id,
  rec."userId",
  rec."contentType",
  rec."contentId",
  rec.reason,
  rec.score,
  rec."createdAt"
FROM legacy.recommendations rec
JOIN public.users u ON u.id = rec."userId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.integration_links (
  id,
  "userId",
  type,
  "isActive",
  "accessToken",
  "refreshToken",
  "tokenExpiresAt",
  "createdAt",
  "updatedAt"
)
SELECT
  il.id,
  il."userId",
  il.type,
  il."isActive",
  il."accessToken",
  il."refreshToken",
  il."tokenExpiresAt",
  il."createdAt",
  il."updatedAt"
FROM legacy.integration_links il
JOIN public.users u ON u.id = il."userId"
ON CONFLICT ("userId", type) DO UPDATE SET
  "isActive" = EXCLUDED."isActive",
  "accessToken" = EXCLUDED."accessToken",
  "refreshToken" = EXCLUDED."refreshToken",
  "tokenExpiresAt" = EXCLUDED."tokenExpiresAt",
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.events (
  id,
  "userId",
  type,
  data,
  "createdAt"
)
SELECT
  e.id,
  e."userId",
  e.type::text::public."EventType",
  CASE WHEN e.data IS NULL THEN NULL ELSE to_jsonb(e.data) END,
  e."createdAt"
FROM legacy.events e
LEFT JOIN public.users u ON u.id = e."userId"
WHERE e."userId" IS NULL OR u.id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.admin_logs (
  id,
  "adminId",
  action,
  "targetId",
  "targetType",
  details,
  "createdAt"
)
SELECT
  al.id,
  al."adminId",
  al.action,
  al."targetId",
  al."targetType",
  al.details,
  al."createdAt"
FROM legacy.admin_logs al
JOIN public.users u ON u.id = al."adminId"
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.rate_limit_counters (
  id,
  identifier,
  "userId",
  "ipAddress",
  endpoint,
  count,
  "resetAt"
)
SELECT
  rlc.id,
  COALESCE(rlc.identifier, rlc."userId", rlc."ipAddress", 'anonymous'),
  rlc."userId",
  rlc."ipAddress",
  rlc.endpoint,
  rlc.count,
  rlc."resetAt"
FROM legacy.rate_limit_counters rlc
LEFT JOIN public.users u ON u.id = rlc."userId"
WHERE rlc."userId" IS NULL OR u.id IS NOT NULL
ON CONFLICT (identifier, endpoint) DO UPDATE SET
  count = EXCLUDED.count,
  "resetAt" = EXCLUDED."resetAt";

INSERT INTO public.search_indices (
  id,
  "entityType",
  "entityId",
  title,
  content,
  tags,
  "createdAt",
  "updatedAt"
)
SELECT
  si.id,
  si."entityType",
  si."entityId",
  si.title,
  si.content,
  COALESCE(si.tags, ARRAY[]::text[]),
  si."createdAt",
  si."updatedAt"
FROM legacy.search_indices si
ON CONFLICT ("entityType", "entityId") DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content,
  tags = EXCLUDED.tags,
  "updatedAt" = EXCLUDED."updatedAt";

INSERT INTO public.cache_entries (
  id,
  key,
  value,
  "expiresAt",
  "createdAt"
)
SELECT
  ce.id,
  ce.key,
  ce.value,
  ce."expiresAt",
  ce."createdAt"
FROM legacy.cache_entries ce
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  "expiresAt" = EXCLUDED."expiresAt";

UPDATE public.user_profiles p
SET
  "totalMoodCheckins" = counts.mood_count,
  "totalJournalPosts" = counts.journal_count,
  "updatedAt" = now()
FROM (
  SELECT
    u.id AS "userId",
    count(DISTINCT m.id)::int AS mood_count,
    count(DISTINCT j.id)::int AS journal_count
  FROM public.users u
  LEFT JOIN public.mood_checkins m ON m."userId" = u.id
  LEFT JOIN public.journals j ON j."userId" = u.id
  GROUP BY u.id
) counts
WHERE p."userId" = counts."userId";

COMMIT;
