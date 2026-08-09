package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.entity.Question;
import com.smartlearning.mapper.QuestionMapper;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/questions")
public class QuestionController {

    private final QuestionMapper questionMapper;

    public QuestionController(QuestionMapper questionMapper) {
        this.questionMapper = questionMapper;
    }

    @GetMapping
    public ApiResponse<List<Question>> list(@RequestParam(required = false) Long kpId) {
        if (kpId != null) {
            return ApiResponse.ok(questionMapper.findByKpId(kpId));
        }
        return ApiResponse.ok(questionMapper.findAll());
    }

    @GetMapping("/{id}")
    public ApiResponse<Question> get(@PathVariable Long id) {
        Question q = questionMapper.findById(id);
        if (q == null) {
            return ApiResponse.fail(404, "题目不存在");
        }
        return ApiResponse.ok(q);
    }

    @PostMapping
    public ApiResponse<Question> create(@RequestBody Question question) {
        questionMapper.insert(question);
        return ApiResponse.ok(questionMapper.findById(question.getId()));
    }

    @PutMapping("/{id}")
    public ApiResponse<Question> update(@PathVariable Long id, @RequestBody Question question) {
        question.setId(id);
        questionMapper.update(question);
        return ApiResponse.ok(questionMapper.findById(id));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<?> delete(@PathVariable Long id) {
        questionMapper.delete(id);
        return ApiResponse.ok();
    }
}
