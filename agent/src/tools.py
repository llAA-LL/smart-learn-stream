"""
Agent tools: functions the agent can call to interact with the Java backend.
JWT token is passed via context variable from the agent invocation.
"""
import logging
from contextvars import ContextVar

import aiohttp
from langchain_core.tools import tool

log = logging.getLogger(__name__)

BACKEND_URL = None
_jwt_token: ContextVar[str | None] = ContextVar("jwt_token", default=None)
_session: aiohttp.ClientSession | None = None


def set_backend_url(url: str):
    global BACKEND_URL
    BACKEND_URL = url.rstrip("/")


async def _get_session() -> aiohttp.ClientSession:
    global _session
    if _session is None or _session.closed:
        timeout = aiohttp.ClientTimeout(total=15)
        _session = aiohttp.ClientSession(timeout=timeout)
    return _session


def set_token(token: str | None):
    _jwt_token.set(token)


async def _get(path: str) -> dict:
    headers = {}
    token = _jwt_token.get()
    if token:
        headers["Authorization"] = f"Bearer {token}"
    session = await _get_session()
    async with session.get(f"{BACKEND_URL}{path}", headers=headers) as resp:
        resp.raise_for_status()
        return await resp.json()


@tool
async def get_user_learning_records() -> str:
    """获取当前用户的所有学习记录,包括学习了哪些知识点、学习次数、每次学习的时长和自评分数。用于回答"我的学习进度"、"最近学了什么"、"学习情况怎么样"等问题。"""
    data = await _get("/records")
    records = data.get("data", [])
    if not records:
        return "暂无学习记录，建议先去学习一些知识点。"
    result = []
    for r in records[:20]:
        result.append(
            f"- [{r.get('kpName', '未知')}] "
            f"学习{r.get('learnCount', 0)}次, "
            f"掌握度{r.get('masteryScore', 0)}分, "
            f"最近学习: {r.get('lastLearnTime', '未知')}"
        )
    return "\n".join(result)


@tool
async def get_user_mastery() -> str:
    """获取当前用户对所有知识点的掌握度评分。用于回答"我哪些知识点掌握得好/不好"、"我的薄弱环节是什么"等问题。"""
    data = await _get("/records/mastery")
    items = data.get("data", [])
    if not items:
        return "暂无掌握度数据。"
    result = ["知识点掌握度："]
    for m in items[:30]:
        score = m.get("masteryScore", 0)
        status = "优秀" if score >= 80 else "良好" if score >= 60 else "薄弱"
        result.append(f"- {m.get('kpName', '未知')}: {score}分 ({status})")
    return "\n".join(result)


@tool
async def get_quiz_history() -> str:
    """获取当前用户的自测历史记录。用于回答"我的自测成绩怎么样"、"最近测试了哪些知识点"等问题。"""
    data = await _get("/quiz/history")
    items = data.get("data", [])
    if not items:
        return "暂无自测记录，建议去知识点自测页面进行测试。"
    result = ["最近自测记录："]
    for q in items[:10]:
        result.append(
            f"- {q.get('kpName', '未知')}: {q.get('score', 0)}分 "
            f"({q.get('correctCount', 0)}/{q.get('totalQuestions', 0)}正确) "
            f"时间: {q.get('completedAt', '未知')}"
        )
    return "\n".join(result)


@tool
async def get_recommendations() -> str:
    """获取系统为用户推荐的学习路径和薄弱知识点。用于回答"我接下来应该学什么"、"系统给我推荐了什么"等问题。"""
    rec_data = await _get("/recommendations")
    weak_data = await _get("/recommendations/weak-points")
    recs = rec_data.get("data", [])
    weaks = weak_data.get("data", [])

    result = []
    if recs:
        result.append("推荐学习：")
        for r in recs[:5]:
            result.append(f"- [{r.get('type', '')}] {r.get('kpName', '')}: {r.get('reason', '')}")
    if weaks:
        result.append("\n薄弱知识点：")
        for w in weaks[:5]:
            result.append(f"- {w.get('kpName', '')}: 掌握度 {w.get('masteryScore', 0)}分")
    if not result:
        return "暂无推荐数据，建议先进行一些学习和自测。"
    return "\n".join(result)


@tool
async def get_learning_plans() -> str:
    """获取当前用户的学习计划。用于回答"我的学习计划是什么"、"计划进度如何"等问题。"""
    data = await _get("/plans")
    plans = data.get("data", [])
    if not plans:
        return "暂无学习计划，可以在学习计划页面创建。"
    result = ["当前学习计划："]
    for p in plans[:5]:
        items = p.get("items", [])
        total = len(items)
        done = sum(1 for i in items if i.get("completed"))
        result.append(
            f"- {p.get('title', '未命名')} [{p.get('status', '')}] "
            f"进度: {done}/{total} ({p.get('progressPercent', 0)}%)"
        )
    return "\n".join(result)


@tool
async def get_user_stats() -> str:
    """获取用户学习统计数据（总学习次数、总时长、活跃天数等）。用于回答"我总共学了多少"等统计类问题。"""
    data = await _get("/records/stats")
    stats = data.get("data", {})
    if not stats:
        return "暂无统计数据。"
    return (
        f"学习统计：\n"
        f"- 总学习记录: {stats.get('totalRecords', 0)}条\n"
        f"- 覆盖知识点: {stats.get('totalKps', 0)}个\n"
        f"- 总学习时长: {stats.get('totalMinutes', 0)}分钟\n"
        f"- 平均掌握度: {stats.get('avgMastery', 0)}分\n"
        f"- 活跃天数: {stats.get('activeDays', 0)}天"
    )


ALL_TOOLS = [
    get_user_learning_records,
    get_user_mastery,
    get_quiz_history,
    get_recommendations,
    get_learning_plans,
    get_user_stats,
]
