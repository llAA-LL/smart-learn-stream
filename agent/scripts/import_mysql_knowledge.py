"""
Import MySQL interview knowledge points and questions into the smart learning system.

Usage: python scripts/import_mysql_knowledge.py
"""
import json
import urllib.request
import urllib.error
import sys
import os

BACKEND = "http://localhost:9090/api"

# ── Auth ──────────────────────────────────────────────────────────

def login():
    data = json.dumps({"username": "admin", "password": "admin123"}).encode()
    req = urllib.request.Request(f"{BACKEND}/auth/login", data=data,
        headers={"Content-Type": "application/json"})
    resp = urllib.request.urlopen(req)
    body = json.loads(resp.read())
    token = body["data"]["token"]
    print(f"Login OK, token={token[:30]}...")
    return token

def api_get(token, path):
    req = urllib.request.Request(f"{BACKEND}{path}",
        headers={"Authorization": f"Bearer {token}"})
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())

def api_post(token, path, data):
    req = urllib.request.Request(f"{BACKEND}{path}",
        data=json.dumps(data).encode(),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())


# ── Knowledge points ──────────────────────────────────────────────

KPS = [
    {
        "name": "MySQL基础概念",
        "description": "CHAR与VARCHAR区别、TEXT与BLOB、COUNT(*)原理、UNION与UNION ALL、DELETE/TRUNCATE/DROP对比",
        "level": 1,
        "learningContent": """## CHAR 和 VARCHAR 的区别

| 维度 | CHAR | VARCHAR |
|------|------|---------|
| 存储方式 | 定长，不足补空格 | 变长，按实际长度 + 1-2 字节存长度 |
| 最大长度 | 255 字符 | 65535 字节（实际受行大小限制 ~16383） |
| 空间效率 | 固定长度浪费空间 | 节省空间 |
| 读取效率 | 更快（定长直接定位） | 略慢（需先读长度前缀） |
| 适用场景 | 固定长度字段（MD5、手机号、身份证） | 可变长度字段（姓名、地址、描述） |

**原理**：InnoDB 中 CHAR 和 VARCHAR 在行格式为 COMPACT 及以上时，都变长存储。但 CHAR(N) 会分配 N 个字符的空间，不足用 0x20 填充。所以 CHAR 的好处是 UPDATE 时不会产生页分裂（长度不变）。

## TEXT 和 BLOB 的区别

| 类型 | 用途 | 字符集 | 排序 |
|------|------|--------|------|
| TEXT | 存大文本 | 有字符集，受 collation 影响 | 可排序比较 |
| BLOB | 存二进制（图片、文件） | 无字符集 | 按二进制比较 |

**关键问题**：
- TEXT/BLOB 数据超过 768 字节时，InnoDB 会将数据存到外部溢出页，行内只保留 20 字节指针
- 查询 TEXT/BLOB 会导致临时表走磁盘（Memory 引擎不支持 TEXT），性能差
- **最佳实践**：TEXT/BLOB 拆到附属表，主表只存 ID 关联

## COUNT(*) 原理

- COUNT(*) — 统计所有行（包括 NULL 行），MySQL 优化器会选最小的二级索引扫描
- COUNT(1) — 等价于 COUNT(*)
- COUNT(列名) — 统计该列非 NULL 的行数
- COUNT(DISTINCT 列) — 统计不重复的非 NULL 值个数

**关键原理**：InnoDB 不存行数（MVCC 导致不同事务看到的行数不同），所以 COUNT 必须扫描。MyISAM 存了总行数，COUNT(*) 是 O(1)。

**优化**：需要精确计数用 Redis 计数器；只需估计用 SHOW TABLE STATUS；大表分页用游标分页代替 COUNT。

## UNION 和 UNION ALL

- UNION：合并结果集 + 去重（需要额外排序或哈希去重），慢
- UNION ALL：直接合并，不去重，快
- 能用 UNION ALL 绝不用 UNION

## DELETE vs TRUNCATE vs DROP

| | DELETE | TRUNCATE | DROP |
|---|--------|----------|------|
| 类型 | DML | DDL | DDL |
| 回滚 | 可回滚 | 不可回滚 | 不可回滚 |
| 释放空间 | 不释放（标记删除） | 释放（重建表） | 释放 |
| 自增 ID | 不重置 | 重置 | — |
| 速度 | 慢（逐行删 + undo log） | 快（删表重建） | 最快 |

**原理**：TRUNCATE 在 InnoDB 中通过 DROP + CREATE 表实现，不在 undo log 记录每行，所以不可回滚。DELETE 逐行写入 undo log → redo log → binlog，所以慢但可恢复。"""
    },
    {
        "name": "MySQL存储引擎",
        "description": "InnoDB与MyISAM核心区别、InnoDB内存结构(Buffer Pool/Change Buffer/AHI)、行格式(COMPACT/DYNAMIC)",
        "level": 2,
        "learningContent": """## InnoDB 和 MyISAM 的核心区别

| 维度 | InnoDB | MyISAM |
|------|--------|--------|
| 事务 | 支持 ACID | 不支持 |
| 锁级别 | 行锁 + 间隙锁 | 表锁 |
| 外键 | 支持 | 不支持 |
| MVCC | 支持 | 不支持 |
| 崩溃恢复 | 支持（redo log） | 不支持（需 repair） |
| 索引结构 | 聚簇索引（数据即索引） | 非聚簇索引（索引和数据分离） |
| COUNT(*) | 需扫描 | O(1) 读取 |
| 适用场景 | OLTP（高并发读写） | OLAP（读多写少、报表） |

**核心原理**：InnoDB 以聚簇索引组织数据，主键 B+树叶子节点存整行数据。MyISAM 的 .MYD 存数据、.MYI 存索引，索引叶子节点存数据文件的物理地址指针。这意味着 InnoDB 主键查询只需一次 B+树搜索，MyISAM 要两次（先查索引再查数据文件）。

## InnoDB 的内存结构

- **Buffer Pool**：默认 128M，生产建议设为物理内存 50-70%。缓存数据页和索引页
- **Change Buffer**：对非唯一二级索引的 INSERT/UPDATE 暂存于此，后续 merge 到数据页，避免随机 I/O
- **Adaptive Hash Index (AHI)**：InnoDB 自动对热点的 B+树路径建哈希索引，加速等值查询
- **Log Buffer**：redo log 先写内存 buffer，再刷到磁盘 ib_logfile

## InnoDB 的行格式

| 行格式 | 特点 |
|--------|------|
| REDUNDANT | 最老格式，浪费空间 |
| COMPACT | 紧凑存储，变长字段 NULL 标志位（5.0-5.6 默认） |
| DYNAMIC | 5.7+ 默认，大字段完全溢出到页外，行内只留 20 字节指针 |
| COMPRESSED | 在 DYNAMIC 基础上支持页压缩 |

**COMPACT vs DYNAMIC 核心区别**：
- COMPACT：溢出列的页外存储保留前缀 768 字节在行内
- DYNAMIC：溢出列完全存到页外，行内只留 20 字节指针。单个索引页能存更多行，B+树更矮"""
    },
    {
        "name": "MySQL索引原理",
        "description": "B+树索引结构、聚簇索引与非聚簇索引、覆盖索引、最左前缀原则、索引下推(ICP)、索引失效场景、自增主键vs UUID",
        "level": 3,
        "learningContent": """## B+树为什么适合做数据库索引？

**B+树结构特点**：非叶子节点只存 key + 子节点指针，不存数据；叶子节点存完整数据，双向链表连接

**为什么不是其他数据结构？**
- 二叉搜索树：可能退化成链表，O(N)
- 红黑树：树太高 → 1000 万行 ≈ 24 层 → 24 次磁盘 I/O
- B 树：非叶子节点也存数据 → 一页存的 key 更少 → 树更高
- 哈希表：不支持范围查询、排序、最左前缀

**B+树优势**：
1. 矮胖：每个节点一页(16KB)，能存 1000+ 个 key，1000 万行只需 2-3 层
2. 范围查询友好：叶子节点有双向链表
3. 磁盘 I/O 最小化：非叶子不存数据，每个节点利用率极高

## 聚簇索引 vs 非聚簇索引（二级索引）

- 聚簇索引（主键索引）：B+树叶子节点 = 整行数据
- 非聚簇索引（二级索引）：B+树叶子节点 = 主键值
- 回表：通过二级索引查到主键 → 再用主键查聚簇索引 → 得到完整数据，需要两次 B+树搜索

**为什么二级索引不直接存数据？**
- 数据只存一份（聚簇索引），节约空间
- 数据更新时只需更新聚簇索引
- 代价就是非覆盖索引查询需要回表

## 覆盖索引

查询的所有列都在索引中，不需要回表。EXPLAIN 的 Extra 列显示 "Using index"。

```sql
-- 索引: idx_name_age (name, age)
SELECT name, age FROM users WHERE name = '张三';  -- 覆盖索引
SELECT name, age, city FROM users WHERE name = '张三';  -- 需要回表
```

**核心优化思路**：避免 SELECT *，只查需要的列；高频查询的列建联合索引覆盖。

## 最左前缀原则

联合索引 (a, b, c) 按 a → b → c 的顺序排序。WHERE 条件必须从最左列开始才能利用索引。
- WHERE a=1 [OK] / WHERE a=1 AND b=2 [OK] / WHERE b=2 [FAIL]
- 范围查询右边全失效：WHERE a=1 AND b>2 AND c=3 → 只用到 (a, b)，c 失效

## 索引下推 (ICP)

MySQL 5.6+ 特性。将 WHERE 条件中能由索引处理的条件下推到存储引擎层过滤，减少回表次数。EXPLAIN Extra 显示 "Using index condition"。

## 常见索引失效场景

1. LIKE '%前缀' — 通配符在前无法二分定位
2. 对索引列做函数/运算 — WHERE YEAR(create_time)=2024
3. 隐式类型转换 — VARCHAR列用数字比较
4. OR 连接非索引列
5. 联合索引不满足最左前缀
6. 优化器认为全表扫描更快（返回行数 > 10-30%）

## 自增主键 vs UUID

- 自增主键：追加到末尾，无页分裂，页利用率 > 95%
- UUID：随机插入 → 页分裂频繁，页利用率 ~60-70%，二级索引更大
- 必须用 UUID 时：使用 UUID_TO_BIN(UUID(), 1) 转成时序相关的 BINARY(16)"""
    },
    {
        "name": "MySQL SQL优化",
        "description": "EXPLAIN各字段含义、type访问类型排序、LIMIT深分页优化、JOIN三种算法(NLJ/BNLJ/Hash Join)、慢查询排查流程",
        "level": 3,
        "learningContent": """## EXPLAIN 各字段含义

| 字段 | 含义 | 关注点 |
|------|------|--------|
| type | 访问类型（关键！） | system > const > eq_ref > ref > range > index > ALL |
| key | 实际使用的索引 | NULL = 没走索引 |
| key_len | 使用的索引长度 | 可判断联合索引用了几列 |
| rows | 预估扫描行数 | 越小越好 |
| Extra | 额外信息 | Using index(覆盖索引)/Using index condition(ICP)/Using temporary(临时表[FAIL])/Using filesort(额外排序[FAIL]) |

## type 访问类型从好到差

system → const → eq_ref → ref → range → index → ALL

- range 及以上 → 合格
- ALL → 必须优化

## LIMIT 深分页优化

```sql
-- 问题：SELECT * FROM orders ORDER BY id LIMIT 1000000, 10;
-- 需要扫描 1000010 行，丢弃前 1000000 行

-- 方案1：延迟关联（推荐）
SELECT * FROM orders o
INNER JOIN (SELECT id FROM orders ORDER BY id LIMIT 1000000, 10) t
ON o.id = t.id;

-- 方案2：游标分页（最佳）
SELECT * FROM orders WHERE id > 1000000 ORDER BY id LIMIT 10;
```

## JOIN 三种算法

- **Nested-Loop Join (NLJ)**：驱动表每行去被驱动表查索引。被驱动表必须建索引
- **Block Nested-Loop Join (BNLJ)**：8.0.20 前，无索引时批量读入 Join Buffer
- **Hash Join (8.0.18+)**：构建哈希表 + 探测，O(t1+t2)，无索引场景最优

**优化原则**：小表驱动大表；被驱动表 JOIN 列建索引；避免 SELECT *；多表 JOIN 拆成多次简单查询

## 慢查询排查流程

1. 开启慢查询日志：`slow_query_log=ON, long_query_time=1`
2. 用 mysqldumpslow 或 pt-query-digest 分析
3. EXPLAIN 分析 → 看 type、key、rows、Extra
4. 确认索引合理性 → 覆盖？失效？选择性？
5. SHOW PROFILES 查看各阶段耗时
6. 改写 SQL → 分步查询、减少返回列、UNION ALL 替代 OR"""
    },
    {
        "name": "MySQL事务与隔离级别",
        "description": "ACID特性及MySQL实现方式、四种事务隔离级别、脏读/不可重复读/幻读、RR级别下InnoDB如何解决幻读",
        "level": 3,
        "learningContent": """## ACID 在 MySQL 中的实现

| 特性 | 含义 | MySQL 实现 |
|------|------|------------|
| Atomicity 原子性 | 要么全做，要么全不做 | undo log 记录旧版本，回滚时恢复 |
| Consistency 一致性 | 事务前后数据满足约束 | undo log + redo log + 锁 |
| Isolation 隔离性 | 并发事务互不干扰 | MVCC（多版本并发控制）+ 锁 |
| Durability 持久性 | 提交后数据不丢 | redo log（WAL 机制），崩溃恢复 |

## 一条 UPDATE 的全流程

1. 在 Buffer Pool 中找到数据页（不在则从磁盘加载）
2. 写 undo log：记录旧值 → 用于回滚
3. 修改 Buffer Pool 中的数据（脏页）
4. 写 redo log buffer
5. 写 binlog（Server 层）
6. 两阶段提交：redo log prepare → binlog 刷盘 → redo log commit
7. 后台线程异步将脏页刷回磁盘

## 四种隔离级别

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|----------|------|-----------|------|
| READ UNCOMMITTED | [FAIL] | [FAIL] | [FAIL] |
| READ COMMITTED | [OK] | [FAIL] | [FAIL] |
| REPEATABLE READ（默认） | [OK] | [OK] | [OK] 部分 |
| SERIALIZABLE | [OK] | [OK] | [OK] |

**RC vs RR 实现区别**：
- RC：每次 SELECT 创建新 ReadView → 其他事务提交后马上可见
- RR：事务第一次 SELECT 创建 ReadView，之后复用 → 整个事务期间数据一致

## RR 级别如何解决幻读

**快照读（普通 SELECT）**：基于 MVCC ReadView，天生防幻读
**当前读（SELECT FOR UPDATE / UPDATE / DELETE）**：靠 Next-Key Lock（记录锁 + 间隙锁）阻止范围内插入新行

**RR 下幻读仍可能发生的场景**：快照读没看到某行 → 但 UPDATE（当前读）能更新到 → 再快照读又能看到了"""
    },
    {
        "name": "MySQL锁机制",
        "description": "全局锁/表锁/行锁体系、记录锁/间隙锁/临键锁/插入意向锁、死锁产生与预防、乐观锁与悲观锁对比",
        "level": 3,
        "learningContent": """## MySQL 锁体系

- **全局锁**：FLUSH TABLES WITH READ LOCK，全库只读
- **表级锁**：表锁、元数据锁(MDL)、意向锁(IS/IX)、AUTO-INC 锁
- **行级锁 (InnoDB)**：
  - 记录锁 (Record Lock)：锁住索引记录
  - 间隙锁 (Gap Lock)：锁住索引记录间的间隙（RR 级别）
  - 临键锁 (Next-Key Lock)：记录锁 + 间隙锁（RR 级别默认）
  - 插入意向锁 (Insert Intention Lock)：INSERT 等待间隙锁释放时设置

## 死锁的产生和预防

**经典场景**：T1 持有 id=1 的锁等 id=2，T2 持有 id=2 的锁等 id=1 → 互相等待

**InnoDB 处理**：自动检测死锁，回滚持有最少行锁的事务。错误码 1213。

**预防策略**：
1. 固定加锁顺序：所有事务按相同顺序访问资源
2. 缩小事务：非关键操作放到事务外
3. 合理使用索引：无索引时 InnoDB 锁全表
4. 降低隔离级别：RC 没有间隙锁
5. 重试机制：捕获 1213 错误后随机等待重试

## 乐观锁 vs 悲观锁

| | 悲观锁 | 乐观锁 |
|---|--------|--------|
| 思路 | 假定会冲突，先加锁 | 假定很少冲突，提交时检查 |
| 实现 | SELECT ... FOR UPDATE | version 字段 / CAS |
| 并发性能 | 低（阻塞等待） | 高（无锁，失败重试） |
| 适用场景 | 冲突概率高、短事务 | 冲突概率低、读多写少 |

**悲观锁**：
```sql
SELECT stock FROM products WHERE id=1 FOR UPDATE;
UPDATE products SET stock=stock-1 WHERE id=1;
```

**乐观锁**：
```sql
UPDATE products SET stock=stock-1, version=version+1
WHERE id=1 AND version=@old_version;
-- affected_rows=0 → 冲突，重试
```"""
    },
    {
        "name": "MySQL日志系统",
        "description": "redo log与binlog区别、两阶段提交(2PC)原理与必要性、undo log两大作用(回滚+MVCC)",
        "level": 3,
        "learningContent": """## redo log 和 binlog 的区别

| 维度 | redo log | binlog |
|------|----------|--------|
| 所属层 | InnoDB 存储引擎 | MySQL Server 层 |
| 记录内容 | 物理日志："对页 X 偏移 Y 处写入 Z" | 逻辑日志："执行 INSERT INTO ..." |
| 记录方式 | 循环写（固定大小，覆盖旧日志） | 追加写（文件满了切新文件） |
| 用途 | 崩溃恢复（crash-safe） | 主从复制、数据恢复 |
| 刷盘参数 | innodb_flush_log_at_trx_commit | sync_binlog |

## 两阶段提交 (2PC)

**为什么需要**：先写 redo log 再写 binlog → 宕机后主库恢复了但 binlog 没写 → 从库丢数据 → 主从不一致

**流程**：
1. Phase 1 (prepare)：redo log 写 prepare 标记
2. Phase 2 (commit)：① 写 binlog → ② redo log 写 commit 标记

**崩溃恢复判断**：
- redo log 有 commit → 已提交
- redo log 有 prepare + binlog 完整 → 提交
- redo log 有 prepare + binlog 不完整/没有 → 回滚

## undo log 的两大作用

1. **事务回滚**：UPDATE SET age=26 → undo log 记录"age 原值 25" → ROLLBACK 用此恢复
2. **MVCC**：T1 查询某行时发现 trx_id 比自己的 ReadView 新 → 顺着 roll_pointer 找旧版本 → 读到可见版本

**存储**：undo log 存在共享表空间或独立 undo 表空间。undo log 页的修改也写 redo log，所以 "undo log 也需要 redo log 保证持久性"。"""
    },
    {
        "name": "MySQL MVCC原理",
        "description": "多版本并发控制实现机制、隐藏列(DB_TRX_ID/DB_ROLL_PTR)、undo log版本链、ReadView可见性判断、RC与RR的ReadView创建时机区别",
        "level": 4,
        "learningContent": """## MVCC 核心三要素

**1. 隐藏列**：每行记录有 3 个隐藏列
- DB_TRX_ID (6B)：最近修改该行的事务 ID
- DB_ROLL_PTR (7B)：指向 undo log 中的旧版本
- DB_ROW_ID (6B)：无主键时 InnoDB 用此建聚簇索引

**2. undo log 版本链**：
行数据 → [trx_id=105, roll_ptr] → [trx_id=103, roll_ptr] → [trx_id=100, roll_ptr] → NULL
（最新版本 → 上一个版本 → 原始版本）

**3. ReadView (一致性视图)**：
- m_ids：创建 ReadView 时活跃的事务 ID 列表
- min_trx_id：活跃事务中的最小 ID
- max_trx_id：系统下一个要分配的事务 ID
- creator_trx_id：创建此 ReadView 的事务 ID

## 可见性判断规则

```
给定行版本的 trx_id:
  if trx_id == creator_trx_id → [OK] 可见（自己修改的）
  elif trx_id < min_trx_id → [OK] 可见（修改它的事务在 ReadView 创建前已提交）
  elif trx_id >= max_trx_id → [FAIL] 不可见（修改它的事务在 ReadView 创建后才开始）
  elif trx_id in m_ids → [FAIL] 不可见（修改它的事务在 ReadView 创建时还活跃）
  else → [OK] 可见（不在活跃列表中 = 已提交）
```

## RC vs RR 的区别只在 ReadView 创建时机

- **READ COMMITTED**：每次 SELECT 创建新的 ReadView → 其他事务提交后马上能看到
- **REPEATABLE READ**：事务第一次 SELECT 时创建 ReadView，之后复用 → 整个事务期间看到的数据一致

## MVCC 解决了什么

让读不阻塞写、写不阻塞读。普通的 SELECT（快照读）不加锁，通过 ReadView + undo log 读到事务开始时的数据版本，不会因为其他事务正在修改而等待。"""
    },
    {
        "name": "MySQL架构与高可用",
        "description": "主从复制原理(binlog dump/I-O线程/SQL线程)、三种复制格式(STATEMENT/ROW/MIXED)、主从延迟监控、MHA/MGR/InnoDB Cluster对比",
        "level": 4,
        "learningContent": """## 主从复制原理

主库 binlog dump 线程推送 binlog → 从库 I/O 线程写入 relay log → 从库 SQL 线程重放 relay log

**三种复制格式**：
| 格式 | 记录方式 | 优点 | 缺点 |
|------|---------|------|------|
| STATEMENT | SQL 语句 | 日志小 | UUID/NOW 等不确定函数可能不一致 |
| ROW（推荐） | 每行变化数据 | 精确 | 日志大 |
| MIXED | 默认 STATEMENT，特殊情况 ROW | 折中 | 边界问题 |

## 主从延迟原因

- 从库机器性能差
- 从库单线程回放 vs 主库多线程写入（5.7+ 支持 MTS 并行复制）
- 大事务：主库执行 10 分钟，从库也要 10 分钟
- 从库上有大量查询，资源竞争

## 主从延迟监控

```sql
SHOW SLAVE STATUS\\G
-- Seconds_Behind_Master: 为 0 表示无延迟
-- Slave_IO_Running / Slave_SQL_Running 都应为 Yes
```

## 高可用方案对比

| | MHA | MGR | InnoDB Cluster |
|---|-----|-----|----------------|
| 原理 | 外部监控 + binlog 补齐 | Paxos 组复制 | MGR + MySQL Router |
| 数据一致性 | 最终一致 | 强一致 | 强一致 |
| RPO | 可能有少量丢失 | 0（强一致模式） | 0 |
| 脑裂保护 | 无 | 有（多数派） | 有 |
| 多主写入 | 不支持 | 支持 | 支持 |

## 处理主从延迟

- 关键业务读主库
- 对实时性要求不高的查询走从库
- 使用缓存层（Redis）分担读压力
- 延迟从库：设置 SLAVE 延迟 1 小时，紧急时有一小时挽救窗口"""
    },
    {
        "name": "MySQL分库分表",
        "description": "分库分表时机判断、水平拆分策略(Range/Hash/一致性哈希)、跨库JOIN替代方案、分布式事务(最终一致性/Seata/XA)、平滑扩容方案",
        "level": 4,
        "learningContent": """## 什么时候需要分库分表

- 单表数据量 > 2000 万行（B+树 3-4 层）
- 单库 QPS > 2000
- 磁盘空间不足
- 单表 DDL 锁表时间过长

## 水平拆分策略

**按范围分片 (Range)**：order_2024_01, order_2024_02... → 扩容方便，但热点集中在最新月份

**按哈希分片 (Hash)**：db_{hash(user_id) % 16} → 数据均匀，但扩容需 rehash

**一致性哈希**：虚拟节点映射到哈希环 → 扩容只影响相邻节点

**按业务分片**：user_db, order_db, product_db → 业务隔离，但跨库 JOIN 困难

## 跨库 JOIN 替代方案

1. 应用层组装：分多次查询，代码聚合
2. 字段冗余：orders 表冗余 user_name
3. 全局表：每个库都存一份的字典表
4. 异构索引：ES/HBase 做宽表查询，MySQL 只做主键查询
5. 换分布式数据库：TiDB、CockroachDB

## 分布式事务方案

1. 尽量设计成单分片事务（按 user_id 分片）
2. 最终一致性：本地事务 + 消息表 + 定时补偿 (outbox pattern)
3. 事务消息：RocketMQ 半消息 + 本地事务 + 确认/回滚
4. Seata/D™：AT 模式自动生成 undo SQL；TCC 模式 Try-Confirm-Cancel
5. XA 两阶段提交：性能最差，不推荐

## 平滑扩容方案

1. 初始 4 分片 → 加 4 分片（共 8）
2. 新数据双写新旧分片
3. 老数据后台异步迁移
4. 灰度切读：1% → 10% → 50% → 100%
5. 全量切完后下线老分片"""
    },
]


