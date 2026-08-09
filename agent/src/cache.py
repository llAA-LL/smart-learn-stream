"""Redis cache for hot question answers. Skips entire RAG pipeline on cache hit."""
import hashlib
import json
import logging

logger = logging.getLogger(__name__)

try:
    import redis
    _redis = redis.Redis(
        host="localhost", port=6379, db=1, decode_responses=True,
        protocol=2,  # RESP2 for old Windows Redis (no HELLO command)
    )
    _redis.ping()
    _available = True
except Exception:
    _redis = None
    _available = False
    logger.warning("Redis cache unavailable — will run full pipeline every time")

CACHE_TTL = 3600  # 1 hour
PREFIX = "agent:cache:"


def _key(question: str) -> str:
    h = hashlib.sha256(question.strip().encode()).hexdigest()[:16]
    return PREFIX + h


def get(question: str) -> dict | None:
    if not _available:
        return None
    try:
        raw = _redis.get(_key(question))
        if raw:
            return json.loads(raw)
    except Exception as e:
        logger.warning("Redis cache get failed: %s", e)
    return None


def set(question: str, response: dict):
    if not _available:
        return
    try:
        _redis.setex(_key(question), CACHE_TTL, json.dumps(response, ensure_ascii=False))
    except Exception as e:
        logger.warning("Redis cache set failed: %s", e)


def invalidate_all():
    if not _available:
        return
    try:
        keys = _redis.keys(PREFIX + "*")
        if keys:
            _redis.delete(*keys)
    except Exception:
        pass
