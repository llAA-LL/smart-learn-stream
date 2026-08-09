# rag-backend - 智能学习系统 v2（RAG AI 助教）

基于 **Spring AI + DeepSeek + ChromaDB + MySQL FULLTEXT** 的 Java RAG 问答服务，
是智能学习系统的 AI 对话模块升级版。回答全部基于数据库中的课程知识点，
可溯源、可评估，避免模型凭空编造。

## 技术栈

| 环节 | 技术 | 说明 |
|------|------|------|
| 框架 | Spring Boot 3.5 + Spring AI 1.1 | Java 21 |
| 对话模型 | DeepSeek（deepseek-chat） | OpenAI 兼容接口 |
| Embedding | bge-small-zh-v1.5（本地 Python 推理服务，默认） | 零注册零成本，复用 agent 虚拟环境 |
| Embedding（备选） | bge-m3（SiliconFlow API） | 切换 rag.embedding.provider=openai-api 并配 Key |
| 向量库 | ChromaDB（HTTP 服务） | 复用本机 Python 环境中的 chromadb |
| 稀疏检索 | MySQL 8 FULLTEXT（ngram） | 中文关键词检索 |
| 融合 | RRF（Reciprocal Rank Fusion） | 不依赖两种检索的分数可比性 |
| 精排 | DeepSeek LLM 打分（0-10） | 失败自动回退 RRF 顺序 |

## 架构

```
用户提问
  → 稠密路：Embedding → Chroma 向量相似度
  → 稀疏路：MySQL FULLTEXT 关键词
  → RRF 融合 → LLM 重排
  → Prompt 组装（只依据资料 + 引用编号）
  → DeepSeek 流式回答（SSE）
```

离线建索引：
```
knowledge_points 表 → 分块（知识点感知 + 重叠窗口）→ bge-m3 向量化 → Chroma
```

## 快速开始

**一键启动（本地开发，推荐）**：
```powershell
powershell -ExecutionPolicy Bypass -File scripts\start-all.ps1
```
该脚本会依次启动 ChromaDB（8000）、本地 Embedding 服务（5003）、RAG 后端（9091）。
前置条件：MySQL 已运行且 `smart_learning` 库存在；`.env` 中已配置 `DEEPSEEK_API_KEY`。

分步启动（调试用）：

1. 确保本机 MySQL 已启动，`smart_learning` 库存在（由智能学习系统创建）。
2. 启动 ChromaDB（使用已有的 Python 环境）：
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\start-chroma.ps1
   ```
3. 启动本地 Embedding 服务（默认方案，无需任何 API Key）：
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\start-embedding.ps1
   ```
   如果改用 SiliconFlow API，注册后把 Key 配到 `.env`，并将
   `application.yml` 中 `rag.embedding.provider` 改为 `openai-api`。
4. 配置 `DEEPSEEK_API_KEY`（对话 + 重排）：已在 `.env` 中复用 agent 的 Key。
5. 用 IDEA 打开项目并运行 `RagBackendApplication`（端口 9091），
   或执行 `powershell -ExecutionPolicy Bypass -File scripts\start-app.ps1`。
6. 建立索引：
   ```bash
   curl -X POST http://localhost:9091/api/rag/index/rebuild
   ```
7. 测试问答（非流式）：
   ```bash
   curl -X POST http://localhost:9091/api/rag/chat \
     -H "Content-Type: application/json" \
     -d '{"conversationId":"demo-1","history":[],"question":"什么是死锁？有哪些必要条件？"}'
   ```

调试检索（不调 LLM，排查检索质量）：
```bash
curl "http://localhost:9091/api/rag/retrieve?question=什么是死锁&topK=5"
```

## Docker 部署

**方式一：仅 RAG 服务**
```bash
cd rag-backend
cp .env.example .env   # 填入 DEEPSEEK_API_KEY、SILICONFLOW_API_KEY
docker compose up -d --build
```
容器内向量化使用 SiliconFlow API（`RAG_EMBEDDING_PROVIDER=openai-api`），
无需本地 Python 服务；MySQL 通过 `host.docker.internal` 连接本机。

