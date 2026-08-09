package com.smartlearning.mapper;

import com.smartlearning.entity.RecommendationLog;
import org.apache.ibatis.annotations.*;

@Mapper
public interface RecommendationLogMapper {

    @Insert("INSERT INTO recommendation_logs (user_id, kp_id, reason, clicked) VALUES (#{userId}, #{kpId}, #{reason}, #{clicked})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(RecommendationLog log);

    @Select("SELECT rl.*, kp.name as kp_name FROM recommendation_logs rl LEFT JOIN knowledge_points kp ON rl.kp_id = kp.id WHERE rl.user_id = #{userId} ORDER BY rl.created_at DESC LIMIT 50")
    java.util.List<java.util.Map<String, Object>> findRecentByUserId(Long userId);

    @Update("UPDATE recommendation_logs SET clicked = true WHERE user_id = #{userId} AND kp_id = #{kpId} AND clicked = false")
    int markClicked(@Param("userId") Long userId, @Param("kpId") Long kpId);
}
