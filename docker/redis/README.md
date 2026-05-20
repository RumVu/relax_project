# Redis

Redis runs from `docker-compose.yml` for backend caching, session coordination,
BullMQ queues, Socket.IO fan-out, and future rate limiting.

Default local connection:

```env
REDIS_URL="redis://localhost:6379"
REDIS_KEY_PREFIX="dcb:"
REDIS_DEFAULT_TTL_SECONDS="300"
QUEUE_ENABLED="true"
QUEUE_PREFIX="dcb"
QUEUE_DEFAULT_ATTEMPTS="3"
QUEUE_BACKOFF_DELAY_MS="1000"
```

Backend health endpoints:

- `GET /redis/health` returns config status without opening a Redis connection.
- `GET /redis/health?deep=true` runs a real `PING` against Redis.
- `GET /queues/health?deep=true` checks BullMQ's Redis connection.
- `GET /realtime/health` shows whether Socket.IO is using Redis adapter or
  in-memory fallback.
