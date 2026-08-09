package com.smartlearning.controller;

import com.smartlearning.annotation.RateLimit;
import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.LearningRecord;
import com.smartlearning.entity.UserKpMastery;
import com.smartlearning.service.LearningRecordService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/records")
public class LearningRecordController {

    private final LearningRecordService recordService;

    public LearningRecordController(LearningRecordService recordService) {
        this.recordService = recordService;
    }

    @PostMapping
    @RateLimit(value = 30, window = 60, key = "record")
    public ApiResponse<LearningRecord> create(@RequestAttribute("userId") Long userId,
                                               @RequestBody LearningRecord record) {
        return ApiResponse.ok(recordService.record(userId, record));
    }

    @GetMapping
    public ApiResponse<List<LearningRecord>> list(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(recordService.getUserRecords(userId));
    }

    @GetMapping("/stats")
    public ApiResponse<Map<String, Object>> stats(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(recordService.getStats(userId));
    }

    @GetMapping("/mastery")
    public ApiResponse<List<UserKpMastery>> mastery(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(recordService.getUserMastery(userId));
    }

    @GetMapping("/hot-courses")
    public ApiResponse<List<Map<String, Object>>> hotCourses() {
        return ApiResponse.ok(recordService.getHotCourses(10));
    }

    @GetMapping("/hot-kps")
    public ApiResponse<List<Map<String, Object>>> hotKnowledgePoints() {
        return ApiResponse.ok(recordService.getHotKnowledgePoints(10));
    }
}
