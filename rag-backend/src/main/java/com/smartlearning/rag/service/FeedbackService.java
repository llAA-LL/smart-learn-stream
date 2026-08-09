package com.smartlearning.rag.service;

import com.smartlearning.rag.dto.FeedbackRequest;
import java.util.stream.Collectors;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class FeedbackService {

    private final JdbcTemplate jdbcTemplate;

    public FeedbackService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(FeedbackRequest request) {
        String kpIds = request.sources() == null ? "" :
                request.sources().stream().map(String::valueOf).collect(Collectors.joining(","));
        jdbcTemplate.update("""
                INSERT INTO rag_feedback (conversation_id, question, answer, rating, source_kp_ids)
                VALUES (?, ?, ?, ?, ?)
                """,
                request.conversationId(),
                request.question(),
                request.answer(),
                request.rating(),
                kpIds);
    }
}
