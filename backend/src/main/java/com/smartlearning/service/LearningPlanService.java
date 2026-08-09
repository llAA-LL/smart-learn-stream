package com.smartlearning.service;

import com.smartlearning.entity.LearningPlan;
import com.smartlearning.entity.PlanItem;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.LearningPlanMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class LearningPlanService {

    private final LearningPlanMapper planMapper;

    public LearningPlanService(LearningPlanMapper planMapper) {
        this.planMapper = planMapper;
    }

    public List<LearningPlan> getUserPlans(Long userId) {
        List<LearningPlan> plans = planMapper.findByUserId(userId);
        for (LearningPlan plan : plans) {
            List<PlanItem> items = planMapper.findItemsByPlanId(plan.getId());
            plan.setItems(items);
            plan.setProgressPercent(calcProgress(items));
        }
        return plans;
    }

    public LearningPlan findById(Long id) {
        LearningPlan plan = planMapper.findById(id);
        if (plan == null) {
            throw new BusinessException(404, "学习计划不存在");
        }
        List<PlanItem> items = planMapper.findItemsByPlanId(plan.getId());
        plan.setItems(items);
        plan.setProgressPercent(calcProgress(items));
        return plan;
    }

    private double calcProgress(List<PlanItem> items) {
        if (items == null || items.isEmpty()) return 100.0;
        double totalScore = items.stream()
            .mapToInt(i -> Boolean.TRUE.equals(i.getCompleted())
                ? (i.getCompletedScore() != null ? i.getCompletedScore() : 100)
                : 0)
            .sum();
        return Math.round(totalScore / items.size() * 10.0) / 10.0;
    }

    @Transactional
    public LearningPlan create(Long userId, LearningPlan plan) {
        plan.setUserId(userId);
        if (plan.getStatus() == null) {
            plan.setStatus("ACTIVE");
        }
        planMapper.insert(plan);
        if (plan.getItems() != null) {
            for (PlanItem item : plan.getItems()) {
                item.setPlanId(plan.getId());
                if (item.getSortOrder() == null) item.setSortOrder(0);
                planMapper.insertItem(item);
            }
        }
        return findById(plan.getId());
    }

    @Transactional
    public LearningPlan update(LearningPlan plan) {
        findById(plan.getId());
        planMapper.update(plan);
        return findById(plan.getId());
    }

    @Transactional
    public PlanItem toggleItem(Long itemId) {
        PlanItem target = planMapper.findItemById(itemId);
        if (target == null) {
            throw new BusinessException(404, "计划条目不存在");
        }
        target.setCompleted(!Boolean.TRUE.equals(target.getCompleted()));
        target.setCompletedAt(target.getCompleted() ? LocalDateTime.now() : null);
        planMapper.updateItemStatus(target);
        return target;
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        planMapper.delete(id);
    }
}
