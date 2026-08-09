package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class LearningRecord {
    private Long id;
    private Long userId;
    private Long courseId;
    private Long kpId;
    private Integer durationMinutes;
    private Integer masteryLevel;
    private String notes;
    private LocalDate recordDate;
    private LocalDateTime createdAt;

    // non-persistent
    private String courseName;
    private String kpName;
}
