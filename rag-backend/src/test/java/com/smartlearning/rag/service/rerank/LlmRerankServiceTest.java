package com.smartlearning.rag.service.rerank;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.service.retrieval.RankedChunk;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;

@ExtendWith(MockitoExtension.class)
class LlmRerankServiceTest {

    @Mock
    private ChatModel chatModel;

    private LlmRerankService service(boolean enabled) throws Exception {
        RagProperties props = new RagProperties();
        props.getRerank().setEnabled(enabled);
        return new LlmRerankService(chatModel, props);
    }

    private RankedChunk chunk(Long id, String name) {
        return new RankedChunk(id, name, name + " 内容", 0.1, List.of("dense"));
    }

    private ChatResponse response(String text) {
        return new ChatResponse(List.of(new Generation(new AssistantMessage(text))));
    }

    @Test
    void rerankReordersByLlmScores() throws Exception {
        List<RankedChunk> candidates = List.of(chunk(1L, "A"), chunk(2L, "B"), chunk(3L, "C"));
        when(chatModel.call(any(Prompt.class))).thenReturn(response("{\"scores\": [9, 2, 5]}"));

        List<RankedChunk> result = service(true).rerank("question", candidates);

        assertThat(result).extracting(RankedChunk::kpId).containsExactly(1L, 3L, 2L);
    }

    @Test
    void rerankParsesScoresInsideMarkdownCodeBlock() throws Exception {
        List<RankedChunk> candidates = List.of(chunk(1L, "A"), chunk(2L, "B"));
        when(chatModel.call(any(Prompt.class))).thenReturn(response("```json\n{\"scores\": [3, 8]}\n```"));

        List<RankedChunk> result = service(true).rerank("question", candidates);

        assertThat(result).extracting(RankedChunk::kpId).containsExactly(2L, 1L);
    }

    @Test
    void rerankFallsBackToOriginalOrderOnFailure() throws Exception {
        List<RankedChunk> candidates = List.of(chunk(1L, "A"), chunk(2L, "B"));
        when(chatModel.call(any(Prompt.class))).thenThrow(new RuntimeException("API down"));

        List<RankedChunk> result = service(true).rerank("question", candidates);

        assertThat(result).isSameAs(candidates);
    }

    @Test
    void disabledRerankSkipsModelCall() throws Exception {
        List<RankedChunk> candidates = List.of(chunk(1L, "A"), chunk(2L, "B"));

        List<RankedChunk> result = service(false).rerank("question", candidates);

        assertThat(result).isSameAs(candidates);
        verify(chatModel, never()).call(any(Prompt.class));
    }
}
