package com.smartlearning.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class PlanItemDTO {
    private Long courseId;
    private Long kpId;
    private String itemType;
    private LocalDate targetDate;
}
