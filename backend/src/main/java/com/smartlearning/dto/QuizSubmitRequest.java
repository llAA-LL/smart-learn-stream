package com.smartlearning.dto;

import lombok.Data;
import java.util.List;

@Data
public class QuizSubmitRequest {
    private Long kpId;
    private List<AnswerEntry> answers;

    @Data
    public static class AnswerEntry {
        private Long questionId;
        private String userAnswer;
    }
}
