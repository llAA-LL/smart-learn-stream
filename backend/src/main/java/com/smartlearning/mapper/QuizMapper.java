package com.smartlearning.mapper;

import com.smartlearning.entity.QuizAnswer;
import com.smartlearning.entity.QuizAttempt;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface QuizMapper {

    // Attempts
    @Insert("INSERT INTO quiz_attempts (user_id, kp_id, total_questions, correct_count, score, completed_at) VALUES (#{userId}, #{kpId}, #{totalQuestions}, #{correctCount}, #{score}, #{completedAt})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertAttempt(QuizAttempt attempt);

    @Select("SELECT * FROM quiz_attempts WHERE id = #{id}")
    QuizAttempt findAttemptById(Long id);

    @Select("SELECT qa.*, kp.name as kp_name FROM quiz_attempts qa LEFT JOIN knowledge_points kp ON qa.kp_id = kp.id WHERE qa.user_id = #{userId} ORDER BY qa.completed_at DESC")
    List<QuizAttempt> findByUserId(Long userId);

    @Select("SELECT COUNT(*) FROM quiz_attempts WHERE user_id = #{userId}")
    int countByUserId(Long userId);

    @Select("SELECT qa.*, kp.name as kp_name FROM quiz_attempts qa LEFT JOIN knowledge_points kp ON qa.kp_id = kp.id WHERE qa.user_id = #{userId} ORDER BY qa.completed_at DESC LIMIT #{offset}, #{limit}")
    List<QuizAttempt> findPageByUserId(@Param("userId") Long userId, @Param("offset") int offset, @Param("limit") int limit);

    @Select("SELECT qa.*, kp.name as kp_name FROM quiz_attempts qa LEFT JOIN knowledge_points kp ON qa.kp_id = kp.id WHERE qa.user_id = #{userId} AND qa.kp_id = #{kpId} ORDER BY qa.completed_at DESC")
    List<QuizAttempt> findByUserAndKp(@Param("userId") Long userId, @Param("kpId") Long kpId);

    @Select("SELECT MAX(score) FROM quiz_attempts WHERE user_id = #{userId} AND kp_id = #{kpId}")
    Integer bestScoreByUserAndKp(@Param("userId") Long userId, @Param("kpId") Long kpId);

    // Answers
    @Insert("INSERT INTO quiz_answers (attempt_id, question_id, user_answer, is_correct) VALUES (#{attemptId}, #{questionId}, #{userAnswer}, #{isCorrect})")
    int insertAnswer(QuizAnswer answer);

    @Select("SELECT a.*, q.content as question_content, q.answer as correct_answer, q.explanation FROM quiz_answers a LEFT JOIN questions q ON a.question_id = q.id WHERE a.attempt_id = #{attemptId}")
    List<QuizAnswer> findAnswersByAttemptId(Long attemptId);
}
