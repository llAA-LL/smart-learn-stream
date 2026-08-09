package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Question {
    private Long id;
    private Long kpId;
    private String questionType;
    private String content;
    private String options;
    private String answer;
    private String explanation;
    private Integer difficulty;
    private LocalDateTime createdAt;

    // non-persistent
    private String kpName;
    private String courseName;
}
