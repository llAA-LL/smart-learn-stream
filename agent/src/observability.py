"""In-memory observability: request counts and latency distributions."""
import time
import threading
from collections import defaultdict

# ── Counters ──────────────────────────────────────────────────────

_lock = threading.Lock()

_total_requests = 0
_cache_hits = 0
_oos_blocks = 0
_chitchat_routes = 0
_rag_requests = 0

# Latency buckets (ms): simple list, truncated at MAX_SAMPLES
MAX_SAMPLES = 1000
_graph_latencies: list[float] = []  # graph execution time
_retrieve_latencies: list[float] = []  # retrieval only
_llm_latencies: list[float] = []  # LLM generation
_total_latencies: list[float] = []  # end-to-end


def record_graph(ms: float):
    with _lock:
        _graph_latencies.append(ms)
        if len(_graph_latencies) > MAX_SAMPLES:
            _graph_latencies.pop(0)


def record_retrieve(ms: float):
    with _lock:
        _retrieve_latencies.append(ms)
        if len(_retrieve_latencies) > MAX_SAMPLES:
            _retrieve_latencies.pop(0)


def record_llm(ms: float):
    with _lock:
        _llm_latencies.append(ms)
        if len(_llm_latencies) > MAX_SAMPLES:
            _llm_latencies.pop(0)


def record_total(ms: float):
    with _lock:
        _total_latencies.append(ms)
        if len(_total_latencies) > MAX_SAMPLES:
            _total_latencies.pop(0)


def inc_request():
    global _total_requests
    with _lock:
        _total_requests += 1


def inc_cache():
    global _cache_hits
    with _lock:
        _cache_hits += 1


def inc_oos():
    global _oos_blocks
    with _lock:
        _oos_blocks += 1


def inc_chitchat():
    global _chitchat_routes
    with _lock:
        _chitchat_routes += 1


def inc_rag():
    global _rag_requests
    with _lock:
        _rag_requests += 1


# ── Helpers ────────────────────────────────────────────────────────

def _percentile(sorted_vals: list[float], p: float) -> float:
    if not sorted_vals:
        return 0.0
    k = (len(sorted_vals) - 1) * p
    f = int(k)
    c = k - f
    if f + 1 < len(sorted_vals):
        return sorted_vals[f] * (1 - c) + sorted_vals[f + 1] * c
    return sorted_vals[f]


def snapshot() -> dict:
    """Thread-safe snapshot of all metrics."""
    with _lock:
        gl = sorted(_graph_latencies.copy())
        rl = sorted(_retrieve_latencies.copy())
        ll = sorted(_llm_latencies.copy())
        tl = sorted(_total_latencies.copy())
        total = _total_requests
        ch = _cache_hits
        oos = _oos_blocks
        cc = _chitchat_routes
        rag = _rag_requests

    return {
        "requests": {
            "total": total,
            "rag": rag,
            "chitchat": cc,
            "oos_blocked": oos,
        },
        "cache": {
            "hits": ch,
            "hit_rate": f"{ch / total:.1%}" if total > 0 else "N/A",
        },
        "latency_ms": {
            "graph": {"p50": _percentile(gl, 0.5), "p95": _percentile(gl, 0.95), "p99": _percentile(gl, 0.99)},
            "retrieve": {"p50": _percentile(rl, 0.5), "p95": _percentile(rl, 0.95), "p99": _percentile(rl, 0.99)},
            "llm": {"p50": _percentile(ll, 0.5), "p95": _percentile(ll, 0.95), "p99": _percentile(ll, 0.99)},
            "total": {"p50": _percentile(tl, 0.5), "p95": _percentile(tl, 0.95), "p99": _percentile(tl, 0.99)},
        },
        "samples": len(tl),
    }
