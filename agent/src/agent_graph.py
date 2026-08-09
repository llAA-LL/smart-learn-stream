"""
Production-grade LangGraph agent pipeline — optimized for speed.

Key design: single LLM call per user message.
  - Retrieval always runs (local, fast)
  - Tool detection via regex keyword match (no LLM call needed)
  - Generated answer combines RAG context + tool results in one pass

Graph:
  rewrite → hybrid_retrieve → check_tools → generate → END
"""
import logging
import re
import time
from typing import Annotated, AsyncGenerator, TypedDict

from langchain_core.messages import BaseMessage, HumanMessage, SystemMessage
from langgraph.graph import StateGraph, END
from langgraph.graph.message import add_messages

from config import settings
from llm_service import chat_complete
from rag_service import get_vectorstore
from retrieval_service import hybrid_retrieve, sparse_retrieve, dense_retrieve, rrf_fusion
from tools import ALL_TOOLS, set_token, _get, _jwt_token
from tool_cache import get as tool_cache_get, set as tool_cache_set
from observability import (
    record_graph, record_retrieve, record_llm, record_total,
    inc_request, inc_cache, inc_oos, inc_chitchat, inc_rag,
)
from prompts import (
    SYSTEM_PROMPT, QUESTION_REWRITE_PROMPT, CONTEXT_INSTRUCTIONS, SELF_CHECK_PROMPT, FOLLOW_UP_PROMPT,
    SUMMARIZE_HISTORY_PROMPT,
)
from safety_service import check_input_safety, check_output_safety

logger = logging.getLogger(__name__)

# ── State ────────────────────────────────────────────────────────

class AgentState(TypedDict):
    messages: Annotated[list[BaseMessage], add_messages]
    question: str
    kb_id: str
    history: list[dict] | None
    rewritten_question: str | None
    query_variants: list[str] | None
    retrieved_docs: list[dict] | None
    tool_results: str | None
    answer: str | None
    sources: list[dict] | None
    tools_used: list[str] | None
    need_retrieval: bool | None
    out_of_scope: bool | None
    redirect_hint: str | None


# ── Keyword-based tool detection (no LLM call) ───────────────────

TOOL_KEYWORDS = {
    "get_user_learning_records": ["学习记录", "学习进度", "最近学了", "学了什么", "学习情况", "我的学习"],
    "get_user_mastery": ["掌握度", "掌握情况", "掌握得好", "掌握得不好", "哪个知识点", "知识点掌握"],
    "get_quiz_history": ["自测", "测试成绩", "测验", "考试", "成绩怎么样", "测试历史"],
    "get_recommendations": ["推荐", "接下来学", "接下来该学", "该学什么", "下一步", "建议学"],
    "get_learning_plans": ["学习计划", "计划进度", "我的计划"],
    "get_user_stats": ["总共学了", "统计", "学习数据", "学习统计", "学了多少"],
}

def detect_tools(question: str) -> list[str]:
    """Fast keyword-based tool detection — avoids an LLM call."""
    detected = []
    for tool_name, keywords in TOOL_KEYWORDS.items():
        for kw in keywords:
            if kw in question:
                detected.append(tool_name)
                break
    return detected


# ── Query routing: classify question → optimal retrieval params ───

# (keyword list, dense_weight, sparse_weight, top_k)
_ROUTES: list[tuple[list[str], float, float, int]] = [
    # Code-heavy → BM25 better (exact keyword/token match)
    (["代码", "怎么写", "实现", "源码", "bug", "报错", "调试", "函数", "方法",
      "类", "接口", "语法", "用法", "API", "配置", "注解", "依赖", "导包",
      "import", "public", "class", "new ", "lambda", "stream"], 0.3, 0.7, 5),
    # Comparison → need more docs, balanced weights
    (["区别", "对比", "比较", "不同", "哪个好", "优缺点", "vs", "差异",
      "选择", "还是", "分别", "各自"], 0.5, 0.5, 8),
    # How-to / deep dive → need more context
    (["如何", "怎么", "怎样", "步骤", "流程", "搭建", "设计", "优化",
      "解决", "方案", "实践", "落地", "实战", "经验"], 0.6, 0.4, 6),
]

# Default: concept / definition → dense better (semantic similarity)
_DEFAULT_ROUTE = (0.7, 0.3, 4)

# Vague-concept triggers for HyDE
_HYDE_TRIGGERS = ["理解", "概念", "原理", "思想", "本质", "为什么", "是什么", "设计思想"]


