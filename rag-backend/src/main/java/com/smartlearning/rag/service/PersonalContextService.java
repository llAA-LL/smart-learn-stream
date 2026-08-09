package com.smartlearning.rag.service;

import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

/**
 * 从主后端拉取用户学习概况（统计 / 薄弱点 / 推荐），
 * 供 AI 助教回答"我的学习进度怎么样"这类个人化问题。
 * 主后端不可用时静默降级（返回 null，不影响知识问答）。
 */
@Service
public class PersonalContextService {

    private static final Logger log = LoggerFactory.getLogger(PersonalContextService.class);

    private final RestClient restClient;

    public PersonalContextService(@Value("${app.main-backend-url:http://localhost:9090}") String baseUrl) {
        this.restClient = RestClient.builder()
                .requestFactory(new SimpleClientHttpRequestFactory())
                .baseUrl(baseUrl)
                .build();
    }

    public String fetch(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        try {
            ApiResponse resp = restClient.get()
                    .uri("/api/ai/context")
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .body(ApiResponse.class);
            if (resp == null || resp.data() == null) {
                return null;
            }
            ContextData d = resp.data();
            StringBuilder sb = new StringBuilder();
            sb.append("学习统计：今日 ").append(d.todayMinutes()).append(" 分钟，")
                    .append("本周 ").append(d.weekMinutes()).append(" 分钟，")
                    .append("累计 ").append(d.totalMinutes()).append(" 分钟。");
            if (d.weakPoints() != null && !d.weakPoints().isEmpty()) {
                sb.append("薄弱知识点：");
                sb.append(String.join("、", d.weakPoints().stream()
                        .map(w -> w.get("kpName") + "（" + w.get("masteryScore") + "分）")
                        .toList()));
                sb.append("。");
            }
            if (d.recommendations() != null && !d.recommendations().isEmpty()) {
                sb.append("当前推荐学习：");
                sb.append(String.join("、", d.recommendations().stream()
                        .map(r -> r.get("kpName") + "（" + r.get("reason") + "）")
                        .toList()));
                sb.append("。");
            }
            return sb.toString();
        } catch (Exception e) {
            log.warn("获取个人学习上下文失败: {}", e.getMessage());
            return null;
        }
    }

    private record ApiResponse(int code, String message, ContextData data) {
    }

    private record ContextData(Object todayMinutes, Object weekMinutes, Object totalMinutes,
                               List<Map<String, Object>> weakPoints,
                               List<Map<String, Object>> recommendations) {
    }
}
