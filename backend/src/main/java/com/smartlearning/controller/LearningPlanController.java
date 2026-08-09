package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.LearningPlan;
import com.smartlearning.entity.PlanItem;
import com.smartlearning.service.LearningPlanService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/plans")
public class LearningPlanController {

    private final LearningPlanService planService;

    public LearningPlanController(LearningPlanService planService) {
        this.planService = planService;
    }

    @GetMapping
    public ApiResponse<List<LearningPlan>> list(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(planService.getUserPlans(userId));
    }

    @GetMapping("/{id}")
    public ApiResponse<LearningPlan> get(@PathVariable Long id) {
        return ApiResponse.ok(planService.findById(id));
    }

    @PostMapping
    public ApiResponse<LearningPlan> create(@RequestAttribute("userId") Long userId,
                                             @RequestBody LearningPlan plan) {
        return ApiResponse.ok(planService.create(userId, plan));
    }

    @PutMapping("/{id}")
    public ApiResponse<LearningPlan> update(@PathVariable Long id, @RequestBody LearningPlan plan) {
        plan.setId(id);
        return ApiResponse.ok(planService.update(plan));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<?> delete(@PathVariable Long id) {
        planService.delete(id);
        return ApiResponse.ok();
    }

    @PutMapping("/items/{itemId}/toggle")
    public ApiResponse<PlanItem> toggleItem(@PathVariable Long itemId) {
        return ApiResponse.ok(planService.toggleItem(itemId));
    }
}