def _route_query(question: str) -> dict:
    """Classify question type and return optimal (dense_weight, sparse_weight, top_k, use_hyde)."""
    q = question.strip()
    for keywords, dw, sw, tk in _ROUTES:
        for kw in keywords:
            if kw in q:
                use_hyde = any(t in q for t in _HYDE_TRIGGERS)
                return {"dense_weight": dw, "sparse_weight": sw, "top_k": tk, "use_hyde": use_hyde}
    # Default route
    use_hyde = any(t in q for t in _HYDE_TRIGGERS)
    return {"dense_weight": _DEFAULT_ROUTE[0], "sparse_weight": _DEFAULT_ROUTE[1],
            "top_k": _DEFAULT_ROUTE[2], "use_hyde": use_hyde}


async def _generate_hypothetical_answer(question: str) -> str | None:
    """Generate a short hypothetical answer to improve dense retrieval (HyDE).

    Returns None if HyDE is skipped or fails, so caller falls back to raw question.
    """
    prompt = (
        "Write a short paragraph (2-3 sentences) answering this question as if you were a textbook. "
        "Include key technical terms. Do NOT write code — only natural language explanation.\n\n"
        f"Question: {question}\n\n"
        "Hypothetical answer:"
    )
    try:
        resp = await chat_complete(
            [{"role": "user", "content": prompt}],
            temperature=0.2, max_tokens=150,
        )
        hypo = resp.choices[0].message.content.strip()
        return hypo if len(hypo) > 20 else None
    except Exception:
        return None


# ── Self-cognition boundary: detect questions beyond the agent's scope ──

import re as _re

# (pattern, category, redirect hint)
OOS_PATTERNS: list[tuple[str, str, str]] = [
    # Writing complete projects / applications
    (r"(帮我|给我|替我).*(写|做|开发|搭建|构建|创建).*(项目|应用|系统|网站|APP|app|小程序|平台|软件)",
     "帮你写完整项目", "我无法直接生成完整的项目代码，但可以帮你梳理架构设计、关键模块的实现思路、或解释相关技术原理。"),
    (r"(帮我|给我).*(写|生成).*(完整|整个|全部)", "帮你生成完整内容",
     "与其一次性生成大量内容，不如告诉我你想理解哪个具体的知识点或技术点，我来深入讲解。"),
    # Non-learning / off-topic tasks
    (r"(今天|明天|现在).*(天气|温度|下雨|刮风)", "查天气",
     "我无法查询实时天气。我是学习助手，擅长解释技术概念、分析面试考题、帮你复习课程知识。"),
    (r"(帮我|给我).*((写|回复|拟|起草).*邮件|发邮件)", "写邮件",
     "我无法帮你写邮件。不过如果你想了解网络协议中 SMTP 的工作原理，我可以解释。"),
    (r"(帮我|给我).*((点|叫|买|订).*外卖|外卖|打车|购物|订票)", "生活服务",
     "我是学习助手，无法帮你处理这类生活事务。有学习问题随时问我。"),
    (r"^.*(讲个|说个|来一段).*(笑话|段子|相声|脱口秀)", "讲笑话",
     "我是学习助手，不是段子手——不过我可以把复杂的技术概念讲得很有趣，想试试吗？"),
    # Harmful / unethical requests
    (r"(黑客|破解|盗版|刷课|作弊|代考|代写|代做)", "不合规请求",
     "我不能帮你做这类事情。如果你对网络安全或相关技术原理感兴趣，我可以从学术角度介绍。"),
    # Very generic life advice
    (r"(怎么|如何|怎样).*(谈恋爱|找对象|追女生|追男生|约会|分手)", "情感咨询",
     "情感问题我确实不懂。不过如果你想了解如何高效学习、制定复习计划，我很擅长。"),
    (r"(帮我|给我).*(算|占卜|算命|看相|风水|星座|塔罗)", "占卜算命",
     "这个超出我的知识范围了。如果你对概率统计或者贝叶斯定理感兴趣，那我们可以聊聊数学。"),
]


def _check_boundary(question: str) -> tuple[bool, str]:
    """Check if question is out of scope. Returns (is_out_of_scope, redirect_hint)."""
    q = question.strip()
    for pattern, category, hint in OOS_PATTERNS:
        if _re.search(pattern, q):
            logger.info("Out-of-scope detected: category='%s', question='%s'", category, q[:80])
            return True, hint
    return False, ""


# ── Node Functions ───────────────────────────────────────────────

