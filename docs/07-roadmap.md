# Project Roadmap

## Phase 1 — Core Backend & Web Admin (Completed)

- NestJS backend with Prisma ORM, PostgreSQL
- Auth (local + Google OAuth), JWT sessions
- Mood check-ins, journals, relax sessions CRUD
- Admin dashboard with analytics overview
- Swagger/OpenAPI documentation
- Rate limiting, Redis caching, BullMQ job queues
- Audit logging

## Phase 2 — Mobile MVP (Completed)

- Flutter app with full API integration
- Mood check-in with intensity + notes + tags
- Journal with privacy (isPrivate) and favorites
- Breathing exercises with timer
- Meditation sessions
- Ambient sounds player
- Companion pet with mood-based messages
- Weather integration
- Push notifications + smart reminders
- Offline mode (Hive cache + sync queue)
- Billing/subscription with tier management

## Phase 3 — Personalization & Intelligence (Completed)

- Smart Recommendation Engine (mood + history + time + triggers)
- Activity Effectiveness Dashboard (per-activity metrics)
- Trigger Map with stress cause tracking
- AI Companion with chat history
- Weekly Wellness Report (BullMQ scheduled job)
- Personal Wellness Plan
- Content Rating system
- Smart journal prompts + auto tags

## Phase 4 — Safety & Privacy (Completed)

- Crisis Safety Layer (keyword detection, safe responses, hotlines)
- Trusted Buddy Check-in (SOS messaging with templates)
- Privacy Vault (PIN lock, hide preview, private AI mode, export)
- Emergency contact management
- Safety disclaimer

## Phase 5 — Platform & Operations (Completed)

- Feature Flags (predefined + mobile remote config)
- Ops Dashboard (DB, Redis, Queue, Provider status)
- A/B Testing framework (experiments + variant assignment)
- Demo Story Mode (guided walkthrough + 14-day seed data)
- Sound Mixer (multi-audio simultaneous playback)
- Achievement & gamification system

## Phase 6 — Production Deployment (Pending)

> Heavy AWS infrastructure — requires dedicated planning

- AWS ECS/Fargate container orchestration
- RDS PostgreSQL managed database
- ElastiCache Redis
- S3 + CloudFront for static assets
- Route53 DNS + ACM SSL
- CI/CD pipeline (GitHub Actions to ECR to ECS)
- Monitoring: CloudWatch, Sentry
- Auto-scaling policies
- Database backup strategy

## Phase 7 — Growth & Experimentation (Pending)

- Lock Screen Widget (requires native Swift/Kotlin)
- Advanced A/B testing with statistical significance
- User segmentation + cohort analysis
- Notification optimization
- App Store + Google Play deployment
- Analytics dashboard with retention metrics
