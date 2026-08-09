package com.smartlearning.service;

import com.smartlearning.util.RedisUtil;
import org.springframework.beans.factory.annotation.Value;

import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * Multi-level caching strategy:
 * - Knowledge graph: cached 1 hour, invalidated on write
 * - Recommendations: cached 30 min per user
 * - Course list: cached 10 min
 * - Stats counter: Redis atomic ops, synchronized to DB periodically
 */
public class CacheService {

    private final RedisUtil redisUtil;

    @Value("${cache.knowledge-graph-ttl:3600}")
    private long kgTtl;

    @Value("${cache.recommendation-ttl:1800}")
    private long recTtl;

    @Value("${cache.course-list-ttl:600}")
    private long courseTtl;

    public CacheService(RedisUtil redisUtil) {
        this.redisUtil = redisUtil;
    }

    // ---- Generic cache-aside pattern ----
    @SuppressWarnings("unchecked")
    public <T> T getOrSet(String key, long ttlSeconds, Supplier<T> loader) {
        T cached = redisUtil.get(key);
        if (cached != null) {
            return cached;
        }
        T value = loader.get();
        if (value != null) {
            redisUtil.set(key, value, ttlSeconds, TimeUnit.SECONDS);
        }
        return value;
    }

    public void evict(String key) {
        redisUtil.delete(key);
    }

    public void evictPattern(String pattern) {
        for (String key : redisUtil.keys(pattern)) {
            redisUtil.delete(key);
        }
    }

    // ---- Knowledge Graph Cache ----
    private static final String KG_GRAPH_KEY = "cache:kg:graph";
    private static final String KG_NODES_KEY = "cache:kg:nodes";

    public <T> T getOrLoadKgGraph(Supplier<T> loader) {
        return getOrSet(KG_GRAPH_KEY, kgTtl, loader);
    }

    public <T> T getOrLoadKgNodes(Supplier<T> loader) {
        return getOrSet(KG_NODES_KEY, kgTtl, loader);
    }

    public void evictKgCache() {
        evict(KG_GRAPH_KEY);
        evict(KG_NODES_KEY);
    }

    // ---- Recommendation Cache (per user) ----
    private static final String REC_PREFIX = "cache:rec:";

    public <T> T getOrLoadRecommendation(Long userId, Supplier<T> loader) {
        return getOrSet(REC_PREFIX + userId, recTtl, loader);
    }

    public void evictRecommendation(Long userId) {
        evict(REC_PREFIX + userId);
    }

    // ---- Course List Cache ----
    private static final String COURSE_LIST_KEY = "cache:course:list";

    public <T> T getOrLoadCourseList(Supplier<T> loader) {
        return getOrSet(COURSE_LIST_KEY, courseTtl, loader);
    }

    public void evictCourseCache() {
        evict(COURSE_LIST_KEY);
    }

    // ---- Stats Counter Keys (public static for cross-service access) ----
    public static final String STAT_TODAY = "stat:today:";
    public static final String STAT_WEEK = "stat:week:";
    public static final String STAT_TOTAL = "stat:total:";
    public static final String ZSET_HOT_COURSES = "stat:hot:courses";
    public static final String ZSET_HOT_KPS = "stat:hot:kps";

    public RedisUtil redis() {
        return redisUtil;
    }
}
