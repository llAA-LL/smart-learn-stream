package com.smartlearning.rag.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.ai.chroma.vectorstore.ChromaApi;
import org.springframework.ai.chroma.vectorstore.ChromaVectorStore;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/**
 * ChromaDB 连接配置。
 * <p>
 * 说明：Spring AI 1.1.x 的 Chroma 自动配置会把 host:port 拼成不带协议头的 baseUrl，
 * JDK HTTP 客户端无法识别（invalid URI scheme）；同时本地 Chroma 1.5.9 的默认
 * 租户/库是 default_tenant / default_database。因此这里手动提供 ChromaApi 与
 * VectorStore Bean，绕过自动配置。
 */
@Configuration
public class VectorStoreConfig {

    @Bean
    public ChromaApi chromaApi(RestClient.Builder restClientBuilder,
                               ObjectMapper objectMapper,
                               @Value("${spring.ai.vectorstore.chroma.client.host:localhost}") String host,
                               @Value("${spring.ai.vectorstore.chroma.client.port:8000}") int port) {
        String baseUrl = "http://" + host + ":" + port;
        return new ChromaApi(baseUrl, restClientBuilder, objectMapper);
    }

    @Bean
    public VectorStore chromaVectorStore(ChromaApi chromaApi,
                                         EmbeddingModel embeddingModel,
                                         @Value("${spring.ai.vectorstore.chroma.collection-name:smart_learning_kp}") String collectionName) {
        return ChromaVectorStore.builder(chromaApi, embeddingModel)
                .tenantName("default_tenant")
                .databaseName("default_database")
                .collectionName(collectionName)
                .initializeSchema(true)
                .build();
    }
}