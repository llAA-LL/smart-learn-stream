package com.smartlearning.service;

import com.smartlearning.dto.QuizSubmitRequest;
import com.smartlearning.entity.*;
import com.smartlearning.dto.PagedResult;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.*;
import com.smartlearning.util.DistributedLock;
import com.smartlearning.util.RedisUtil;
import com.smartlearning.util.AnswerGrader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class QuizService {

    private final QuestionMapper questionMapper;
    private final QuizMapper quizMapper;
    private final LearningPlanMapper planMapper;
    private final UserKpMasteryMapper masteryMapper;
    private final RedisUtil redisUtil;
    private final DistributedLock distributedLock;

    private static final int QUIZ_SIZE = 5;

    public QuizService(QuestionMapper questionMapper, QuizMapper quizMapper,
                       LearningPlanMapper planMapper, UserKpMasteryMapper masteryMapper,
                       RedisUtil redisUtil, DistributedLock distributedLock) {
        this.questionMapper = questionMapper;
        this.quizMapper = quizMapper;
        this.planMapper = planMapper;
        this.masteryMapper = masteryMapper;
        this.redisUtil = redisUtil;
        this.distributedLock = distributedLock;
    }

    /**
     * Generate a quiz by randomly selecting questions for a knowledge point.
     * Answers are stripped from the returned questions.
     */
    public List<Question> generateQuiz(Long kpId) {
        int total = questionMapper.countByKpId(kpId);
        if (total == 0) {
            throw new BusinessException(404, "该知识点暂无题目");
        }
        int limit = Math.min(QUIZ_SIZE, total);
        List<Question> questions = questionMapper.findRandomByKpId(kpId, limit);
        for (Question q : questions) {
            q.setAnswer(null);
            q.setExplanation(null);
        }
        return questions;
    }

    /**
     * Submit answers, grade them, save the attempt, and update plan items + mastery.
     */
    @Transactional
    public Map<String, Object> submitQuiz(Long userId, QuizSubmitRequest request) {
        Long kpId = request.getKpId();
        List<QuizSubmitRequest.AnswerEntry> entries = request.getAnswers();

        if (entries == null || entries.isEmpty()) {
            throw new BusinessException(400, "答案不能为空");
        }

        // Load questions and grade
        int correctCount = 0;
        List<QuizAnswer> gradedAnswers = new ArrayList<>();

        for (var entry : entries) {
            Question question = questionMapper.findById(entry.getQuestionId());
            if (question == null) {
                throw new BusinessException(404, "题目不存在: " + entry.getQuestionId());
            }
            boolean isCorrect = AnswerGrader.grade(question, entry.getUserAnswer());
            if (isCorrect) correctCount++;

            QuizAnswer answer = new QuizAnswer();
            answer.setQuestionId(entry.getQuestionId());
            answer.setUserAnswer(entry.getUserAnswer());
            answer.setIsCorrect(isCorrect);
            gradedAnswers.add(answer);
        }

        int totalQuestions = entries.size();
        int score = Math.round((float) correctCount * 100 / totalQuestions);

        // Save attempt
        QuizAttempt attempt = new QuizAttempt();
        attempt.setUserId(userId);
        attempt.setKpId(kpId);
        attempt.setTotalQuestions(totalQuestions);
        attempt.setCorrectCount(correctCount);
        attempt.setScore(score);
        attempt.setCompletedAt(LocalDateTime.now());
        quizMapper.insertAttempt(attempt);

        // Save individual answers
        for (QuizAnswer answer : gradedAnswers) {
            answer.setAttemptId(attempt.getId());
            quizMapper.insertAnswer(answer);
        }

        // Auto-complete matching plan items with the quiz score
        updatePlanItems(userId, kpId, score);

        // Update mastery
        updateMastery(userId, kpId, score);

        // Load answer details for response
        List<QuizAnswer> answerDetails = quizMapper.findAnswersByAttemptId(attempt.getId());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("attemptId", attempt.getId());
        result.put("score", score);
        result.put("correctCount", correctCount);
        result.put("totalQuestions", totalQuestions);
        result.put("passed", score >= 60);
        result.put("answers", answerDetails);
        return result;
    }

    private void updatePlanItems(Long userId, Long kpId, int score) {
        List<PlanItem> matches = planMapper.findMatchingItems(userId, null, kpId);
        for (PlanItem item : matches) {
            if (!Boolean.TRUE.equals(item.getCompleted()) || item.getCompletedScore() == null || score > item.getCompletedScore()) {
                item.setCompleted(true);
                item.setCompletedScore(score);
                item.setCompletedAt(LocalDateTime.now());
                planMapper.updateItemStatus(item);
            }
        }
    }

    private void updateMastery(Long userId, Long kpId, int score) {
        String lockKey = "mastery:" + userId + ":" + kpId;
        String lockToken = distributedLock.tryLock(lockKey);
        if (lockToken == null) return;

        try {
            UserKpMastery mastery = masteryMapper.findByUserAndKp(userId, kpId);
            if (mastery == null) {
                mastery = new UserKpMastery();
                mastery.setUserId(userId);
                mastery.setKpId(kpId);
                mastery.setMasteryScore(score);
                mastery.setLearnCount(1);
            } else {
                int newScore = (int) (mastery.getMasteryScore() * 0.5 + score * 0.5);
                mastery.setMasteryScore(Math.min(100, newScore));
                mastery.setLearnCount(mastery.getLearnCount() + 1);
            }
            mastery.setLastLearnAt(LocalDateTime.now());
            masteryMapper.upsert(mastery);

            redisUtil.delete("cache:rec:" + userId);
        } finally {
            distributedLock.unlock(lockKey, lockToken);
        }
    }

    public PagedResult<QuizAttempt> getUserHistory(Long userId, int page, int pageSize) {
        List<QuizAttempt> list = quizMapper.findPageByUserId(userId, (page - 1) * pageSize, pageSize);
        return new PagedResult<>(list, quizMapper.countByUserId(userId), page, pageSize);
    }

    public QuizAttempt getAttemptDetail(Long userId, Long attemptId) {
        QuizAttempt attempt = quizMapper.findAttemptById(attemptId);
        if (attempt == null) {
            throw new BusinessException(404, "测验记录不存在");
        }
        if (!attempt.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权查看他人的测验记录");
        }
        attempt.setAnswers(quizMapper.findAnswersByAttemptId(attemptId));
        return attempt;
    }
}
