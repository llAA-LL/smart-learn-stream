package com.smartlearning.rag.embedding;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * 本地 Embedding 模型适配器：通过 HTTP 调用 Python 侧的 sentence-transformers
 * 推理服务（bge-small-zh-v1.5）。零 API 成本，查询侧自动追加 bge 检索指令。
 */
public class LocalEmbeddingModel implements EmbeddingModel {

    private final RestClient restClient;

    public LocalEmbeddingModel(String baseUrl) {
        this.restClient = RestClient.builder()
                .requestFactory(new SimpleClientHttpRequestFactory())
                .baseUrl(baseUrl)
                .build();
    }

    @Override
    public float[] embed(String text) {
        // 查询侧：追加 bge 检索指令，提升召回质量
        return embedTexts(List.of(text), true).get(0);
    }

    @Override
    public float[] embed(Document document) {
        // 文档侧：不加指令
        return embedTexts(List.of(getEmbeddingContent(document)), false).get(0);
    }

    @Override
    public EmbeddingResponse call(EmbeddingRequest request) {
        List<String> texts = request.getInstructions();
        List<float[]> vectors = embedTexts(texts, false);
        List<Embedding> embeddings = new ArrayList<>();
        for (int i = 0; i < vectors.size(); i++) {
            embeddings.add(new Embedding(vectors.get(i), i));
        }
        return new EmbeddingResponse(embeddings);
    }

    @Override
    public int dimensions() {
        // bge-small-zh-v1.5 固定 512 维，避免每次调用远程接口探测
        return 512;
    }

    private List<float[]> embedTexts(List<String> inputs, boolean isQuery) {
        Map<String, Object> body = Map.of("inputs", inputs, "is_query", isQuery);
        EmbeddingServerResponse response = restClient.post()
                .uri("/embed")
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .body(EmbeddingServerResponse.class);
        if (response == null || response.embeddings() == null) {
            return List.of();
        }
        List<float[]> result = new ArrayList<>();
        for (List<Double> vec : response.embeddings()) {
            float[] arr = new float[vec.size()];
            for (int i = 0; i < vec.size(); i++) {
                arr[i] = vec.get(i).floatValue();
            }
            result.add(arr);
        }
        return result;
    }

    private record EmbeddingServerResponse(List<List<Double>> embeddings) {
    }
}
