package com.smartlearning.rag.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * RAG 模块配置，对应 application.yml 中的 rag.* 前缀。
 */
@ConfigurationProperties(prefix = "rag")
public class RagProperties {

    private final Retrieval retrieval = new Retrieval();
    private final Rerank rerank = new Rerank();
    private final Index index = new Index();
    private final Memory memory = new Memory();
    private final Cache cache = new Cache();

    public Retrieval getRetrieval() {
        return retrieval;
    }

    public Rerank getRerank() {
        return rerank;
    }

    public Index getIndex() {
        return index;
    }

    public Memory getMemory() {
        return memory;
    }

    public Cache getCache() {
        return cache;
    }

    public static class Retrieval {
        private int denseTopK = 10;
        private int sparseTopK = 10;
        private int rerankTopK = 5;

        public int getDenseTopK() {
            return denseTopK;
        }

        public void setDenseTopK(int denseTopK) {
            this.denseTopK = denseTopK;
        }

        public int getSparseTopK() {
            return sparseTopK;
        }

        public void setSparseTopK(int sparseTopK) {
            this.sparseTopK = sparseTopK;
        }

        public int getRerankTopK() {
            return rerankTopK;
        }

        public void setRerankTopK(int rerankTopK) {
            this.rerankTopK = rerankTopK;
        }
    }

    public static class Rerank {
        private boolean enabled = true;
        private int maxChars = 600;
        /**
         * LLM 重排后的最低保留分（0-10）。
         * 打分标准与 rerank-prompt 一致：6-8 相关、3-5 泛泛背景、0-2 无关。
         * 低于该分数的片段会被过滤，避免把无关知识点塞进上下文和引用列表。
         */
        private int minScore = 4;

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public int getMaxChars() {
            return maxChars;
        }

        public void setMaxChars(int maxChars) {
            this.maxChars = maxChars;
        }

        public int getMinScore() {
            return minScore;
        }

        public void setMinScore(int minScore) {
            this.minScore = minScore;
        }
    }

    public static class Index {
        private int chunkSize = 800;
        private int chunkOverlap = 80;
        private int batchSize = 32;
        /**
         * 启动自愈：应用就绪后用探针查询检测向量索引是否为空，
         * 为空则自动重建（幂等）。防止"向量库空、只剩关键词检索"的静默劣化。
         */
        private boolean autoHealOnEmpty = true;

        public int getChunkSize() {
            return chunkSize;
        }

        public void setChunkSize(int chunkSize) {
            this.chunkSize = chunkSize;
        }

        public int getChunkOverlap() {
            return chunkOverlap;
        }

        public void setChunkOverlap(int chunkOverlap) {
            this.chunkOverlap = chunkOverlap;
        }

        public int getBatchSize() {
            return batchSize;
        }

        public void setBatchSize(int batchSize) {
            this.batchSize = batchSize;
        }

        public boolean isAutoHealOnEmpty() {
            return autoHealOnEmpty;
        }

        public void setAutoHealOnEmpty(boolean autoHealOnEmpty) {
            this.autoHealOnEmpty = autoHealOnEmpty;
        }
    }

    public static class Memory {
        private boolean enabled = true;
        private int maxTurns = 10;

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public int getMaxTurns() {
            return maxTurns;
        }

        public void setMaxTurns(int maxTurns) {
            this.maxTurns = maxTurns;
        }
    }

    public static class Cache {
        private boolean enabled = true;
        private long ttlSeconds = 86400;

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public long getTtlSeconds() {
            return ttlSeconds;
        }

        public void setTtlSeconds(long ttlSeconds) {
            this.ttlSeconds = ttlSeconds;
        }
    }
}