async def node_rewrite_question(state: AgentState) -> dict:
    history = state.get("history") or []
    question = state["question"]

    # No history: skip the LLM call, but add keyword-based variants for free
    if not history:
        variants = _fast_variants(question)
        return {"rewritten_question": question, "query_variants": variants}

    # Use last 2 exchanges only
    history_str = ""
    for msg in history[-4:]:
        role = "用户" if msg["role"] == "user" else "助手"
        history_str += f"{role}: {msg['content'][:100]}\n"

    prompt = QUESTION_REWRITE_PROMPT.format(history=history_str, question=question)

    try:
        response = await chat_complete([{"role": "user", "content": prompt}], temperature=0.3, max_tokens=100)
        lines = response.choices[0].message.content.strip().split("\n")
        lines = [l.strip().lstrip("1234567890. -") for l in lines if l.strip()]
        rewritten = lines[0] if lines else question
        variants = [v for v in lines[1:3] if len(v) > 3]
        return {"rewritten_question": rewritten or question, "query_variants": variants}
    except Exception:
        return {"rewritten_question": question, "query_variants": []}


def _fast_variants(question: str) -> list[str]:
    """Generate 1-2 keyword-based query variants without an LLM call."""
    q = question.strip()
    variants = []
    # Heuristic: create a shorter version by removing question words
    for prefix in ["什么是", "解释一下", "如何", "怎么", "请说明"]:
        if q.startswith(prefix) and len(q) > len(prefix) + 2:
            variants.append(q[len(prefix):])
            break
    # Add a version with "原理" or "面试" angle
    if "原理" not in q and "面试" not in q:
        variants.append(q.rstrip("？?") + "原理")
    return [v for v in variants if v != q and len(v) > 3][:2]


def _cross_query_rrf(doc_lists: list[list[dict]], k: int = 60) -> list[dict]:
    """Merge ranked doc lists from multiple queries using RRF. Best rank across queries wins."""
    scores: dict[str, float] = {}
    docs_map: dict[str, dict] = {}

    for docs in doc_lists:
        for rank, doc in enumerate(docs, 1):
            key = _doc_key(doc)
            rrf = 1 / (k + rank)
            if rrf > scores.get(key, 0):
                scores[key] = rrf
                docs_map[key] = doc

    sorted_keys = sorted(scores, key=scores.get, reverse=True)
    return [docs_map[key] for key in sorted_keys]


def _doc_key(doc: dict) -> str:
    """Stable dedup key: kp_id + chunk_index uniquely identifies each chunk."""
    return f"{doc.get('kp_id')}:{doc.get('chunk_index', 0)}"


async def node_retrieve(state: AgentState) -> dict:
    """Adaptive multi-query hybrid retrieval with weighted RRF + HyDE.

    Classifies question type → picks optimal dense/sparse weights and top_k.
    Vague/conceptual questions trigger HyDE: LLM generates a hypothetical answer
    that is used as the dense query for better semantic retrieval.
    """
    t0 = time.perf_counter()
    question = state.get("rewritten_question") or state["question"]
    variants = state.get("query_variants") or []
    vs = get_vectorstore()
    collection = vs._collection
    kb_id = state.get("kb_id", "smart_learning")

    route = _route_query(question)

    # HyDE: generate hypothetical answer for vague/conceptual questions.
    # Fire HyDE + sparse retrieval in parallel (both are I/O-bound).
    import asyncio as _asyncio

    hypo = None
    if route["use_hyde"]:
        hyde_task = _asyncio.create_task(_generate_hypothetical_answer(question))
        sparse_task = _asyncio.create_task(sparse_retrieve(kb_id, question))
        hypo = await hyde_task
        sparse_docs = await sparse_task
    else:
        sparse_docs = await sparse_retrieve(kb_id, question)

    dense_query = hypo if hypo else question

    # Run main dense query + variant queries in parallel
    tasks = [dense_retrieve(collection, dense_query, top_k=settings.dense_top_k)]
    tasks += [dense_retrieve(collection, v, top_k=settings.dense_top_k) for v in variants[:2]]
    dense_results = await _asyncio.gather(*tasks)

    # Fuse each dense result with the shared sparse result
    fused = []
    for dense_docs in dense_results:
        if dense_docs or sparse_docs:
            fused.append(rrf_fusion(dense_docs, sparse_docs,
                                    dense_weight=route["dense_weight"],
                                    sparse_weight=route["sparse_weight"]))
        else:
            fused.append([])

    if len(fused) > 1:
        docs = _cross_query_rrf(fused)[:route["top_k"]]
    else:
        docs = fused[0][:route["top_k"]] if fused else []

    elapsed = time.perf_counter() - t0
    record_retrieve(elapsed * 1000)
    logger.info("⏱ retrieve: %.2fs, queries=%d, docs=%d, route=(dw=%.1f,sw=%.1f,k=%d), hyde=%s",
                elapsed, len(dense_results), len(docs),
                route["dense_weight"], route["sparse_weight"], route["top_k"],
                "yes" if hypo else "no")
    return {"retrieved_docs": docs}


