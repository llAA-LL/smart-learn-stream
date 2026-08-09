package com.smartlearning.rag.service.chunking;

import static org.assertj.core.api.Assertions.assertThat;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.entity.KnowledgePoint;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.ai.document.Document;

class DocumentChunkerTest {

    private DocumentChunker chunker(int size, int overlap) {
        RagProperties props = new RagProperties();
        props.getIndex().setChunkSize(size);
        props.getIndex().setChunkOverlap(overlap);
        return new DocumentChunker(props);
    }

    @Test
    void shortContentProducesSingleChunkWithMetadata() {
        KnowledgePoint kp = new KnowledgePoint(1L, "死锁", "四个必要条件",
                "死锁是两个或多个进程无限期等待对方持有的资源。", 1L, 2);

        List<Document> docs = chunker(800, 80).chunk(kp);

        assertThat(docs).hasSize(1);
        assertThat(docs.get(0).getId()).isEqualTo("kp-1-0");
        assertThat(docs.get(0).getText()).contains("死锁");
        assertThat(docs.get(0).getMetadata().get("kpId")).isEqualTo(1L);
        assertThat(docs.get(0).getMetadata().get("kpName")).isEqualTo("死锁");
        assertThat(docs.get(0).getMetadata().get("courseId")).isEqualTo(1L);
    }

    @Test
    void longContentSplitsIntoMultipleChunksWithOverlap() {
        StringBuilder content = new StringBuilder();
        for (int i = 0; i < 30; i++) {
            content.append("第").append(i).append("段，内容内容内容内容内容内容内容内容内容。\n");
        }
        KnowledgePoint kp = new KnowledgePoint(2L, "长知识点", null, content.toString(), 1L, 1);

        List<Document> docs = chunker(100, 20).chunk(kp);

        assertThat(docs.size()).isGreaterThan(1);
        for (Document d : docs) {
            assertThat(d.getText()).contains("【知识点】长知识点");
        }
        // 相邻块通过重叠窗口保持上下文衔接
        String firstText = docs.get(0).getText();
        String tail = firstText.substring(Math.max(0, firstText.length() - 20));
        assertThat(docs.get(1).getText()).contains(tail);
    }

    @Test
    void blankContentStillProducesHeaderChunk() {
        KnowledgePoint kp = new KnowledgePoint(3L, "空知识点", "描述", null, 1L, 1);

        List<Document> docs = chunker(100, 10).chunk(kp);

        assertThat(docs).hasSize(1);
        assertThat(docs.get(0).getText()).isEqualTo("【知识点】空知识点\n【描述】描述");
    }

    @Test
    void singleParagraphLongerThanChunkSizeHardSplits() {
        KnowledgePoint kp = new KnowledgePoint(4L, "超长段", null, "字".repeat(300), 1L, 1);

        List<Document> docs = chunker(100, 20).chunk(kp);

        assertThat(docs.size()).isGreaterThan(2);
        for (Document d : docs) {
            assertThat(d.getText().length()).isLessThanOrEqualTo(120);
        }
    }
}
