"""Redis cache for tool results. 5-min TTL, keyed by tool name + user ID."""
import hashlib
import json
import logging

logger = logging.getLogger(__name__)

try:
    import redis
    _redis = redis.Redis(
        host="localhost", port=6379, db=1, decode_responses=True,
        protocol=2,
    )
    _redis.ping()
    _available = True
except Exception:
    _redis = None
    _available = False

TAG = "agent:tool:"
TTL = 300  # 5 minutes


def _cache_key(tool_name: str, user_id: str = "anon") -> str:
    h = hashlib.sha256(f"{tool_name}:{user_id}".encode()).hexdigest()[:16]
    return TAG + h


def get(tool_name: str, user_id: str = "anon") -> str | None:
    if not _available:
        return None
    try:
        raw = _redis.get(_cache_key(tool_name, user_id))
        if raw:
            logger.info("Tool cache hit: %s", tool_name)
            return raw
    except Exception as e:
        logger.warning("Tool cache get failed: %s", e)
    return None


def set(tool_name: str, result: str, user_id: str = "anon"):
    if not _available:
        return
    try:
        _redis.setex(_cache_key(tool_name, user_id), TTL, result)
    except Exception as e:
        logger.warning("Tool cache set failed: %s", e)


def invalidate(user_id: str = "anon"):
    if not _available:
        return
    try:
        keys = _redis.keys(TAG + "*")
        if keys:
            _redis.delete(*keys)
    except Exception:
        pass
