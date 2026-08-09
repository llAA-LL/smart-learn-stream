package com.smartlearning.rag.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.ChatTurn;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.ListOperations;
import org.springframework.data.redis.core.StringRedisTemplate;

@ExtendWith(MockitoExtension.class)
class ChatMemoryServiceTest {

    @Mock
    private StringRedisTemplate redis;

    @Mock
    private ListOperations<String, String> listOps;

    private final ObjectMapper mapper = new ObjectMapper();

    private ChatMemoryService service(int maxTurns) {
        RagProperties props = new RagProperties();
        props.getMemory().setEnabled(true);
        props.getMemory().setMaxTurns(maxTurns);
        return new ChatMemoryService(redis, mapper, props);
    }

    @Test
    void loadParsesTurnsAndCapsToMaxTurns() throws Exception {
        when(redis.opsForList()).thenReturn(listOps);
        when(listOps.range(anyString(), anyLong(), anyLong())).thenReturn(List.of(
                mapper.writeValueAsString(new ChatTurn("user", "q1")),
                mapper.writeValueAsString(new ChatTurn("assistant", "a1")),
                mapper.writeValueAsString(new ChatTurn("user", "q2")),
                mapper.writeValueAsString(new ChatTurn("assistant", "a2"))
        ));

        List<ChatTurn> turns = service(1).load("c1", 1);

        assertThat(turns).hasSize(2);
        assertThat(turns.get(0).content()).isEqualTo("q2");
        assertThat(turns.get(1).role()).isEqualTo("assistant");
    }

    @Test
    void appendPushesJsonAndTrimsOldEntries() throws Exception {
        when(redis.opsForList()).thenReturn(listOps);
        when(listOps.size("rag:chat:c1")).thenReturn(30L);

        service(10).append("c1", new ChatTurn("user", "q"), new ChatTurn("assistant", "a"));

        verify(listOps).rightPushAll(eq("rag:chat:c1"), anyString(), anyString());
        verify(listOps).trim("rag:chat:c1", 10, -1);
    }

    @Test
    void disabledMemoryDoesNothing() {
        RagProperties props = new RagProperties();
        props.getMemory().setEnabled(false);
        ChatMemoryService service = new ChatMemoryService(redis, mapper, props);

        service.append("c1", new ChatTurn("user", "q"), new ChatTurn("assistant", "a"));
        service.load("c1", 10);

        verifyNoInteractions(redis);
    }

    @Test
    void nullConversationIsIgnored() {
        service(10).append(null, new ChatTurn("user", "q"), new ChatTurn("assistant", "a"));

        verifyNoInteractions(redis);
    }
}
