package com.smartlearning.rag.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import org.mockito.ArgumentCaptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.Citation;
import com.smartlearning.rag.service.AnswerCacheService.CachedAnswer;
import java.time.Duration;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

@ExtendWith(MockitoExtension.class)
class AnswerCacheServiceTest {

    @Mock
    private StringRedisTemplate redis;

    @Mock
    private ValueOperations<String, String> valueOps;

    private final ObjectMapper mapper = new ObjectMapper();

    private AnswerCacheService service(boolean enabled) {
        RagProperties props = new RagProperties();
        props.getCache().setEnabled(enabled);
        props.getCache().setTtlSeconds(3600);
        return new AnswerCacheService(redis, mapper, props);
    }

    @Test
    void getReturnsNullWhenDisabled() {
        AnswerCacheService service = service(false);

        assertThat(service.get("问题")).isNull();
        verifyNoInteractions(redis);
    }

    @Test
    void getParsesCachedAnswer() throws Exception {
        when(redis.opsForValue()).thenReturn(valueOps);
        CachedAnswer expected = new CachedAnswer("回答", List.of(new Citation(1L, "死锁", 0.5, List.of("dense"))), 123L);
        when(valueOps.get(anyString())).thenReturn(mapper.writeValueAsString(expected));

        CachedAnswer actual = service(true).get("什么是死锁？");

        assertThat(actual).isNotNull();
        assertThat(actual.answer()).isEqualTo("回答");
        assertThat(actual.citations()).hasSize(1);
        assertThat(actual.elapsedMs()).isEqualTo(123L);
    }

    @Test
    void putWritesJsonWithTtl() {
        when(redis.opsForValue()).thenReturn(valueOps);

        service(true).put("问题", "回答", List.of(), 50L);

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        verify(valueOps).set(keyCaptor.capture(), anyString(), eq(Duration.ofSeconds(3600)));
        String key = keyCaptor.getValue();
        assertThat(key).startsWith("rag:cache:q:");
        assertThat(key).hasSize("rag:cache:q:".length() + 64);
        assertThat(key.substring("rag:cache:q:".length())).matches("[0-9a-f]{64}");
    }
}
