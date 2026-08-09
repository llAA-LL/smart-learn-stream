package com.smartlearning.rag.controller;

import static org.hamcrest.Matchers.containsString;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.asyncDispatch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.request;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.dto.ChatRequest;
import com.smartlearning.rag.dto.ChatResponse;
import com.smartlearning.rag.dto.Citation;
import com.smartlearning.rag.repository.KnowledgePointRepository;
import com.smartlearning.rag.service.ChatMemoryService;
import com.smartlearning.rag.service.FeedbackService;
import com.smartlearning.rag.service.KnowledgeIndexService;
import com.smartlearning.rag.service.RagChatService;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import reactor.core.publisher.Flux;

@WebMvcTest(RagChatController.class)
class RagChatControllerWebTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private RagChatService ragChatService;

    @MockBean
    private KnowledgeIndexService indexService;

    @MockBean
    private KnowledgePointRepository knowledgePointRepository;

    @MockBean
    private FeedbackService feedbackService;

    @MockBean
    private ChatMemoryService memoryService;

    @Test
    void chatRejectsBlankQuestion() throws Exception {
        mockMvc.perform(post("/api/rag/chat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"conversationId\":\"c1\",\"history\":[],\"question\":\"  \"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void chatReturnsAnswerAndCitations() throws Exception {
        when(ragChatService.chat(any(ChatRequest.class))).thenReturn(new ChatResponse(
                "c1", "根据资料，死锁是...",
                List.of(new Citation(1L, "死锁", 0.9, List.of("dense", "sparse"))),
                120L));

        mockMvc.perform(post("/api/rag/chat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"conversationId\":\"c1\",\"history\":[],\"question\":\"什么是死锁？\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.answer").value("根据资料，死锁是..."))
                .andExpect(jsonPath("$.citations[0].kpName").value("死锁"));
    }

    @Test
    void retrieveRejectsInvalidMode() throws Exception {
        mockMvc.perform(get("/api/rag/retrieve")
                        .param("question", "q")
                        .param("mode", "bad"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void streamReturnsSseEvents() throws Exception {
        when(ragChatService.stream(any(ChatRequest.class))).thenReturn(new RagChatService.ChatStream(
                List.of(new Citation(1L, "死锁", 0.9, List.of("dense"))),
                Flux.just("根据资料，死锁是...")));

        MvcResult result = mockMvc.perform(post("/api/rag/chat/stream")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"conversationId\":\"c1\",\"history\":[],\"question\":\"什么是死锁？\"}"))
                .andExpect(request().asyncStarted())
                .andReturn();

        Thread.sleep(300); // 等待虚拟线程发送 citations/delta 事件
        mockMvc.perform(asyncDispatch(result))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("event:delta")));
    }

    @Test
    void feedbackValidatesInput() throws Exception {
        mockMvc.perform(post("/api/rag/feedback")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"question\":\"\",\"answer\":\"a\",\"rating\":\"up\"}"))
                .andExpect(status().isBadRequest());
    }
}
