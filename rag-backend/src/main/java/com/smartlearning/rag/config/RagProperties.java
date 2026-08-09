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
    }

    public static class Index {
        private int chunkSize = 800;
        private int chunkOverlap = 80;
        private int batchSize = 32;

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
