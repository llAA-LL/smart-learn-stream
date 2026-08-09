package com.smartlearning.rag.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.List;

/**
 * 问答请求：conversationId 用于前端串联会话，history 为最近若干轮历史。
 */
public record ChatRequest(
        String conversationId,
        List<ChatTurn> history,
        @NotBlank(message = "问题不能为空") String question,
        String token
) {
}
