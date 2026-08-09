"""
Production-grade hybrid retrieval: Dense (embeddings) + Sparse (BM25) → RRF fusion → LLM rerank.
BM25 index is persisted to disk for fast restarts.
"""
import os
import re
import pickle
import logging

from rank_bm25 import BM25Okapi
import jieba

from config import settings

logger = logging.getLogger(__name__)

# In-memory BM25 cache: {kb_id: (BM25Okapi, chunks, metadatas)}
_bm25_cache: dict[str, tuple] = {}


def _tokenize(text: str) -> list[str]:
    """Tokenize text for BM25. Uses jieba for Chinese + regex for ASCII words."""
    tokens = []
    # jieba cut for Chinese word segmentation
    tokens.extend(jieba.lcut(text))
    # Also extract ASCII words (code keywords, variable names, English terms)
    ascii_words = re.findall(r"[a-zA-Z0-9_]{2,}", text)
    tokens.extend([w.lower() for w in ascii_words])
    # Filter: remove whitespace-only and single-char tokens
    return [t.strip().lower() for t in tokens if len(t.strip()) > 1]


# ── BM25 persistence ────────────────────────────────────────────

def _bm25_path(kb_id: str) -> str:
    os.makedirs(settings.bm25_persist_dir, exist_ok=True)
    return os.path.join(settings.bm25_persist_dir, f"{kb_id}.pkl")


def save_bm25(kb_id: str, documents: list[str], metadatas: list[dict]):
    tokenized = [_tokenize(d) for d in documents]
    bm25 = BM25Okapi(tokenized)
    _bm25_cache[kb_id] = (bm25, documents, metadatas)
    try:
        with open(_bm25_path(kb_id), "wb") as f:
            pickle.dump((documents, metadatas, tokenized), f)
        logger.info("BM25 index saved for kb=%s (%d docs)", kb_id, len(documents))
    except Exception as e:
        logger.warning("Failed to persist BM25 for kb=%s: %s", kb_id, e)


def load_bm25(kb_id: str) -> bool:
    path = _bm25_path(kb_id)
    if not os.path.exists(path):
        return False
    try:
        with open(path, "rb") as f:
            documents, metadatas, tokenized = pickle.load(f)
        _bm25_cache[kb_id] = (BM25Okapi(tokenized), documents, metadatas)
        logger.info("BM25 index loaded for kb=%s (%d docs)", kb_id, len(documents))
        return True
    except Exception as e:
        logger.warning("Failed to load BM25 for kb=%s: %s", kb_id, e)
        return False


def get_bm25(kb_id: str) -> tuple:
    if kb_id not in _bm25_cache:
        load_bm25(kb_id)
    return _bm25_cache.get(kb_id, (None, [], []))


def invalidate_bm25(kb_id: str):
    _bm25_cache.pop(kb_id, None)
    try:
        os.remove(_bm25_path(kb_id))
    except FileNotFoundError:
        pass


# ── Dense retrieval ─────────────────────────────────────────────

async def dense_retrieve(collection, question: str, top_k: int | None = None) -> list[dict]:
    """Dense retrieval — generate query embedding in Python to avoid ChromaDB Rust default model mismatch."""
    if top_k is None:
        top_k = settings.dense_top_k

    from rag_service import _get_embeddings
    query_embedding = _get_embeddings().embed_query(question)

    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k,
        include=["documents", "metadatas", "distances"],
    )

    docs = []
    if results["documents"] and results["documents"][0]:
        for i in range(len(results["documents"][0])):
            meta = results["metadatas"][0][i]
            docs.append({
                "content": results["documents"][0][i],
                "kp_name": meta.get("name", ""),
                "kp_id": meta.get("kp_id"),
                "course_name": meta.get("course_name", ""),
                "description": meta.get("description", ""),
                "chunk_index": meta.get("chunk_index"),
                "chunk_count": meta.get("chunk_count"),
                "section": meta.get("section", ""),
                "content_type": meta.get("content_type", ""),
                "has_code": meta.get("has_code", False),
                "dense_score": float(1 - results["distances"][0][i]),
                "source": "dense",
            })
    return docs


# ── Sparse (BM25) retrieval ─────────────────────────────────────

