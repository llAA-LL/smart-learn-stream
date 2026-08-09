"""Centralized settings loaded from environment variables."""
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # DeepSeek / LLM
    deepseek_api_key: str = ""
    deepseek_base_url: str = "https://api.deepseek.com"
    llm_model: str = "deepseek-chat"

    # Embedding
    embedding_model: str = "BAAI/bge-small-zh-v1.5"

    # Reranker (local cross-encoder, no API call)
    reranker_model: str = "BAAI/bge-reranker-base"

    # Backend
    java_backend_url: str = "http://localhost:9090/api"

    # Storage
    chroma_persist_dir: str = "./data/chroma"
    bm25_persist_dir: str = "./data/bm25"

    # RAG parameters
    dense_top_k: int = 20
    sparse_top_k: int = 20
    rerank_top_k: int = 6
    max_history_turns: int = 10

    # Text chunking
    chunk_size: int = 800
    chunk_overlap: int = 150

    # Safety
    enable_safety_check: bool = False

    # Server
    host: str = "0.0.0.0"
    port: int = 5002

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
