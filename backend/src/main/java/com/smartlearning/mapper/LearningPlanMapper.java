package com.smartlearning.mapper;

import com.smartlearning.entity.LearningPlan;
import com.smartlearning.entity.PlanItem;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface LearningPlanMapper {

    @Select("SELECT * FROM learning_plans WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<LearningPlan> findByUserId(Long userId);

    @Select("SELECT * FROM learning_plans WHERE id = #{id}")
    LearningPlan findById(Long id);

    @Insert("INSERT INTO learning_plans (user_id, title, description, start_date, end_date, status) VALUES (#{userId}, #{title}, #{description}, #{startDate}, #{endDate}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(LearningPlan plan);

    @Update("UPDATE learning_plans SET title=#{title}, description=#{description}, start_date=#{startDate}, end_date=#{endDate}, status=#{status} WHERE id=#{id}")
    int update(LearningPlan plan);

    @Delete("DELETE FROM learning_plans WHERE id=#{id}")
    int delete(Long id);

    // Plan Items
    @Select("SELECT pi.*, c.name as course_name, kp.name as kp_name FROM plan_items pi LEFT JOIN courses c ON pi.course_id = c.id LEFT JOIN knowledge_points kp ON pi.kp_id = kp.id WHERE pi.id = #{id}")
    PlanItem findItemById(Long id);

    @Select("SELECT pi.*, c.name as course_name, kp.name as kp_name FROM plan_items pi LEFT JOIN courses c ON pi.course_id = c.id LEFT JOIN knowledge_points kp ON pi.kp_id = kp.id WHERE pi.plan_id = #{planId} ORDER BY pi.sort_order")
    List<PlanItem> findItemsByPlanId(Long planId);

    @Insert("INSERT INTO plan_items (plan_id, course_id, kp_id, item_type, sort_order, target_date) VALUES (#{planId}, #{courseId}, #{kpId}, #{itemType}, #{sortOrder}, #{targetDate})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertItem(PlanItem item);

    @Update("UPDATE plan_items SET completed=#{completed}, completed_score=#{completedScore}, completed_at=#{completedAt} WHERE id=#{id}")
    int updateItemStatus(PlanItem item);

    @Delete("DELETE FROM plan_items WHERE id=#{id}")
    int deleteItem(Long id);

    @Select("SELECT pi.* FROM plan_items pi INNER JOIN learning_plans lp ON pi.plan_id = lp.id WHERE lp.user_id = #{userId} AND lp.status = 'ACTIVE' AND (pi.completed IS NULL OR pi.completed = 0) AND ((pi.kp_id = #{kpId}) OR (pi.course_id = #{courseId}))")
    List<PlanItem> findMatchingItems(@Param("userId") Long userId, @Param("courseId") Long courseId, @Param("kpId") Long kpId);
}