async def node_check_tools(state: AgentState) -> dict:
    """Run detected backend tools in parallel, with 5-min Redis cache."""
    question = state.get("rewritten_question") or state["question"]
    tool_names = detect_tools(question)
    if not tool_names:
        return {"tool_results": None, "tools_used": []}

    name_to_fn = {t.name: t for t in ALL_TOOLS}
    t0 = time.perf_counter()

    # Extract user ID from token for cache key isolation
    try:
        token_val = _jwt_token.get()
    except LookupError:
        token_val = None
    uid = token_val or "anon"

    async def run_one(name):
        # Check cache first
        cached = tool_cache_get(name, uid)
        if cached:
            return cached

        fn = name_to_fn.get(name)
        if fn:
            try:
                result = await fn.ainvoke({})
                if result:
                    tool_cache_set(name, result, uid)
                return result
            except Exception as e:
                logger.warning("Tool %s failed: %s", name, e)
                return None
        return None

    import asyncio
    tool_outputs = await asyncio.gather(*[run_one(n) for n in tool_names])
    logger.info("⏱ node_check_tools (with cache): %.2fs", time.perf_counter() - t0)

    results = []
    for name, output in zip(tool_names, tool_outputs):
        if output:
            results.append(f"【{name}】\n{output}")

    return {
        "tool_results": "\n\n".join(results) if results else None,
        "tools_used": tool_names,
    }


def _estimate_tokens(text: str) -> int:
    """Rough token estimate for Chinese-heavy text. ~2 chars per token on average."""
    return max(1, len(text) // 2)


# Context budget: reserve ~1024 tokens for the answer, keep total context manageable
MAX_CONTEXT_TOKENS = 3200


# Cache for history summaries (cheap in-memory, avoids re-summarizing same prefix)
_summary_cache: dict[str, str] = {}


async def _summarize_history(history: list[dict]) -> str | None:
    """Summarize old history when conversation gets long. Returns summary or None."""
    if not history or len(history) <= 6:
        return None

    # Only summarize if we have at least 8 messages and the prefix isn't cached
    prefix = history[:-3]  # Keep last 3 exchanges raw
    if len(prefix) < 4:
        return None

    cache_key = str(hash(tuple((m.get("role"), m.get("content", "")[:50]) for m in prefix)))
    if cache_key in _summary_cache:
        return _summary_cache[cache_key]

    history_text = ""
    for m in prefix:
        role = "用户" if m["role"] == "user" else "助手"
        history_text += f"{role}: {m['content'][:200]}\n"

    try:
        prompt = SUMMARIZE_HISTORY_PROMPT.format(history=history_text)
        resp = await chat_complete(
            [{"role": "user", "content": prompt}],
            temperature=0.3, max_tokens=200,
        )
        summary = resp.choices[0].message.content.strip()
        _summary_cache[cache_key] = summary
        return summary
    except Exception as e:
        logger.warning("History summary failed: %s", e)
        return None


def _build_messages(
    question: str,
    docs: list[dict],
    tool_results: str | None,
    history: list[dict],
    need_retrieval: bool = True,
    history_summary: str | None = None,
) -> list[dict]:
    """Build structured messages (system + user) with context budget management."""
    # Build context sections
    if need_retrieval:
        docs_str = _format_docs_grouped(docs) if docs else ""
    else:
        docs_str = ""  # RAG was intentionally skipped — no knowledge base section

    # Include summary for long conversations
    if history_summary:
        history_str = f"【对话摘要】{history_summary}\n\n---\n\n{_format_history(history[-3:], max_chars=200)}"
    else:
        history_str = _format_history(history)
    tools_str = tool_results or ""

    # Use a lighter context template when RAG is skipped
    if not need_retrieval and not tools_str:
        # Pure chitchat — skip heavy context sections
        context = f"\n## 用户问题\n{question}"
    else:
        context = CONTEXT_INSTRUCTIONS.format(
            tool_results=tools_str or "(无)",
            docs=docs_str or "(知识库未找到相关内容)",
            history=history_str,
            question=question,
        )
    total_tokens = _estimate_tokens(SYSTEM_PROMPT) + _estimate_tokens(context)
    if total_tokens > MAX_CONTEXT_TOKENS:
        # Trim docs first (they're usually the largest)
        excess = total_tokens - MAX_CONTEXT_TOKENS
        docs_str = _format_docs_grouped(docs, max_content_chars=400)
        context = CONTEXT_INSTRUCTIONS.format(
            tool_results=tools_str or "(无)",
            docs=docs_str or "(知识库未找到相关内容)",
            history=history_str,
            question=question,
        )
        # If still over, trim history
        if _estimate_tokens(SYSTEM_PROMPT) + _estimate_tokens(context) > MAX_CONTEXT_TOKENS:
            history_str = _format_history(history, max_chars=60)
            context = CONTEXT_INSTRUCTIONS.format(
                tool_results=tools_str or "(无)",
                docs=docs_str or "(知识库未找到相关内容)",
                history=history_str,
                question=question,
            )

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
    ]

    # Inject history as structured messages (not just text)
    if history:
        for msg in history[-6:]:
            role = "assistant" if msg["role"] == "assistant" else "user"
            content = msg["content"]
            if len(content) > 200:
                content = content[:200] + "..."
            messages.append({"role": role, "content": content})

    messages.append({"role": "user", "content": context})
    return messages


