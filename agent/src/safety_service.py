"""Input/output safety guardrails using LLM-based checks."""
import logging
from llm_service import chat_complete
from prompts import INPUT_SAFETY_PROMPT, OUTPUT_SAFETY_PROMPT
from config import settings

logger = logging.getLogger(__name__)


async def check_input_safety(question: str) -> tuple[bool, str]:
    """Check if user input is safe. Returns (is_safe, reason)."""
    if not settings.enable_safety_check:
        return True, ""

    prompt = INPUT_SAFETY_PROMPT.format(question=question)
    messages = [
        {"role": "system", "content": "You are a content safety filter. Reply with one word only."},
        {"role": "user", "content": prompt},
    ]

    try:
        response = await chat_complete(messages, temperature=0.0, max_tokens=100)
        result = response.choices[0].message.content.strip()

        if result.upper().startswith("SAFE"):
            return True, ""
        reason = result.replace("UNSAFE", "").strip().lstrip("-").strip()
        return False, reason or "Content violates safety policy"
    except Exception as e:
        logger.warning("Input safety check failed (allowing): %s", e)
        return True, ""


async def check_output_safety(answer: str, context: str) -> tuple[bool, str]:
    """Check if generated output is safe. Returns (is_safe, reason)."""
    if not settings.enable_safety_check:
        return True, ""

    prompt = OUTPUT_SAFETY_PROMPT.format(answer=answer, context=context[:3000])
    messages = [
        {"role": "system", "content": "You are a content safety filter. Reply with one word only."},
        {"role": "user", "content": prompt},
    ]

    try:
        response = await chat_complete(messages, temperature=0.0, max_tokens=100)
        result = response.choices[0].message.content.strip()

        if result.upper().startswith("SAFE"):
            return True, ""
        reason = result.replace("UNSAFE", "").strip().lstrip("-").strip()
        return False, reason or "Generated content violates safety policy"
    except Exception as e:
        logger.warning("Output safety check failed (allowing): %s", e)
        return True, ""
