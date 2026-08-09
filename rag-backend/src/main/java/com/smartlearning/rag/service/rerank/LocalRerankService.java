package com.smartlearning.rag.service.rerank;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.service.retrieval.RankedChunk;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * 本地重排：调用 Python 推理服务的 bge-reranker-base。
 * 相比 LLM 重排省去一次 DeepSeek 调用（约 800ms），零外部成本。
 */
public class LocalRerankService implements Reranker {

    private static final Logger log = LoggerFactory.getLogger(LocalRerankService.class);

    private final RestClient restClient;
    private final RagProperties props;

    public LocalRerankService(String baseUrl, RagProperties props) {
        this.restClient = RestClient.builder()
                .requestFactory(new SimpleClientHttpRequestFactory())
                .baseUrl(baseUrl)
                .build();
        this.props = props;
    }

    @Override
    public List<RankedChunk> rerank(String question, List<RankedChunk> candidates) {
        if (!props.getRerank().isEnabled() || candidates.size() <= 1) {
            return candidates;
        }
        try {
            int maxChars = props.getRerank().getMaxChars();
            List<String> texts = candidates.stream()
                    .map(c -> {
                        String content = c.content();
                        return content.length() > maxChars
                                ? content.substring(0, maxChars) + "…" : content;
                    })
                    .toList();
            Map<String, Object> body = Map.of("question", question, "candidates", texts);
            RerankResponse response = restClient.post()
                    .uri("/rerank")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(RerankResponse.class);
            if (response == null || response.scores() == null
                    || response.scores().size() != candidates.size()) {
                log.warn("本地重排返回数量不匹配({})，回退 RRF 顺序",
                        response == null ? "null" : response.scores().size());
                return candidates;
            }
            List<ScoredCandidate> scored = new ArrayList<>();
            for (int i = 0; i < candidates.size(); i++) {
                scored.add(new ScoredCandidate(candidates.get(i), response.scores().get(i)));
            }
            scored.sort(Comparator.comparingDouble(ScoredCandidate::score).reversed());
            return scored.stream().map(ScoredCandidate::chunk).toList();
        } catch (Exception e) {
            log.warn("本地重排失败，回退到 RRF 顺序: {}", e.getMessage());
            return candidates;
        }
    }

    private record ScoredCandidate(RankedChunk chunk, double score) {
    }

    private record RerankResponse(List<Double> scores) {
    }
}
