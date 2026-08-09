package com.smartlearning.mapper;

import com.smartlearning.entity.Question;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface QuestionMapper {

    @Select("SELECT q.*, kp.name as kp_name, c.name as course_name FROM questions q LEFT JOIN knowledge_points kp ON q.kp_id = kp.id LEFT JOIN courses c ON kp.course_id = c.id ORDER BY q.kp_id, q.id")
    List<Question> findAll();

    @Select("SELECT q.*, kp.name as kp_name, c.name as course_name FROM questions q LEFT JOIN knowledge_points kp ON q.kp_id = kp.id LEFT JOIN courses c ON kp.course_id = c.id WHERE q.id = #{id}")
    Question findById(Long id);

    @Select("SELECT q.*, kp.name as kp_name, c.name as course_name FROM questions q LEFT JOIN knowledge_points kp ON q.kp_id = kp.id LEFT JOIN courses c ON kp.course_id = c.id WHERE q.kp_id = #{kpId} ORDER BY q.difficulty, q.id")
    List<Question> findByKpId(Long kpId);

    @Select("SELECT q.*, kp.name as kp_name FROM questions q LEFT JOIN knowledge_points kp ON q.kp_id = kp.id WHERE q.kp_id = #{kpId} ORDER BY RAND() LIMIT #{limit}")
    List<Question> findRandomByKpId(@Param("kpId") Long kpId, @Param("limit") int limit);

    @Select("SELECT COUNT(*) FROM questions WHERE kp_id = #{kpId}")
    int countByKpId(Long kpId);

    @Insert("INSERT INTO questions (kp_id, question_type, content, options, answer, explanation, difficulty) VALUES (#{kpId}, #{questionType}, #{content}, #{options}, #{answer}, #{explanation}, #{difficulty})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Question question);

    @Update("UPDATE questions SET kp_id=#{kpId}, question_type=#{questionType}, content=#{content}, options=#{options}, answer=#{answer}, explanation=#{explanation}, difficulty=#{difficulty} WHERE id=#{id}")
    int update(Question question);

    @Delete("DELETE FROM questions WHERE id=#{id}")
    int delete(Long id);
}