**方式二：并入主系统**
根目录 `docker-compose.yml` 已包含 `rag-backend` 与 `chroma` 服务，
`docker compose up -d --build` 一键拉起全套（mysql/redis/backend/agent/chroma/rag-backend/frontend）。
前端 nginx 已配置 `/api/rag` 反代到 rag-backend。

## API 摘要

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/rag/chat` | 非流式问答，返回 answer + citations |
| POST | `/api/rag/chat/stream` | SSE 流式问答（citations → delta → done） |
| POST | `/api/rag/index/rebuild` | 重建向量索引（幂等，可重复执行） |
| GET | `/api/rag/retrieve` | 只检索不生成，调试用 |
| DELETE | `/api/rag/chat/{conversationId}` | 清空某会话的服务端记忆 |
| POST | `/api/rag/feedback` | 保存回答反馈（点赞/点踩） |

## 面试要点（提前准备）

- 为什么 RAG 而不是微调：知识高频更新、可溯源、成本低、无 GPU 训练门槛。
- 分块策略：知识点天然成块；长内容按段落聚合 + 重叠窗口，标题/描述始终保留。
- 为什么混合检索：向量召回同义改写强、关键词召回专有名词/精确术语强。
- RRF 为什么可行：只看排名不看分数，天然免疫两个检索路的分数体系差异。
- 重排的价值：候选 TopK 内排序不精准时，用 LLM 精排提升答案质量。
- 防幻觉：系统提示词限定"只依据资料 + 引用编号"；检索为空时直接返回兜底文案，不调用 LLM。

## 功能与测试

- ✅ RAG 全链路：分块 → 混合检索 → RRF → LLM 重排 → 流式问答（SSE）
- ✅ 引用来源展示、无资料兜底、点赞/点踩反馈（`POST /api/rag/feedback`）
- ✅ 前端接入：`AgentChat.vue` 已切换至本服务（SSE + 引用标签）
- ✅ 多轮会话记忆：服务端 Redis 持久化（`rag:chat:{conversationId}`，最多 10 轮），
  客户端断线/刷新不丢上下文；Redis 不可用时自动降级为客户端 history
- ✅ 热问题缓存：Redis Cache-Aside，重复问题 17ms 返回（首答 4-6s），零额外 LLM 调用
- ✅ 重排可切换：`rag.rerank.provider=llm`（默认，hit@1 87.5%）/ `local`（离线 bge-reranker，80%）
- ✅ 接口限流：Redis 固定窗口（按 IP），chat 15/min、stream 20/min、retrieve 120/min，超限返回 429
- ✅ 日志埋点：每个请求记录 retrieve/rerank/generate 三段耗时与缓存命中情况
- ✅ 集成测试：MVC 层 + SSE 流式（`@WebMvcTest`，5 个用例）
- ✅ CI：GitHub Actions（rag-backend 单测 + 前端构建），见 `.github/workflows/ci.yml`
- ✅ 评测框架：40 题 QA + 对照实验 + 报告（`eval/`）
- ✅ 单元 + 集成测试：分块、RRF、重排、记忆、缓存、限流接口（`mvn test`，23 个用例）
- ✅ Docker：独立 compose + 主系统集成

## 后续计划（未做）

- [ ] Embedding 结果缓存（检索侧，降低 Python 推理压力）
- [ ] 评测补充：bge-m3 与 bge-small-zh 对比、rerank-top-k 敏感性

## 日志示例

```text
chat cid=tier2-miss cache=MISS retrieve=114ms rerank=1037ms generate=2339ms total=3502ms citations=8
chat cid=tier2-test cache=HIT total=15ms
```

## CI

`.github/workflows/ci.yml` 已配置两个 job：

- rag-backend：`mvn test`（23 个用例，无需外部服务即可运行）
- frontend：`npm ci && npm run build`

仓库目前未初始化 git，推到 GitHub 前先 `git init`。

## 性能要点

- 本地检索链路 ~30ms；Chat 总延迟约 95% 来自 DeepSeek 生成，符合 RAG 典型画像。
- 热问题缓存命中后重复提问 17ms（见 `eval/perf-report.md`）。
- Embedding 多 worker 实测收益有限（CPU 推理瓶颈），需要并发吞吐请切 API Embedding。
- 完整压测数据与结论见 [eval/perf-report.md](eval/perf-report.md)，脚本 `scripts/perf-test.js`。

## 评测

`eval/` 目录下是完整的评测框架：

- `qa.jsonl`：40 道题，基于 `knowledge_points` 表真实知识点构造
- `knowledge-points.json`：知识点快照（接口拉取）
- `run-eval.ps1`：一键评测脚本
  - 完整跑：`powershell -ExecutionPolicy Bypass -File eval\run-eval.ps1`
  - 只重判（改裁判规则后）：`powershell -ExecutionPolicy Bypass -File eval\run-eval.ps1 -RejudgeOnly`
- `report.md`：生成的评测报告（检索命中率 + 回答质量 + 逐题明细）

注意：PowerShell 5.1 会把无 charset 的 HTTP 响应按 Latin-1 解码，脚本内已通过
`RawContentStream` + UTF-8 显式解码处理，修改脚本时不要改回 `$resp.Content`。

评测结论摘要：混合检索 Top-5 命中 97.5%，LLM 重排把 Top-1 从 65% 提到 87.5%，
RAG 回答引用率 100% 零编造；低分主要来自课程资料未覆盖的 11 道题（RAG 诚实说明，
属预期行为）。


## 排错记录（实测踩坑）

1. **Spring AI 1.1.x + 本地 Chroma 启动报 `invalid URI scheme localhost`**
   自动配置会把 host:port 拼成不带协议头的 baseUrl，JDK HTTP 客户端不认。
   同时 Spring AI 1.1.x 走 Chroma v2 API，本地 Chroma 1.5.9 的默认租户/库是
   `default_tenant` / `default_database`。本项目通过 `VectorStoreConfig`
   手动提供 ChromaApi Bean 解决，详见该文件注释。

2. **MySQL 服务停止导致连接被重置**
   如果启动时报 `Connection reset`，先确认 MySQL 是否在运行
   （`Get-NetTCPConnection -LocalPort 3306 -State Listen`）。
   服务方式启动需管理员权限；也可直接用 mysqld 启动：
   ```powershell
   & "D:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --defaults-file="D:\ProgramData\MySQL\MySQL Server 8.0\my.ini"
   ```

3. **Embedding/对话报 401 Token is invalid**
   说明 `DEEPSEEK_API_KEY` 或 `SILICONFLOW_API_KEY` 未配置或配置错误。
   SiliconFlow 注册后，在 [API 密钥页面](https://cloud.siliconflow.cn) 创建 Key，
   免费额度即可跑 bge-m3；或直接用默认的本地 Embedding 服务（无需 Key）。

4. **本地 Embedding 服务未启动**
   报 `Connection refused` 时，先执行 `scripts\start-embedding.ps1`，
   确认端口 5003 的 `/health` 返回 ok。

5. **从 .env 读不到 API Key（表现为对话报 401，Key 是 sk-placeholder）**
   PowerShell 5.1 的 `Get-Content` 默认按 GBK 读 UTF-8 文件，中文注释可能
   "吞掉"下一行的换行符。`.env` 必须用 UTF-8 显式读取，
   `scripts\start-app.ps1` 已处理，勿改回 `Get-Content`。

6. **Java 调本地 Python 服务返回 422（body missing）**
   使用 `RestClient.builder()` 默认的 JDK HttpClient 时，请求体会异常丢失。
   `LocalEmbeddingModel` 已改用 `SimpleClientHttpRequestFactory` 解决。

7. **重排提示词报 "The template string is not valid"**
   Spring AI 的 PromptTemplate 会把 `{...}` 当占位符，提示词里的 JSON 示例
   （如 {"scores": [...]}）必须写成纯文字描述，避免字面花括号。
