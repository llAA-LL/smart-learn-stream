package com.smartlearning.rag.config;

import com.smartlearning.rag.service.rerank.LlmRerankService;
import com.smartlearning.rag.service.rerank.LocalRerankService;
import com.smartlearning.rag.service.rerank.Reranker;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * 重排器开关：
 * <ul>
 *   <li>provider=llm（默认）：DeepSeek 打分，hit@1 命中率更高（87.5% vs 80%）；</li>
 *   <li>provider=local：本地 bge-reranker-base，零外部依赖，可离线运行。</li>
 * </ul>
 */
@Configuration
public class RerankConfig {

    @Bean
    @ConditionalOnProperty(prefix = "rag.rerank", name = "provider", havingValue = "llm")
    public Reranker llmReranker(ChatModel chatModel, RagProperties props) throws Exception {
        return new LlmRerankService(chatModel, props);
    }

    @Bean
    @Primary
    @ConditionalOnProperty(prefix = "rag.rerank", name = "provider", havingValue = "local", matchIfMissing = true)
    public Reranker localReranker(
            @Value("${rag.rerank.local-url:http://127.0.0.1:5003}") String baseUrl,
            RagProperties props) {
        return new LocalRerankService(baseUrl, props);
    }
}