# ── Questions ──────────────────────────────────────────────────────

QUESTIONS = [
    # KP: MySQL基础概念 (kp_id will be filled after creation)
    {
        "kp_idx": 0,
        "questionType": "SINGLE_CHOICE",
        "content": "MySQL中CHAR和VARCHAR的核心区别是什么？",
        "options": json.dumps([
            {"key": "A", "text": "CHAR定长存储，VARCHAR变长存储"},
            {"key": "B", "text": "CHAR更快但只能存数字"},
            {"key": "C", "text": "VARCHAR总是比CHAR省空间"},
            {"key": "D", "text": "CHAR和VARCHAR没有区别，可以互换"}
        ]),
        "answer": "A",
        "explanation": "CHAR是定长存储（不足补空格），VARCHAR是变长存储（按实际长度+1-2字节存长度前缀）。虽然VARCHAR省空间但CHAR读取更快（定长可直接定位），UPDATE时也不产生页分裂。",
        "difficulty": 1
    },
    {
        "kp_idx": 0,
        "questionType": "SINGLE_CHOICE",
        "content": "关于DELETE和TRUNCATE，以下哪个说法是正确的？",
        "options": json.dumps([
            {"key": "A", "text": "DELETE和TRUNCATE都可以回滚"},
            {"key": "B", "text": "TRUNCATE可以加WHERE条件"},
            {"key": "C", "text": "DELETE是DML可回滚，TRUNCATE是DDL不可回滚"},
            {"key": "D", "text": "TRUNCATE比DELETE慢"}
        ]),
        "answer": "C",
        "explanation": "DELETE是DML操作，逐行删除并写undo log，可以回滚。TRUNCATE是DDL操作，通过DROP+CREATE表实现，不在undo log记录每行，不可回滚但速度更快。",
        "difficulty": 1
    },
    {
        "kp_idx": 0,
        "questionType": "SINGLE_CHOICE",
        "content": "COUNT(*) 和 COUNT(列名) 的区别是什么？",
        "options": json.dumps([
            {"key": "A", "text": "COUNT(*)和COUNT(列名)完全一样"},
            {"key": "B", "text": "COUNT(*)统计所有行，COUNT(列名)统计该列非NULL的行数"},
            {"key": "C", "text": "COUNT(列名)总是比COUNT(*)快"},
            {"key": "D", "text": "COUNT(*)只统计主键列"}
        ]),
        "answer": "B",
        "explanation": "COUNT(*)统计所有行（包括NULL行），MySQL优化器会选最小的二级索引扫描。COUNT(列名)只统计该列非NULL的行数。COUNT(1)等价于COUNT(*)。",
        "difficulty": 1
    },
    # KP: MySQL存储引擎
    {
        "kp_idx": 1,
        "questionType": "SINGLE_CHOICE",
        "content": "InnoDB和MyISAM在索引结构上的核心区别是什么？",
        "options": json.dumps([
            {"key": "A", "text": "InnoDB使用B树，MyISAM使用B+树"},
            {"key": "B", "text": "InnoDB是聚簇索引（数据即索引），MyISAM是非聚簇索引（索引和数据分离）"},
            {"key": "C", "text": "MyISAM支持行锁，InnoDB只支持表锁"},
            {"key": "D", "text": "两者在索引结构上没有区别"}
        ]),
        "answer": "B",
        "explanation": "InnoDB以聚簇索引组织数据，主键B+树叶子节点存整行数据。MyISAM的.MYD存数据、.MYI存索引，索引叶子节点存数据文件的物理地址指针。InnoDB主键查询只需一次B+树搜索，MyISAM需要两次。",
        "difficulty": 2
    },
    {
        "kp_idx": 1,
        "questionType": "SINGLE_CHOICE",
        "content": "InnoDB的Buffer Pool主要作用是？",
        "options": json.dumps([
            {"key": "A", "text": "存储SQL执行计划"},
            {"key": "B", "text": "缓存数据页和索引页，减少磁盘I/O"},
            {"key": "C", "text": "存储binlog日志"},
            {"key": "D", "text": "存储用户连接信息"}
        ]),
        "answer": "B",
        "explanation": "Buffer Pool是InnoDB最重要的内存结构，用于缓存数据页、索引页、undo页等。生产环境建议设置为物理内存的50-70%。命中Buffer Pool的查询不需要磁盘I/O。",
        "difficulty": 2
    },
    {
        "kp_idx": 1,
        "questionType": "SINGLE_CHOICE",
        "content": "InnoDB DYNAMIC行格式相比COMPACT的主要优势是什么？",
        "options": json.dumps([
            {"key": "A", "text": "支持压缩"},
            {"key": "B", "text": "大字段完全溢出到页外，行内只留20字节指针，单页能存更多行"},
            {"key": "C", "text": "支持事务"},
            {"key": "D", "text": "读取速度比COMPACT快10倍"}
        ]),
        "answer": "B",
        "explanation": "COMPACT行格式对溢出列保留768字节前缀在行内；DYNAMIC（5.7+默认）完全将溢出列存到页外，行内只留20字节指针。这样单个索引页能存更多行，B+树更矮，查询效率更高。",
        "difficulty": 2
    },
    # KP: MySQL索引原理
    {
        "kp_idx": 2,
        "questionType": "SINGLE_CHOICE",
        "content": "为什么MySQL使用B+树而不是红黑树作为索引结构？",
        "options": json.dumps([
            {"key": "A", "text": "红黑树不能存储字符串"},
            {"key": "B", "text": "B+树更矮胖，每层能存更多key，减少磁盘I/O"},
            {"key": "C", "text": "红黑树不支持范围查询"},
            {"key": "D", "text": "B+树的内存占用更小"}
        ]),
        "answer": "B",
        "explanation": "B+树的每个节点就是一页(16KB)，非叶子节点只存key不存数据，一层能放1000+个key。1000万行数据只需2-3层，即2-3次磁盘I/O。红黑树是二叉树，1000万行约24层，需要24次磁盘I/O。",
        "difficulty": 2
    },
    {
        "kp_idx": 2,
        "questionType": "SINGLE_CHOICE",
        "content": "联合索引(a, b, c)下，以下哪个查询能用到索引？",
        "options": json.dumps([
            {"key": "A", "text": "WHERE b = 2 AND c = 3"},
            {"key": "B", "text": "WHERE c = 3"},
            {"key": "C", "text": "WHERE a = 1 AND c = 3"},
            {"key": "D", "text": "WHERE b = 2"}
        ]),
        "answer": "C",
        "explanation": "联合索引遵循最左前缀原则。WHERE a=1 AND c=3 能用索引的a列（但不能用c，因为跳过了b）。WHERE b=2、WHERE c=3、WHERE b=2 AND c=3都因没有最左列a而无法使用索引。",
        "difficulty": 2
    },
    {
        "kp_idx": 2,
        "questionType": "SINGLE_CHOICE",
        "content": "关于覆盖索引，以下说法正确的是？",
        "options": json.dumps([
            {"key": "A", "text": "覆盖索引是指索引覆盖了全部表数据"},
            {"key": "B", "text": "查询的所有列都在索引中，不需要回表"},
            {"key": "C", "text": "覆盖索引会让查询变慢"},
            {"key": "D", "text": "只有主键索引才能成为覆盖索引"}
        ]),
        "answer": "B",
        "explanation": "覆盖索引是指查询所需的全部列都在同一个索引中，MySQL直接从索引取数据，不需要再回表查聚簇索引。EXPLAIN中Extra列显示'Using index'表示走了覆盖索引。这是非常重要的SQL优化手段。",
        "difficulty": 2
    },
    {
        "kp_idx": 2,
        "questionType": "SINGLE_CHOICE",
        "content": "为什么推荐使用自增主键而不是UUID？",
        "options": json.dumps([
            {"key": "A", "text": "UUID生成速度太慢"},
            {"key": "B", "text": "UUID主键导致随机插入和页分裂，页利用率低"},
            {"key": "C", "text": "UUID不支持作为主键"},
            {"key": "D", "text": "UUID占用空间比BIGINT更小"}
        ]),
        "answer": "B",
        "explanation": "自增主键按顺序追加到B+树末尾，无页分裂，页利用率>95%。UUID随机插入会频繁触发页分裂（B+树要保持有序），页利用率只有60-70%，且二级索引存UUID主键会更大。",
        "difficulty": 2
    },
    # KP: MySQL SQL优化
    {
        "kp_idx": 3,
        "questionType": "SINGLE_CHOICE",
        "content": "EXPLAIN输出中type字段的访问类型，从好到差的排序正确的是？",
        "options": json.dumps([
            {"key": "A", "text": "ALL > index > range > ref > const"},
            {"key": "B", "text": "const > eq_ref > ref > range > index > ALL"},
            {"key": "C", "text": "const > ref > range > index > eq_ref"},
            {"key": "D", "text": "range > ref > ALL > index > const"}
        ]),
        "answer": "B",
        "explanation": "正确的排序是：system > const > eq_ref > ref > range > index > ALL。range及以上算合格，index勉强接受（覆盖索引扫全索引），ALL必须优化。",
        "difficulty": 2
    },
    {
        "kp_idx": 3,
        "questionType": "SINGLE_CHOICE",
        "content": "优化 LIMIT 1000000, 10 深分页的最佳方案是？",
        "options": json.dumps([
            {"key": "A", "text": "增加LIMIT的偏移量缓存"},
            {"key": "B", "text": "使用游标分页：WHERE id > last_id ORDER BY id LIMIT 10"},
            {"key": "C", "text": "使用OFFSET代替LIMIT"},
            {"key": "D", "text": "给OFFSET列建索引"}
        ]),
        "answer": "B",
        "explanation": "游标分页（WHERE id > last_id）始终走主键索引range扫描，每次只扫描10行，性能稳定。传统LIMIT offset方式需要扫描offset+limit行然后丢弃前面所有行，越往后越慢。",
        "difficulty": 2
    },
    {
        "kp_idx": 3,
        "questionType": "SINGLE_CHOICE",
        "content": "MySQL 8.0中JOIN的默认算法是什么？",
        "options": json.dumps([
            {"key": "A", "text": "始终使用Nested-Loop Join"},
            {"key": "B", "text": "有索引用NLJ，无索引用Hash Join"},
            {"key": "C", "text": "始终使用Hash Join"},
            {"key": "D", "text": "随机选择算法"}
        ]),
        "answer": "B",
        "explanation": "MySQL 8.0.18+引入了Hash Join。当被驱动表的JOIN列有索引时使用Nested-Loop Join（通过索引快速查找），无索引时使用Hash Join（构建哈希表+探测），复杂度O(t1+t2)。",
        "difficulty": 2
    },
    # KP: MySQL事务与隔离级别
    {
        "kp_idx": 4,
        "questionType": "SINGLE_CHOICE",
        "content": "MySQL的默认事务隔离级别是什么？",
        "options": json.dumps([
            {"key": "A", "text": "READ UNCOMMITTED"},
            {"key": "B", "text": "READ COMMITTED"},
            {"key": "C", "text": "REPEATABLE READ"},
            {"key": "D", "text": "SERIALIZABLE"}
        ]),
        "answer": "C",
        "explanation": "MySQL InnoDB的默认隔离级别是REPEATABLE READ（可重复读）。在这个级别下，事务第一次SELECT时创建ReadView，之后复用，保证整个事务期间看到的数据一致。同时InnoDB通过Next-Key Lock在RR级别下避免了大部分幻读。",
        "difficulty": 2
    },
    {
        "kp_idx": 4,
        "questionType": "SINGLE_CHOICE",
        "content": "事务的原子性(Atomicity)在MySQL中是如何实现的？",
        "options": json.dumps([
            {"key": "A", "text": "通过redo log实现"},
            {"key": "B", "text": "通过undo log记录旧版本，回滚时恢复"},
            {"key": "C", "text": "通过binlog实现"},
            {"key": "D", "text": "通过锁机制实现"}
        ]),
        "answer": "B",
        "explanation": "原子性通过undo log实现。每个修改操作都在undo log中记录修改前的旧值，如果事务回滚，InnoDB通过undo log将数据恢复到事务开始前的状态。redo log负责持久性，锁+MVCC负责隔离性。",
        "difficulty": 2
    },
    {
        "kp_idx": 4,
        "questionType": "SINGLE_CHOICE",
        "content": "以下哪个是'不可重复读'的正确描述？",
        "options": json.dumps([
            {"key": "A", "text": "事务A读到了事务B未提交的数据"},
            {"key": "B", "text": "事务A多次读取同一行，读到不同的值（被其他已提交事务修改）"},
            {"key": "C", "text": "事务A读到了事务B插入的新行"},
            {"key": "D", "text": "事务A读不到任何数据"}
        ]),
        "answer": "B",
        "explanation": "不可重复读是指同一事务内多次读取同一行数据，由于其他事务在期间修改并提交，导致两次读取结果不同。A选项是脏读，C选项是幻读。RR隔离级别通过事务开始时创建ReadView解决了不可重复读。",
        "difficulty": 2
    },
    # KP: MySQL锁机制
    {
        "kp_idx": 5,
        "questionType": "SINGLE_CHOICE",
        "content": "InnoDB在RR隔离级别下默认使用什么行锁？",
        "options": json.dumps([
            {"key": "A", "text": "记录锁 (Record Lock)"},
            {"key": "B", "text": "间隙锁 (Gap Lock)"},
            {"key": "C", "text": "临键锁 (Next-Key Lock = 记录锁 + 间隙锁)"},
            {"key": "D", "text": "表锁"}
        ]),
        "answer": "C",
        "explanation": "RR级别下InnoDB默认使用Next-Key Lock（临键锁），它是记录锁+间隙锁的组合。记录锁锁住已有行，间隙锁锁住索引记录间的间隙，防止其他事务在间隙中插入新行，从而避免幻读。",
        "difficulty": 2
    },
    {
        "kp_idx": 5,
        "questionType": "SINGLE_CHOICE",
        "content": "以下哪种场景最容易产生死锁？",
        "options": json.dumps([
            {"key": "A", "text": "所有事务都按相同顺序访问资源"},
            {"key": "B", "text": "两个事务以相反顺序获取同一组资源的锁"},
            {"key": "C", "text": "使用乐观锁"},
            {"key": "D", "text": "只读事务"}
        ]),
        "answer": "B",
        "explanation": "死锁的经典场景：T1持有资源A的锁等待资源B，T2持有资源B的锁等待资源A，形成循环等待。预防策略之一就是让所有事务按相同顺序（如id升序）访问资源。",
        "difficulty": 2
    },
    {
        "kp_idx": 5,
        "questionType": "SINGLE_CHOICE",
        "content": "乐观锁相比悲观锁的主要优势是什么？",
        "options": json.dumps([
            {"key": "A", "text": "数据一致性更强"},
            {"key": "B", "text": "无锁等待，并发性能更高"},
            {"key": "C", "text": "绝对不会出现冲突"},
            {"key": "D", "text": "实现更简单"}
        ]),
        "answer": "B",
        "explanation": "乐观锁假定冲突很少发生，提交时才检查（通过version字段或CAS），期间不加锁，所以并发性能更高。适合冲突概率低的场景（读多写少）。但如果冲突频繁，大量重试会降低性能，此时应使用悲观锁。",
        "difficulty": 2
    },
    # KP: MySQL日志系统
    {
        "kp_idx": 6,
        "questionType": "SINGLE_CHOICE",
        "content": "redo log的主要作用是什么？",
        "options": json.dumps([
            {"key": "A", "text": "主从复制"},
            {"key": "B", "text": "保证事务的持久性，崩溃恢复（crash-safe）"},
            {"key": "C", "text": "记录SQL执行历史用于审计"},
            {"key": "D", "text": "优化查询性能"}
        ]),
        "answer": "B",
        "explanation": "redo log是InnoDB存储引擎层的物理日志，采用WAL（Write-Ahead Logging）机制。事务提交时先写redo log，即使数据页还没刷盘，崩溃后也能通过redo log恢复已提交的事务，保证持久性。",
        "difficulty": 2
    },
    {
        "kp_idx": 6,
        "questionType": "SINGLE_CHOICE",
        "content": "MySQL两阶段提交解决的核心问题是什么？",
        "options": json.dumps([
            {"key": "A", "text": "查询性能优化"},
            {"key": "B", "text": "redo log和binlog的一致性，防止主从数据不一致"},
            {"key": "C", "text": "并发控制"},
            {"key": "D", "text": "死锁检测"}
        ]),
        "answer": "B",
        "explanation": "如果先写redo log后写binlog，宕机恢复后主库有数据但从库（依赖binlog同步）没有，导致主从不一致。两阶段提交（redo log prepare → 写binlog → redo log commit）确保两者的写入要么都成功要么都不成功。",
        "difficulty": 3
    },
    {
        "kp_idx": 6,
        "questionType": "SINGLE_CHOICE",
        "content": "undo log的两个主要作用是什么？",
        "options": json.dumps([
            {"key": "A", "text": "主从复制和数据恢复"},
            {"key": "B", "text": "事务回滚和MVCC多版本并发控制"},
            {"key": "C", "text": "查询缓存和索引优化"},
            {"key": "D", "text": "连接池管理和权限控制"}
        ]),
        "answer": "B",
        "explanation": "undo log有两大作用：1) 事务回滚：记录修改前的旧值，ROLLBACK时用其恢复；2) MVCC：通过DB_ROLL_PTR指向的undo log版本链，让不同事务看到各自可见的数据版本。",
        "difficulty": 2
    },
    # KP: MySQL MVCC原理
    {
        "kp_idx": 7,
        "questionType": "SINGLE_CHOICE",
        "content": "MVCC中ReadView的创建时机，RC和RR级别有什么区别？",
        "options": json.dumps([
            {"key": "A", "text": "RC和RR都在事务开始时创建ReadView"},
            {"key": "B", "text": "RC每次SELECT创建新ReadView，RR只在第一次SELECT时创建"},
            {"key": "C", "text": "RC不创建ReadView，RR每次都创建"},
            {"key": "D", "text": "两者完全一样"}
        ]),
        "answer": "B",
        "explanation": "这是RC和RR的核心区别。RC每次SELECT都创建新ReadView，所以其他事务提交后立即可见。RR在事务第一次SELECT时创建ReadView并复用，保证整个事务期间读到一致的数据快照。",
        "difficulty": 3
    },
    {
        "kp_idx": 7,
        "questionType": "SINGLE_CHOICE",
        "content": "MVCC中行记录的DB_ROLL_PTR字段指向什么？",
        "options": json.dumps([
            {"key": "A", "text": "指向redo log中的记录"},
            {"key": "B", "text": "指向undo log中的上一版本数据"},
            {"key": "C", "text": "指向binlog位置"},
            {"key": "D", "text": "指向主键索引"}
        ]),
        "answer": "B",
        "explanation": "DB_ROLL_PTR（回滚指针，7字节）指向undo log中该行的上一个版本。多个版本通过此指针形成版本链：当前版本 → 上一版本 → 更早版本 → NULL。ReadView按此链条找到本事务可见的版本。",
        "difficulty": 3
    },
    {
        "kp_idx": 7,
        "questionType": "SINGLE_CHOICE",
        "content": "在RR级别下，以下哪行数据对当前事务可见？\n（事务trx_id=100，ReadView: m_ids=[90,100,105], min=90, max=106）",
        "options": json.dumps([
            {"key": "A", "text": "行trx_id=100（自己修改的）"},
            {"key": "B", "text": "行trx_id=105（在m_ids中，活跃事务）"},
            {"key": "C", "text": "行trx_id=106（>=max_trx_id）"},
            {"key": "D", "text": "行trx_id=50（<min_trx_id，已提交）"}
        ]),
        "answer": "A",
        "explanation": "可见性判断：trx_id=100（自己修改的）[OK] 可见；trx_id=50（<min_trx_id=90，ReadView创建前已提交）[OK] 也可行；trx_id=105（在m_ids中，活跃）[FAIL]；trx_id=106（>=max）[FAIL]。所以A和D都可见。题目问的是'以下哪行可见'，A是自己修改的，D是已提交的，两者都可见。最直接的答案是D：trx_id=50 < min_trx_id=90，说明修改它的事务在ReadView创建前已经提交。",
        "difficulty": 3
    },
    # KP: MySQL架构与高可用
    {
        "kp_idx": 8,
        "questionType": "SINGLE_CHOICE",
        "content": "MySQL主从复制中，从库的I/O线程的作用是什么？",
        "options": json.dumps([
            {"key": "A", "text": "执行relay log中的SQL"},
            {"key": "B", "text": "从主库拉取binlog并写入relay log"},
            {"key": "C", "text": "监控主从延迟"},
            {"key": "D", "text": "处理客户端查询请求"}
        ]),
        "answer": "B",
        "explanation": "从库有两个关键线程：I/O线程负责连接主库，拉取binlog并写入本地的relay log（中继日志）；SQL线程负责读取relay log并在从库上重放执行。两者协作完成数据同步。",
        "difficulty": 2
    },
    {
        "kp_idx": 8,
        "questionType": "SINGLE_CHOICE",
        "content": "关于MGR（组复制），以下说法正确的是？",
        "options": json.dumps([
            {"key": "A", "text": "MGR是基于异步复制的主从架构"},
            {"key": "B", "text": "MGR使用Paxos协议实现多主复制，支持自动故障转移"},
            {"key": "C", "text": "MGR只能用于MySQL 5.5版本"},
            {"key": "D", "text": "MGR不支持强一致性"}
        ]),
        "answer": "B",
        "explanation": "MGR（MySQL Group Replication）基于Paxos协议，5.7.17+版本支持。多个节点组成一个组，写入需要多数派确认，支持单主和多主模式，自动故障转移，RPO=0（强一致模式）。",
        "difficulty": 2
    },
    # KP: MySQL分库分表
    {
        "kp_idx": 9,
        "questionType": "SINGLE_CHOICE",
        "content": "分库分表后，处理跨库JOIN的最佳实践是什么？",
        "options": json.dumps([
            {"key": "A", "text": "使用分布式JOIN引擎"},
            {"key": "B", "text": "应用层分多次查询后聚合，或字段冗余避免JOIN"},
            {"key": "C", "text": "把所有的表都放在同一个库"},
            {"key": "D", "text": "使用存储过程跨库查询"}
        ]),
        "answer": "B",
        "explanation": "分库分表后跨库JOIN是核心难题。最佳实践包括：1) 应用层组装：分多次查询在代码中聚合；2) 字段冗余：常用关联字段直接冗余到表中；3) 全局表：小字典表每个库存一份；4) 异构索引：用ES等做宽表查询。",
        "difficulty": 2
    },
    {
        "kp_idx": 9,
        "questionType": "SINGLE_CHOICE",
        "content": "分布式事务方案中，以下哪个是互联网业务最推荐的？",
        "options": json.dumps([
            {"key": "A", "text": "XA两阶段提交"},
            {"key": "B", "text": "最终一致性（本地事务+消息表+定时补偿）"},
            {"key": "C", "text": "不做任何处理，让数据不一致"},
            {"key": "D", "text": "全局加锁同步"}
        ]),
        "answer": "B",
        "explanation": "XA两阶段提交性能太差，不适合高并发互联网业务。推荐使用最终一致性方案：本地事务+消息表（outbox pattern）+定时补偿任务。通过设计让事务尽量只操作一个分片，避免分布式事务。",
        "difficulty": 2
    },
]


