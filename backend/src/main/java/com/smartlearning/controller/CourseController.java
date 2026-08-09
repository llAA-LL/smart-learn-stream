package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.Course;
import com.smartlearning.service.CourseService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/courses")
public class CourseController {

    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    @GetMapping
    public ApiResponse<List<Course>> list() {
        return ApiResponse.ok(courseService.findAll());
    }

    @GetMapping("/{id}")
    public ApiResponse<Course> get(@PathVariable Long id) {
        return ApiResponse.ok(courseService.findById(id));
    }

    @PostMapping
    public ApiResponse<Course> create(@RequestBody Course course,
                                       @RequestAttribute("userId") Long userId) {
        course.setCreatedBy(userId);
        return ApiResponse.ok(courseService.create(course));
    }

    @PutMapping("/{id}")
    public ApiResponse<Course> update(@PathVariable Long id, @RequestBody Course course) {
        course.setId(id);
        return ApiResponse.ok(courseService.update(course));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<?> delete(@PathVariable Long id) {
        courseService.delete(id);
        return ApiResponse.ok();
    }
}
