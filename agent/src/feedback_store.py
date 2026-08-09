"""Persist user feedback in Redis for analysis and quality improvement."""
import json
import logging
from datetime import datetime, timezone

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

FEEDBACK_KEY = "agent:feedback"
FEEDBACK_TTL = 86400 * 30  # 30 days


def save(question: str, answer: str, rating: str, sources: list[dict] | None = None,
         follow_ups: list[str] | None = None) -> bool:
    """Save user feedback. rating: 'up' or 'down'."""
    if not _available:
        return False
    try:
        entry = {
            "question": question[:500],
            "answer": answer[:1000],
            "rating": rating,
            "sources": sources or [],
            "follow_ups": follow_ups or [],
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        _redis.lpush(FEEDBACK_KEY, json.dumps(entry, ensure_ascii=False))
        _redis.expire(FEEDBACK_KEY, FEEDBACK_TTL)
        logger.info("Feedback saved: %s for '%s'", rating, question[:60])
        return True
    except Exception as e:
        logger.warning("Failed to save feedback: %s", e)
        return False


def stats() -> dict:
    """Get aggregate feedback stats."""
    if not _available:
        return {"available": False}
    try:
        items = _redis.lrange(FEEDBACK_KEY, 0, -1)
        up = sum(1 for i in items if json.loads(i).get("rating") == "up")
        down = len(items) - up
        return {"available": True, "up": up, "down": down, "total": len(items)}
    except Exception:
        return {"available": False, "up": 0, "down": 0, "total": 0}
