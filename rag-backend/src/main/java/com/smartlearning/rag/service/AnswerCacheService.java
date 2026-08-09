package com.smartlearning.rag.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.Citation;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.HexFormat;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/**
 * 热问题回答缓存（Cache-Aside）：
 * 仅缓存"无历史上下文的独立问题"，避免多轮对话语境不一致。
 * Redis 不可用时静默降级，不影响主链路。
 */
@Service
public class AnswerCacheService {

    private static final Logger log = LoggerFactory.getLogger(AnswerCacheService.class);
    private static final String KEY_PREFIX = "rag:cache:q:";

    private final StringRedisTemplate redis;
    private final ObjectMapper objectMapper;
    private final RagProperties props;

    public AnswerCacheService(StringRedisTemplate redis, ObjectMapper objectMapper, RagProperties props) {
        this.redis = redis;
        this.objectMapper = objectMapper;
        this.props = props;
    }

    public CachedAnswer get(String question) {
        if (!props.getCache().isEnabled() || question == null) {
            return null;
        }
        try {
            String raw = redis.opsForValue().get(key(question));
            if (raw == null) {
                return null;
            }
            return objectMapper.readValue(raw, CachedAnswer.class);
        } catch (Exception e) {
            log.warn("读取回答缓存失败: {}", e.getMessage());
            return null;
        }
    }

    public void put(String question, String answer, List<Citation> citations, long elapsedMs) {
        if (!props.getCache().isEnabled() || question == null || answer == null) {
            return;
        }
        try {
            String json = objectMapper.writeValueAsString(new CachedAnswer(answer, citations, elapsedMs));
            redis.opsForValue().set(key(question), json, Duration.ofSeconds(props.getCache().getTtlSeconds()));
        } catch (Exception e) {
            log.warn("写入回答缓存失败: {}", e.getMessage());
        }
    }

    private String key(String question) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(question.getBytes(StandardCharsets.UTF_8));
            return KEY_PREFIX + HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            // 理论不可达
            return KEY_PREFIX + Integer.toHexString(question.hashCode());
        }
    }

    public record CachedAnswer(String answer, List<Citation> citations, long elapsedMs) {
    }
}
