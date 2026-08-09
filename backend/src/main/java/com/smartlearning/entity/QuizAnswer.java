package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QuizAnswer {
    private Long id;
    private Long attemptId;
    private Long questionId;
    private String userAnswer;
    private Boolean isCorrect;
    private LocalDateTime createdAt;

    // non-persistent
    private String questionContent;
    private String correctAnswer;
    private String explanation;
}
