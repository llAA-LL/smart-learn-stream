package com.smartlearning.service;

import com.smartlearning.entity.KnowledgePoint;
import com.smartlearning.entity.RecommendationLog;
import com.smartlearning.entity.UserKpMastery;
import com.smartlearning.mapper.KnowledgePointMapper;
import com.smartlearning.mapper.RecommendationLogMapper;
import com.smartlearning.mapper.UserKpMasteryMapper;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendationService {

    private final KnowledgePointMapper kpMapper;
    private final UserKpMasteryMapper masteryMapper;
    private final RecommendationLogMapper logMapper;
    private final CacheService cacheService;

    public RecommendationService(KnowledgePointMapper kpMapper, UserKpMasteryMapper masteryMapper,
                                  RecommendationLogMapper logMapper, CacheService cacheService) {
        this.kpMapper = kpMapper;
        this.masteryMapper = masteryMapper;
        this.logMapper = logMapper;
        this.cacheService = cacheService;
    }

    /**
     * Recommend next knowledge points. Cached per user for 30 minutes.
     */
    public List<Map<String, Object>> recommend(Long userId) {
        return cacheService.getOrLoadRecommendation(userId, () -> computeRecommendations(userId));
    }

    private List<Map<String, Object>> computeRecommendations(Long userId) {
        List<UserKpMastery> userMastery = masteryMapper.findByUserId(userId);
        Set<Long> masteredKpIds = userMastery.stream()
                .filter(m -> m.getMasteryScore() >= 60)
                .map(UserKpMastery::getKpId)
                .collect(Collectors.toSet());

        Set<Long> weakKpIds = userMastery.stream()
                .filter(m -> m.getMasteryScore() < 60)
                .map(UserKpMastery::getKpId)
                .collect(Collectors.toSet());

        List<KnowledgePoint> allKps = kpMapper.findAll();
        // 批量加载前置关系，避免循环内逐条查询（N+1）
        Map<Long, List<Long>> prereqMap = kpMapper.findAllEdges().stream()
                .collect(Collectors.groupingBy(
                        com.smartlearning.entity.KpPrerequisite::getKpId,
                        Collectors.mapping(
                                com.smartlearning.entity.KpPrerequisite::getPrerequisiteKpId,
                                Collectors.toList())));
        Map<Long, Integer> levelMap = allKps.stream()
                .collect(Collectors.toMap(KnowledgePoint::getId, KnowledgePoint::getLevel, (a, b) -> a));

        List<Map<String, Object>> recommendations = new ArrayList<>();

        for (KnowledgePoint kp : allKps) {
            if (masteredKpIds.contains(kp.getId())) continue;

            List<Long> prereqs = prereqMap.getOrDefault(kp.getId(), List.of());
            boolean prereqsSatisfied = prereqs.isEmpty() || masteredKpIds.containsAll(prereqs);
            if (!prereqsSatisfied) continue;

            Map<String, Object> rec = new LinkedHashMap<>();
            rec.put("kpId", kp.getId());
            rec.put("kpName", kp.getName());
            rec.put("courseName", kp.getCourseName());

            if (weakKpIds.contains(kp.getId())) {
                rec.put("type", "REVIEW");
                rec.put("reason", "该知识点掌握度较低，建议复习巩固");
                rec.put("priority", 1);
            } else if (prereqs.stream().anyMatch(masteredKpIds::contains)) {
                rec.put("type", "NEXT");
                rec.put("reason", "前置知识已掌握，可进入学习");
                rec.put("priority", 2);
            } else {
                rec.put("type", "NEW");
                rec.put("reason", "可探索的新知识领域");
                rec.put("priority", 3);
            }
            recommendations.add(rec);
        }

        recommendations.sort(Comparator
                .<Map<String, Object>>comparingInt(m -> (int) m.get("priority"))
                .thenComparing(m -> levelMap.getOrDefault(m.get("kpId"), 99)));

        return recommendations.stream().limit(10).collect(Collectors.toList());
    }

    public List<UserKpMastery> getWeakPoints(Long userId) {
        List<UserKpMastery> all = masteryMapper.findByUserId(userId);
        return all.stream()
                .filter(m -> m.getMasteryScore() < 60)
                .sorted(Comparator.comparingInt(UserKpMastery::getMasteryScore))
                .collect(Collectors.toList());
    }

    /**
     * Log when a user views recommendations for analytics.
     */
    public void logView(Long userId, String reason) {
        RecommendationLog log = new RecommendationLog();
        log.setUserId(userId);
        log.setReason(reason);
        log.setClicked(false);
        logMapper.insert(log);
    }

    /** 用户点击推荐：把对应推荐记录标记为已点击，形成"浏览→点击"闭环。 */
    public void markClicked(Long userId, Long kpId) {
        logMapper.markClicked(userId, kpId);
    }
}