async def sparse_retrieve(kb_id: str, question: str, top_k: int | None = None) -> list[dict]:
    if top_k is None:
        top_k = settings.sparse_top_k

    bm25, all_chunks, all_metadatas = get_bm25(kb_id)
    if bm25 is None or not all_chunks:
        return []

    tokenized = _tokenize(question)
    scores = bm25.get_scores(tokenized)
    if max(scores) <= 0:
        return []

    if len(scores) <= top_k:
        top_indices = list(range(len(scores)))
    else:
        top_indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:top_k]

    max_score = max(scores)
    docs = []
    for idx in top_indices:
        if scores[idx] <= 0:
            continue
        meta = all_metadatas[idx] if all_metadatas else {}
        docs.append({
            "content": all_chunks[idx],
            "kp_name": meta.get("name", ""),
            "kp_id": meta.get("kp_id"),
            "course_name": meta.get("course_name", ""),
            "description": meta.get("description", ""),
            "chunk_index": meta.get("chunk_index"),
            "chunk_count": meta.get("chunk_count"),
            "section": meta.get("section", ""),
            "content_type": meta.get("content_type", ""),
            "has_code": meta.get("has_code", False),
            "sparse_score": float(scores[idx] / max_score),
            "source": "sparse",
        })
    return docs


# ── RRF Fusion ──────────────────────────────────────────────────

def _doc_key(doc: dict) -> str:
    """Stable dedup key: kp_id + chunk_index uniquely identifies each chunk."""
    return f"{doc.get('kp_id')}:{doc.get('chunk_index', 0)}"


def rrf_fusion(dense_docs: list[dict], sparse_docs: list[dict], k: int = 60,
               dense_weight: float = 0.5, sparse_weight: float = 0.5) -> list[dict]:
    """RRF fusion with configurable source weights. Default 0.5/0.5 = equal."""
    scores: dict[str, float] = {}
    docs_map: dict[str, dict] = {}

    for rank, doc in enumerate(dense_docs, 1):
        key = _doc_key(doc)
        scores[key] = scores.get(key, 0) + dense_weight / (k + rank)
        docs_map[key] = doc

    for rank, doc in enumerate(sparse_docs, 1):
        key = _doc_key(doc)
        scores[key] = scores.get(key, 0) + sparse_weight / (k + rank)
        docs_map[key] = doc

    sorted_keys = sorted(scores, key=scores.get, reverse=True)
    return [docs_map[key] for key in sorted_keys]


async def hybrid_retrieve(collection, kb_id: str, question: str,
                          dense_weight: float = 0.5, sparse_weight: float = 0.5,
                          top_k: int | None = None) -> list[dict]:
    """Dense + Sparse → weighted RRF fusion.

    Args:
        dense_weight: weight for dense retrieval scores (0.0–1.0)
        sparse_weight: weight for sparse/BM25 scores (0.0–1.0)
        top_k: override rerank_top_k from settings (adaptive retrieval)
    """
    if top_k is None:
        top_k = settings.rerank_top_k

    dense_docs = await dense_retrieve(collection, question)
    sparse_docs = await sparse_retrieve(kb_id, question)

    if not dense_docs and not sparse_docs:
        return []
    if not sparse_docs:
        return dense_docs[:top_k]
    if not dense_docs:
        return sparse_docs[:top_k]

    return rrf_fusion(dense_docs, sparse_docs,
                      dense_weight=dense_weight, sparse_weight=sparse_weight)[:top_k]


# ── Cross-Encoder Rerank (local, no API call) ────────────────────

_reranker = None


def _get_reranker():
    global _reranker
    if _reranker is None:
        from sentence_transformers import CrossEncoder
        _reranker = CrossEncoder(
            settings.reranker_model,
            device="cpu",
        )
        logger.info("Cross-encoder loaded: %s", settings.reranker_model)
    return _reranker


def cross_encoder_rerank(question: str, docs: list[dict], top_k: int | None = None) -> list[dict]:
    """Local cross-encoder rerank. Scores top-N candidates only for speed on CPU."""
    if top_k is None:
        top_k = settings.rerank_top_k
    if len(docs) <= top_k:
        return docs

    # Only score top candidates (RRF already pre-ranked them), keep CPU time bounded
    score_limit = max(top_k * 2, 12)
    candidates = docs[:score_limit]
    rest = docs[score_limit:]

    model = _get_reranker()
    pairs = [(question, doc["content"][:1000]) for doc in candidates]
    scores = model.predict(pairs, show_progress_bar=False)

    for i, score in enumerate(scores):
        candidates[i]["rerank_score"] = float(score)

    candidates.sort(key=lambda d: d.get("rerank_score", 0), reverse=True)
    # Merge back: top_k from reranked candidates + remaining unranked docs
    return candidates[:top_k] + rest
