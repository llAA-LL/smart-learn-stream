package com.smartlearning.rag.service;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.ChatRequest;
import com.smartlearning.rag.dto.ChatResponse;
import com.smartlearning.rag.dto.ChatTurn;
import com.smartlearning.rag.dto.Citation;
import com.smartlearning.rag.service.rerank.Reranker;
import com.smartlearning.rag.service.retrieval.HybridRetrievalService;
import com.smartlearning.rag.service.retrieval.RankedChunk;
import com.smartlearning.rag.service.AnswerCacheService.CachedAnswer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.core.io.ClassPathResource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

/**
 * RAG 问答编排：检索 → 重排 → 组装 Prompt → 生成（支持流式）。
 */
@Service
public class RagChatService {

    private static final Logger log = LoggerFactory.getLogger(RagChatService.class);

    public static final String NO_CONTEXT_ANSWER =
            "根据现有学习资料，暂时没有找到与这个问题相关的知识点。";

    private final HybridRetrievalService retrievalService;
    private final Reranker rerankService;
    private final ChatModel chatModel;
    private final RagProperties props;
    private final ChatMemoryService memoryService;
    private final AnswerCacheService cacheService;
    private final PersonalContextService personalContextService;
    private final String systemPromptTemplate;

    public RagChatService(HybridRetrievalService retrievalService,
                          Reranker rerankService,
                          ChatModel chatModel,
                          RagProperties props,
                          ChatMemoryService memoryService,
                          AnswerCacheService cacheService,
                          PersonalContextService personalContextService) throws Exception {
        this.retrievalService = retrievalService;
        this.rerankService = rerankService;
        this.chatModel = chatModel;
        this.props = props;
        this.memoryService = memoryService;
        this.cacheService = cacheService;
        this.personalContextService = personalContextService;
        this.systemPromptTemplate = new ClassPathResource("prompts/system-prompt.txt")
                .getContentAsString(StandardCharsets.UTF_8);
    }

    public ChatResponse chat(ChatRequest request) {
        long start = System.currentTimeMillis();
        boolean cacheable = isCacheable(request);
        List<ChatTurn> turns = loadTurns(request);
        String personalContext = null;
        if (cacheable) {
            CachedAnswer cached = cacheService.get(request.question());
            if (cached != null) {
                log.info("chat cid={} cache=HIT total={}ms",
                        request.conversationId(), System.currentTimeMillis() - start);
                return new ChatResponse(request.conversationId(), cached.answer(), cached.citations(),
                        cached.elapsedMs());
            }
        } else {
            personalContext = personalContextService.fetch(request.token());
        }

        int topK = props.getRetrieval().getRerankTopK();
        long t1 = System.currentTimeMillis();
        List<RankedChunk> fused = retrievalService.retrieve(request.question(), topK);
        long t2 = System.currentTimeMillis();
        List<RankedChunk> chunks = rerankService.rerank(request.question(), fused);
        long t3 = System.currentTimeMillis();
        List<Citation> citations = toCitations(chunks);

        if (chunks.isEmpty() && personalContext == null) {
            remember(request, NO_CONTEXT_ANSWER);
            log.info("chat cid={} cache=MISS retrieve={}ms rerank={}ms generate=0ms total={}ms chunks=0",
                    request.conversationId(), t2 - t1, t3 - t2, System.currentTimeMillis() - start);
            return new ChatResponse(request.conversationId(), NO_CONTEXT_ANSWER, citations,
                    System.currentTimeMillis() - start);
        }

        List<Message> messages = buildMessages(request, chunks, turns, personalContext);
        String answer = chatModel.call(new Prompt(messages)).getResult().getOutput().getText();
        long t4 = System.currentTimeMillis();
        remember(request, answer);
        if (cacheable) {
            cacheService.put(request.question(), answer, citations, System.currentTimeMillis() - start);
        }
        log.info("chat cid={} cache=MISS retrieve={}ms rerank={}ms generate={}ms total={}ms citations={}",
                request.conversationId(), t2 - t1, t3 - t2, t4 - t3,
                System.currentTimeMillis() - start, citations.size());
        return new ChatResponse(request.conversationId(), answer, citations,
                System.currentTimeMillis() - start);
    }

