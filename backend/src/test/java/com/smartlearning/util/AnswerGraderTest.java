package com.smartlearning.util;

import static org.assertj.core.api.Assertions.assertThat;

import com.smartlearning.entity.Question;
import org.junit.jupiter.api.Test;

class AnswerGraderTest {

    private Question question(String type, String answer) {
        Question q = new Question();
        q.setQuestionType(type);
        q.setAnswer(answer);
        return q;
    }

    @Test
    void singleChoiceIgnoresCaseAndWhitespace() {
        assertThat(AnswerGrader.grade(question("SINGLE_CHOICE", "A"), "a")).isTrue();
        assertThat(AnswerGrader.grade(question("SINGLE_CHOICE", " B "), "b")).isTrue();
        assertThat(AnswerGrader.grade(question("SINGLE_CHOICE", "B"), "A")).isFalse();
    }

    @Test
    void multiChoiceIgnoresOptionOrder() {
        assertThat(AnswerGrader.grade(question("MULTI_CHOICE", "ABC"), "C,A,B")).isTrue();
        assertThat(AnswerGrader.grade(question("MULTI_CHOICE", "AB"), "AC")).isFalse();
    }

    @Test
    void trueFalseIsCaseInsensitive() {
        assertThat(AnswerGrader.grade(question("TRUE_FALSE", "TRUE"), "true")).isTrue();
        assertThat(AnswerGrader.grade(question("TRUE_FALSE", "TRUE"), "FALSE")).isFalse();
    }

    @Test
    void nullAnswerOrMissingQuestionIsFalse() {
        assertThat(AnswerGrader.grade(question("SINGLE_CHOICE", "A"), null)).isFalse();
        assertThat(AnswerGrader.grade(new Question(), "A")).isFalse();
    }
}
