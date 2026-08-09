package com.smartlearning.rag.dto;

import java.util.List;

public record ChatResponse(
        String conversationId,
        String answer,
        List<Citation> citations,
        long elapsedMs
) {
}
