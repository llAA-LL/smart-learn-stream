package com.smartlearning.mapper;

import com.smartlearning.entity.LearningRecord;
import org.apache.ibatis.annotations.*;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
public interface LearningRecordMapper {

    @Select("SELECT lr.*, c.name as course_name, kp.name as kp_name FROM learning_records lr LEFT JOIN courses c ON lr.course_id = c.id LEFT JOIN knowledge_points kp ON lr.kp_id = kp.id WHERE lr.user_id = #{userId} ORDER BY lr.created_at DESC")
    List<LearningRecord> findByUserId(Long userId);

    @Select("SELECT lr.*, c.name as course_name, kp.name as kp_name FROM learning_records lr LEFT JOIN courses c ON lr.course_id = c.id LEFT JOIN knowledge_points kp ON lr.kp_id = kp.id WHERE lr.user_id = #{userId} AND lr.record_date BETWEEN #{start} AND #{end} ORDER BY lr.record_date")
    List<LearningRecord> findByUserAndDateRange(@Param("userId") Long userId, @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Insert("INSERT INTO learning_records (user_id, course_id, kp_id, duration_minutes, mastery_level, notes, record_date) VALUES (#{userId}, #{courseId}, #{kpId}, #{durationMinutes}, #{masteryLevel}, #{notes}, #{recordDate})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(LearningRecord record);

    // Statistics
    @Select("SELECT COALESCE(SUM(duration_minutes), 0) FROM learning_records WHERE user_id = #{userId} AND record_date = #{date}")
    int totalMinutesByDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Select("SELECT COALESCE(SUM(duration_minutes), 0) FROM learning_records WHERE user_id = #{userId} AND record_date >= #{date}")
    int totalMinutesSince(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Select("SELECT record_date as date, SUM(duration_minutes) as minutes FROM learning_records WHERE user_id = #{userId} AND record_date BETWEEN #{start} AND #{end} GROUP BY record_date ORDER BY record_date")
    List<Map<String, Object>> dailyStats(@Param("userId") Long userId, @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Select("SELECT COALESCE(SUM(duration_minutes), 0) FROM learning_records WHERE user_id = #{userId}")
    int totalMinutesAllTime(Long userId);
}