    public ChatStream stream(ChatRequest request) {
        long start = System.currentTimeMillis();
        boolean cacheable = isCacheable(request);
        List<ChatTurn> turns = loadTurns(request);
        String personalContext = null;
        if (cacheable) {
            CachedAnswer cached = cacheService.get(request.question());
            if (cached != null) {
                log.info("stream cid={} cache=HIT total={}ms",
                        request.conversationId(), System.currentTimeMillis() - start);
                return new ChatStream(cached.citations(),
                        Flux.just(cached.answer()).doOnComplete(() -> remember(request, cached.answer())));
            }
        } else {
            personalContext = personalContextService.fetch(request.token());
        }

        int topK = props.getRetrieval().getRerankTopK();
        long t1 = System.currentTimeMillis();
        List<RankedChunk> fused = retrievalService.retrieve(request.question(), topK);
        long t2 = System.currentTimeMillis();
        List<RankedChunk> chunks = rerankService.rerank(request.question(), fused);
        long t3 = System.currentTimeMillis();
        List<Citation> citations = toCitations(chunks);
        if (chunks.isEmpty() && personalContext == null) {
            return new ChatStream(citations,
                    Flux.just(NO_CONTEXT_ANSWER).doOnComplete(() -> remember(request, NO_CONTEXT_ANSWER)));
        }
        List<Message> messages = buildMessages(request, chunks, turns, personalContext);
        StringBuilder answer = new StringBuilder();
        Flux<String> flux = chatModel.stream(new Prompt(messages))
                .map(response -> response.getResult().getOutput().getText())
                .filter(text -> text != null && !text.isEmpty())
                .doOnNext(answer::append)
                .doOnComplete(() -> {
                    long end = System.currentTimeMillis();
                    remember(request, answer.toString());
                    if (cacheable) {
                        cacheService.put(request.question(), answer.toString(), citations,
                                end - start);
                    }
                    log.info("stream cid={} cache=MISS retrieve={}ms rerank={}ms generate={}ms total={}ms citations={}",
                            request.conversationId(), t2 - t1, t3 - t2, end - t3, end - start,
                            citations.size());
                });
        return new ChatStream(citations, flux);
    }

    /** 评测用：按指定模式检索（不做重排）。 */
    public List<RankedChunk> retrieve(String question, int topK,
                                      HybridRetrievalService.RetrievalMode mode) {
        return retrievalService.retrieve(question, topK, mode);
    }

    /** 评测用：仅重排。 */
    public List<RankedChunk> rerank(String question, List<RankedChunk> chunks) {
        return rerankService.rerank(question, chunks);
    }

    private List<Message> buildMessages(ChatRequest request, List<RankedChunk> chunks, List<ChatTurn> turns,
                                        String personalContext) {
        String context = buildContext(chunks);
        PromptTemplate template = new PromptTemplate(systemPromptTemplate);
        template.add("context", context);
        template.add("personal_context", personalContext == null ? "" : personalContext);
        String system = template.render();

        List<Message> messages = new ArrayList<>();
        messages.add(new SystemMessage(system));
        for (ChatTurn turn : turns) {
            if ("user".equals(turn.role())) {
                messages.add(new UserMessage(turn.content()));
            } else if ("assistant".equals(turn.role())) {
                messages.add(new AssistantMessage(turn.content()));
            }
        }
        messages.add(new UserMessage(request.question()));
        return messages;
    }

    /**
     * 会话记忆：优先 Redis（服务端持久化），Redis 为空时回退到客户端传入的 history。
     */
    private List<ChatTurn> loadTurns(ChatRequest request) {
        List<ChatTurn> turns = memoryService.load(request.conversationId(),
                props.getMemory().getMaxTurns());
        if (turns.isEmpty() && request.history() != null) {
            int cap = props.getMemory().getMaxTurns() * 2;
            turns = request.history().stream().limit(cap).toList();
        }
        return turns;
    }

    private void remember(ChatRequest request, String answer) {
        memoryService.append(request.conversationId(),
                new ChatTurn("user", request.question()),
                new ChatTurn("assistant", answer));
    }

    /** 带用户 token 的请求不参与热问题缓存（个人化回答，避免跨用户串数据）。 */
    private boolean isCacheable(ChatRequest request) {
        return request.token() == null || request.token().isBlank();
    }

    /** 流式结果：先返回引用来源，再订阅回答流。 */
    public record ChatStream(List<Citation> citations, Flux<String> flux) {
    }

    private String buildContext(List<RankedChunk> chunks) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < chunks.size(); i++) {
            RankedChunk chunk = chunks.get(i);
            sb.append("[").append(i + 1).append("] ")
                    .append("（知识点：").append(chunk.kpName()).append("）\n")
                    .append(chunk.content()).append("\n\n");
        }
        return sb.toString();
    }

    private List<Citation> toCitations(List<RankedChunk> chunks) {
        return chunks.stream()
                .map(c -> new Citation(c.kpId(), c.kpName(), c.score(), c.sources()))
                .toList();
    }
}
