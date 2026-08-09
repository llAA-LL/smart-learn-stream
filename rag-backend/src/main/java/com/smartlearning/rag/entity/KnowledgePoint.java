package com.smartlearning.rag.entity;

/**
 * 知识点，对应 MySQL 表 knowledge_points。
 * 每个知识点天然是 RAG 的一个检索单元：标题 + 描述 + 学习内容。
 */
public record KnowledgePoint(
        Long id,
        String name,
        String description,
        String learningContent,
        Long courseId,
        Integer level
) {

    /** 组装成送给检索/模型的文本。 */
    public String toText() {
        StringBuilder sb = new StringBuilder();
        sb.append("【知识点】").append(name == null ? "" : name);
        if (description != null && !description.isBlank()) {
            sb.append("\n【描述】").append(description);
        }
        if (learningContent != null && !learningContent.isBlank()) {
            sb.append("\n【内容】").append(learningContent);
        }
        return sb.toString();
    }
}
