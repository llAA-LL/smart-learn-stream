package com.smartlearning.config;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * 知识点增删改后，异步通知 RAG 服务重建索引（失败只记日志，不影响主流程）。
 */
@Component
public class RagIndexNotifier {

    private static final Logger log = LoggerFactory.getLogger(RagIndexNotifier.class);

    private final RestClient restClient;
    private final ExecutorService executor = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "rag-index-notify");
        t.setDaemon(true);
        return t;
    });

    public RagIndexNotifier(@Value("${rag-backend.url}") String ragBackendUrl) {
        this.restClient = RestClient.builder().baseUrl(ragBackendUrl).build();
    }

    public void notifyRebuild() {
        executor.execute(() -> {
            try {
                restClient.post()
                        .uri("/api/rag/index/rebuild")
                        .contentType(MediaType.APPLICATION_JSON)
                        .retrieve()
                        .toBodilessEntity();
                log.info("已通知 RAG 服务重建索引");
            } catch (Exception e) {
                log.warn("通知 RAG 重建索引失败: {}", e.getMessage());
            }
        });
    }
}
