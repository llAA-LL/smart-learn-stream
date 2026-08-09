package com.smartlearning.rag.dto;

public record IndexResult(
        int knowledgePoints,
        int chunks,
        long durationMs
) {
}
