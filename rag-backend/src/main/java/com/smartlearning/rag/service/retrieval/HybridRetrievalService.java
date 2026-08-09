package com.smartlearning.rag.service.retrieval;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.repository.KnowledgePointRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

/**
 * 混合检索：
 * <ul>
 *   <li>稠密路：问题 Embedding 后在 Chroma 做向量相似度检索；</li>
 *   <li>稀疏路：MySQL FULLTEXT（ngram）关键词检索；</li>
 *   <li>融合：Reciprocal Rank Fusion（RRF），score = Σ 1/(k + rank)，k=60。</li>
 * </ul>
 * RRF 的优点是不需要两个检索路共享同一套分数体系，直接比较排名。
 */
@Service
public class HybridRetrievalService {

    private static final int RRF_K = 60;

    /** 检索模式：对照实验用（单路 / 混合）。 */
    public enum RetrievalMode {
        DENSE,
        SPARSE,
        HYBRID
    }

    private final VectorStore vectorStore;
    private final KnowledgePointRepository repository;
    private final RagProperties props;

    public HybridRetrievalService(VectorStore vectorStore,
                                  KnowledgePointRepository repository,
                                  RagProperties props) {
        this.vectorStore = vectorStore;
        this.repository = repository;
        this.props = props;
    }

    public List<RankedChunk> retrieve(String question, int limit) {
        return retrieve(question, limit, RetrievalMode.HYBRID);
    }

    public List<RankedChunk> retrieve(String question, int limit, RetrievalMode mode) {
        Map<Long, RankedChunk> fused = new LinkedHashMap<>();

        if (mode == RetrievalMode.DENSE || mode == RetrievalMode.HYBRID) {
            // 稠密检索：向量相似度
            List<Document> denseDocs = vectorStore.similaritySearch(SearchRequest.builder()
                    .query(question)
                    .topK(props.getRetrieval().getDenseTopK())
                    .build());
            for (int i = 0; i < denseDocs.size(); i++) {
                Document doc = denseDocs.get(i);
                Long kpId = ((Number) doc.getMetadata().get("kpId")).longValue();
                String kpName = String.valueOf(doc.getMetadata().get("kpName"));
                RankedChunk chunk = new RankedChunk(kpId, kpName, doc.getText(),
                        rrfScore(i + 1), new ArrayList<>(List.of("dense")));
                fused.merge(kpId, chunk, RankedChunk::merge);
            }
        }

        if (mode == RetrievalMode.SPARSE || mode == RetrievalMode.HYBRID) {
            // 稀疏检索：MySQL 全文
            List<KnowledgePointRepository.SparseHit> sparseHits =
                    repository.sparseSearch(question, props.getRetrieval().getSparseTopK());
            for (int i = 0; i < sparseHits.size(); i++) {
                KnowledgePointRepository.SparseHit hit = sparseHits.get(i);
                RankedChunk chunk = new RankedChunk(hit.id(), hit.name(), hit.toText(),
                        rrfScore(i + 1), new ArrayList<>(List.of("sparse")));
                fused.merge(hit.id(), chunk, RankedChunk::merge);
            }
        }

        return fused.values().stream()
                .sorted(Comparator.comparingDouble(RankedChunk::score).reversed())
                .limit(limit)
                .toList();
    }

    private double rrfScore(int rank) {
        return 1.0 / (RRF_K + rank);
    }
}
