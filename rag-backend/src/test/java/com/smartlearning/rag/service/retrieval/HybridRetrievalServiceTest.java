package com.smartlearning.rag.service.retrieval;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.repository.KnowledgePointRepository;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;

@ExtendWith(MockitoExtension.class)
class HybridRetrievalServiceTest {

    @Mock
    private VectorStore vectorStore;

    @Mock
    private KnowledgePointRepository repository;

    private HybridRetrievalService service() {
        RagProperties props = new RagProperties();
        props.getRetrieval().setDenseTopK(5);
        props.getRetrieval().setSparseTopK(5);
        return new HybridRetrievalService(vectorStore, repository, props);
    }

    private Document doc(Long id, String name) {
        return new Document("kp-" + id, name + " content",
                Map.of("kpId", id, "kpName", name));
    }

    private KnowledgePointRepository.SparseHit hit(Long id, String name) {
        return new KnowledgePointRepository.SparseHit(id, name, null, name + " content", 5.0);
    }

    @Test
    void hybridFusionMergesBothSourcesAndSumsScores() {
        when(vectorStore.similaritySearch(any(SearchRequest.class)))
                .thenReturn(List.of(doc(1L, "A"), doc(2L, "B")));
        when(repository.sparseSearch(anyString(), anyInt()))
                .thenReturn(List.of(hit(2L, "B"), hit(3L, "C")));

        List<RankedChunk> result = service().retrieve("query", 5);

        assertThat(result).hasSize(3);
        // B 同时被两路召回：分数相加，来源标记两者
        RankedChunk b = result.stream().filter(c -> c.kpId() == 2L).findFirst().orElseThrow();
        assertThat(b.sources()).contains("dense", "sparse");
        assertThat(b.score()).isEqualTo(1.0 / 61 + 1.0 / 62, org.assertj.core.data.Offset.offset(1e-9));
        // B（双路）应排第一
        assertThat(result.get(0).kpId()).isEqualTo(2L);
    }

    @Test
    void denseOnlyModeSkipsSparse() {
        when(vectorStore.similaritySearch(any(SearchRequest.class)))
                .thenReturn(List.of(doc(1L, "A")));

        List<RankedChunk> result = service().retrieve("query", 5,
                HybridRetrievalService.RetrievalMode.DENSE);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).sources()).containsExactly("dense");
        verify(repository, never()).sparseSearch(anyString(), anyInt());
    }

    @Test
    void sparseOnlyModeSkipsDense() {
        when(repository.sparseSearch(anyString(), anyInt()))
                .thenReturn(List.of(hit(3L, "C")));

        List<RankedChunk> result = service().retrieve("query", 5,
                HybridRetrievalService.RetrievalMode.SPARSE);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).sources()).containsExactly("sparse");
        verify(vectorStore, never()).similaritySearch(any(SearchRequest.class));
    }
}
