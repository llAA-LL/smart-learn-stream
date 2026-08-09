package com.smartlearning.util;

import com.smartlearning.entity.Question;
import java.util.Arrays;

/**
 * 答题判分纯逻辑（无 Spring 依赖），便于单元测试。
 */
public final class AnswerGrader {

    private AnswerGrader() {
    }

    public static boolean grade(Question question, String userAnswer) {
        if (userAnswer == null || question.getAnswer() == null) {
            return false;
        }
        String type = question.getQuestionType();
        String ua = userAnswer.trim();
        String correct = question.getAnswer().trim();

        if ("TRUE_FALSE".equals(type) || "SHORT_ANSWER".equals(type)) {
            return ua.equalsIgnoreCase(correct);
        }
        // SINGLE_CHOICE / MULTI_CHOICE：忽略选项顺序与干扰字符
        return normalizeKeys(ua).equals(normalizeKeys(correct));
    }

    static String normalizeKeys(String keys) {
        char[] chars = keys.replaceAll("[^a-zA-Z]", "").toUpperCase().toCharArray();
        Arrays.sort(chars);
        return new String(chars);
    }
}
