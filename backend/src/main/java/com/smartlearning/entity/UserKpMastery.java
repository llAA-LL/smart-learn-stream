package com.smartlearning.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserKpMastery {
    private Long id;
    private Long userId;
    private Long kpId;
    private Integer masteryScore;
    private Integer learnCount;
    private LocalDateTime lastLearnAt;

    // non-persistent
    private String kpName;
}
