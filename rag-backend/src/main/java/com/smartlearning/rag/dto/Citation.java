package com.smartlearning.rag.dto;

import java.util.List;

/**
 * 回答引用来源，前端可以展示"依据哪个知识点回答"。
 */
public record Citation(
        Long kpId,
        String kpName,
        double score,
        List<String> sources
) {
}
