package com.smartlearning.controller;

import com.smartlearning.dto.ApiResponse;
import com.smartlearning.dto.QuizSubmitRequest;
import com.smartlearning.entity.Question;
import com.smartlearning.entity.QuizAttempt;
import com.smartlearning.service.QuizService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/quiz")
public class QuizController {

    private final QuizService quizService;

    public QuizController(QuizService quizService) {
        this.quizService = quizService;
    }

    @GetMapping("/generate")
    public ApiResponse<List<Question>> generate(@RequestParam Long kpId) {
        return ApiResponse.ok(quizService.generateQuiz(kpId));
    }

    @PostMapping("/submit")
    public ApiResponse<Map<String, Object>> submit(@RequestAttribute("userId") Long userId,
                                                    @RequestBody QuizSubmitRequest request) {
        return ApiResponse.ok(quizService.submitQuiz(userId, request));
    }

    @GetMapping("/history")
    public ApiResponse<List<QuizAttempt>> history(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(quizService.getUserHistory(userId));
    }

    @GetMapping("/attempts/{id}")
    public ApiResponse<QuizAttempt> getAttempt(@RequestAttribute("userId") Long userId,
                                                @PathVariable Long id) {
        return ApiResponse.ok(quizService.getAttemptDetail(userId, id));
    }
}
