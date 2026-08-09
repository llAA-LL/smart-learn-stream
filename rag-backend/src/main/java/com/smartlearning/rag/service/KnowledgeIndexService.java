package com.smartlearning.rag.service;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.IndexResult;
import com.smartlearning.rag.entity.KnowledgePoint;
import com.smartlearning.rag.repository.KnowledgePointRepository;
import com.smartlearning.rag.service.chunking.DocumentChunker;
import java.util.ArrayList;
import java.util.List;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

/**
 * 建索引：MySQL 知识点 → 分块 → Embedding → 写入 Chroma。
 * 使用确定性 Document id，重复执行是幂等的（Chroma 按 id 覆盖）。
 */
@Service
public class KnowledgeIndexService {

    private final KnowledgePointRepository repository;
    private final DocumentChunker chunker;
    private final VectorStore vectorStore;
    private final RagProperties props;

    public KnowledgeIndexService(KnowledgePointRepository repository,
                                 DocumentChunker chunker,
                                 VectorStore vectorStore,
                                 RagProperties props) {
        this.repository = repository;
        this.chunker = chunker;
        this.vectorStore = vectorStore;
        this.props = props;
    }

    public IndexResult rebuild() {
        long start = System.currentTimeMillis();
        List<KnowledgePoint> points = repository.findAll();
        List<Document> chunks = new ArrayList<>();
        for (KnowledgePoint point : points) {
            chunks.addAll(chunker.chunk(point));
        }

        int batchSize = props.getIndex().getBatchSize();
        for (int i = 0; i < chunks.size(); i += batchSize) {
            List<Document> batch = chunks.subList(i, Math.min(i + batchSize, chunks.size()));
            vectorStore.add(batch);
        }

        return new IndexResult(points.size(), chunks.size(), System.currentTimeMillis() - start);
    }
}
