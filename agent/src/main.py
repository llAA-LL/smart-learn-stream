"""
FastAPI entry point — production-grade AI Agent with streaming, hybrid RAG, and safety.
"""
import sys
from pathlib import Path

# Fix working directory to project root (parent of src/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "src"))

# Use HF mirror for mainland China
import os as _os
_os.environ.setdefault("HF_ENDPOINT", "https://hf-mirror.com")
# Prevent __pycache__ from triggering watchfiles reloads
_os.environ["PYTHONDONTWRITEBYTECODE"] = "1"

# chdir to project root so relative paths (data/, .env) resolve correctly
_os.chdir(str(PROJECT_ROOT))

import base64
import json
import logging
import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

load_dotenv()

from config import settings
from rag_service import ingest_knowledge_points, get_vectorstore
from agent_graph import run_agent, run_agent_stream
from tools import set_backend_url
from cache import get as cache_get, set as cache_set
from feedback_store import save as feedback_save, stats as feedback_stats
from observability import snapshot, inc_cache

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
for noisy in ("chromadb", "httpx", "openai", "urllib3", "sentence_transformers"):
    logging.getLogger(noisy).setLevel(logging.WARNING)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    set_backend_url(settings.java_backend_url)
    logger.info("Agent starting: backend=%s, llm=%s @ %s",
                 settings.java_backend_url, settings.llm_model, settings.deepseek_base_url)

    try:
        count = await ingest_knowledge_points()
        logger.info("Ingestion complete: %d documents", count)
    except Exception as e:
        logger.warning("Ingestion failed (backend may not be ready): %s", e)

    yield


app = FastAPI(title="Smart Learning Agent", version="2.0", lifespan=lifespan)


# ── Request/Response models ──────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    history: list[dict] | None = None
    token: str | None = None


class ChatResponse(BaseModel):
    reply: str
    sources: list[dict] = []
    rewritten_question: str | None = None
    follow_ups: list[str] = []


# ── Helpers ───────────────────────────────────────────────────────

def _validate_token(token: str | None) -> str | None:
    """Validate JWT token format. Returns token if valid, raises HTTPException if invalid.

    Does NOT verify signature (backend handles that when tools are called).
    Only checks structural validity to catch garbage input early.
    """
    if token is None or not token.strip():
        return None
    parts = token.split(".")
    if len(parts) != 3:
        raise HTTPException(status_code=401, detail="Invalid JWT format: must have 3 parts")
    try:
        # Decode payload to check expiration (best-effort, no signature verification)
        payload = parts[1]
        # Add padding for base64
        payload += "=" * (4 - len(payload) % 4)
        claims = json.loads(base64.urlsafe_b64decode(payload))
        import time as _time
        exp = claims.get("exp", 0)
        if exp and exp < _time.time():
            raise HTTPException(status_code=401, detail="Token expired")
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid JWT token")
    return token


# ── Endpoints ────────────────────────────────────────────────────

@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    """Non-streaming chat endpoint with Redis cache for hot questions."""
    try:
        token = _validate_token(req.token)

        # Cache: skip entire RAG pipeline on hit
        if not req.history and not token:
            cached = cache_get(req.message)
            if cached:
                inc_cache()
                logger.info("Cache hit for: %s", req.message[:50])
                return ChatResponse(**cached)

        result = await run_agent(
            question=req.message,
            history=req.history,
            jwt_token=token,
        )
        resp = ChatResponse(
            reply=result["answer"],
            sources=result.get("sources", []),
            rewritten_question=result.get("rewritten_question"),
            follow_ups=result.get("follow_ups", []),
        )

        # Cache: store result for future hits (only for stateless queries)
        if not req.history and not token:
            resp_dict = resp.model_dump()
            resp_dict.pop("rewritten_question", None)
            cache_set(req.message, resp_dict)

        return resp
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Chat failed")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/chat/stream")
async def chat_stream(req: ChatRequest):
    """SSE streaming chat endpoint."""
    try:
        token = _validate_token(req.token)
    except HTTPException as e:
        async def error_gen():
            yield f"event: error\ndata: {e.detail}\n\n"
        return StreamingResponse(error_gen(), media_type="text/event-stream")

    async def event_generator():
        try:
            async for chunk in run_agent_stream(
                question=req.message,
                history=req.history,
                jwt_token=token,
            ):
                event_type = chunk["event"]
                data = chunk["data"]
                if isinstance(data, str):
                    import json
                    data_str = json.dumps(data, ensure_ascii=False)
                elif isinstance(data, dict):
                    import json
                    data_str = json.dumps(data, ensure_ascii=False)
                else:
                    data_str = str(data)
                yield f"event: {event_type}\ndata: {data_str}\n\n"
        except Exception as e:
            logger.exception("Stream failed")
            import json
            yield f"event: error\ndata: {json.dumps(str(e), ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@app.get("/health")
async def health():
    return {"status": "ok", "version": "2.0"}


@app.post("/reindex")
async def reindex():
    count = await ingest_knowledge_points(force=True)
    return {"status": "ok", "documents": count}


class FeedbackRequest(BaseModel):
    question: str
    answer: str
    rating: str  # "up" or "down"
    sources: list[dict] | None = None
    follow_ups: list[str] | None = None


@app.post("/feedback")
async def feedback(req: FeedbackRequest):
    if req.rating not in ("up", "down"):
        raise HTTPException(status_code=400, detail="rating must be 'up' or 'down'")
    ok = feedback_save(req.question, req.answer, req.rating, req.sources, req.follow_ups)
    return {"status": "ok" if ok else "redis_unavailable"}


@app.get("/feedback/stats")
async def get_feedback_stats():
    return feedback_stats()


@app.get("/metrics")
async def metrics():
    return snapshot()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=True,
        reload_excludes=["**/__pycache__/**", "**/*.pyc", "**/data/**", "**/.git/**"],
    )