async def _self_check(answer: str) -> tuple[bool, str]:
    """Quick self-check: does the answer cite sources and avoid hallucination?"""
    if not answer or len(answer) < 50:
        return True, ""
    try:
        prompt = SELF_CHECK_PROMPT.format(answer=answer[:2000])
        resp = await chat_complete(
            [{"role": "user", "content": prompt}],
            temperature=0.0, max_tokens=80,
        )
        result = resp.choices[0].message.content.strip()
        if result.upper().startswith("FAIL"):
            reason = result[4:].strip().lstrip("-").strip()
            return False, reason or "质量检查未通过"
        return True, ""
    except Exception:
        return True, ""  # don't block on check failure


async def _generate_follow_ups(question: str, answer: str) -> list[str]:
    """Generate 2-3 follow-up questions based on the answer."""
    if not answer or len(answer) < 100:
        return []
    try:
        prompt = FOLLOW_UP_PROMPT.format(question=question[:300], answer=answer[:1500])
        resp = await chat_complete(
            [{"role": "user", "content": prompt}],
            temperature=0.6, max_tokens=150,
        )
        lines = resp.choices[0].message.content.strip().split("\n")
        return [line.strip().lstrip("1234567890. -") for line in lines if line.strip()][:3]
    except Exception as e:
        logger.warning("Follow-up generation failed: %s", e)
        return []


def _fallback_response(question: str, docs: list[dict]) -> str:
    """Build a degraded response from retrieved docs when LLM is unavailable."""
    if not docs:
        return "抱歉，AI 服务暂时不可用，且未找到相关知识点。请稍后重试。"
    parts = ["## AI 服务暂时不可用\n\n以下是根据你的问题检索到的相关知识点，供参考：\n"]
    for i, d in enumerate(docs[:5], 1):
        parts.append(f"### [{i}] {d.get('kp_name', '')}")
        if d.get("description"):
            parts.append(f"**摘要**: {d['description']}")
        parts.append(d["content"][:500])
        parts.append("")
    parts.append("---\n*AI 服务恢复后会自动切换回正常模式，请稍后再试。*")
    return "\n".join(parts)


OUT_OF_SCOPE_TEMPLATE = """## 抱歉，这个请求超出了我的能力范围

{redirect_hint}

---

**我擅长的事情**：
- 解释技术概念和原理（JVM、数据结构、算法、网络协议等）
- 分析面试高频考点并提供解题思路
- 回答课程知识库中的问题（{course_hint}）
- 查询你的学习记录、掌握度、推荐学习计划

试试问我：Java 的垃圾回收机制是什么？HashMap 为什么线程不安全？如何设计一个高并发系统？"""


def _get_course_hint() -> str:
    """Get a short hint about available courses."""
    try:
        vs = get_vectorstore()
        data = vs._collection.get(include=["metadatas"], limit=50)
        courses = set()
        if data and data["metadatas"]:
            for m in data["metadatas"]:
                if m.get("course_name"):
                    courses.add(m["course_name"])
        if courses:
            return "、".join(sorted(courses)[:5])
    except Exception:
        pass
    return "Java、数据结构、数据库等"


def _refuse_response(redirect_hint: str) -> str:
    return OUT_OF_SCOPE_TEMPLATE.format(
        redirect_hint=redirect_hint,
        course_hint=_get_course_hint(),
    )


# ── Build Graph ──────────────────────────────────────────────────

# ── Keywords that signal knowledge-seeking (needs RAG) ──────────

RAG_TRIGGERS = [
    "是什么", "什么是", "什么意思", "解释", "原理", "怎么", "如何",
    "区别", "对比", "比较", "定义", "概念", "有哪些", "几种", "分类",
    "实现", "源码", "底层", "源码", "HashMap", "JVM", "并发", "线程",
    "算法", "数据结构", "设计模式", "框架", "Spring", "Redis", "MySQL",
    "Java", "Python", "Go", "Rust", "C++", "数据库", "缓存", "消息队列",
    "分布式", "微服务", "网络", "HTTP", "TCP", "操作系统", "内存",
    "CAP", "RPC", "REST", "API", "OOP", "AOP", "IOC", "GC",
    "知识", "学习", "课程", "考试", "考点", "面试",
    "代码", "示例", "例子", "怎么写", "用法", "语法",
    "为什么", "原因", "作用", "用途", "特点", "优缺点",
]

