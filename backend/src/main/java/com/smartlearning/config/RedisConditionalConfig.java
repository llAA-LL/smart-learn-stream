package com.smartlearning.config;

import com.smartlearning.service.CacheService;
import com.smartlearning.service.TokenBlacklistService;
import com.smartlearning.util.DistributedLock;
import com.smartlearning.util.RedisUtil;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;

@Configuration
public class RedisConditionalConfig {

    // ---- Real beans (when RedisTemplate is available) ----
    @Bean
    @SuppressWarnings({"rawtypes", "unchecked"})
    public RedisUtil redisUtil(@Qualifier("redisTemplate") ObjectProvider<RedisTemplate> provider) {
        RedisTemplate template = provider.getIfAvailable();
        if (template != null) {
            return new RedisUtil(template);
        }
        return noOpRedisUtil();
    }

    @Bean
    public CacheService cacheService(ObjectProvider<RedisUtil> provider) {
        RedisUtil redis = provider.getIfAvailable();
        if (redis != null && redis.getTemplate() != null) {
            return new CacheService(redis);
        }
        return noOpCacheService();
    }

    @Bean
    public TokenBlacklistService tokenBlacklistService(ObjectProvider<RedisUtil> provider) {
        RedisUtil redis = provider.getIfAvailable();
        if (redis != null && redis.getTemplate() != null) {
            return new TokenBlacklistService(redis);
        }
        return noOpBlacklistService();
    }

    @Bean
    public DistributedLock distributedLock(ObjectProvider<RedisUtil> provider) {
        RedisUtil redis = provider.getIfAvailable();
        if (redis != null && redis.getTemplate() != null) {
            return new DistributedLock(redis);
        }
        return noOpLock();
    }

    // ---- No-op fallbacks ----
    private RedisUtil noOpRedisUtil() {
        return new RedisUtil(null) {
            public void set(String k, Object v) {}
            public void set(String k, Object v, long t, java.util.concurrent.TimeUnit u) {}
            public <T> T get(String k) { return null; }
            public boolean exists(String k) { return false; }
            public void delete(String k) {}
            public boolean expire(String k, long t, java.util.concurrent.TimeUnit u) { return true; }
            public long getExpire(String k) { return -1L; }
            public long increment(String k) { return 0L; }
            public long increment(String k, long d) { return d; }
            public void sAdd(String k, Object... vs) {}
            public boolean sIsMember(String k, Object v) { return false; }
            public java.util.Set<Object> sMembers(String k) { return java.util.Collections.emptySet(); }
            public long sRemove(String k, Object... vs) { return 0L; }
            public boolean zAdd(String k, Object v, double s) { return true; }
            public double zIncrementScore(String k, Object v, double d) { return 0.0; }
            public java.util.Set<org.springframework.data.redis.core.ZSetOperations.TypedTuple<Object>> zReverseRangeWithScores(String k, long s, long e) { return java.util.Collections.emptySet(); }
            public void hSet(String k, String f, Object v) {}
            public <T> T hGet(String k, String f) { return null; }
            public java.util.Map<Object, Object> hGetAll(String k) { return java.util.Collections.emptyMap(); }
            public long hIncrement(String k, String f, long d) { return d; }
            public java.util.Set<String> keys(String p) { return java.util.Collections.emptySet(); }
            public org.springframework.data.redis.core.RedisTemplate<String, Object> getTemplate() { return null; }
        };
    }

    private CacheService noOpCacheService() {
        return new CacheService(null) {
            public <T> T getOrSet(String key, long ttl, java.util.function.Supplier<T> loader) {
                return loader.get();
            }
            public void evict(String key) {}
            public void evictPattern(String pattern) {}
            public <T> T getOrLoadKgGraph(java.util.function.Supplier<T> loader) { return loader.get(); }
            public <T> T getOrLoadKgNodes(java.util.function.Supplier<T> loader) { return loader.get(); }
            public void evictKgCache() {}
            public <T> T getOrLoadRecommendation(Long uid, java.util.function.Supplier<T> l) { return l.get(); }
            public void evictRecommendation(Long uid) {}
            public <T> T getOrLoadCourseList(java.util.function.Supplier<T> l) { return l.get(); }
            public void evictCourseCache() {}
            public com.smartlearning.util.RedisUtil redis() { return null; }
        };
    }

    private TokenBlacklistService noOpBlacklistService() {
        return new TokenBlacklistService(null) {
            public void blacklist(String token, long ttl) {}
            public boolean isBlacklisted(String token) { return false; }
        };
    }

    private DistributedLock noOpLock() {
        return new DistributedLock(null) {
            public String tryLock(String key, long wait, long lease) { return "noop"; }
            public String tryLock(String key) { return "noop"; }
            public void unlock(String key, String token) {}
        };
    }
}
