package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.UserKpMastery;
import com.smartlearning.service.LearningRecordService;
import com.smartlearning.service.RecommendationService;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 供 AI 助教（RAG 服务）拉取用户学习概况：
 * 统计、薄弱点、当前推荐，一次聚合，避免 RAG 多次调用业务接口。
 */
@RestController
@RequestMapping("/api/ai")
public class AiContextController {

    private final LearningRecordService recordService;
    private final RecommendationService recommendationService;

    public AiContextController(LearningRecordService recordService,
                               RecommendationService recommendationService) {
        this.recordService = recordService;
        this.recommendationService = recommendationService;
    }

    @GetMapping("/context")
    public ApiResponse<Map<String, Object>> context(@RequestAttribute("userId") Long userId) {
        Map<String, Object> stats = recordService.getStats(userId);
        List<UserKpMastery> weakPoints = recommendationService.getWeakPoints(userId);
        List<Map<String, Object>> recommendations = recommendationService.recommend(userId);

        Map<String, Object> ctx = new LinkedHashMap<>();
        ctx.put("todayMinutes", stats.get("todayMinutes"));
        ctx.put("weekMinutes", stats.get("weekMinutes"));
        ctx.put("totalMinutes", stats.get("totalMinutes"));
        ctx.put("weakPoints", weakPoints.stream().limit(5).map(w -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("kpId", w.getKpId());
            m.put("kpName", w.getKpName());
            m.put("masteryScore", w.getMasteryScore());
            return m;
        }).toList());
        ctx.put("recommendations", recommendations.stream().limit(3).map(r -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("kpId", r.get("kpId"));
            m.put("kpName", r.get("kpName"));
            m.put("reason", r.get("reason"));
            return m;
        }).toList());
        return ApiResponse.ok(ctx);
    }
}
