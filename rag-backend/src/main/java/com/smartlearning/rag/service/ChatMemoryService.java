package com.smartlearning.rag.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.ChatTurn;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/**
 * 服务端多轮会话记忆（Redis List，按时间序）。
 * <p>
 * key = rag:chat:{conversationId}，每个元素是一条 JSON 化的 ChatTurn；
 * 写入时 LTRIM 裁剪到 max-turns * 2 条。Redis 不可用时自动降级为空记忆，
 * 不影响主链路。
 */
@Service
public class ChatMemoryService {

    private static final Logger log = LoggerFactory.getLogger(ChatMemoryService.class);
    private static final String KEY_PREFIX = "rag:chat:";

    private final StringRedisTemplate redis;
    private final ObjectMapper objectMapper;
    private final RagProperties props;

    public ChatMemoryService(StringRedisTemplate redis, ObjectMapper objectMapper, RagProperties props) {
        this.redis = redis;
        this.objectMapper = objectMapper;
        this.props = props;
    }

    public List<ChatTurn> load(String conversationId, int maxTurns) {
        if (!active(conversationId)) {
            return List.of();
        }
        try {
            List<String> raw = redis.opsForList().range(key(conversationId), 0, -1);
            if (raw == null || raw.isEmpty()) {
                return List.of();
            }
            List<ChatTurn> turns = new ArrayList<>();
            for (String entry : raw) {
                try {
                    turns.add(objectMapper.readValue(entry, ChatTurn.class));
                } catch (Exception ignored) {
                    // 单条损坏不影响其他记录
                }
            }
            int cap = maxTurns * 2;
            if (turns.size() > cap) {
                return new ArrayList<>(turns.subList(turns.size() - cap, turns.size()));
            }
            return turns;
        } catch (Exception e) {
            log.warn("加载会话记忆失败（Redis 不可用？）: {}", e.getMessage());
            return List.of();
        }
    }

    public void append(String conversationId, ChatTurn userTurn, ChatTurn assistantTurn) {
        if (!active(conversationId)) {
            return;
        }
        try {
            String key = key(conversationId);
            redis.opsForList().rightPushAll(key,
                    objectMapper.writeValueAsString(userTurn),
                    objectMapper.writeValueAsString(assistantTurn));
            int cap = props.getMemory().getMaxTurns() * 2;
            Long size = redis.opsForList().size(key);
            if (size != null && size > cap) {
                redis.opsForList().trim(key, size - cap, -1);
            }
        } catch (Exception e) {
            log.warn("保存会话记忆失败: {}", e.getMessage());
        }
    }

    public void clear(String conversationId) {
        if (conversationId == null || conversationId.isBlank()) {
            return;
        }
        try {
            redis.delete(key(conversationId));
        } catch (Exception e) {
            log.warn("清除会话记忆失败: {}", e.getMessage());
        }
    }

    private boolean active(String conversationId) {
        return props.getMemory().isEnabled()
                && conversationId != null
                && !conversationId.isBlank();
    }

    private String key(String conversationId) {
        return KEY_PREFIX + conversationId;
    }
}
