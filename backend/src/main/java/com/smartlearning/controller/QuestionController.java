package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.dto.PagedResult;
import com.smartlearning.entity.Question;
import com.smartlearning.mapper.QuestionMapper;
import com.smartlearning.annotation.RequireRole;
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
    @RequireRole("ADMIN")
    public ApiResponse<PagedResult<Question>> list(@RequestParam(required = false) Long kpId,
                                                   @RequestParam(defaultValue = "1") int page,
                                                   @RequestParam(defaultValue = "20") int pageSize) {
        int size = Math.min(pageSize, 100);
        int offset = (Math.max(page, 1) - 1) * size;
        if (kpId != null) {
            return ApiResponse.ok(new PagedResult<>(
                    questionMapper.findPageByKp(kpId, offset, size),
                    questionMapper.countByKpId(kpId), Math.max(page, 1), size));
        }
        return ApiResponse.ok(new PagedResult<>(
                questionMapper.findPageAll(offset, size),
                questionMapper.countAll(), Math.max(page, 1), size));
    }

    @GetMapping("/{id}")
    @RequireRole("ADMIN")
    public ApiResponse<Question> get(@PathVariable Long id) {
        Question q = questionMapper.findById(id);
        if (q == null) {
            return ApiResponse.fail(404, "题目不存在");
        }
        return ApiResponse.ok(q);
    }

    @PostMapping
    @RequireRole("ADMIN")
    public ApiResponse<Question> create(@RequestBody Question question) {
        questionMapper.insert(question);
        return ApiResponse.ok(questionMapper.findById(question.getId()));
    }

    @PutMapping("/{id}")
    @RequireRole("ADMIN")
    public ApiResponse<Question> update(@PathVariable Long id, @RequestBody Question question) {
        question.setId(id);
        questionMapper.update(question);
        return ApiResponse.ok(questionMapper.findById(id));
    }

    @DeleteMapping("/{id}")
    @RequireRole("ADMIN")
    public ApiResponse<?> delete(@PathVariable Long id) {
        questionMapper.delete(id);
        return ApiResponse.ok();
    }
}
