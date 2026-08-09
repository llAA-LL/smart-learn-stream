package com.smartlearning.entity;

import java.time.LocalDateTime;

public class RecommendationLog {
    private Long id;
    private Long userId;
    private Long kpId;
    private String reason;
    private Boolean clicked;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getKpId() { return kpId; }
    public void setKpId(Long kpId) { this.kpId = kpId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public Boolean getClicked() { return clicked; }
    public void setClicked(Boolean clicked) { this.clicked = clicked; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
