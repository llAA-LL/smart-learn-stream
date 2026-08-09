package com.smartlearning.rag.config;

import com.smartlearning.rag.embedding.LocalEmbeddingModel;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Embedding 模型开关：
 * <ul>
 *   <li>provider=local-python：复用本机 Python 推理服务（默认，零注册零成本）；</li>
 *   <li>provider=openai-api：使用 SiliconFlow bge-m3 API（需配置 SILICONFLOW_API_KEY）。</li>
 * </ul>
 * 定义本地 Bean 后，Spring AI 的 OpenAI Embedding 自动配置会自动让位。
 */
@Configuration
public class EmbeddingModelConfig {

    @Bean
    @Primary
    @ConditionalOnProperty(prefix = "rag.embedding", name = "provider", havingValue = "local-python")
    public EmbeddingModel localEmbeddingModel(
            @Value("${rag.embedding.local-python-url:http://127.0.0.1:5003}") String baseUrl) {
        return new LocalEmbeddingModel(baseUrl);
    }
}
