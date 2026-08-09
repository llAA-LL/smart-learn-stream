package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class PlanItem {
    private Long id;
    private Long planId;
    private Long courseId;
    private Long kpId;
    private String itemType;
    private Integer sortOrder;
    private LocalDate targetDate;
    private Boolean completed;
    private Integer completedScore;
    private LocalDateTime completedAt;

    // non-persistent
    private String courseName;
    private String kpName;
}
