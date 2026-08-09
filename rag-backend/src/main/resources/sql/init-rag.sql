-- RAG 稀疏检索依赖的 MySQL 全文索引（ngram 中文分词）
-- 幂等：索引已存在时的报错会被 spring.sql.init.continue-on-error 忽略
ALTER TABLE knowledge_points
    ADD FULLTEXT INDEX ft_kp_rag_search (name, description, learning_content) WITH PARSER ngram;

-- 用户对 RAG 回答的反馈（前端点赞/点踩）
CREATE TABLE IF NOT EXISTS rag_feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id VARCHAR(64),
    question TEXT,
    answer MEDIUMTEXT,
    rating VARCHAR(8) COMMENT 'up or down',
    source_kp_ids VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
