package com.smartlearning.rag.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.List;

/**
 * 回答反馈：前端点赞/点踩，用于后续评估与数据收集。
 */
public record FeedbackRequest(
        String conversationId,
        @NotBlank(message = "问题不能为空") String question,
        @NotBlank(message = "回答不能为空") String answer,
        @NotBlank(message = "评分类型不能为空") String rating,
        List<Long> sources
) {
}
