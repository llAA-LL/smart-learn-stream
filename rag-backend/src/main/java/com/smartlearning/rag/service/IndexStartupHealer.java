package com.smartlearning.rag.service;

import com.smartlearning.rag.config.RagProperties;
import com.smartlearning.rag.dto.IndexResult;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 启动自愈：向量索引为空时自动重建。
 *
 * <p>背景：Chroma 向量库可能因环境迁移、路径切换或初始化遗漏而为空，此时稠密检索
 * 静默失效（不报错、日志正常），只剩关键词模糊匹配，回答质量明显下降——这是此前
 * "JVM 内存模型答非所问"事故的根因。本组件在应用就绪后用一个固定探针查询检测
 * 集合是否为空：为空则调用 {@link KnowledgeIndexService#rebuild()}（幂等，按
 * kp-{id}-{index} 覆盖），非空则跳过，探测失败则记录警告并跳过，不让启动失败。</p>
 *
 * <p>注意：不用 Chroma HTTP /count 接口判断空——实测 Chroma 1.5.9 该接口在集合
 * 已有数据时仍可能返回 0，而探针走的是与真实检索完全一致的
 * {@link VectorStore#similaritySearch} 链路，结果更可靠。</p>
 */
@Component
public class IndexStartupHealer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(IndexStartupHealer.class);
    /** 固定探针：任意能命中知识库的短查询，仅用于判断集合是否为空。 */
    private static final String PROBE_QUERY = "JVM 内存 学习";

    private final VectorStore vectorStore;
    private final KnowledgeIndexService indexService;
    private final RagProperties props;

    public IndexStartupHealer(VectorStore vectorStore,
                              KnowledgeIndexService indexService,
                              RagProperties props) {
        this.vectorStore = vectorStore;
        this.indexService = indexService;
        this.props = props;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!props.getIndex().isAutoHealOnEmpty()) {
            log.info("向量索引自愈已禁用（rag.index.auto-heal-on-empty=false）");
            return;
        }
        try {
            List<Document> probe = vectorStore.similaritySearch(SearchRequest.builder()
                    .query(PROBE_QUERY)
                    .topK(1)
                    .build());
            if (probe != null && !probe.isEmpty()) {
                log.info("向量索引健康（探针命中 {} 条），跳过自动重建", probe.size());
                return;
            }

            log.warn("向量索引为空，触发自动重建（幂等，重复执行安全）...");
            long start = System.currentTimeMillis();
            IndexResult result = indexService.rebuild();
            log.info("向量索引自动重建完成: {} 个知识点 -> {} 个分块，耗时 {}ms",
                    result.knowledgePoints(), result.chunks(), result.durationMs());
        } catch (Exception e) {
            log.warn("向量索引健康检查失败（本地嵌入服务未就绪？），跳过自动重建: {}", e.getMessage());
        }
    }
}
