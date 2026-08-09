package com.smartlearning.util;

import java.util.Collections;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Redis-based distributed lock for coordinating concurrent operations.
 * Uses SET NX EX pattern with Lua-based safe unlock.
 */
public class DistributedLock {

    private static final String LOCK_PREFIX = "lock:";
    private static final long DEFAULT_WAIT_MS = 3000;
    private static final long DEFAULT_LEASE_MS = 10000;

    private final RedisUtil redisUtil;

    public DistributedLock(RedisUtil redisUtil) {
        this.redisUtil = redisUtil;
    }

    /**
     * Try to acquire a lock. Returns a lock token if successful, null otherwise.
     */
    public String tryLock(String lockKey, long waitMs, long leaseMs) {
        String token = UUID.randomUUID().toString();
        String key = LOCK_PREFIX + lockKey;
        long deadline = System.currentTimeMillis() + waitMs;

        while (System.currentTimeMillis() < deadline) {
            Boolean acquired = redisUtil.getTemplate()
                    .opsForValue()
                    .setIfAbsent(key, token, leaseMs, TimeUnit.MILLISECONDS);
            if (Boolean.TRUE.equals(acquired)) {
                return token;
            }
            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return null;
            }
        }
        return null;
    }

    public String tryLock(String lockKey) {
        return tryLock(lockKey, DEFAULT_WAIT_MS, DEFAULT_LEASE_MS);
    }

    /**
     * Release lock using Lua script to ensure atomicity (only release if token matches).
     */
    public void unlock(String lockKey, String token) {
        String key = LOCK_PREFIX + lockKey;
        String script =
                "if redis.call('GET', KEYS[1]) == ARGV[1] then " +
                "  return redis.call('DEL', KEYS[1]) " +
                "else " +
                "  return 0 " +
                "end";
        redisUtil.getTemplate().execute(
                new org.springframework.data.redis.core.script.DefaultRedisScript<>(script, Long.class),
                Collections.singletonList(key), token);
    }
}
