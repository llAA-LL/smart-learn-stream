"""
RAG service: manages ChromaDB vector store + BM25 index for knowledge points.
Supports semantic text chunking for fine-grained retrieval.
"""
import os
import re
import logging

import aiohttp
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter

from config import settings
from retrieval_service import save_bm25

logger = logging.getLogger(__name__)

_embeddings = None
_vectorstore = None
COLLECTION_NAME = "knowledge_points"
KB_ID = "smart_learning"

# Markdown + Chinese-aware separators: split on headings first, then paragraphs, then sentences
_CHUNK_SEPARATORS = [
    "\n## ",
    "\n### ",
    "\n#### ",
    "\n---",
    "\n\n",
    "\n",
    "。",
    "；",
    "，",
    " ",
    "",
]


def _get_embeddings():
    global _embeddings
    if _embeddings is None:
        _embeddings = HuggingFaceEmbeddings(
            model_name=settings.embedding_model,
            model_kwargs={"device": "cpu"},
            encode_kwargs={"normalize_embeddings": True},
        )
    return _embeddings


def get_vectorstore() -> Chroma:
    global _vectorstore
    if _vectorstore is None:
        _vectorstore = Chroma(
            collection_name=COLLECTION_NAME,
            embedding_function=_get_embeddings(),
            persist_directory=settings.chroma_persist_dir,
        )
    return _vectorstore


def _extract_section_title(text: str) -> str:
    """Extract the first heading from a chunk for use as section title."""
    m = re.search(r"^#{1,4}\s*(.+)", text, re.MULTILINE)
    return m.group(1).strip() if m else ""


def _detect_content_features(text: str) -> dict:
    """Detect content features for metadata tagging."""
    has_code = bool(re.search(r"```|`[^`]+`|\bprint\b|\bdef\b|\bclass\b|\bimport\b|\bvar\b|\bfunction\b", text))
    has_table = bool(re.search(r"\|.*\|.*\|", text))
    has_list = bool(re.search(r"(^|\n)[\s]*[-*+]\s|[\s]*\d+[.、]\s", text, re.MULTILINE))
    has_formula = bool(re.search(r"[=≈≠≤≥∑∏∫√∞αβγδελμπσφω]", text))

    # Content type classification
    code_lines = len(re.findall(r"```", text)) // 2
    total_lines = text.count("\n") + 1
    code_ratio = code_lines / total_lines if total_lines > 0 else 0

    if code_ratio > 0.3:
        content_type = "代码"
    elif has_formula:
        content_type = "公式"
    elif has_list and not has_code:
        content_type = "要点"
    else:
        # Check if it's a contrast/comparison or definition
        if re.search(r"区别|对比|vs\.?|不同|相同|相似", text):
            content_type = "对比"
        elif re.search(r"步骤|流程|首先|然后|最后|第[一二三四五六七八九十\d]+步", text):
            content_type = "步骤"
        else:
            content_type = "概念"

    return {
        "has_code": has_code,
        "has_table": has_table,
        "has_list": has_list,
        "content_type": content_type,
    }


def _split_content(text: str) -> list[str]:
    """Split a knowledge point's full text into semantic chunks."""
    splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
        separators=_CHUNK_SEPARATORS,
        chunk_size=settings.chunk_size,
        chunk_overlap=settings.chunk_overlap,
        encoding_name="cl100k_base",
    )
    chunks = splitter.split_text(text)
    return chunks


async def ingest_knowledge_points(force: bool = False):
    """Fetch KPs from Java backend, chunk, index into ChromaDB and BM25.

    By default, skips re-indexing if data already exists (incremental mode).
    Use force=True or POST /reindex to force a full rebuild.
    """
    global _vectorstore

    if not force and os.path.exists(settings.chroma_persist_dir) and os.listdir(settings.chroma_persist_dir):
        logger.info("ChromaDB already exists, skipping re-index. Use /reindex to rebuild.")
        vs = get_vectorstore()
        count = vs._collection.count()
        logger.info("Existing index: %d documents", count)
        return count

    backend = settings.java_backend_url
    timeout = aiohttp.ClientTimeout(total=30)
    async with aiohttp.ClientSession(timeout=timeout) as session:
        async with session.get(f"{backend}/knowledge-graph/nodes") as resp:
            data = await resp.json()
            kps = data.get("data", [])

    all_docs = []
    all_chunks = []
    all_metadatas = []
    total_chunks = 0

    for kp in kps:
        content = kp.get("learningContent") or ""
        if not content.strip():
            continue

        kp_name = kp.get("name", "")
        course_name = kp.get("courseName", "")
        description = kp.get("description", "") or ""

        # Split only the actual content — not the wrapper header
        chunks = _split_content(content)
        chunk_count = len(chunks)

        for i, chunk_text in enumerate(chunks):
            section = _extract_section_title(chunk_text)
            features = _detect_content_features(chunk_text)
            # Prepend KP context to each chunk so it's self-contained
            chunk_text = f"【{kp_name}】（{course_name}）\n{chunk_text}"
            metadata = {
                "kp_id": kp["id"],
                "name": kp_name,
                "course_name": course_name,
                "course_id": kp.get("courseId"),
                "level": kp.get("level") or 0,
                "description": description,
                "chunk_index": i,
                "chunk_count": chunk_count,
                "section": section,
                **features,
            }
            doc = Document(page_content=chunk_text, metadata=metadata)
            all_docs.append(doc)
            all_chunks.append(chunk_text)
            all_metadatas.append(metadata)
            total_chunks += 1

    if not all_docs:
        logger.warning("No knowledge points with learning content found")
        return 0

    # Reset and re-index from scratch
    import shutil
    shutil.rmtree(settings.chroma_persist_dir, ignore_errors=True)
    shutil.rmtree(settings.bm25_persist_dir, ignore_errors=True)
    _vectorstore = None

    vs = get_vectorstore()
    vs.add_documents(all_docs)
    save_bm25(KB_ID, all_chunks, all_metadatas)
    logger.info(
        "Ingested %d knowledge points → %d chunks (ChromaDB + BM25, chunk_size=%d, overlap=%d)",
        len(kps), total_chunks, settings.chunk_size, settings.chunk_overlap,
    )
    return total_chunks


def search_knowledge(query: str, k: int = 5) -> list[dict]:
    """Simple vector search (used as fallback, main path uses hybrid_retrieve)."""
    vs = get_vectorstore()
    results = vs.similarity_search(query, k=k)
    return [
        {
            "kp_id": doc.metadata.get("kp_id"),
            "name": doc.metadata.get("name", ""),
            "course_name": doc.metadata.get("course_name", ""),
            "chunk_index": doc.metadata.get("chunk_index"),
            "chunk_count": doc.metadata.get("chunk_count"),
            "section": doc.metadata.get("section", ""),
            "content": doc.page_content,
        }
        for doc in results
    ]
