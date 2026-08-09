# MySQL 面试题详解（全面覆盖 + 原理解析）

---

## 目录

1. [基础概念](#1-基础概念)
2. [存储引擎](#2-存储引擎)
3. [索引原理](#3-索引原理)
4. [SQL 优化](#4-sql-优化)
5. [事务与隔离级别](#5-事务与隔离级别)
6. [锁机制](#6-锁机制)
7. [日志系统](#7-日志系统)
8. [MVCC 原理](#8-mvcc-原理)
9. [架构与高可用](#9-架构与高可用)
10. [分库分表](#10-分库分表)
11. [实战场景题](#11-实战场景题)

---

## 1. 基础概念

### Q1: CHAR 和 VARCHAR 的区别？

| 维度 | CHAR | VARCHAR |
|------|------|---------|
| 存储方式 | 定长，不足补空格 | 变长，按实际长度 + 1-2 字节存长度 |
| 最大长度 | 255 字符 | 65535 字节（实际受行大小限制 ~16383） |
| 空间效率 | 固定长度浪费空间 | 节省空间 |
| 读取效率 | 更快（定长直接定位） | 略慢（需先读长度前缀） |
| 适用场景 | 固定长度字段（MD5、手机号、身份证） | 可变长度字段（姓名、地址、描述） |
| 尾部空格 | 查询时会去掉 | 保留 |

**原理**：InnoDB 中 CHAR 和 VARCHAR 在行格式为 COMPACT 及以上时，都变长存储。但 CHAR(N) 会分配 N 个字符的空间，不足用 0x20 填充。所以 CHAR 的好处是 UPDATE 时不会产生页分裂（长度不变）。

### Q2: TEXT 和 BLOB 的区别？什么情况下该用？

| 类型 | 用途 | 字符集 | 排序 |
|------|------|--------|------|
| TEXT | 存大文本 | 有字符集，受 collation 影响 | 可排序比较 |
| BLOB | 存二进制（图片、文件） | 无字符集 | 按二进制比较 |

**关键问题**：
- TEXT/BLOB 数据超过 768 字节时，InnoDB 会将数据存到外部溢出页，行内只保留 20 字节指针
- 查询 TEXT/BLOB 会导致临时表走磁盘（Memory 引擎不支持 TEXT），性能差
- **最佳实践**：TEXT/BLOB 拆到附属表，主表只存 ID 关联

```sql
-- ❌ 不推荐
CREATE TABLE articles (
    id INT PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,  -- 大字段在主表
    INDEX idx_title (title)
);

-- ✅ 推荐：拆分
CREATE TABLE articles (
    id INT PRIMARY KEY,
    title VARCHAR(200),
    INDEX idx_title (title)
);
CREATE TABLE article_contents (
    article_id INT PRIMARY KEY,
    content TEXT
);
```

### Q3: COUNT(\*)、COUNT(1)、COUNT(列名)、COUNT(DISTINCT) 的区别？

```
COUNT(*)    — 统计所有行（包括 NULL 行），MySQL 优化器会选最小的二级索引扫描
COUNT(1)    — 等价于 COUNT(*)，扫描每一行判断 1 是否为 NULL（永远不是）
COUNT(列名) — 统计该列非 NULL 的行数，走该列索引
COUNT(DISTINCT 列) — 统计不重复的非 NULL 值个数
```

**性能**：`COUNT(*)` ≈ `COUNT(1)` > `COUNT(列名)`（有索引时差不多）

**关键原理**：InnoDB 不存行数（MVCC 导致不同事务看到的行数不同），所以 COUNT 必须扫描。MyISAM 存了总行数，COUNT(\*) 是 O(1)。

**优化**：
- 需要精确计数 → 用 Redis 计数器或单独统计表
- 只需要估计 → `SHOW TABLE STATUS` 或 `EXPLAIN SELECT COUNT(*)` 取 rows 估算
- 大表分页计数 → 用子查询 `WHERE id > last_id` 替代 `LIMIT offset, count`

### Q4: UNION 和 UNION ALL 的区别？

- **UNION**：合并结果集 + 去重（需要额外排序或哈希去重），慢
- **UNION ALL**：直接合并，不去重，快

```sql
-- UNION: 实际执行 → 合并 → 排序去重 → 返回
SELECT name FROM t1 UNION SELECT name FROM t2;

-- UNION ALL: 直接追加结果
SELECT name FROM t1 UNION ALL SELECT name FROM t2;
```

**原理**：UNION 的去重相当于在每个字段上做 DISTINCT，当结果集大时需要临时表+filesort。能用 UNION ALL 绝不用 UNION。

### Q5: TRUNCATE、DELETE、DROP 的区别？

| | DELETE | TRUNCATE | DROP |
|---|--------|----------|------|
| 类型 | DML | DDL | DDL |
| 回滚 | 可回滚 | 不可回滚（隐式提交） | 不可回滚 |
| 触发 trigger | 触发 | 不触发 | — |
| 释放空间 | 不释放（标记删除） | 释放（重建表） | 释放 |
| 自增 ID | 不重置 | 重置 | — |
| 速度 | 慢（逐行删 + undo log） | 快（删表重建） | 最快 |
| WHERE | 支持 | 不支持 | 不支持 |

**原理**：TRUNCATE 在 InnoDB 中通过 DROP + CREATE 表实现（或逐页释放），不在 undo log 记录每行，所以不可回滚。DELETE 逐行写入 undo log → redo log → binlog，所以慢但可恢复。

---

## 2. 存储引擎

### Q6: InnoDB 和 MyISAM 的核心区别？

| 维度 | InnoDB | MyISAM |
|------|--------|--------|
| 事务 | 支持 ACID | 不支持 |
| 锁级别 | 行锁 + 间隙锁 | 表锁 |
| 外键 | 支持 | 不支持 |
| MVCC | 支持 | 不支持 |
| 崩溃恢复 | 支持（redo log） | 不支持（需 repair） |
| 索引结构 | 聚簇索引（数据即索引） | 非聚簇索引（索引和数据分离） |
| COUNT(\*) | 需扫描 | O(1) 读取 |
| 全文索引 | 5.6+ 支持 | 原生支持 |
| 压缩 | 支持页压缩 | 支持表压缩 |
| 适用场景 | OLTP（高并发读写） | OLAP（读多写少、报表） |

**核心原理**：InnoDB 以聚簇索引组织数据，主键 B+树叶子节点存整行数据。MyISAM 的 `.MYD` 存数据、`.MYI` 存索引，索引叶子节点存数据文件的物理地址指针。这意味着 InnoDB 主键查询只需一次 B+树搜索，MyISAM 要两次（先查索引再查数据文件）。

### Q7: InnoDB 的内存结构是怎样的？

```
┌─────────────────── InnoDB Buffer Pool ──────────────────┐
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ 数据页   │  │ 索引页   │  │ undo 页  │              │
│  │ (缓存)   │  │ (缓存)   │  │ (缓存)   │              │
│  └──────────┘  └──────────┘  └──────────┘              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ 插入缓冲 │  │ 自适应    │  │ 锁信息   │              │
│  │ (Change  │  │ 哈希索引  │  │          │              │
│  │  Buffer) │  │ (AHI)     │  │          │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└────────────────────────────────────────────────────────┘
         ↑↓ 由后台线程管理刷盘
┌─────────────────────────────────────────────┐
│  磁盘: .ibd (表空间) + ib_logfile (redo log) │
└─────────────────────────────────────────────┘
```

- **Buffer Pool**：默认 128M，生产建议设为物理内存 50-70%。缓存数据页和索引页
- **Change Buffer**：对非唯一二级索引的 INSERT/UPDATE 暂存于此，后续 merge 到数据页。避免随机 I/O
- **Adaptive Hash Index (AHI)**：InnoDB 自动对热点的 B+树路径建哈希索引，加速等值查询
- **Log Buffer**：redo log 先写内存 buffer，再刷到磁盘 `ib_logfile`

### Q8: InnoDB 的行格式有哪些？COMPACT 和 DYNAMIC 的区别？

| 行格式 | 特点 | 适用 |
|--------|------|------|
| REDUNDANT | 最老格式，浪费空间 | 不推荐 |
| COMPACT | 紧凑存储，变长字段 NULL 标志位 | 5.0-5.6 默认 |
| DYNAMIC | 5.7+ 默认，大字段完全溢出 | 通用推荐 |
| COMPRESSED | 在 DYNAMIC 基础上支持页压缩 | 磁盘空间紧张时 |

**COMPACT vs DYNAMIC 核心区别**：

- **COMPACT**：溢出列的页外存储保留前缀 768 字节在行内
- **DYNAMIC**：溢出列完全存到页外，行内只留 20 字节指针。这样单个索引页能存更多行，B+树更矮

```
COMPACT 格式行:
┌──────┬──────┬──────────────────┬─────┬─────────┐
│ 变长  │ NULL │ 列1 │ 列2 │ ... │ 溢出列 │ 溢出列   │
│ 字段  │ 标志  │     │     │     │ 768字节 │ 完整存储在│
│ 长度  │ 位   │     │     │     │ 前缀    │ BLOB页   │
└──────┴──────┴──────────────────┴─────┴─────────┘

DYNAMIC 格式行:
┌──────┬──────┬──────────────────┬──────┐
│ 变长  │ NULL │ 列1 │ 列2 │ ... │ 溢出列│ 溢出列
│ 字段  │ 标志  │     │     │     │ (20B) │ → BLOB页
│ 长度  │ 位   │     │     │     │ 指针  │
└──────┴──────┴──────────────────┴──────┘
```

---

## 3. 索引原理

### Q9: B+树为什么适合做数据库索引？

**B+树结构特点**：

```
                    [30 | 60]              ← 非叶子节点只存 key + 子节点指针
                   /    |    \
           [10|20]    [40|50]    [70|80]   ← 不存数据，一页能放更多 key
           /  |  \    /  |  \    /  |  \
         ①中②中③  ④中⑤  ⑥中⑦  ⑧中⑨    ← 叶子节点存完整数据，双向链表连接
         ←──────── 双向链表 ────────→        ← 支持范围查询
```

**为什么是 B+树而不是二叉树/红黑树/B 树？**

| 数据结构 | 关键缺陷 |
|----------|---------|
| 二叉搜索树 | 可能退化成链表，O(N) |
| 红黑树 | 二叉树，树太高 → 磁盘 I/O 次数多。1000 万行 ≈ 24 层 → 24 次 I/O |
| B 树 | 非叶子节点也存数据 → 一页存的 key 更少 → 树更高 |
| 哈希表 | 不支持范围查询、排序、最左前缀 |

**B+树优势**：
1. **矮胖**：每个节点就是一页(16KB)，能存 1000+ 个 key，1000 万行只需 2-3 层
2. **范围查询友好**：叶子节点有双向链表，`BETWEEN a AND b` 找到 a 后顺着链表读即可
3. **磁盘 I/O 最小化**：一次磁盘读取是一整页（16KB），B+树一页全是 key（非叶子不存数据），每个节点利用率极高

### Q10: 聚簇索引和非聚簇索引（二级索引）的区别？

```
聚簇索引（主键索引）:
    B+树叶子节点 = 整行数据

    [key: id=10]  →  {id:10, name:"张三", age:25, city:"北京"}
    [key: id=20]  →  {id:20, name:"李四", age:30, city:"上海"}
    ...

非聚簇索引（二级索引）:
    B+树叶子节点 = 主键值（不是数据！）

    [key: name="张三"] → id=10
    [key: name="李四"] → id=20
    ...

回表:
    SELECT * FROM users WHERE name = '张三';
    ① 先查 name 索引 → 得到 id=10
    ② 再用 id=10 查聚簇索引 → 得到整行数据
    → 这叫"回表"，需要两次 B+树搜索
```

**为什么二级索引不直接存数据？**
- 数据只存一份（聚簇索引），二级索引存主键引用 → 节约空间
- 数据更新时只需更新聚簇索引，二级索引不需要更新（除非主键变了）
- 代价就是非覆盖索引查询需要回表

### Q11: 什么是覆盖索引？什么情况下会用到？

覆盖索引：查询的所有列都在索引中，不需要回表。

```sql
-- 表: users (id PK, name, age, city)
-- 索引: idx_name_age (name, age)

-- ✅ 覆盖索引（只查 name, age, id）
SELECT name, age FROM users WHERE name = '张三';
SELECT id, name, age FROM users WHERE name = '张三';  -- id 在二级索引叶子节点

-- ❌ 需要回表（查了 city）
SELECT name, age, city FROM users WHERE name = '张三';
```

**EXPLAIN 证据**：`Extra` 列显示 `Using index` 表示走了覆盖索引。

**核心优化思路**：
- 避免 `SELECT *`，只查需要的列
- 高频查询的列建联合索引覆盖
- 但不要为了覆盖索引建太多列（索引变大，维护成本高）

### Q12: 最左前缀原则是什么？为什么会有这个原则？

```sql
-- 联合索引: (a, b, c)

-- ✅ 用到索引
WHERE a = 1                     -- 匹配最左列 a
WHERE a = 1 AND b = 2          -- 匹配 a + b
WHERE a = 1 AND b = 2 AND c = 3 -- 匹配全部
WHERE a = 1 AND c = 3          -- 匹配 a（c 不行，跳过了 b）

-- ❌ 用不到索引
WHERE b = 2                    -- 没有 a
WHERE c = 3                    -- 没有 a
WHERE b = 2 AND c = 3          -- 没有 a
```

**原理**：联合索引的 B+树按 `(a, b, c)` 的顺序排序：

```
索引排序结果:
(1, 1, 1)  ← 先按 a 排
(1, 1, 2)  ← a 相同则按 b 排
(1, 2, 1)  ← b 相同则按 c 排
(2, 1, 1)
(2, 1, 2)
...
```

当你 `WHERE b = 2`，B+树的第一排序键是 a，a 是乱的，没法利用 B+树的有序性进行二分查找。

**"范围查询右边全失效"**：

```sql
WHERE a = 1 AND b > 2 AND c = 3
-- 用到: (a, b)，c 失效
-- 因为 b 是范围查询，b 值不唯一，c 在 b 的每个范围内部都是乱的
```

### Q13: 索引下推（ICP）是什么？

5.6+ 特性。MySQL 将 WHERE 条件中能由索引处理的条件下推到存储引擎层过滤，减少回表次数。

```sql
-- 联合索引: (name, age)
SELECT * FROM users WHERE name LIKE '张%' AND age = 25;

-- 无 ICP (5.6之前):
-- ① 从索引找到 name LIKE '张%' 的所有行
-- ② 每条都回表取完整数据
-- ③ 在 Server 层过滤 age = 25
-- 问题: 如果 1000 个 name LIKE '张%'，只有 10 个 age=25，990 次回表是浪费

-- 有 ICP:
-- ① 从索引找到 name LIKE '张%' 
-- ② 在存储引擎层直接检查 age = 25（age 在索引里！）
-- ③ 只对真正符合条件的 10 行回表
-- 节省: 990 次回表
```

**EXPLAIN**：`Extra` 列显示 `Using index condition`。

### Q14: 什么是索引失效？常见的索引失效场景有哪些？

```sql
-- 1. LIKE 前缀通配符
WHERE name LIKE '%三'   -- ❌ 失效（% 在前，无法二分定位）
WHERE name LIKE '张%'   -- ✅ 走索引

-- 2. 对索引列做函数/运算
WHERE YEAR(create_time) = 2024     -- ❌ 失效
WHERE create_time >= '2024-01-01' AND create_time < '2025-01-01'  -- ✅ 走索引
WHERE id + 1 = 10                  -- ❌ 失效（等价于 id = 9 但 MySQL 不优化）

-- 3. 隐式类型转换
-- phone 是 VARCHAR 类型
WHERE phone = 13800138000   -- ❌ 失效！字符串 = 数字，MySQL 把列转成数字
WHERE phone = '13800138000' -- ✅ 走索引

-- 4. OR 连接非索引列
-- idx_name 存在，但 age 无索引
WHERE name = '张三' OR age = 25  -- ❌ 可能全表扫描
-- 改为:
SELECT * FROM users WHERE name = '张三'
UNION ALL
SELECT * FROM users WHERE age = 25 AND name != '张三'

-- 5. 联合索引不满足最左前缀
-- 索引: (a, b, c)
WHERE b = 2  -- ❌ 跳过 a

-- 6. != / <> / NOT IN (选择性差时)
WHERE status != 'deleted'  -- 如果只有 1% 是 deleted，全表扫描可能更快

-- 7. IS NULL / IS NOT NULL (取决于 NULL 值比例)
-- 如果 NULL 值占比很大，可能不走索引

-- 8. 优化器认为全表扫描更快
-- 当查询返回的行数超过总行数的 10-30%，优化器会倾向于全表扫描
```

**判断索引是否生效**：`EXPLAIN` 的 `key` 列显示实际使用的索引，`type` 列应避免 `ALL`（全表扫描）。

### Q15: 为什么要尽量用自增主键？用 UUID 有什么问题？

```
自增主键插入:
[1][2][3][4][5]...[99] ← 新记录 id=100 追加到末尾
                      [100] → 只操作最后一页，无页分裂

UUID 主键插入:
[5][7][8][9]...[58][61] ← 新记录 id=43 插入到中间
                [43] → 页满时触发页分裂，页利用率低

页分裂过程:
┌──────────────┐          ┌───────┐  ┌───────┐
│ 1 3 5 7 9    │ 插入4 →  │ 1 3 4 │  │ 5 7 9 │
│ (页满)       │          │ (50%) │  │ (50%) │  页利用率仅 50%
└──────────────┘          └───────┘  └───────┘
```

**UUID 的额外问题**：
- 36 字节（CHAR）或 16 字节（BINARY），比 BIGINT(8 字节) 大
- 二级索引叶子节点存主键值 → UUID 主键导致二级索引更大
- 随机 I/O：数据分散在不同的页中，缓存命中率低
- **页分裂 + 页利用率低（~60-70% vs ~95%+）**

**如果必须用 UUID**：使用 `UUID_TO_BIN(UUID(), 1)` 将 UUID 转成时序相关的 BINARY(16)，减少随机性。

---

## 4. SQL 优化

### Q16: EXPLAIN 各字段的含义是什么？

```sql
EXPLAIN SELECT * FROM users WHERE name = '张三';
```

| 字段 | 含义 | 关注点 |
|------|------|--------|
| **id** | 查询序号 | 相同 id 从上往下执行，不同 id 越大越先执行 |
| **select_type** | 查询类型 | SIMPLE(简单)、PRIMARY(外层)、SUBQUERY(子查询)、DERIVED(派生表) |
| **type** | **访问类型（关键！）** | system > const > eq_ref > ref > range > index > ALL |
| **possible_keys** | 可能用到的索引 | 候选索引列表 |
| **key** | **实际使用的索引** | NULL = 没走索引 |
| **key_len** | 使用的索引长度 | 越大用的列越多。可判断联合索引用了几列 |
| **ref** | 索引比较的列或常量 | const / 列名 |
| **rows** | **预估扫描行数** | 越小越好，与实际可能偏差较大 |
| **filtered** | 按表条件过滤后剩余百分比 | rows × filtered = 实际返回行数估算 |
| **Extra** | **额外信息（关键！）** | 见下方 |

**Extra 关键值**：

| 值 | 含义 | 评价 |
|----|------|------|
| Using index | 覆盖索引，不回表 | ✅ 最好 |
| Using index condition | 索引下推 (ICP) | ✅ 好 |
| Using where | Server 层过滤 | ⚠️ 一般 |
| Using temporary | 用了临时表 | ❌ 差，需优化 |
| Using filesort | 额外排序（非索引序） | ❌ 差，需优化 |
| Using join buffer | join 用了连接缓冲 | ⚠️ 被驱动表没索引 |

### Q17: type 字段的访问类型从好到差排序？

```
system   — 表只有一行（系统表），const 的特例
const    — 主键或唯一索引等值查询，最多返回一行
eq_ref   — JOIN 时被驱动表用主键/唯一索引关联，一行对应一行
ref      — 普通索引等值查询，可能返回多行
range    — 索引范围扫描（BETWEEN、>、<、IN）
index    — 全索引扫描（扫整个索引，不扫数据，比 ALL 好）
ALL      — 全表扫描（最差）
```

**实际判断标准**：
- `range` 及以上 → 合格
- `index` → 勉强接受（比如覆盖索引扫全表但不需要回表）
- `ALL` → 必须优化

### Q18: 如何优化 LIMIT 深分页？

```sql
-- 问题查询: 第 100001 页，每页 10 条
SELECT * FROM orders ORDER BY id LIMIT 1000000, 10;
-- MySQL 需要扫描 1000010 行，丢弃前 1000000 行，只返回 10 行
-- 大量随机 I/O，越往后越慢
```

**方案 1：延迟关联（推荐）**

```sql
-- ✅ 子查询先用覆盖索引定位，只取 id 回表
SELECT * FROM orders o
INNER JOIN (
    SELECT id FROM orders
    ORDER BY id LIMIT 1000000, 10
) t ON o.id = t.id;
```

**方案 2：游标分页（最佳，但需要前端配合）**

```sql
-- 第 1 页
SELECT * FROM orders WHERE id > 0 ORDER BY id LIMIT 10;
-- 拿到最后一行的 id = 10

-- 第 2 页
SELECT * FROM orders WHERE id > 10 ORDER BY id LIMIT 10;
-- 始终走主键索引 range 扫描，性能稳定
```

**方案 3：如果允许不准，用覆盖索引 + 子查询估算**

```sql
-- 先快速跳过
SELECT * FROM orders WHERE id >= (
    SELECT id FROM orders ORDER BY id LIMIT 1000000, 1
) ORDER BY id LIMIT 10;
```

### Q19: JOIN 的三种算法及区别？

**Nested-Loop Join (NLJ)**：

```
for each row in t1 (驱动表):
    for each row in t2 (被驱动表):
        if match(t1.key, t2.key):
            output row
```

- 被驱动表的关联列**必须有索引**（用索引快速查找，否则退化为 SNLJ）
- 驱动表越小越好（外层循环次数少）

**Block Nested-Loop Join (BNLJ)**：

```
8.0.20 之前，被驱动表无索引时使用。
将驱动表数据批量读入 Join Buffer，减少被驱动表扫描次数。
```

**Hash Join (8.0.18+ 推荐)**：

```
① 用驱动表数据构建哈希表
② 扫描被驱动表，每行到哈希表中查找匹配
③ 复杂度 O(t1 + t2)，比 NLJ 的 O(t1 * log t2) 在无索引场景更好
```

**优化原则**：

```sql
-- ✅ 小表驱动大表
SELECT * FROM small_table s
JOIN big_table b ON s.id = b.small_id;

-- ✅ 被驱动表的 JOIN 列建索引
CREATE INDEX idx_small_id ON big_table(small_id);

-- ✅ 避免 SELECT *，只取需要的列
SELECT s.name, b.order_no FROM ...

-- ❌ JOIN 条件用函数
ON YEAR(a.date) = b.year  -- 索引失效

-- ❌ 多表 JOIN（超过 3 表）
-- 拆成多次简单查询，应用层组装
```

### Q20: 如何发现和优化慢查询？

```sql
-- 1. 开启慢查询日志
SET GLOBAL slow_query_log = ON;
SET GLOBAL long_query_time = 1;           -- 超过 1 秒记录
SET GLOBAL log_queries_not_using_indexes = ON;

-- 2. 查看慢查询统计
SHOW VARIABLES LIKE 'slow_query%';
SHOW STATUS LIKE 'Slow_queries';

-- 3. 用 mysqldumpslow 分析
-- mysqldumpslow -s t -t 10 slow.log   # 按时间排序 top 10

-- 4. 用 pt-query-digest（Percona Toolkit）更详细分析
-- pt-query-digest slow.log > analysis.txt
```

**拿到具体 SQL 后的优化步骤**：

```
① EXPLAIN 分析 → 看 type、key、rows、Extra
② 确认索引是否合理 → 是否用到、是否覆盖、是否失效
③ SHOW CREATE TABLE → 检查表结构和现有索引
④ SHOW PROFILES / PERFORMANCE_SCHEMA → 查看各阶段耗时
⑤ OPTIMIZE TABLE → 重建表，回收碎片
⑥ 考虑改写 SQL → 分步查询、减少返回列、用 UNION ALL 替代 OR
```

---

## 5. 事务与隔离级别

### Q21: 事务的 ACID 特性，MySQL 分别是怎么实现的？

| 特性 | 含义 | MySQL 实现 |
|------|------|------------|
| **A**tomicity 原子性 | 要么全做，要么全不做 | **undo log** 记录旧版本数据，回滚时用它恢复 |
| **C**onsistency 一致性 | 事务前后数据满足所有约束 | undo log + redo log + 锁 共同保证 |
| **I**solation 隔离性 | 并发事务互不干扰 | **MVCC**（多版本并发控制）+ **锁** |
| **D**urability 持久性 | 事务提交后数据不丢 | **redo log**（WAL 机制），崩溃后用它恢复 |

**一条 UPDATE 语句的全流程**：

```
① 执行器调用存储引擎：UPDATE users SET age=26 WHERE id=10
② InnoDB: 在 Buffer Pool 中找到 id=10 的数据页
③ 如果不在 Buffer Pool：从磁盘加载到 Buffer Pool
④ 写 undo log：记录 age 旧值 25 → 用于回滚
⑤ 修改 Buffer Pool 中的数据：age=26（此时为脏页）
⑥ 写 redo log buffer：记录"在哪个页的什么位置把 age 改为 26"
⑦ 写 binlog（Server 层）：记录 SQL 语句
⑧ 提交事务：redo log 刷盘（prepare → binlog 刷盘 → redo log commit）
⑨ 后台线程异步将 Buffer Pool 脏页刷回磁盘
```

### Q22: 四种事务隔离级别及各自解决的问题？

| 隔离级别 | 脏读 | 不可重复读 | 幻读 | 实现方式 |
|----------|------|-----------|------|----------|
| READ UNCOMMITTED | ❌ 有 | ❌ 有 | ❌ 有 | 直接读最新值 |
| READ COMMITTED | ✅ 无 | ❌ 有 | ❌ 有 | 每次查询创建新 ReadView |
| REPEATABLE READ（默认） | ✅ 无 | ✅ 无 | ✅ 部分无 | 事务启动时创建 ReadView |
| SERIALIZABLE | ✅ 无 | ✅ 无 | ✅ 无 | 所有 SELECT 加共享锁 |

**三个问题解释**：

```
-- 表: account (id, balance)
-- 初始: balance = 1000

脏读 (Dirty Read):
  T1: UPDATE SET balance = 800 WHERE id = 1   -- 未提交
  T2: SELECT balance → 读到 800              -- 脏读！
  T1: ROLLBACK → balance 回到 1000
  T2 基于 800 做了错误决策

不可重复读 (Non-Repeatable Read):
  T1: SELECT balance → 1000
  T2: UPDATE SET balance = 800; COMMIT;
  T1: SELECT balance → 800                  -- 同一事务两次读到不同值！

幻读 (Phantom Read):
  T1: SELECT * WHERE age > 20 → 5 行
  T2: INSERT INTO users (age=25); COMMIT;
  T1: SELECT * WHERE age > 20 → 6 行        -- 多了一行"幻影"！
```

### Q23: InnoDB 在 RR 级别下如何部分解决幻读？

**快照读（Snapshot Read）天生防幻读**：

```sql
-- 普通 SELECT 是快照读，基于 MVCC ReadView
-- 事务开始时创建 ReadView，之后一直看到同一版本数据
SELECT * FROM users WHERE age > 20;
-- T2 插入 age=25 对 T1 不可见，因为该行的 trx_id > T1 的 ReadView 上限
```

**当前读（Current Read）靠 Next-Key Lock 防幻读**：

```sql
-- 以下语句是当前读，读最新数据
SELECT ... FOR UPDATE;
SELECT ... LOCK IN SHARE MODE;
UPDATE ... WHERE ...;
DELETE ... WHERE ...;

-- 对于范围条件，InnoDB 加 Next-Key Lock
-- 例如 WHERE id BETWEEN 10 AND 20：
--   记录锁: id=10, 15, 20 的已有行
--   间隙锁: (10,15), (15,20)   ← 阻止插入
--   临键锁: (5,10], (10,15], (15,20], (20,25]  ← 记录+间隙
```

**RR 下幻读仍可能发生的场景**：

```sql
-- T1:
BEGIN;
SELECT * FROM users WHERE id = 100;  -- 快照读，不存在
-- T2: INSERT INTO users VALUES (100, 'test'); COMMIT;
-- T1:
UPDATE users SET name = 'changed' WHERE id = 100;  -- 当前读，能更新 T2 插入的行！
-- 诡异现象: 快照读说没有，UPDATE 却更新了一行
SELECT * FROM users WHERE id = 100;  -- 现在能看到了（因为 UPDATE 更新了行的 trx_id）
```

---

## 6. 锁机制

### Q24: MySQL 有哪些锁？它们的粒度是什么？

```
MySQL 锁体系:
├── 全局锁: FLUSH TABLES WITH READ LOCK (全库只读，用于全库备份)
│
├── 表级锁
│   ├── 表锁: LOCK TABLES ... READ/WRITE
│   ├── 元数据锁 (MDL): DDL/DML 时自动加，防止 DDL 与 DML 冲突
│   ├── 意向锁 (IS/IX): InnoDB 内部，表示表中有行级锁
│   └── AUTO-INC 锁: 自增主键插入时
│
└── 行级锁 (InnoDB)
    ├── 记录锁 (Record Lock): 锁住索引记录
    ├── 间隙锁 (Gap Lock): 锁住索引记录间的间隙（RR 级别）
    ├── 临键锁 (Next-Key Lock): 记录锁 + 间隙锁（RR 级别默认）
    └── 插入意向锁 (Insert Intention Lock): INSERT 等待间隙锁释放时设置
```

### Q25: 死锁是怎么产生的？如何预防？

**经典死锁场景**：

```sql
-- T1:                          T2:
BEGIN;                         BEGIN;
UPDATE t SET col=1 WHERE id=1; -- 持有 id=1 的 X 锁
--                               UPDATE t SET col=1 WHERE id=2; -- 持有 id=2 的 X 锁
UPDATE t SET col=1 WHERE id=2; -- 等待 T2 释放 id=2 的锁
--                               UPDATE t SET col=1 WHERE id=1; -- 等待 T1 释放 id=1 的锁
-- 💀 互相等待 → 死锁
```

**InnoDB 处理**：
- 自动检测死锁（`innodb_deadlock_detect = ON`），回滚持有最少行锁的事务
- 错误码：`1213: Deadlock found when trying to get lock; try restarting transaction`

**预防策略**：

```
① 固定加锁顺序：所有事务按相同顺序（如 id 升序）访问资源
② 缩小事务：把非关键的 SELECT 和预处理放到事务外
③ 合理使用索引：无索引时 InnoDB 会锁全表所有行（导致锁范围膨胀）
④ 降低隔离级别：RC 级别没有间隙锁，减少锁冲突
⑤ 拆分大事务：一个大事务拆成多个小事务
⑥ 重试机制：捕获 1213 错误，随机等待后重试
```

### Q26: 乐观锁和悲观锁的区别？各适用于什么场景？

| | 悲观锁 | 乐观锁 |
|---|--------|--------|
| 思路 | 假定有人会冲突，先加锁 | 假定很少冲突，提交时检查 |
| 实现 | `SELECT ... FOR UPDATE` | version 字段 / CAS |
| 并发性能 | 低（阻塞等待） | 高（无锁，失败重试） |
| 适用场景 | 冲突概率高、短事务 | 冲突概率低、读多写少 |
| 死锁风险 | 有 | 无 |
| 数据一致性 | 强 | 最终一致（需重试保证） |

```sql
-- 悲观锁实现
BEGIN;
SELECT stock FROM products WHERE id = 1 FOR UPDATE;  -- 加排他锁
-- 检查 stock >= order_count
UPDATE products SET stock = stock - order_count WHERE id = 1;
COMMIT;

-- 乐观锁实现
-- 表加 version 字段
UPDATE products 
SET stock = stock - order_count, version = version + 1
WHERE id = 1 AND version = @old_version;
-- affected_rows = 0 → 版本冲突，重试
```

---

## 7. 日志系统

### Q27: redo log 和 binlog 的区别？

| 维度 | redo log | binlog |
|------|----------|--------|
| 所属层 | InnoDB 存储引擎 | MySQL Server 层 |
| 记录内容 | 物理日志："对页 X 偏移 Y 处写入 Z" | 逻辑日志："执行 INSERT INTO ..." |
| 记录方式 | 循环写（固定大小，覆盖旧日志） | 追加写（文件满了切新文件） |
| 用途 | **崩溃恢复**（crash-safe） | 主从复制、数据恢复 |
| 刷盘参数 | `innodb_flush_log_at_trx_commit` | `sync_binlog` |

**为什么需要两个日志？**

崩溃恢复的关键是 redo log（WAL 机制），能保证已提交事务不丢失。binlog 是 MySQL Server 层的日志，主从复制的基础。两者配合使用，这就是**两阶段提交**的原因。

### Q28: 什么是两阶段提交？为什么需要？

```
问题场景:
  先写 redo log，再写 binlog:
    T1 提交 → redo log 写入 → 宕机 → binlog 没写
    恢复后: 主库有 T1（redo 恢复了），从库没有 T1（binlog 没同步）
    → 主从数据不一致！

两阶段提交 (2PC):
  ┌─ Phase 1: prepare ───────────────────┐
  │ redo log 写 prepare 标记              │
  │ 此时事务尚未最终决定提交还是回滚        │
  └───────────────────────────────────────┘
                ↓
  ┌─ Phase 2: commit ────────────────────┐
  │ ① 写 binlog                          │
  │ ② redo log 写 commit 标记             │
  └───────────────────────────────────────┘

崩溃恢复时:
  - redo log 有 commit → 事务已提交，无需处理
  - redo log 有 prepare + binlog 完整 → 提交事务
  - redo log 有 prepare + binlog 不完整 → 回滚事务
  - redo log 只有 prepare + 没有 binlog → 回滚事务
```

### Q29: undo log 的作用是什么？

**两大作用**：

```
① 事务回滚:
   UPDATE SET age=26 WHERE id=10
   undo log 记录: "id=10 的 age 原值是 25"
   ROLLBACK → 用 undo log 恢复 age=25

② MVCC (ReadView):
   T1 (trx_id=100) 查询 id=10 时，发现该行 trx_id=105（未来事务修改的）
   → 顺着行记录的 roll_pointer 找到 trx_id=100 可见的版本
   → 读到 age=25（即事务 105 之前的值）
```

**undo log 的存储**：存在共享表空间或独立的 undo 表空间中。undo log 也是以页为单位，页的修改同样写 redo log。所以说"undo log 也需要 redo log 来保证持久性"。

---

## 8. MVCC 原理

### Q30: MVCC 的实现原理是什么？

MVCC = 多版本并发控制，让读不阻塞写、写不阻塞读。

**核心三要素**：

```
① 隐藏列:
   每行记录有 3 个隐藏列:
   - DB_TRX_ID (6B): 最近修改该行的事务 ID
   - DB_ROLL_PTR (7B): 指向 undo log 中的旧版本
   - DB_ROW_ID (6B): 如果没有主键，InnoDB 用它建聚簇索引

② undo log 版本链:
   行数据 → [trx_id=105, roll_ptr] → [trx_id=103, roll_ptr] → [trx_id=100, roll_ptr] → NULL
                ↑ 最新版本              ↑ 上一个版本            ↑ 原始版本

③ ReadView (一致性视图):
   - m_ids: 创建 ReadView 时活跃的事务 ID 列表
   - min_trx_id: 活跃事务中的最小 ID
   - max_trx_id: 系统下一个要分配的事务 ID
   - creator_trx_id: 创建这个 ReadView 的事务 ID
```

**可见性判断规则**：

```
给定行版本的 trx_id:
  if trx_id == creator_trx_id:
      ✅ 可见（自己修改的）
  elif trx_id < min_trx_id:
      ✅ 可见（修改它的事务在 ReadView 创建前已提交）
  elif trx_id >= max_trx_id:
      ❌ 不可见（修改它的事务在 ReadView 创建后才开始）
  elif trx_id in m_ids:
      ❌ 不可见（修改它的事务在 ReadView 创建时还活跃）
  else:
      ✅ 可见（不在活跃列表中 = 已提交）
```

**RC vs RR 的区别只在 ReadView 创建时机**：

```
READ COMMITTED:
  每次 SELECT 创建新的 ReadView
  → 其他事务提交后马上能看到

REPEATABLE READ:
  事务第一次 SELECT 时创建 ReadView，之后复用
  → 整个事务期间看到的数据一致
```

### Q31: 一个具体的 MVCC 例子？

```
初始: users 表 id=1, name='A', trx_id=90

T1 (trx_id=100):                    T2 (trx_id=101):
BEGIN;                              BEGIN;
-- 第一次 SELECT，创建 ReadView
-- m_ids=[100,101], min=100, max=102
SELECT name → 'A' (trx_id=90 < 100, 可见)
                                    
                                    UPDATE users SET name='B' WHERE id=1;
                                    -- 创建新版本: trx_id=101
                                    -- undo log 记录: name='A' (trx_id=90)
                                    COMMIT;

SELECT name → 'A' (trx_id=101 在 m_ids 中，不可见)
-- 顺 undo log 找 trx_id=90 的版本 → 'A'
-- 这就是 RR！T2 的修改对 T1 不可见

COMMIT;
SELECT name → 'B' (T2 已提交，T1 也提交了，新 ReadView)
```

---

## 9. 架构与高可用

### Q32: 主从复制的原理是什么？

```
主库 (Master)                    从库 (Slave)
┌───────────┐                   ┌───────────┐
│ 数据变更   │                   │           │
│    ↓      │                   │ 应用 relay │
│ binlog    │ ── I/O 线程 ──→  │   log     │ ← I/O 线程
│ dump      │   推送 binlog     │ relay log │   拉取 binlog
│ 线程      │                   │    ↓      │
│           │                   │ SQL 线程   │
│           │                   │ 重放 relay│
│           │                   │   log     │
└───────────┘                   └───────────┘
```

**三种复制格式**：

| 格式 | 记录方式 | 优点 | 缺点 |
|------|---------|------|------|
| STATEMENT | SQL 语句 | 日志小 | 不确定函数可能不一致（UUID、NOW） |
| ROW（推荐） | 每行变化的具体数据 | 精确，不会不一致 | 日志大（DELETE 100 万行 → 100 万条记录） |
| MIXED | 默认 STATEMENT，特殊情况 ROW | 折中 | 仍可能有边界问题 |

**主从延迟的原因**：
- 从库机器性能差
- 从库单线程回放（5.6 前），主库多线程写入 → 5.7+ 支持并行复制（MTS）
- 大事务：一个事务在主库执行 10 分钟，从库也要 10 分钟
- 从库上有大量查询，资源竞争

### Q33: 主从延迟怎么监控和处理？

```sql
-- 监控主从延迟
SHOW SLAVE STATUS\G
-- 关键字段:
-- Seconds_Behind_Master: 从库落后主库的秒数（为 0 表示无延迟）
-- Slave_IO_Running: Yes
-- Slave_SQL_Running: Yes
-- Retrieved_Gtid_Set / Executed_Gtid_Set

-- 或通过 percona 工具:
pt-heartbeat --update -D test --create-table  # 主库每秒写心跳
pt-heartbeat --monitor -D test                 # 从库监控延迟
```

**解决方案**：
- 关键业务读主库（强制走主库）
- 对实时性要求不高的查询走从库
- MGR (Group Replication) 或 InnoDB Cluster → 多主架构
- 使用缓存层（Redis）分担读压力

### Q34: MHA、MGR、InnoDB Cluster 的区别？

| | MHA | MGR | InnoDB Cluster |
|---|-----|-----|----------------|
| 原理 | 外部监控 + binlog 补齐 | Paxos 组复制 | MGR + MySQL Router + MySQL Shell |
| 自动故障转移 | ✅ 是 | ✅ 是 | ✅ 是 |
| 数据一致性 | 最终一致（异步） | 强一致（可配置） | 强一致 |
| RPO | 可能有少量丢失 | 0（强一致模式） | 0 |
| 脑裂保护 | 无（靠 VIP/脚本） | 有（Paxos 多数派） | 有 |
| 多主写入 | 不支持 | 支持 | 支持 |
| MySQL 版本 | 5.5+ | 5.7.17+ | 8.0+ |

---

## 10. 分库分表

### Q35: 什么时候需要分库分表？有哪些常见的拆分策略？

**分库分表信号**：
- 单表数据量 > 2000 万行（B+树 3-4 层，性能开始下降）
- 单库 QPS > 2000（单实例扛不住）
- 磁盘空间不足
- 单表 DDL 锁表时间过长，影响业务

**水平拆分（Sharding）策略**：

```
① 按范围分片 (Range):
   order_2024_01, order_2024_02, ...
   优点: 扩容方便，按时间段归档
   缺点: 热点数据集中在最新月份

② 按哈希分片 (Hash):
   db_{hash(user_id) % 16}
   优点: 数据均匀分布
   缺点: 扩容需要 rehash，动态扩容难

③ 一致性哈希:
   虚拟节点映射到哈希环
   优点: 扩容只影响相邻节点
   缺点: 实现复杂

④ 按业务分片:
   user_db (用户), order_db (订单), product_db (商品)
   优点: 业务隔离，互不影响
   缺点: 跨库 JOIN 困难
```

### Q36: 分库分表后怎么处理跨库查询和分布式事务？

**跨库 JOIN 的替代方案**：

```
① 应用层组装: 分多次查询，代码里做聚合
② 字段冗余: 常用关联数据直接冗余到表中
   例: orders 表冗余 user_name（避免 JOIN user 表）
③ 全局表: 每个库都存一份的小表（如国家/城市字典）
④ 异构索引: ES/HBase 做宽表查询，MySQL 只做主键查询
⑤ 换数据库: TiDB、CockroachDB 原生支持分布式 JOIN
```

**分布式事务方案**：

```
① 尽量避免: 通过设计让事务只操作一个分片
   例: 用户及其订单按 user_id 分到同一分片

② 最终一致性 (推荐):
   本地事务 + 消息表 + 定时补偿
   outbox pattern: 业务操作和消息写在同一个本地事务中

③ 事务消息 (RocketMQ / Kafka):
   半消息 → 执行本地事务 → 确认/回滚

④ Seata / DTM (强一致):
   AT 模式: 自动生成 undo SQL
   TCC 模式: Try-Confirm-Cancel
   性能较低，适合对一致性要求极高的场景

⑤ XA 协议 (两阶段提交):
   性能最差，不推荐在互联网业务中使用
```

### Q37: 如何设计一个平滑的分库分表扩容方案？

**方案：一致性哈希 + 虚拟节点 + 双写过渡**

```
① 初始: 4 个分片，hash(user_id) % 4
② 新加 4 个分片（总共 8 个）:
   - 新数据: 双写到新旧两个分片
   - 老数据: 后台异步迁移，迁移完切读
   - 灰度: 先切 1% 流量读新分片，逐步放大
   - 全量切完后，老分片下线

③ 停写方案 (对可用性要求不高):
   - 发布停写公告
   - 停业务写入
   - 数据迁移
   - 切换配置
   - 恢复写入
```

---

## 11. 实战场景题

### Q38: 设计一个高并发的秒杀系统数据库方案？

**核心问题**：`UPDATE stock SET count = count - 1 WHERE id = ? AND count > 0` 在超高并发下，大量事务排队等行锁。

**方案**：

```sql
-- ① 热点分离: 库存分到多条记录
CREATE TABLE seckill_stock (
    id BIGINT PRIMARY KEY,
    product_id BIGINT,
    stock_slice INT,   -- 1-N，热 key 变成 N 个 key
    count INT,
    UNIQUE KEY (product_id, stock_slice)
);

-- 随机选一个库存片扣减
UPDATE seckill_stock 
SET count = count - 1 
WHERE product_id = ? AND stock_slice = FLOOR(RAND() * 20) AND count > 0;

-- ② Redis 预扣库存（旁路缓存）
-- 用户请求 → Redis DECR → 扣减成功 → 异步写 MySQL
-- Redis 扣完直接返回"已售罄"，MySQL 不需要承受全部流量

-- ③ 请求排队削峰
-- 网关层用令牌桶/漏桶限流
-- 消息队列缓冲请求，后端按固定速率消费
```

### Q39: 大表新增字段怎么做（在线 DDL）？

```sql
-- MySQL 8.0+ 大部分 ALTER TABLE 支持 ALGORITHM=INSTANT (只改元数据)
ALTER TABLE big_table ADD COLUMN new_col VARCHAR(100) DEFAULT '', ALGORITHM=INSTANT;

-- 不支持的改动用 pt-online-schema-change (Percona)
-- 原理: 新建表 → 触发器同步增量 → 分批复制数据 → 原子切换
pt-online-schema-change \
  --alter "ADD COLUMN new_col VARCHAR(100) DEFAULT ''" \
  --execute \
  D=test,t=big_table

-- 或 gh-ost (GitHub)
gh-ost \
  --alter="ADD COLUMN new_col VARCHAR(100) DEFAULT ''" \
  --database=test --table=big_table \
  --execute
```

### Q40: 数据误删除了怎么恢复？

```
场景 1: DELETE 误删 → ROLLBACK（如果还没 COMMIT）
场景 2: 已提交，有备份
  ① 从最近备份恢复一个临时库
  ② 从 binlog 中找到备份之后到误删之前的所有操作，重放
  ③ mysqlbinlog --start-datetime="..." --stop-datetime="..." binlog.0000X | mysql

场景 3: DROP TABLE / TRUNCATE
  - 立刻设置只读，防止数据被覆盖
  - 用备份 + binlog 恢复

预防:
  - 生产环境手动操作前 BEGIN; 确认无误再 COMMIT
  - sql_safe_updates = ON（没 WHERE 的 DML 会报错）
  - 备份策略: 全量(每天) + 增量 binlog(实时)
  - 延迟从库: SLAVE 延迟 1 小时，紧急情况下有 1 小时窗口挽救
```

### Q41: 遇到过 MySQL CPU 飙高怎么排查？

```sql
-- ① 找到占用 CPU 的线程
SHOW PROCESSLIST;  -- 或 SELECT * FROM information_schema.PROCESSLIST;
-- 关注: Time 很长、State 不是 idle 的连接

-- ② 分析该线程正在执行的 SQL
-- 记下线程 ID，然后:
SHOW FULL PROCESSLIST;
SELECT * FROM performance_schema.threads WHERE PROCESSLIST_ID = ?;
SELECT * FROM performance_schema.events_statements_current WHERE THREAD_ID = ?;

-- ③ 常见原因
-- a. 慢 SQL + 高并发（大量连接都执行慢查询）
-- b. 排序/group by 没走索引 → 大量 CPU 做排序
-- c. 大表 JOIN（结果集爆炸）
-- d. 锁等待（SHOW ENGINE INNODB STATUS 看锁信息）
-- e. 死锁检测（innodb_deadlock_detect=ON 时，检测开销 O(n²)）

-- ④ 紧急处理: KILL 掉问题查询
KILL <thread_id>;
```

### Q42: 数据库连接池大小怎么配置？

```
计算公式（经验）:
  pool_size = (core_count * 2) + effective_spindle_count

  但实际更简单:
  ① 对于纯 CPU 操作: pool_size ≈ CPU 核心数
  ② 对于 I/O 操作（数据库）: pool_size ≈ CPU 核心数 * (1 + avg_io_wait_time / avg_cpu_time)

HikariCP 的推荐:
  最大连接数 = CPU核心 * 2 + 磁盘数
  例: 4 核 CPU + 1 SSD ≈ 10 连接

注意:
  - 连接数不是越大越好（连接本身消耗内存 + 上下文切换成本）
  - MySQL 默认 max_connections = 151，连接池总和不要超过它
  - 连接数上限受 MySQL 的 max_connections 限制
  - 多个应用实例连接池总和不能超过 MySQL 上限
```

### Q43: 字段为什么要 NOT NULL？NULL 有什么问题？

```
问题 1: NULL 的判断是 IS NULL / IS NOT NULL，用 = NULL 无效
问题 2: COUNT(col) 不统计 NULL → 容易算错
问题 3: 索引中 NULL 的处理: 所有 NULL 被视为不同值（唯一索引允许多个 NULL）
问题 4: NULL 值的存储: COMPACT 格式下，NULL 列通过 NULL 标志位存储（不占数据空间）
         但 NULL 值判断需要额外的逻辑处理
问题 5: DISTINCT / GROUP BY / ORDER BY 中 NULL 的行为可能不符合预期
问题 6: JOIN 中 NULL != NULL，不能用 = 匹配

最佳实践:
  - 所有列尽量 NOT NULL DEFAULT ''
  - 数值列 DEFAULT 0
  - 日期列设置合理的默认值
  - 如果确实需要"无值"的语义，用特殊值代替代替 NULL
    例: 状态字段 status DEFAULT 'unknown' 替代 NULL
```

### Q44: 如何进行数据库的容量规划和监控？

```
监控指标:
  ① QPS / TPS
  ② 连接数 (Threads_connected / max_connections)
  ③ 慢查询数 (Slow_queries)
  ④ Buffer Pool 命中率 (Innodb_buffer_pool_read_requests / reads)
  ⑤ 表锁 / 行锁等待 (Innodb_row_lock_waits)
  ⑥ 主从延迟 (Seconds_Behind_Master)
  ⑦ 磁盘使用率
  ⑧ 连接超时 / 拒绝连接数 (Connection_errors_max_connections)

关键阈值:
  - Buffer Pool 命中率 < 95% → 考虑加内存
  - 活跃连接 > 80% max → 扩容或优化
  - 磁盘 < 20% 剩余 → 清理或扩容
  - QPS > 当前实例 70% 上限 → 准备扩容

容量规划:
  - 当前数据量 × (1 + 月增长率) ^ 月份
  - 例: 100GB × 1.1^12 ≈ 313GB/年 → 提前半年准备扩容
```

### Q45: 如何保证缓存（Redis）和数据库的数据一致性？

```
写操作顺序选择:

① 先删缓存 → 再更新 DB（❌ 有漏洞）
   T1 删缓存 → T2 读缓存没命中 → T2 读 DB(旧值) → T2 写缓存(旧值)
   → T1 更新 DB(新值)
   结果: 缓存旧值、DB 新值 → 不一致

② 先更新 DB → 再删缓存（✅ 推荐）
   T1 更新 DB → T1 删缓存
   T2 读缓存(没命中) → 读 DB(新值) → 写缓存(新值)
   问题: 极小概率 T1 删缓存失败 → 不一致

③ 延迟双删（优化）:
   ① 先删缓存
   ② 更新 DB
   ③ 延迟 N 毫秒（如 500ms）
   ④ 再次删缓存
   目的: 防止并发读把旧值写回缓存

最终兜底: 缓存设置合理的过期时间
  → 即使出现短暂不一致，过期后自动修正
```

---

> **面试技巧**：MySQL 面试的重点是 **索引原理 + 事务/MVCC + SQL 优化**。面试官通常顺着一个点深挖——比如你说"加了索引"，他会追问"为什么这个索引有效？最左前缀怎么回事？回表是什么？怎么优化？"。把原理讲透比背答案重要得多。
