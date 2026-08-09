package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.KnowledgePoint;
import com.smartlearning.service.KnowledgeGraphService;
import com.smartlearning.annotation.RequireRole;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/knowledge-graph")
public class KnowledgeGraphController {

    private final KnowledgeGraphService kgService;

    public KnowledgeGraphController(KnowledgeGraphService kgService) {
        this.kgService = kgService;
    }

    @GetMapping("/nodes")
    public ApiResponse<List<KnowledgePoint>> listNodes(@RequestParam(required = false) Long courseId) {
        if (courseId != null) {
            return ApiResponse.ok(kgService.findByCourseId(courseId));
        }
        return ApiResponse.ok(kgService.findAll());
    }

    @GetMapping("/nodes/{id}")
    public ApiResponse<KnowledgePoint> getNode(@PathVariable Long id) {
        return ApiResponse.ok(kgService.findById(id));
    }

    @PostMapping("/nodes")
    @RequireRole("ADMIN")
    public ApiResponse<KnowledgePoint> createNode(@RequestBody KnowledgePoint kp) {
        return ApiResponse.ok(kgService.create(kp));
    }

    @PutMapping("/nodes/{id}")
    @RequireRole("ADMIN")
    public ApiResponse<KnowledgePoint> updateNode(@PathVariable Long id, @RequestBody KnowledgePoint kp) {
        kp.setId(id);
        return ApiResponse.ok(kgService.update(kp));
    }

    @DeleteMapping("/nodes/{id}")
    @RequireRole("ADMIN")
    public ApiResponse<?> deleteNode(@PathVariable Long id) {
        kgService.delete(id);
        return ApiResponse.ok();
    }

    @GetMapping("/graph")
    public ApiResponse<Map<String, Object>> graphData() {
        return ApiResponse.ok(kgService.getGraphData());
    }
}
