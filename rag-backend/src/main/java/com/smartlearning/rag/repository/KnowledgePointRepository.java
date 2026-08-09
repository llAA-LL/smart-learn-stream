package com.smartlearning.rag.repository;

import com.smartlearning.rag.entity.KnowledgePoint;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

/**
 * 知识点数据访问：全量读取用于建索引，FULLTEXT 查询用于稀疏检索。
 */
@Repository
public class KnowledgePointRepository {

    private final JdbcTemplate jdbcTemplate;

    public KnowledgePointRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<KnowledgePoint> MAPPER = (rs, i) -> new KnowledgePoint(
            rs.getLong("id"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getString("learning_content"),
            (Long) rs.getObject("course_id"),
            (Integer) rs.getObject("level")
    );

    public List<KnowledgePoint> findAll() {
        return jdbcTemplate.query(
                "SELECT id, name, description, learning_content, course_id, level FROM knowledge_points",
                MAPPER);
    }

    /**
     * MySQL FULLTEXT（ngram 中文分词）关键词检索，即稀疏检索路。
     */
    public List<SparseHit> sparseSearch(String question, int limit) {
        String sql = """
                SELECT id, name, description, learning_content,
                       MATCH(name, description, learning_content)
                           AGAINST (? IN NATURAL LANGUAGE MODE) AS score
                FROM knowledge_points
                WHERE MATCH(name, description, learning_content)
                      AGAINST (? IN NATURAL LANGUAGE MODE)
                ORDER BY score DESC
                LIMIT ?
                """;
        return jdbcTemplate.query(sql, (rs, i) -> new SparseHit(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getString("learning_content"),
                rs.getDouble("score")
        ), question, question, limit);
    }

    public record SparseHit(
            Long id,
            String name,
            String description,
            String content,
            double score
    ) {
        public String toText() {
            StringBuilder sb = new StringBuilder();
            sb.append("【知识点】").append(name == null ? "" : name);
            if (description != null && !description.isBlank()) {
                sb.append("\n【描述】").append(description);
            }
            if (content != null && !content.isBlank()) {
                sb.append("\n【内容】").append(content);
            }
            return sb.toString();
        }
    }
}
