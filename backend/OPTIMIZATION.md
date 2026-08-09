# 主后端优化记录（2026-08-09）

## 安全（已修复并实测）

1. **密码哈希升级**：SHA-256（无盐）→ BCrypt（`spring-security-crypto`）。
   - `data.sql` 种子用户密码改为 BCrypt("123456")，并用
     `ON DUPLICATE KEY UPDATE` 自动迁移历史 SHA-256 记录。
   - 实测：zhangsan/123456 登录成功。

2. **注册接口角色注入**：原来 `@RequestBody User` 可携带 `role=ADMIN`。
   改为独立 `RegisterRequest` DTO，服务端强制 `STUDENT`，并加参数校验
   （用户名 3-50、密码 6-64）。
   - 实测：伪造 `role=ADMIN` 注册，返回角色仍为 STUDENT。

3. **注册响应泄露密码哈希**：原 `register` 直接返回含 password 的 User。
   改为返回脱敏副本（password=null）。
   - 实测：响应中 password 为空。

4. **越权访问（IDOR）**：`GET /api/quiz/attempts/{id}` 原无归属校验。
   改为校验 `attempt.userId == 当前登录用户`，否则 403。
   - 实测：lisi 访问 zhangsan 的 attempt → HTTP 403。

5. **业务异常 HTTP 状态码恒为 200**：BusinessException 现在按业务码映射
   真实状态（401/403/404/429），前端 axios 的 401 拦截恢复正常语义。
   - 实测：错误密码登录返回 HTTP 401。

6. **内部错误信息泄露**：500 响应不再拼接 `e.getMessage()`，只返回通用文案。

7. **敏感配置环境变量化**：`jwt.secret`、`jwt.expiration`、数据库密码支持
   环境变量覆盖（本地保留默认值）。

## 正确性

8. **周统计 bug**：`totalMinutesByDate` 是精确匹配单日，
   原代码用 `today.minusDays(7)` 只统计了 7 天前那一天。
   新增 `totalMinutesSince`（`record_date >= ?`）修复最近 7 天统计。

## 性能

9. **推荐接口 N+1**：`computeRecommendations` 循环内逐条查询前置关系。
   改用已存在的 `findAllEdges()` 一次批量加载，构建 prereqMap。

## 可测试性

10. 抽取纯判分逻辑 `AnswerGrader`（无 Spring 依赖），新增单测：
    - `AnswerGraderTest`：单选/多选/判断/空值（4 个用例）
    - `UserServiceTest`：BCrypt 登录、错误密码、注册强制角色、重复用户名（5 个用例）

## 权限体系（2026-08-09 第二轮）

11. **新增 `@RequireRole` 注解 + `RoleCheckAspect`**：按 JwtInterceptor 写入的
    role 请求属性做切面校验，无权限抛 403（真实 HTTP 状态码）。
12. **管理端接口 ADMIN 化**：
    - `QuestionController`（list/get/create/update/delete）：全部仅 ADMIN，
      修复学生可经 `/api/questions` 直接看到题目答案的问题；
    - `CourseController` 的 create/update/delete：仅 ADMIN；
    - `KnowledgeGraphController` 的 create/update/delete：仅 ADMIN（读接口保持开放）。
13. **初始化管理员**：`data.sql` 新增内置账号 `admin / admin123`（BCrypt），
    每次启动幂等 upsert。前端侧边栏"题目管理"按角色对 STUDENT 隐藏。
14. 新增 `RoleCheckAspectTest`（3 个用例），后端测试总数 12 个。

## 验证方式

```bash
mvn -f backend/pom.xml test          # 9 个用例全过
mvn -f backend/pom.xml -DskipTests package
java -jar backend/target/smart-learning-system-1.0.0.jar
```
