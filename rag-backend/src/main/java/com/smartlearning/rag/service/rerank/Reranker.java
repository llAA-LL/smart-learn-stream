package com.smartlearning.rag.service.rerank;

import com.smartlearning.rag.service.retrieval.RankedChunk;
import java.util.List;

/**
 * 重排器抽象：LLM 打分与本地 bge-reranker 均可接入。
 */
public interface Reranker {

    List<RankedChunk> rerank(String question, List<RankedChunk> candidates);
}
