package com.smartlearning.service;

import com.smartlearning.entity.LearningRecord;
import com.smartlearning.entity.UserKpMastery;
import com.smartlearning.dto.PagedResult;
import com.smartlearning.mapper.LearningRecordMapper;
import com.smartlearning.mapper.UserKpMasteryMapper;
import com.smartlearning.util.DistributedLock;
import com.smartlearning.util.RedisUtil;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Service
public class LearningRecordService {

    private final LearningRecordMapper recordMapper;
    private final UserKpMasteryMapper masteryMapper;
    private final RedisUtil redisUtil;
    private final DistributedLock distributedLock;

    public LearningRecordService(LearningRecordMapper recordMapper,
                                  UserKpMasteryMapper masteryMapper,
                                  RedisUtil redisUtil,
                                  DistributedLock distributedLock) {
        this.recordMapper = recordMapper;
        this.masteryMapper = masteryMapper;
        this.redisUtil = redisUtil;
        this.distributedLock = distributedLock;
    }

    /**
     * Record learning session. Uses:
     * - Distributed lock on user_kp for mastery update consistency
     * - Redis INCR for atomic counter updates
     * - ZSet for hot courses/knowledge points ranking
     */
    @Transactional
    public LearningRecord record(Long userId, LearningRecord record) {
        if (record.getRecordDate() == null) {
            record.setRecordDate(LocalDate.now());
        }
        record.setUserId(userId);
        recordMapper.insert(record);

        String today = record.getRecordDate().format(DateTimeFormatter.ISO_LOCAL_DATE);

        // Atomic counters in Redis — fire and forget, no DB contention
        redisUtil.increment(CacheService.STAT_TODAY + userId + ":" + today, record.getDurationMinutes());
        redisUtil.expire(CacheService.STAT_TODAY + userId + ":" + today, 48, TimeUnit.HOURS);

        redisUtil.increment(CacheService.STAT_WEEK + userId, record.getDurationMinutes());
        redisUtil.expire(CacheService.STAT_WEEK + userId, 7, TimeUnit.DAYS);

        redisUtil.increment(CacheService.STAT_TOTAL + userId, record.getDurationMinutes());

        // Hot ranking: ZSet increment for course and knowledge point
        if (record.getCourseId() != null) {
            redisUtil.zIncrementScore(CacheService.ZSET_HOT_COURSES, record.getCourseId().toString(), 1);
        }
        if (record.getKpId() != null) {
            redisUtil.zIncrementScore(CacheService.ZSET_HOT_KPS, record.getKpId().toString(), 1);
        }

        // Update mastery with distributed lock to prevent concurrent score corruption
        if (record.getKpId() != null && record.getMasteryLevel() != null) {
            String lockKey = "mastery:" + userId + ":" + record.getKpId();
            String lockToken = distributedLock.tryLock(lockKey);
            if (lockToken != null) {
                try {
                    UserKpMastery mastery = masteryMapper.findByUserAndKp(userId, record.getKpId());
                    if (mastery == null) {
                        mastery = new UserKpMastery();
                        mastery.setUserId(userId);
                        mastery.setKpId(record.getKpId());
                        mastery.setMasteryScore(record.getMasteryLevel());
                        mastery.setLearnCount(1);
                    } else {
                        // Weighted average: 70% historical + 30% latest
                        int newScore = (int) (mastery.getMasteryScore() * 0.7 + record.getMasteryLevel() * 0.3);
                        mastery.setMasteryScore(Math.min(100, newScore));
                        mastery.setLearnCount(mastery.getLearnCount() + 1);
                    }
                    mastery.setLastLearnAt(java.time.LocalDateTime.now());
                    masteryMapper.upsert(mastery);

                    // Evict recommendation cache since mastery changed
                    redisUtil.delete("cache:rec:" + userId);
                } finally {
                    distributedLock.unlock(lockKey, lockToken);
                }
            }
        }
        return record;
    }

    public PagedResult<LearningRecord> getUserRecords(Long userId, int page, int pageSize) {
        List<LearningRecord> list = recordMapper.findPageByUserId(userId, (page - 1) * pageSize, pageSize);
        return new PagedResult<>(list, recordMapper.countByUserId(userId), page, pageSize);
    }

    /**
     * Get stats from Redis counters (fast path).
     * Falls back to DB for historical data if Redis key is missing.
     */
    public Map<String, Object> getStats(Long userId) {
        LocalDate today = LocalDate.now();
        String todayKey = CacheService.STAT_TODAY + userId + ":" + today.format(DateTimeFormatter.ISO_LOCAL_DATE);
        String weekKey = CacheService.STAT_WEEK + userId;
        String totalKey = CacheService.STAT_TOTAL + userId;

        Map<String, Object> stats = new LinkedHashMap<>();

        Integer todayMinutes = redisUtil.get(todayKey);
        if (todayMinutes == null) {
            todayMinutes = recordMapper.totalMinutesByDate(userId, today);
            redisUtil.set(todayKey, todayMinutes, 48, TimeUnit.HOURS);
        }
        stats.put("todayMinutes", todayMinutes);

        Integer weekMinutes = redisUtil.get(weekKey);
        if (weekMinutes == null) {
            // 修复：此前 totalMinutesByDate 是精确匹配单日，这里应统计最近 7 天
            weekMinutes = recordMapper.totalMinutesSince(userId, today.minusDays(7));
            redisUtil.set(weekKey, weekMinutes, 7, TimeUnit.DAYS);
        }
        stats.put("weekMinutes", weekMinutes);

        Integer totalMinutes = redisUtil.get(totalKey);
        if (totalMinutes == null) {
            totalMinutes = recordMapper.totalMinutesAllTime(userId);
            redisUtil.set(totalKey, totalMinutes);
        }
        stats.put("totalMinutes", totalMinutes);

        // Daily stats still from DB (detail data)
        List<Map<String, Object>> dailyStats = recordMapper.dailyStats(userId, today.minusDays(30), today);
        stats.put("dailyStats", dailyStats);

        return stats;
    }

    public List<UserKpMastery> getUserMastery(Long userId) {
        return masteryMapper.findByUserId(userId);
    }

    /**
     * Get hot courses ranking from Redis ZSet.
     */
    public List<Map<String, Object>> getHotCourses(int topN) {
        List<Map<String, Object>> result = new ArrayList<>();
        var topSet = redisUtil.zReverseRangeWithScores(CacheService.ZSET_HOT_COURSES, 0, topN - 1);
        if (topSet != null) {
            for (var entry : topSet) {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("courseId", Long.parseLong(entry.getValue().toString()));
                item.put("count", entry.getScore().longValue());
                result.add(item);
            }
        }
        return result;
    }

    /**
     * Get hot knowledge points ranking from Redis ZSet.
     */
    public List<Map<String, Object>> getHotKnowledgePoints(int topN) {
        List<Map<String, Object>> result = new ArrayList<>();
        var topSet = redisUtil.zReverseRangeWithScores(CacheService.ZSET_HOT_KPS, 0, topN - 1);
        if (topSet != null) {
            for (var entry : topSet) {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("kpId", Long.parseLong(entry.getValue().toString()));
                item.put("count", entry.getScore().longValue());
                result.add(item);
            }
        }
        return result;
    }
}
