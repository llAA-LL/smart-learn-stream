package com.smartlearning.rag.service.rerank;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.service.retrieval.RankedChunk;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.core.io.ClassPathResource;

/**
 * LLM 精排：让 DeepSeek 对候选片段按相关性打分（0-10），
 * 解决"向量/关键词都召回但排序不精准"的问题。
 * 打分失败时自动回退到 RRF 融合后的顺序，保证链路可用。
 */
public class LlmRerankService implements Reranker {

    private static final Logger log = LoggerFactory.getLogger(LlmRerankService.class);
    private static final Pattern SCORES_PATTERN = Pattern.compile("\\[(\\s*-?\\d+\\s*(,\\s*-?\\d+\\s*)*)]");

    private final ChatModel chatModel;
    private final RagProperties props;
    private final String rerankPromptTemplate;

    public LlmRerankService(ChatModel chatModel, RagProperties props) throws Exception {
        this.chatModel = chatModel;
        this.props = props;
        this.rerankPromptTemplate = new ClassPathResource("prompts/rerank-prompt.txt")
                .getContentAsString(StandardCharsets.UTF_8);
    }

    public List<RankedChunk> rerank(String question, List<RankedChunk> candidates) {
        if (!props.getRerank().isEnabled() || candidates.size() <= 1) {
            return candidates;
        }
        try {
            PromptTemplate template = new PromptTemplate(rerankPromptTemplate);
            template.add("question", question);
            template.add("candidates", buildCandidateList(candidates));
            String promptText = template.render();
            String response = chatModel.call(new Prompt(promptText))
                    .getResult()
                    .getOutput()
                    .getText();
            List<Integer> scores = parseScores(response);
            if (scores.size() != candidates.size()) {
                log.warn("重排打分数量不匹配({} != {})，回退 RRF 顺序", scores.size(), candidates.size());
                return candidates;
            }

            List<ScoredCandidate> scored = new ArrayList<>();
            for (int i = 0; i < candidates.size(); i++) {
                scored.add(new ScoredCandidate(candidates.get(i), scores.get(i)));
            }
            scored.sort(Comparator.comparingInt(ScoredCandidate::score).reversed());
            return scored.stream().map(ScoredCandidate::chunk).toList();
        } catch (Exception e) {
            log.warn("LLM 重排失败，回退到 RRF 顺序: {}", e.getMessage());
            return candidates;
        }
    }

    private String buildCandidateList(List<RankedChunk> candidates) {
        StringBuilder sb = new StringBuilder();
        int maxChars = props.getRerank().getMaxChars();
        for (int i = 0; i < candidates.size(); i++) {
            RankedChunk chunk = candidates.get(i);
            String content = chunk.content();
            if (content.length() > maxChars) {
                content = content.substring(0, maxChars) + "…";
            }
            sb.append(i + 1).append(". ").append(content).append("\n");
        }
        return sb.toString();
    }

    private List<Integer> parseScores(String response) {
        Matcher matcher = SCORES_PATTERN.matcher(response);
        if (!matcher.find()) {
            throw new IllegalArgumentException("无法从重排结果解析分数: " + response);
        }
        List<Integer> scores = new ArrayList<>();
        for (String part : matcher.group(1).split(",")) {
            scores.add(Integer.parseInt(part.trim()));
        }
        return scores;
    }

    private record ScoredCandidate(RankedChunk chunk, int score) {
    }
}
