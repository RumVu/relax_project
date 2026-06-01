# Audio Storage Sync

Seed data creates `AmbientSound` rows, but Supabase Storage still needs real
MP3 objects. Use this command whenever the catalog changes or a bucket is
empty:

```bash
npm run storage:sync-ambient-sounds
```

What it does:

- reads `apps/backend/prisma/ambient-sounds.catalog.cjs`
- downloads each `sourceUrl`
- uploads the MP3 to `SUPABASE_BUCKET/ambient-sounds/{key}.mp3`
- updates `ambient_sounds.soundUrl` with the real Supabase public URL
- registers the object in `storage_files`

Useful options:

```bash
npm run storage:sync-ambient-sounds -- --verify-only
npm run storage:sync-ambient-sounds -- --category=LOFI
npm run storage:sync-ambient-sounds -- --category=LOFI,CHILL --force
npm run storage:sync-ambient-sounds -- --dry-run --limit=3
```

Required backend env:

```env
DATABASE_URL=
SUPABASE_URL=
SUPABASE_SECRET_KEY=
SUPABASE_BUCKET=public-assets
```

`SUPABASE_SECRET_KEY` is backend-only. Do not put it in frontend or mobile env.