CHITCHAT_PATTERNS = [
    r"^(你好|hi|hello|嘿|嗨)[\s!！。.,，]*$",
    r"^(谢谢|感谢|多谢|thanks|thank)[\s!！。.,，]*$",
    r"^(你是谁|你叫什么|你是做什么的|你的名字)[\s?？!！。]*$",
    r"^(再见|拜拜|bye|回头见)[\s!！。.,，]*$",
    r"^(今天|明天|昨天).*(星期几|几号|日期|天气)",
    r"^(好吧|嗯|哦|好的|ok|OK|行|可以)[\s!！。.,，]*$",
    r"^(你会|你能).*(做什么|干嘛|什么|哪些)",
    r"^(讲个|说个).*(笑话|故事)",
]


def _needs_rag(question: str) -> bool:
    """Fast heuristic: does this question need knowledge retrieval?"""
    q = question.strip().lower()

    # Very short questions usually don't need RAG
    if len(q) <= 2:
        return False

    # Check chitchat patterns first
    import re
    for pat in CHITCHAT_PATTERNS:
        if re.match(pat, question.strip()):
            return False

    # Check knowledge-seeking triggers
    for kw in RAG_TRIGGERS:
        if kw.lower() in q:
            return True

    # Default: if short (< 10 chars and no trigger matched), skip RAG
    # Longer questions likely need knowledge context
    return len(q) >= 10


async def node_classify(state: AgentState) -> dict:
    question = state.get("rewritten_question") or state["question"]
    out_of_scope, redirect_hint = _check_boundary(question)
    need = _needs_rag(question) if not out_of_scope else False
    if out_of_scope:
        inc_oos()
    elif not need:
        inc_chitchat()
    else:
        inc_rag()
    logger.info("classify: need_rag=%s out_of_scope=%s for '%s'", need, out_of_scope, question[:60])
    return {"need_retrieval": need, "out_of_scope": out_of_scope, "redirect_hint": redirect_hint}


def build_graph() -> StateGraph:
    workflow = StateGraph(AgentState)

    workflow.add_node("rewrite_question", node_rewrite_question)
    workflow.add_node("classify", node_classify)
    workflow.add_node("retrieve", node_retrieve)
    workflow.add_node("check_tools", node_check_tools)
    # Note: generation happens outside the graph (streaming or non-streaming)

    workflow.set_entry_point("rewrite_question")
    workflow.add_edge("rewrite_question", "classify")

    def route_after_classify(state: AgentState) -> str:
        if state.get("need_retrieval"):
            return "retrieve"
        return "check_tools"

    workflow.add_conditional_edges("classify", route_after_classify, {
        "retrieve": "retrieve",
        "check_tools": "check_tools",
    })
    workflow.add_edge("retrieve", "check_tools")
    workflow.add_edge("check_tools", END)

    return workflow


_graph = None


def get_graph():
    global _graph
    if _graph is None:
        _graph = build_graph().compile()
    return _graph


# ── Helpers ──────────────────────────────────────────────────────

def _format_history(history: list[dict], max_chars: int = 150) -> str:
    if not history:
        return "(无历史对话)"
    lines = []
    for msg in history[-4:]:
        role = "用户" if msg["role"] == "user" else "助手"
        lines.append(f"{role}: {msg['content'][:max_chars]}")
    return "\n".join(lines)


