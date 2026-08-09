package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.UserKpMastery;
import com.smartlearning.service.RecommendationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    @GetMapping
    public ApiResponse<List<Map<String, Object>>> recommend(@RequestAttribute("userId") Long userId) {
        List<Map<String, Object>> result = recommendationService.recommend(userId);
        recommendationService.logView(userId, "viewed_recommendations");
        return ApiResponse.ok(result);
    }

    @GetMapping("/weak-points")
    public ApiResponse<List<UserKpMastery>> weakPoints(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(recommendationService.getWeakPoints(userId));
    }
}
