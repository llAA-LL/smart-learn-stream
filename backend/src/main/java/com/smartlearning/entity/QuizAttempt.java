package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class QuizAttempt {
    private Long id;
    private Long userId;
    private Long kpId;
    private Integer totalQuestions;
    private Integer correctCount;
    private Integer score;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    // non-persistent
    private String kpName;
    private List<QuizAnswer> answers;
}
