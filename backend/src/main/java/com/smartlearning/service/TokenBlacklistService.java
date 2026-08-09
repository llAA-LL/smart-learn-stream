package com.smartlearning.service;

import com.smartlearning.util.RedisUtil;

import java.util.concurrent.TimeUnit;

/**
 * JWT token blacklist stored in Redis.
 * When a user logs out, the token is added to blacklist with TTL matching remaining validity.
 * Interceptor checks blacklist before allowing access.
 */
public class TokenBlacklistService {

    private static final String BLACKLIST_PREFIX = "token_blacklist:";

    private final RedisUtil redisUtil;

    public TokenBlacklistService(RedisUtil redisUtil) {
        this.redisUtil = redisUtil;
    }

    /**
     * Add token to blacklist with remaining TTL.
     * @param token JWT token
     * @param remainingTtlSeconds remaining token lifetime in seconds
     */
    public void blacklist(String token, long remainingTtlSeconds) {
        if (remainingTtlSeconds <= 0) return;
        String key = BLACKLIST_PREFIX + token;
        redisUtil.set(key, "1", remainingTtlSeconds, TimeUnit.SECONDS);
    }

    /**
     * Check if token is in blacklist.
     */
    public boolean isBlacklisted(String token) {
        return redisUtil.exists(BLACKLIST_PREFIX + token);
    }

    /**
     * Clean up expired entries (Redis handles this automatically via TTL).
     * This method exists for manual cleanup if needed.
     */
    public long getBlacklistSize() {
        return redisUtil.keys(BLACKLIST_PREFIX + "*").size();
    }
}
