package com.smartlearning.rag.service.chunking;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.entity.KnowledgePoint;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.ai.document.Document;
import org.springframework.stereotype.Component;

/**
 * 知识点感知的分块器：
 * <ul>
 *   <li>标题/描述始终保留在每个块里，避免子块丢失上下文；</li>
 *   <li>长内容按段落聚合，超过 chunk-size 时截断并带重叠窗口；</li>
 *   <li>Document id 使用 kp-{id}-{index} 的确定性格式，重复建索引时按 id 覆盖（upsert）。</li>
 * </ul>
 */
@Component
public class DocumentChunker {

    private final int chunkSize;
    private final int chunkOverlap;

    public DocumentChunker(RagProperties props) {
        this.chunkSize = props.getIndex().getChunkSize();
        this.chunkOverlap = props.getIndex().getChunkOverlap();
    }

    public List<Document> chunk(KnowledgePoint kp) {
        String header = buildHeader(kp);
        String body = kp.learningContent() == null ? "" : kp.learningContent().trim();

        List<Document> docs = new ArrayList<>();
        if (body.isBlank()) {
            docs.add(buildDocument(kp, header, "", 0));
            return docs;
        }

        int index = 0;
        StringBuilder buffer = new StringBuilder();
        for (String raw : body.split("\\n+")) {
            String paragraph = raw.trim();
            if (paragraph.isBlank()) {
                continue;
            }
            // 单段超长：先清空缓冲，再按字符窗口硬切（带重叠）
            if (paragraph.length() > chunkSize) {
                if (!buffer.isEmpty()) {
                    docs.add(buildDocument(kp, header, buffer.toString().trim(), index++));
                    buffer.setLength(0);
                }
                for (String part : splitBySize(paragraph, chunkSize, chunkOverlap)) {
                    docs.add(buildDocument(kp, header, part, index++));
                }
                continue;
            }
            // 超过容量：落盘当前缓冲，并把上一块尾部片段带进下一块保持衔接
            if (!buffer.isEmpty() && buffer.length() + paragraph.length() + 1 > chunkSize) {
                String flushed = buffer.toString().trim();
                docs.add(buildDocument(kp, header, flushed, index++));
                buffer.setLength(0);
                if (chunkOverlap > 0 && !flushed.isEmpty()) {
                    String overlap = flushed.length() <= chunkOverlap
                            ? flushed : flushed.substring(flushed.length() - chunkOverlap);
                    buffer.append(overlap).append("\n");
                }
            }
            buffer.append(paragraph).append("\n");
        }
        if (!buffer.isEmpty()) {
            docs.add(buildDocument(kp, header, buffer.toString().trim(), index));
        }
        return docs;
    }

    private Document buildDocument(KnowledgePoint kp, String header, String body, int index) {
        String text = body.isBlank() ? header : header + "\n" + body;
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("kpId", kp.id());
        metadata.put("kpName", kp.name());
        metadata.put("courseId", kp.courseId() == null ? -1L : kp.courseId());
        metadata.put("level", kp.level() == null ? -1 : kp.level());
        return new Document("kp-" + kp.id() + "-" + index, text, metadata);
    }

    private String buildHeader(KnowledgePoint kp) {
        StringBuilder sb = new StringBuilder();
        sb.append("【知识点】").append(kp.name() == null ? "" : kp.name());
        if (kp.description() != null && !kp.description().isBlank()) {
            sb.append("\n【描述】").append(kp.description());
        }
        return sb.toString();
    }

    private List<String> splitBySize(String text, int size, int overlap) {
        List<String> parts = new ArrayList<>();
        int start = 0;
        while (start < text.length()) {
            int end = Math.min(start + size, text.length());
            parts.add(text.substring(start, end));
            if (end == text.length()) {
                break;
            }
            start = end - overlap;
        }
        return parts;
    }
}
