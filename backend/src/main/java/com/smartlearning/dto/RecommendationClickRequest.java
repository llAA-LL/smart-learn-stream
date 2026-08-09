package com.smartlearning.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RecommendationClickRequest {

    @NotNull(message = "知识点ID不能为空")
    private Long kpId;
}
