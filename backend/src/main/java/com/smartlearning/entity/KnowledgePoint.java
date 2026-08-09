package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class KnowledgePoint {
    private Long id;
    private String name;
    private String description;
    private String learningContent;
    private Long courseId;
    private Integer level;
    private Double xPosition;
    private Double yPosition;
    private LocalDateTime createdAt;

    // non-persistent fields for graph data
    private String courseName;
    private List<Long> prerequisiteIds;
}
