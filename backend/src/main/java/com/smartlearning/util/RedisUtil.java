package com.smartlearning.util;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;

import java.util.*;
import java.util.concurrent.TimeUnit;

public class RedisUtil {

    @SuppressWarnings("rawtypes")
    private final RedisTemplate redisTemplate;

    @SuppressWarnings({"rawtypes", "unchecked"})
    public RedisUtil(RedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    // ---- String ----
    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    @SuppressWarnings("unchecked")
    public <T> T get(String key) {
        return (T) redisTemplate.opsForValue().get(key);
    }

    public boolean exists(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    public boolean expire(String key, long timeout, TimeUnit unit) {
        return Boolean.TRUE.equals(redisTemplate.expire(key, timeout, unit));
    }

    public long getExpire(String key) {
        Long ttl = redisTemplate.getExpire(key);
        return ttl != null ? ttl : -1;
    }

    // ---- Increment / Counter ----
    public long increment(String key) {
        Long val = redisTemplate.opsForValue().increment(key);
        return val != null ? val : 0;
    }

    public long increment(String key, long delta) {
        Long val = redisTemplate.opsForValue().increment(key, delta);
        return val != null ? val : 0;
    }

    // ---- Set ----
    public void sAdd(String key, Object... values) {
        redisTemplate.opsForSet().add(key, values);
    }

    public boolean sIsMember(String key, Object value) {
        return Boolean.TRUE.equals(redisTemplate.opsForSet().isMember(key, value));
    }

    public Set<Object> sMembers(String key) {
        return redisTemplate.opsForSet().members(key);
    }

    public long sRemove(String key, Object... values) {
        Long removed = redisTemplate.opsForSet().remove(key, values);
        return removed != null ? removed : 0;
    }

    // ---- ZSet (sorted set) ----
    public boolean zAdd(String key, Object value, double score) {
        return Boolean.TRUE.equals(redisTemplate.opsForZSet().add(key, value, score));
    }

    public double zIncrementScore(String key, Object value, double delta) {
        Double score = redisTemplate.opsForZSet().incrementScore(key, value, delta);
        return score != null ? score : 0;
    }

    public Set<ZSetOperations.TypedTuple<Object>> zReverseRangeWithScores(String key, long start, long end) {
        return redisTemplate.opsForZSet().reverseRangeWithScores(key, start, end);
    }

    // ---- Hash ----
    public void hSet(String key, String field, Object value) {
        redisTemplate.opsForHash().put(key, field, value);
    }

    @SuppressWarnings("unchecked")
    public <T> T hGet(String key, String field) {
        return (T) redisTemplate.opsForHash().get(key, field);
    }

    public Map<Object, Object> hGetAll(String key) {
        return redisTemplate.opsForHash().entries(key);
    }

    public long hIncrement(String key, String field, long delta) {
        return redisTemplate.opsForHash().increment(key, field, delta);
    }

    // ---- Keys ----
    public Set<String> keys(String pattern) {
        return redisTemplate.keys(pattern);
    }

    @SuppressWarnings("rawtypes")
    public RedisTemplate getTemplate() {
        return redisTemplate;
    }
}
