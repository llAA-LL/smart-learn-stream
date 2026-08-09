package com.smartlearning.mapper;

import com.smartlearning.entity.UserKpMastery;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface UserKpMasteryMapper {

    @Select("SELECT ukm.*, kp.name as kp_name FROM user_kp_mastery ukm JOIN knowledge_points kp ON ukm.kp_id = kp.id WHERE ukm.user_id = #{userId}")
    List<UserKpMastery> findByUserId(Long userId);

    @Select("SELECT ukm.*, kp.name as kp_name FROM user_kp_mastery ukm JOIN knowledge_points kp ON ukm.kp_id = kp.id WHERE ukm.user_id = #{userId} AND ukm.kp_id = #{kpId}")
    UserKpMastery findByUserAndKp(@Param("userId") Long userId, @Param("kpId") Long kpId);

    @Insert("INSERT INTO user_kp_mastery (user_id, kp_id, mastery_score, learn_count, last_learn_at) VALUES (#{userId}, #{kpId}, #{masteryScore}, #{learnCount}, #{lastLearnAt}) ON DUPLICATE KEY UPDATE mastery_score=#{masteryScore}, learn_count=#{learnCount}, last_learn_at=#{lastLearnAt}")
    int upsert(UserKpMastery mastery);
}
