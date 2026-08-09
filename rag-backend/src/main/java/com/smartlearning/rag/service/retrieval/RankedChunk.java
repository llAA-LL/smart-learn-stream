package com.smartlearning.rag.service.retrieval;

import java.util.ArrayList;
import java.util.List;

/**
 * 检索结果：一个知识点及其融合分数、命中的检索路（dense / sparse）。
 */
public record RankedChunk(
        Long kpId,
        String kpName,
        String content,
        double score,
        List<String> sources
) {

    public RankedChunk merge(RankedChunk other) {
        List<String> mergedSources = new ArrayList<>(sources);
        for (String source : other.sources) {
            if (!mergedSources.contains(source)) {
                mergedSources.add(source);
            }
        }
        return new RankedChunk(kpId, kpName, content, score + other.score, mergedSources);
    }
}
