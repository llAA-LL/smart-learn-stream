package com.smartlearning.rag.service;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.IndexResult;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.boot.ApplicationArguments;

@ExtendWith(MockitoExtension.class)
class IndexStartupHealerTest {

    @Mock
    private VectorStore vectorStore;
    @Mock
    private KnowledgeIndexService indexService;
    @Mock
    private ApplicationArguments args;

    private IndexStartupHealer healer(boolean autoHeal) {
        RagProperties props = new RagProperties();
        props.getIndex().setAutoHealOnEmpty(autoHeal);
        return new IndexStartupHealer(vectorStore, indexService, props);
    }

    @Test
    void rebuildsWhenVectorStoreIsEmpty() {
        when(vectorStore.similaritySearch(any(SearchRequest.class))).thenReturn(List.of());
        when(indexService.rebuild()).thenReturn(new IndexResult(1, 2, 3L));

        healer(true).run(args);

        verify(indexService).rebuild();
    }

    @Test
    void skipsWhenVectorStoreHasData() {
        when(vectorStore.similaritySearch(any(SearchRequest.class)))
                .thenReturn(List.of(new Document("kp-1-0", Map.of())));

        healer(true).run(args);

        verify(indexService, never()).rebuild();
    }

    @Test
    void skipsWhenDisabled() {
        healer(false).run(args);

        verify(indexService, never()).rebuild();
    }

    @Test
    void skipsWithoutCrashWhenProbeFails() {
        when(vectorStore.similaritySearch(any(SearchRequest.class)))
                .thenThrow(new RuntimeException("embedding server down"));

        assertThatCode(() -> healer(true).run(args)).doesNotThrowAnyException();
        verify(indexService, never()).rebuild();
    }
}
