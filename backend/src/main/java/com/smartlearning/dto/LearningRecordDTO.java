package com.smartlearning.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class LearningRecordDTO {
    private Long courseId;
    private Long kpId;

    @NotNull @Min(1)
    private Integer durationMinutes;

    private Integer masteryLevel;
    private String notes;
    private LocalDate recordDate;
}
