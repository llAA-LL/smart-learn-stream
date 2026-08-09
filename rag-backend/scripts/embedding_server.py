# -*- coding: utf-8 -*-
"""
本地推理服务（Embedding + Rerank）
==================================
复用智能学习系统 agent 虚拟环境中的 sentence-transformers：
- POST /embed    bge-small-zh-v1.5 文本向量化（查询侧自动加检索指令）
- POST /rerank   bge-reranker-base 候选片段相关性打分

启动（默认 2 个 worker，可经 EMBDEDDING_WORKERS 调整）：
    E:\\smart-learning-system\\agent\\.venv\\Scripts\\python.exe embedding_server.py
"""
import os

import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import CrossEncoder, SentenceTransformer

QUERY_INSTRUCTION = "为这个句子生成表示以用于检索相关文章："

app = FastAPI(title="Local Inference Service")

print("Loading BAAI/bge-small-zh-v1.5 ...")
MODEL = SentenceTransformer("BAAI/bge-small-zh-v1.5")
print("Loading BAAI/bge-reranker-base ...")
RERANKER = CrossEncoder("BAAI/bge-reranker-base")
print("Models loaded")


class EmbedRequest(BaseModel):
    inputs: list[str]
    is_query: bool = False


class EmbedResponse(BaseModel):
    embeddings: list[list[float]]


class RerankRequest(BaseModel):
    question: str
    candidates: list[str]


class RerankResponse(BaseModel):
    scores: list[float]


@app.post("/embed", response_model=EmbedResponse)
def embed(req: EmbedRequest) -> EmbedResponse:
    texts = [QUERY_INSTRUCTION + text if req.is_query else text for text in req.inputs]
    vectors = MODEL.encode(texts, normalize_embeddings=True, show_progress_bar=False)
    return EmbedResponse(embeddings=[v.tolist() for v in vectors])


@app.post("/rerank", response_model=RerankResponse)
def rerank(req: RerankRequest) -> RerankResponse:
    pairs = [[req.question, candidate] for candidate in req.candidates]
    scores = RERANKER.predict(pairs, show_progress_bar=False)
    return RerankResponse(scores=[float(s) for s in scores])


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "model": "BAAI/bge-small-zh-v1.5", "reranker": "BAAI/bge-reranker-base"}


if __name__ == "__main__":
    # 直接运行脚本时使用单 worker（调试用）；多 worker 请用 start-embedding.ps1
    # 注意：Windows 上 uvicorn.run(workers>1) 会崩溃，多进程必须走 CLI 参数
    uvicorn.run("embedding_server:app", host="127.0.0.1", port=5003, workers=1)
