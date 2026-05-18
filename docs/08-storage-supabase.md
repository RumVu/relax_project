# Supabase Storage

Backend storage is configured through Supabase Storage. The bucket name is not hardcoded; it comes from `SUPABASE_BUCKET` in `apps/backend/.env`.

## Environment

Required backend variables:

```env
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_PUBLISHABLE_KEY="your-publishable-key"
SUPABASE_SECRET_KEY="your-service-role-or-secret-key"
SUPABASE_BUCKET="public-assets"
```

Keep `SUPABASE_SECRET_KEY` backend-only. Do not expose it through web or mobile environment variables.

Frontend variables:

```env
NEXT_PUBLIC_SUPABASE_URL="https://your-project.supabase.co"
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY="your-publishable-key"
```

The backend can also fall back to `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` for shared public config, but privileged storage operations still require `SUPABASE_SECRET_KEY`.

## Bucket Setup

Use the bucket name from `SUPABASE_BUCKET`. Current local config points at:

```text
public-assets
```

Recommended folders:

```text
app-themes/
onboarding-slides/
companion-assets/
ambient-sounds/
breathing-exercises/
cozy-quotes/
users/{userId}/
```

If the bucket is public, frontend can use the public URL returned by the backend. If the bucket is private, use signed read URLs.

## API

Health check:

```http
GET /storage/health
```

Deep health check, including a real Supabase bucket lookup:

```http
GET /storage/health?deep=true
```

Create signed upload URL:

```http
POST /storage/signed-upload-url
Content-Type: application/json

{
  "path": "companion-assets/cat-idle.png",
  "upsert": true
}
```

Response includes `signedUrl`, `token`, `bucket`, and normalized `path`.

Get public URL:

```http
GET /storage/public-url?path=companion-assets/cat-idle.png
```

Get signed read URL:

```http
GET /storage/signed-url?path=companion-assets/cat-idle.png&expiresIn=3600
```

Register uploaded file metadata:

```http
POST /storage/files
Content-Type: application/json

{
  "filename": "cat-idle.png",
  "mimetype": "image/png",
  "size": 123456,
  "path": "companion-assets/cat-idle.png"
}
```

List metadata:

```http
GET /storage/files
```

Delete metadata only:

```http
DELETE /storage/files/:id
```

Delete objects from Supabase bucket:

```http
DELETE /storage/objects
Content-Type: application/json

{
  "paths": ["companion-assets/cat-idle.png"]
}
```

## Frontend Upload Flow

1. Call `POST /storage/signed-upload-url` with the target path.
2. Upload the file to the returned `signedUrl` using Supabase's signed upload flow or a raw upload request compatible with Supabase Storage.
3. Call `GET /storage/public-url` for public buckets, or `GET /storage/signed-url` for private buckets.
4. Call `POST /storage/files` to save metadata in the backend database.
5. Store the returned URL/path on the related catalog item, such as `CompanionAsset.previewImageUrl` or `AmbientSound.soundUrl`.

## Error Codes

Storage endpoints use the standard backend error envelope.

Relevant codes:

```text
STORAGE_NOT_CONFIGURED
STORAGE_INVALID_PATH
STORAGE_OPERATION_FAILED
DATABASE_RECORD_NOT_FOUND
```

Invalid paths include empty paths, parent traversal like `../file.png`, and backslash paths.

## Troubleshooting

If `GET /storage/health` returns `configured: false`, fill the missing keys shown in `missingKeys`.

If `GET /storage/health` returns values in `invalidKeys`, replace placeholder values like `your-secret-key` with the real Supabase values.

If `GET /storage/health` returns `urlValid: false`, replace `SUPABASE_URL` with the exact Project URL from Supabase:

```text
https://<project-ref>.supabase.co
```

If `GET /storage/health?deep=true` returns `connected: false` or `bucketFound: false`:

- Check that `SUPABASE_BUCKET` exactly matches the bucket name in Supabase.
- Check that `SUPABASE_SECRET_KEY` is a backend-only key with storage permissions.
- Check that the bucket exists in Supabase Storage.
- For private buckets, use signed read URLs instead of public URLs.

If `POST /storage/signed-upload-url` returns `STORAGE_OPERATION_FAILED`, the backend route is working but Supabase rejected or could not reach the storage request. Start by checking `SUPABASE_URL`, `SUPABASE_SECRET_KEY`, bucket name, and storage policies.