def _format_docs_grouped(docs: list[dict], max_content_chars: int = 800) -> str:
    """Group retrieved chunks by parent KP, merge content for coherent context."""
    from collections import OrderedDict
    groups: OrderedDict[str, list[dict]] = OrderedDict()

    for d in docs:
        kp_id = d.get("kp_id")
        if kp_id not in groups:
            groups[kp_id] = []
        groups[kp_id].append(d)

    ctx = ""
    idx = 1
    chunk_limit = max_content_chars
    multi_chunk_limit = max(300, max_content_chars // 2)

    for kp_id, chunks in groups.items():
        chunks.sort(key=lambda d: d.get("chunk_index", 0))
        kp_name = chunks[0].get("kp_name", "")
        course = chunks[0].get("course_name", "")
        desc = chunks[0].get("description", "")
        ctype = chunks[0].get("content_type", "")

        # Build metadata badges line
        badges = []
        if ctype:
            badges.append(f"类型:{ctype}")
        for c in chunks:
            if c.get("has_code"):
                badges.append("含代码")
                break
        badge_str = f" [{', '.join(badges)}]" if badges else ""

        # Description summary
        desc_line = f" 摘要: {desc}\n" if desc else ""

        if len(chunks) == 1:
            ctx += f"[{idx}] {kp_name}（{course}）{badge_str}\n{desc_line}\n{chunks[0]['content'][:chunk_limit]}\n\n"
        else:
            merged = ""
            for c in chunks:
                section = c.get("section", "")
                ctype_tag = f"[{c.get('content_type', '')}] " if c.get('content_type') else ""
                label = f"【{section}】{ctype_tag}" if section else ctype_tag
                merged += f"{label}\n{c['content'][:multi_chunk_limit]}\n"
            ctx += f"[{idx}] {kp_name}（{course}）{badge_str} ({len(chunks)}个片段)\n{desc_line}\n{merged}\n"
        idx += 1

    return ctx


def _dedup_sources(docs: list[dict]) -> list[dict]:
    """Deduplicate sources by kp_id, keeping first occurrence order."""
    seen = set()
    result = []
    for d in docs:
        kp_id = d.get("kp_id")
        if kp_id and kp_id not in seen:
            seen.add(kp_id)
            result.append({
                "kp_name": d.get("kp_name", ""),
                "course_name": d.get("course_name", ""),
                "kp_id": kp_id,
                "description": d.get("description", ""),
            })
    return result


# ── Public API ───────────────────────────────────────────────────

async def run_agent(
    question: str,
    history: list[dict] | None = None,
    jwt_token: str | None = None,
) -> dict:
    t0 = time.perf_counter()

    # Input safety check
    is_safe, reason = await check_input_safety(question)
    if not is_safe:
        return {
            "answer": f"您的输入包含不当内容，已被拒绝：{reason}",
            "sources": [],
            "rewritten_question": question,
            "tools_used": [],
        }

    set_token(jwt_token)

    graph = get_graph()
    result = await graph.ainvoke({
        "messages": [HumanMessage(content=question)],
        "question": question,
        "kb_id": "smart_learning",
        "history": history or [],
        "rewritten_question": None,
        "query_variants": None,
        "retrieved_docs": None,
        "tool_results": None,
        "answer": None,
        "sources": None,
        "tools_used": None,
        "need_retrieval": None,
        "out_of_scope": None,
        "redirect_hint": None,
    })
    t1 = time.perf_counter()
    record_graph((t1 - t0) * 1000)
    inc_request()

    # Out-of-scope: return polite refusal early
    if result.get("out_of_scope"):
        return {
            "answer": _refuse_response(result.get("redirect_hint", "")),
            "sources": [],
            "rewritten_question": question,
            "tools_used": [],
            "follow_ups": [],
        }

    # LLM generation after graph completes retrieval + tool checking
    question_text = result.get("rewritten_question") or question
    docs = result.get("retrieved_docs") or []
    tool_results = result.get("tool_results")
    need_retrieval = result.get("need_retrieval", True)
    history_list = history or []

    summary = await _summarize_history(history_list)
    messages = _build_messages(question_text, docs, tool_results, history_list, need_retrieval, summary)
    try:
        response = await chat_complete(messages, temperature=0.7, max_tokens=1024)
        answer = response.choices[0].message.content
    except Exception as e:
        logger.error("LLM generation failed, using fallback: %s", e)
        answer = _fallback_response(question_text, docs)
        return {
            "answer": answer,
            "sources": _dedup_sources(docs) if need_retrieval else [],
            "rewritten_question": question_text,
            "tools_used": [],
            "follow_ups": [],
        }
    t2 = time.perf_counter()

    # Output safety check
    context_snippet = question_text[:500]
    out_safe, out_reason = await check_output_safety(answer, context_snippet)
    if not out_safe:
        answer = f"生成的内容被安全过滤器拦截：{out_reason}"

    # Self-check + follow-ups in parallel for RAG answers
    import asyncio as _asyncio
    if need_retrieval and docs:
        check_task = _asyncio.create_task(_self_check(answer))
        follow_task = _asyncio.create_task(_generate_follow_ups(question_text, answer))
        passed, msg = await check_task
        follow_ups = await follow_task
        if not passed:
            logger.warning("Self-check failed: %s, regenerating...", msg)
            try:
                retry_messages = _build_messages(question_text, docs, tool_results, history_list, need_retrieval, summary)
                retry_messages.append({"role": "user", "content": f"你上一次回答被驳回，原因：{msg}。请重新回答，务必标注知识库来源编号。只需给出修改后的回答，不要道歉。"})
                retry_resp = await chat_complete(retry_messages, temperature=0.7, max_tokens=1024)
                answer = retry_resp.choices[0].message.content
                follow_ups = await _generate_follow_ups(question_text, answer)
            except Exception as e:
                logger.error("Retry generation also failed: %s", e)
                # Keep original answer, follow_ups already set from first pass
    else:
        follow_ups = []

    sources = _dedup_sources(docs) if need_retrieval else []
    logger.info("⏱ run_agent: graph=%.2fs, llm=%.2fs, total=%.2fs",
                t1 - t0, t2 - t1, t2 - t0)

    record_llm((t2 - t1) * 1000)
    record_total((t2 - t0) * 1000)

    return {
        "answer": answer,
        "sources": sources,
        "rewritten_question": result.get("rewritten_question", question),
        "tools_used": result.get("tools_used", []),
        "follow_ups": follow_ups,
    }


async def run_agent_stream(
    question: str,
    history: list[dict] | None = None,
    jwt_token: str | None = None,
) -> AsyncGenerator[dict, None]:
    """Streaming agent: runs graph (retrieval + tools), then streams generation token by token."""
    inc_request()
    stream_t0 = time.perf_counter()

    # Input safety check
    is_safe, reason = await check_input_safety(question)
    if not is_safe:
        yield {"event": "error", "data": f"内容安全拒绝：{reason}"}
        return

    set_token(jwt_token)

    initial_state = {
        "messages": [HumanMessage(content=question)],
        "question": question,
        "kb_id": "smart_learning",
        "history": history or [],
        "rewritten_question": None,
        "query_variants": None,
        "retrieved_docs": None,
        "tool_results": None,
        "answer": None,
        "sources": None,
        "tools_used": None,
        "need_retrieval": None,
        "out_of_scope": None,
        "redirect_hint": None,
    }

    graph = get_graph()
    final_state: dict = {}

    yield {"event": "status", "data": "thinking"}

    async for event in graph.astream(initial_state):
        node_name = list(event.keys())[0]
        node_data = event[node_name]

        for k, v in node_data.items():
            final_state[k] = v

        yield {"event": "node", "data": node_name}

    # Out-of-scope: return polite refusal early, no LLM call
    if final_state.get("out_of_scope"):
        refusal = _refuse_response(final_state.get("redirect_hint", ""))
        yield {"event": "token", "data": refusal}
        yield {"event": "done", "data": {
            "answer": refusal,
            "sources": [],
            "tools_used": [],
            "output_safe": True,
            "follow_ups": [],
        }}
        return

    # Build generation prompt from final state
    question_text = final_state.get("rewritten_question") or question
    docs = final_state.get("retrieved_docs") or []
    tool_results = final_state.get("tool_results")
    need_retrieval = final_state.get("need_retrieval", True)
    history_list = history or []

    summary = await _summarize_history(history_list)
    messages = _build_messages(question_text, docs, tool_results, history_list, need_retrieval, summary)

    yield {"event": "status", "data": "generating"}

    full_answer = ""
    t_gen_start = time.perf_counter()
    try:
        response = await chat_complete(
            messages,
            stream=True,
            temperature=0.7,
            max_tokens=1024,
        )
        async for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content:
                content = chunk.choices[0].delta.content
                full_answer += content
                yield {"event": "token", "data": content}
    except Exception as e:
        logger.exception("Stream generation failed, using fallback")
        fallback = _fallback_response(question_text, docs)
        yield {"event": "token", "data": fallback}
        yield {"event": "done", "data": {
            "answer": fallback,
            "sources": _dedup_sources(docs) if need_retrieval else [],
            "tools_used": [],
            "output_safe": True,
            "follow_ups": [],
        }}
        return

    sources = _dedup_sources(docs)

    # Output safety check + parallel self-check & follow-ups
    import asyncio as _asyncio
    context_snippet = question_text[:500]

    async def _post_tasks():
        out_safe, out_reason = await check_output_safety(full_answer, context_snippet)
        if need_retrieval and docs:
            check_task = _asyncio.create_task(_self_check(full_answer))
            follow_task = _asyncio.create_task(_generate_follow_ups(question_text, full_answer))
            passed, msg = await check_task
            follow_ups = await follow_task
        else:
            passed, msg = True, ""
            follow_ups = []
        return out_safe, out_reason, passed, msg, follow_ups

    out_safe, out_reason, passed, msg, follow_ups = await _post_tasks()

    if not passed:
        logger.warning("Stream self-check failed: %s", msg)
        yield {"event": "token", "data": f"\n\n---\n*【自动检测】本次回答可能缺少来源标注，建议追问获取更可靠的解释。*"}

    llm_ms = (time.perf_counter() - t_gen_start) * 1000
    record_llm(llm_ms)
    record_total((time.perf_counter() - stream_t0) * 1000)

    yield {"event": "done", "data": {
        "answer": full_answer if out_safe else f"生成的内容被安全过滤器拦截：{out_reason}",
        "sources": sources,
        "tools_used": final_state.get("tools_used", []),
        "output_safe": out_safe,
        "follow_ups": follow_ups,
    }}