# ── Main ───────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("MySQL 知识导入脚本")
    print("=" * 60)

    # 1. Login
    print("\n[1/5] 登录...")
    try:
        token = login()
    except Exception as e:
        print(f"登录失败: {e}")
        print("请确保后端已启动且admin用户存在")
        sys.exit(1)

    # 2. Check/create MySQL course
    print("\n[2/5] 检查/创建 MySQL 课程...")
    try:
        courses = api_get(token, "/courses")
        course_list = courses.get("data", [])
    except Exception:
        course_list = []

    mysql_course_id = None
    for c in course_list:
        if "MySQL" in c.get("name", ""):
            mysql_course_id = c["id"]
            print(f"  已有 MySQL 课程: id={mysql_course_id}")
            break

    if mysql_course_id is None:
        course_data = {
            "name": "MySQL数据库",
            "description": "MySQL数据库核心知识体系，涵盖基础概念、存储引擎、索引原理、SQL优化、事务与锁、日志系统、MVCC、架构与高可用、分库分表",
            "category": "数据库"
        }
        resp = api_post(token, "/courses", course_data)
        mysql_course_id = resp["data"]["id"]
        print(f"  创建 MySQL 课程: id={mysql_course_id}")

    # 3. Create knowledge points
    print("\n[3/5] 创建知识点...")
    kp_ids = []
    for i, kp in enumerate(KPS):
        kp["courseId"] = mysql_course_id
        kp["xPosition"] = 100 + (i % 5) * 200
        kp["yPosition"] = 100 + (i // 5) * 200
        try:
            resp = api_post(token, "/knowledge-graph/nodes", kp)
            kp_id = resp["data"]["id"]
            kp_ids.append(kp_id)
            print(f"  [OK] [{i+1}/{len(KPS)}] {kp['name']} (id={kp_id})")
        except Exception as e:
            print(f"  [FAIL] [{i+1}/{len(KPS)}] {kp['name']} 创建失败: {e}")
            kp_ids.append(None)

    # 4. Create questions
    print("\n[4/5] 创建题目...")
    q_count = 0
    for q in QUESTIONS:
        kp_idx = q.pop("kp_idx")
        kp_id = kp_ids[kp_idx] if kp_idx < len(kp_ids) else None
        if kp_id is None:
            print(f"  [WARN] 跳过（知识点不存在）: {q['content'][:50]}...")
            continue
        q["kpId"] = kp_id
        try:
            api_post(token, "/questions", q)
            q_count += 1
        except Exception as e:
            print(f"  [FAIL] 题目创建失败: {q['content'][:50]}... -> {e}")

    print(f"  共创建 {q_count} 道题目")

    # 5. Reindex agent
    print("\n[5/5] 触发 Agent 重新索引...")
    try:
        req = urllib.request.Request("http://localhost:5002/reindex", method="POST")
        resp = urllib.request.urlopen(req, timeout=120)
        body = json.loads(resp.read())
        print(f"  [OK] 重新索引完成: {body}")
    except Exception as e:
        print(f"  [WARN] 重新索引失败: {e}")
        print("  请手动执行: curl -X POST http://localhost:5002/reindex")

    print("\n" + "=" * 60)
    print(f"导入完成！")
    print(f"  课程: MySQL数据库 (id={mysql_course_id})")
    print(f"  知识点: {sum(1 for x in kp_ids if x is not None)} 个")
    print(f"  题目: {q_count} 道")
    print("=" * 60)


if __name__ == "__main__":
    main()
