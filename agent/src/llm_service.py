"""LLM service with retry logic, shared by all components."""
import logging
from tenacity import (
    retry, stop_after_attempt, wait_exponential, retry_if_exception_type,
)
from openai import AsyncOpenAI, APIError, APIConnectionError, RateLimitError, APITimeoutError
from config import settings

logger = logging.getLogger(__name__)

_client: AsyncOpenAI | None = None

RETRYABLE = (APIConnectionError, RateLimitError, APITimeoutError)


def get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(
            api_key=settings.deepseek_api_key,
            base_url=settings.deepseek_base_url,
            timeout=60.0,
        )
    return _client


@retry(
    retry=retry_if_exception_type(RETRYABLE),
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    reraise=True,
)
async def chat_complete(
    messages: list[dict],
    *,
    stream: bool = False,
    temperature: float = 0.7,
    max_tokens: int = 2048,
):
    client = get_client()
    return await client.chat.completions.create(
        model=settings.llm_model,
        messages=messages,
        stream=stream,
        temperature=temperature,
        max_tokens=max_tokens,
    )
