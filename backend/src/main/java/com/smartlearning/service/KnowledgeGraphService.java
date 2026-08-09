package com.smartlearning.service;

import com.smartlearning.entity.KnowledgePoint;
import com.smartlearning.entity.KpPrerequisite;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.KnowledgePointMapper;
import com.smartlearning.config.RagIndexNotifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class KnowledgeGraphService {

    private final KnowledgePointMapper kpMapper;
    private final CacheService cacheService;
    private final RagIndexNotifier ragIndexNotifier;

    public KnowledgeGraphService(KnowledgePointMapper kpMapper, CacheService cacheService,
                                 RagIndexNotifier ragIndexNotifier) {
        this.kpMapper = kpMapper;
        this.cacheService = cacheService;
        this.ragIndexNotifier = ragIndexNotifier;
    }

    public List<KnowledgePoint> findByCourseId(Long courseId) {
        return cacheService.getOrSet("cache:kg:nodes:course:" + courseId, 3600, () -> {
            List<KnowledgePoint> kps = kpMapper.findByCourseId(courseId);
            for (KnowledgePoint kp : kps) {
                kp.setPrerequisiteIds(kpMapper.findPrerequisiteIds(kp.getId()));
            }
            return kps;
        });
    }

    public List<KnowledgePoint> findAll() {
        return cacheService.getOrLoadKgNodes(() -> {
            List<KnowledgePoint> kps = kpMapper.findAll();
            for (KnowledgePoint kp : kps) {
                kp.setPrerequisiteIds(kpMapper.findPrerequisiteIds(kp.getId()));
            }
            return kps;
        });
    }

    public KnowledgePoint findById(Long id) {
        KnowledgePoint kp = kpMapper.findById(id);
        if (kp == null) {
            throw new BusinessException(404, "知识点不存在");
        }
        kp.setPrerequisiteIds(kpMapper.findPrerequisiteIds(id));
        return kp;
    }

    @Transactional
    public KnowledgePoint create(KnowledgePoint kp) {
        kpMapper.insert(kp);
        if (kp.getPrerequisiteIds() != null) {
            for (Long preId : kp.getPrerequisiteIds()) {
                kpMapper.insertPrerequisite(new KpPrerequisite(null, kp.getId(), preId));
            }
        }
        cacheService.evictKgCache();
        ragIndexNotifier.notifyRebuild();
        return findById(kp.getId());
    }

    @Transactional
    public KnowledgePoint update(KnowledgePoint kp) {
        findById(kp.getId());
        kpMapper.update(kp);
        kpMapper.deletePrerequisites(kp.getId());
        if (kp.getPrerequisiteIds() != null) {
            for (Long preId : kp.getPrerequisiteIds()) {
                if (!preId.equals(kp.getId())) {
                    kpMapper.insertPrerequisite(new KpPrerequisite(null, kp.getId(), preId));
                }
            }
        }
        cacheService.evictKgCache();
        ragIndexNotifier.notifyRebuild();
        return findById(kp.getId());
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        kpMapper.delete(id);
        cacheService.evictKgCache();
        ragIndexNotifier.notifyRebuild();
    }

    public Map<String, Object> getGraphData() {
        return cacheService.getOrLoadKgGraph(() -> {
            List<KnowledgePoint> nodes = findAll();
            List<KpPrerequisite> edges = kpMapper.findAllEdges();

            List<Map<String, Object>> graphNodes = nodes.stream().map(kp -> {
                Map<String, Object> node = new LinkedHashMap<>();
                node.put("id", kp.getId());
                node.put("name", kp.getName());
                node.put("category", kp.getCourseName() != null ? kp.getCourseName() : "未分类");
                node.put("level", kp.getLevel());
                return node;
            }).collect(Collectors.toList());

            List<Map<String, Object>> graphEdges = edges.stream().map(e -> {
                Map<String, Object> edge = new LinkedHashMap<>();
                edge.put("source", e.getPrerequisiteKpId());
                edge.put("target", e.getKpId());
                return edge;
            }).collect(Collectors.toList());

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("nodes", graphNodes);
            result.put("edges", graphEdges);
            return result;
        });
    }
}
