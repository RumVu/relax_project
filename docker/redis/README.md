# Redis

Redis runs from `docker-compose.yml` for backend caching, session coordination,
future queues, WebSocket fan-out, and rate limiting.

Default local connection:

```env
REDIS_URL="redis://localhost:6379"
REDIS_KEY_PREFIX="dcb:"
REDIS_DEFAULT_TTL_SECONDS="300"
```

Backend health endpoints:

- `GET /redis/health` returns config status without opening a Redis connection.
- `GET /redis/health?deep=true` runs a real `PING` against Redis.
