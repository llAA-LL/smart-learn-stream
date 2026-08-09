package com.smartlearning.rag.dto;

/**
 * 一轮对话历史。
 */
public record ChatTurn(String role, String content) {
}
