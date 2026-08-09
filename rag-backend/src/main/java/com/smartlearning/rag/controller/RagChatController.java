package com.smartlearning.rag.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.dto.ChatRequest;
import com.smartlearning.rag.dto.ChatResponse;
import com.smartlearning.rag.dto.IndexResult;
import com.smartlearning.rag.dto.FeedbackRequest;
import com.smartlearning.rag.service.FeedbackService;
import com.smartlearning.rag.annotation.RateLimit;
import com.smartlearning.rag.service.KnowledgeIndexService;
import com.smartlearning.rag.service.RagChatService;
import com.smartlearning.rag.service.ChatMemoryService;
import com.smartlearning.rag.service.retrieval.RankedChunk;
import com.smartlearning.rag.service.retrieval.HybridRetrievalService;
import com.smartlearning.rag.repository.KnowledgePointRepository;
import com.smartlearning.rag.entity.KnowledgePoint;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/api/rag")
public class RagChatController {

    private static final Logger log = LoggerFactory.getLogger(RagChatController.class);
    private static final long STREAM_TIMEOUT_MS = 120_000L;

    private final RagChatService ragChatService;
    private final KnowledgeIndexService indexService;
    private final KnowledgePointRepository knowledgePointRepository;
    private final FeedbackService feedbackService;
    private final ChatMemoryService memoryService;
    private final ObjectMapper objectMapper;
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

    public RagChatController(RagChatService ragChatService,
                             KnowledgeIndexService indexService,
                             KnowledgePointRepository knowledgePointRepository,
                             FeedbackService feedbackService,
                             ChatMemoryService memoryService,
                             ObjectMapper objectMapper) {
        this.ragChatService = ragChatService;
        this.indexService = indexService;
        this.knowledgePointRepository = knowledgePointRepository;
        this.feedbackService = feedbackService;
        this.memoryService = memoryService;
        this.objectMapper = objectMapper;
    }

    @PostMapping("/chat")
    @RateLimit(value = 15, window = 60)
    public ChatResponse chat(@Valid @RequestBody ChatRequest request) {
        return ragChatService.chat(request);
    }

    /**
     * SSE 流式回答：
     * 事件 citations（引用来源）→ delta（逐段内容）→ done。
     */
    @PostMapping("/chat/stream")
    @RateLimit(value = 20, window = 60)
    public SseEmitter stream(@Valid @RequestBody ChatRequest request) {
        SseEmitter emitter = new SseEmitter(STREAM_TIMEOUT_MS);
        executor.execute(() -> {
            try {
                RagChatService.ChatStream result = ragChatService.stream(request);
                emitter.send(SseEmitter.event().name("citations")
                        .data(objectMapper.writeValueAsString(result.citations())));

                Flux<String> flux = result.flux();
                flux.subscribe(
                        delta -> sendSafe(emitter, SseEmitter.event().name("delta").data(delta)),
                        error -> {
                            log.warn("流式生成失败: {}", error.getMessage());
                            try {
                                emitter.send(SseEmitter.event().name("error").data(error.getMessage()));
                            } catch (IOException ignored) {
                                // 客户端已断开
                            }
                            emitter.completeWithError(error);
                        },
                        () -> {
                            sendSafe(emitter, SseEmitter.event().name("done").data(""));
                            emitter.complete();
                        }
                );
            } catch (Exception e) {
                log.error("SSE 处理异常", e);
                try {
                    emitter.send(SseEmitter.event().name("error").data(e.getMessage()));
                } catch (IOException ignored) {
                    // 客户端已断开
                }
                emitter.completeWithError(e);
            }
        });
        return emitter;
    }

    @PostMapping("/index/rebuild")
    @RateLimit(value = 5, window = 60)
    public IndexResult rebuild() {
        return indexService.rebuild();
    }

    /**
     * 调试用：只看检索结果、不调 LLM，方便排查"是检索坏了还是生成坏了"。
     * 支持对照实验参数：mode=dense|sparse|hybrid，rerank=true|false。
     */
    @GetMapping("/retrieve")
    @RateLimit(value = 120, window = 60)
    public List<RankedChunk> retrieve(@RequestParam String question,
                                      @RequestParam(defaultValue = "5") int topK,
                                      @RequestParam(defaultValue = "hybrid") String mode,
                                      @RequestParam(defaultValue = "true") boolean rerank) {
        HybridRetrievalService.RetrievalMode retrievalMode =
                HybridRetrievalService.RetrievalMode.valueOf(mode.toUpperCase());
        List<RankedChunk> chunks = ragChatService.retrieve(question, topK, retrievalMode);
        if (rerank) {
            return ragChatService.rerank(question, chunks);
        }
        return chunks;
    }

    /**
     * 评测用：返回全部知识点（含内容），用于构造 QA 评测集。
     */
    @GetMapping("/knowledge-points")
    public List<KnowledgePoint> knowledgePoints() {
        return knowledgePointRepository.findAll();
    }

    @PostMapping("/feedback")
    @RateLimit(value = 60, window = 60)
    public void feedback(@Valid @RequestBody FeedbackRequest request) {
        feedbackService.save(request);
    }

    /** 清空某会话的服务端记忆（前端"清空对话"时调用）。 */
    @DeleteMapping("/chat/{conversationId}")
    public ResponseEntity<Void> clearConversation(@PathVariable String conversationId) {
        memoryService.clear(conversationId);
        return ResponseEntity.noContent().build();
    }

    private void sendSafe(SseEmitter emitter, SseEmitter.SseEventBuilder event) {
        try {
            emitter.send(event);
        } catch (IOException e) {
            log.debug("客户端断开连接: {}", e.getMessage());
            emitter.complete();
        }
    }
}
