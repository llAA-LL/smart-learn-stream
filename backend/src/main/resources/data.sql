-- Sample data for smart_learning system
USE smart_learning;

-- ========== Users ==========
-- 密码统一为 BCrypt("123456")；ON DUPLICATE KEY UPDATE 用于把历史 SHA-256 种子密码迁移为 BCrypt
INSERT INTO users (id, username, password, real_name, role) VALUES
(1, 'admin', '$2b$10$CecCeA5VDbu.KzqkGh41x./sixx2UOAIkDEUH6GQ6AmtFKuT3sHam', '系统管理员', 'ADMIN'),
(2, 'zhangsan', '$2b$10$BWZdinQXCETSGm7rG3NQ0eu0q.OqQcJkDqHNf6QK.5mUJs80PBQIu', '张三', 'STUDENT'),
(3, 'lisi', '$2b$10$BWZdinQXCETSGm7rG3NQ0eu0q.OqQcJkDqHNf6QK.5mUJs80PBQIu', '李四', 'STUDENT')
ON DUPLICATE KEY UPDATE password = VALUES(password);

-- ========== Courses ==========
INSERT IGNORE INTO courses (id, name, description, category) VALUES
(1, 'Java程序设计', '从零基础到企业级开发，系统学习Java语言核心特性、面向对象编程思想、集合框架、多线程与并发编程、JDBC以及主流框架Spring Boot的应用。', '计算机科学'),
(2, '数据结构与算法', '计算机科学的基石课程，涵盖数组、链表、栈、队列、树、图等经典数据结构，以及排序、搜索、贪心、动态规划等核心算法思想。', '计算机科学'),
(3, 'Python数据分析', '使用Python进行数据清洗、处理、分析与可视化，涵盖NumPy、Pandas、Matplotlib等核心库，并入门机器学习基础。', '计算机科学'),
(4, '数据库原理', '系统学习关系型数据库理论，包括ER模型、关系代数、SQL查询优化、索引原理、事务与并发控制、数据库设计范式等核心内容。', '计算机科学'),
(5, '计算机网络', '从物理层到应用层的完整网络协议栈学习，深入理解TCP/IP、HTTP、DNS等核心协议，并涵盖网络安全基础知识。', '计算机科学'),
(6, '操作系统基础', '进程线程管理、内存管理、死锁处理、IO模型等操作系统核心概念，面试高频考点。', '计算机科学'),
(7, 'Linux基础', '常用Linux命令、文件权限管理、用户组管理、Shell脚本编写，后端开发必备技能。', '计算机科学'),
(8, '系统设计基础', '架构设计方法论、常见架构模式（微服务/分层/事件驱动）、分布式系统基础（CAP/一致性哈希/分布式事务）。', '计算机科学');

-- ========== Knowledge Points ==========

-- Java程序设计 (course_id=1)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(1, 'Java基础语法', '变量、数据类型、运算符、流程控制语句、数组等Java语言基础', 1, 0),
(2, '面向对象编程', '类与对象、封装、继承、多态、抽象类、接口等OOP核心概念', 1, 1),
(3, '异常处理机制', 'try-catch-finally、throw/throws、自定义异常、异常链', 1, 1),
(4, '集合框架', 'List、Set、Map接口及实现类ArrayList、LinkedList、HashMap、TreeMap等', 1, 2),
(5, '多线程编程', 'Thread类、Runnable接口、线程同步synchronized、Lock、线程池、并发工具类', 1, 2),
(6, 'JDBC数据库连接', 'DriverManager、Connection、Statement、PreparedStatement、ResultSet、连接池', 1, 2),
(7, 'Spring框架基础', 'IoC容器、依赖注入、AOP面向切面、Spring Boot自动配置、Spring MVC', 1, 3);

-- 数据结构与算法 (course_id=2)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(8, '数组与链表', '动态数组、单向链表、双向链表、循环链表的实现与操作及时间复杂度分析', 2, 0),
(9, '栈与队列', '顺序栈、链栈、循环队列、双端队列、优先队列的原理与应用', 2, 1),
(10, '树与二叉树', '二叉树遍历、二叉搜索树、平衡二叉树AVL、堆、哈夫曼树', 2, 1),
(11, '排序算法', '冒泡、选择、插入、希尔、归并、快速、堆排序的原理、实现与复杂度对比', 2, 1),
(12, '图论基础', '邻接矩阵、邻接表、DFS/BFS遍历、最小生成树、最短路径Dijkstra算法', 2, 2),
(13, '动态规划', '最优子结构、状态转移方程、经典问题：背包、LCS、编辑距离', 2, 2),
(14, '贪心算法', '贪心选择性质、活动安排、哈夫曼编码、最小生成树Kruskal/Prim', 2, 2);

-- Python数据分析 (course_id=3)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(15, 'Python基础语法', '变量类型、列表/元组/字典、函数定义、模块导入、文件IO操作', 3, 0),
(16, 'NumPy数组操作', 'ndarray创建与属性、广播机制、数学运算、切片索引、随机数生成', 3, 1),
(17, 'Pandas数据处理', 'Series/DataFrame、数据读取写入CSV/Excel、缺失值处理、groupby聚合、merge连接', 3, 2),
(18, 'Matplotlib可视化', '折线图、柱状图、散点图、饼图、子图布局、样式定制、Seaborn统计图', 3, 2),
(19, '机器学习基础', '监督/无监督学习、训练集/测试集划分、线性回归、逻辑回归、KNN分类器评估指标', 3, 3);

-- 数据库原理 (course_id=4)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(20, '关系模型基础', '关系、元组、属性、码、关系代数运算（选择σ、投影π、连接⋈、除÷）', 4, 0),
(21, 'SQL查询语言', 'SELECT/FROM/WHERE/GROUP BY/HAVING/ORDER BY、子查询、多表连接、聚合函数', 4, 1),
(22, '索引与查询优化', 'B+树索引、哈希索引、聚簇索引、覆盖索引、EXPLAIN执行计划、慢查询优化', 4, 2),
(23, '事务与并发控制', 'ACID特性、隔离级别、脏读/不可重复读/幻读、MVCC、死锁检测与预防', 4, 2),
(24, '数据库设计范式', 'E-R模型设计、1NF/2NF/3NF/BCNF范式分解、反范式化权衡、物理设计优化', 4, 2);

-- 计算机网络 (course_id=5)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(25, 'OSI七层模型', '应用层、表示层、会话层、传输层、网络层、数据链路层、物理层的功能与协议', 5, 0),
(26, 'TCP/IP协议栈', 'TCP三次握手/四次挥手、流量控制、拥塞控制、IP地址分类、子网划分、CIDR', 5, 1),
(27, 'HTTP协议', '请求/响应模型、状态码、请求方法GET/POST/PUT/DELETE、HTTPS/TLS、Cookie/Session', 5, 1),
(28, 'DNS域名解析', '域名层级结构、递归/迭代查询、DNS缓存、A记录/CNAME/MX记录类型、CDN原理', 5, 1),
(29, '网络安全基础', '对称/非对称加密AES/RSA、数字签名、数字证书、防火墙、SQL注入/XSS防御', 5, 2);

-- Java程序设计 扩展 (course_id=1)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(30, 'JVM与内存模型', 'JVM运行时数据区（堆/栈/方法区/程序计数器）、垃圾回收算法（标记清除/复制/标记整理/分代）、类加载机制（双亲委派模型）、JVM调优参数', 1, 3),
(31, '设计模式', '创建型（单例/工厂/建造者）、结构型（代理/装饰器/适配器/外观）、行为型（观察者/策略/模板方法），Spring框架中的设计模式应用', 1, 3),
(32, 'Java 8+ 新特性', 'Lambda表达式、函数式接口（Function/Predicate/Consumer/Supplier）、Stream API（map/filter/reduce/collect）、Optional类、方法引用、新日期时间API', 1, 2),
(33, '反射与注解', 'Class类与类加载、动态创建对象/调用方法/访问字段、动态代理（JDK Proxy vs CGLIB）、自定义注解与注解处理器（APT）', 1, 2),
(34, 'ORM与MyBatis', 'ORM概念、MyBatis核心配置（SqlSessionFactory/Mapper）、动态SQL（if/foreach/choose）、缓存机制（一级/二级）、与Spring Boot整合', 1, 3),
(35, '测试与构建工具', 'JUnit5注解（@Test/@BeforeEach/@ParameterizedTest）、Mockito模拟依赖、断言（assertEquals/assertThrows）、Maven生命周期与依赖管理', 1, 2);

-- 数据结构与算法 扩展 (course_id=2)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(36, '哈希表', '哈希函数设计、冲突解决（拉链法/开放寻址法）、负载因子与rehash、HashMap源码分析（JDK8红黑树优化）、一致性哈希思想', 2, 1),
(37, '二分查找', '基本二分查找模板、查找第一个/最后一个等于target的位置、搜索旋转排序数组、二分答案（最大化最小值/最小化最大值）', 2, 1),
(38, '字符串算法', 'KMP模式匹配（next数组）、Trie前缀树（插入/查找/前缀搜索）、Rabin-Karp滚动哈希、最长回文子串（中心扩展/Manacher）', 2, 2),
(39, '递归与回溯', '递归三要素（终止条件/递推公式/返回值）、回溯模板（选择→递归→撤销）、经典问题（N皇后/全排列/子集/组合总和）、剪枝优化策略', 2, 2);

-- 数据库原理 扩展 (course_id=4)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(40, 'Redis核心数据结构', '5种基本类型（String/Hash/List/Set/ZSet）及应用场景、缓存策略（Cache-Aside/Read-Through/Write-Behind）、过期删除策略（惰性+定期）、持久化（RDB/AOF混合）', 4, 2),
(41, 'MySQL存储引擎', 'InnoDB架构（缓冲池/change buffer/自适应哈希）、三大日志（redo log WAL/binlog/undo log MVCC）、行锁（Record/Gap/Next-Key）、B+树索引结构', 4, 3);

-- 计算机网络 扩展 (course_id=5)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(42, 'RESTful API设计', '资源命名规范（名词复数/层级结构）、HTTP方法语义（GET/POST/PUT/PATCH/DELETE）、状态码使用、版本管理（URL/Header）、分页与过滤、幂等性设计', 5, 1),
(43, '认证与授权', 'JWT结构（Header/Payload/Signature）与验证流程、OAuth2.0四种授权模式（授权码/密码/客户端凭证/简化）、SSO单点登录原理、RBAC权限模型', 5, 2);

-- 操作系统基础 (course_id=6)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(44, '进程与线程', '进程PCB与五状态模型、上下文切换开销、进程间通信IPC（管道/共享内存/消息队列/Socket）、线程共享与独享资源', 6, 0),
(45, '内存管理', '虚拟内存与页表、缺页中断与页面置换算法（LRU/Clock/Optimal）、分段与分页对比、内存分配算法（首次适应/最佳适应/伙伴系统）', 6, 1),
(46, '死锁', '死锁四个必要条件（互斥/占有等待/不可剥夺/循环等待）、死锁预防（破坏条件）、死锁避免（银行家算法）、死锁检测与恢复', 6, 1),
(47, 'IO模型', '同步与异步IO、阻塞IO(BIO) vs 非阻塞IO(NIO) vs IO多路复用 vs 异步IO(AIO)、select/poll/epoll差异与适用场景、零拷贝技术', 6, 2);

-- Linux基础 (course_id=7)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(48, '常用命令', '文件操作（ls/cd/cp/mv/rm/find）、文本处理（cat/grep/awk/sed）、进程管理（ps/top/kill/nohup）、网络工具（netstat/lsof/curl）、管道与重定向', 7, 0),
(49, '文件权限', 'rwx权限模型、chmod数字与符号模式、chown/chgrp更改所有者、umask默认权限掩码、特殊权限（SUID/SGID/Sticky Bit）、用户组管理', 7, 1),
(50, 'Shell脚本', '变量定义与引用、条件判断（if/case）、循环（for/while）、函数定义与参数传递、crontab定时任务、常见陷阱（变量未加引号/管道丢失状态）', 7, 2);

-- 系统设计基础 (course_id=8)
INSERT IGNORE INTO knowledge_points (id, name, description, course_id, level) VALUES
(51, '系统设计方法', '需求分析与功能拆解、容量估算（QPS/存储/带宽）、数据模型设计（关系型vs文档型）、接口设计、画架构图（4+1视图）、常见面试题框架', 8, 1),
(52, '常见架构模式', '微服务vs单体vsSOA对比、分层架构（Controller/Service/DAO）、事件驱动架构（消息队列解耦）、缓存策略（多级缓存/缓存预热）、读写分离与分库分表', 8, 2),
(53, '分布式基础', 'CAP定理（一致性/可用性/分区容错）、BASE理论、一致性哈希（虚拟节点）、分布式ID生成（雪花算法/号段模式）、分布式事务（2PC/3PC/TCC/Saga）', 8, 3);

-- ========== Learning Content (UPDATE for fresh + existing DBs) ==========
UPDATE knowledge_points SET learning_content = '## Java基础语法\n\nJava是一种强类型的、面向对象的编程语言。掌握基础语法是学习Java的第一步。\n\n### 变量与数据类型\n\nJava有8种基本数据类型（primitive types）：\n- **整数类型**：byte(1字节)、short(2字节)、int(4字节)、long(8字节)\n- **浮点类型**：float(4字节)、double(8字节)\n- **字符类型**：char(2字节，Unicode)\n- **布尔类型**：boolean(true/false)\n\n```java\nint age = 18;\ndouble salary = 8000.50;\nchar grade = ''A'';\nboolean isStudent = true;\nString name = \"张三\"; // String是引用类型\n```\n\n### 运算符\n\n- **算术运算符**：+、-、*、/、%（取模）\n- **比较运算符**：==、!=、>、<、>=、<=\n- **逻辑运算符**：&&（短路与）、||（短路或）、!（非）\n- **赋值运算符**：=、+=、-=、*=、/=\n- **三元运算符**：条件 ? 值1 : 值2\n\n### 流程控制\n\n```java\n// if-else\nif (score >= 90) {\n    grade = \"A\";\n} else if (score >= 60) {\n    grade = \"B\";\n} else {\n    grade = \"C\";\n}\n\n// for循环\nfor (int i = 0; i < 10; i++) {\n    System.out.println(i);\n}\n\n// while循环\nwhile (condition) { /* ... */ }\n\n// switch\nswitch (day) {\n    case 1: System.out.println(\"周一\"); break;\n    default: System.out.println(\"其他\");\n}\n```\n\n### 数组\n\n```java\nint[] arr = new int[5];\nint[] arr2 = {1, 2, 3, 4, 5};\n// 增强for循环\nfor (int num : arr2) {\n    System.out.println(num);\n}\n```\n\n### ⚠️ 常见误区\n1. `==` 比较的是引用地址，不是内容（String比较请用`.equals()`）\n2. 整数除法会截断：`5/2 = 2`（不是2.5）\n3. `float f = 3.14;` 编译错误！需要 `3.14f`' WHERE id = 1;

UPDATE knowledge_points SET learning_content = '## 面向对象编程 (OOP)\n\n面向对象编程是Java的核心思想。三大特性：封装、继承、多态。\n\n### 封装 (Encapsulation)\n\n将数据和操作数据的方法绑定在一起，隐藏内部实现细节。\n\n```java\npublic class Student {\n    private String name;  // 私有字段\n    private int age;\n\n    // getter/setter 控制访问\n    public String getName() { return name; }\n    public void setName(String name) { this.name = name; }\n    public int getAge() { return age; }\n    public void setAge(int age) {\n        if (age > 0) this.age = age;  // 数据校验\n    }\n}\n```\n\n### 继承 (Inheritance)\n\n子类继承父类的属性和方法，实现代码复用。Java单继承（一个类只能有一个直接父类）。\n\n```java\npublic class Animal {\n    protected String name;\n    public void eat() { System.out.println(name + \" is eating\"); }\n}\n\npublic class Dog extends Animal {\n    public void bark() { System.out.println(\"Woof!\"); }\n}\n```\n\n- `super()` 调用父类构造方法\n- `@Override` 注解标记方法重写\n- `final` 类不能被继承，`final` 方法不能被重写\n\n### 多态 (Polymorphism)\n\n同一个方法调用，不同对象表现出不同行为。\n\n```java\nAnimal a1 = new Dog();   // 向上转型\nAnimal a2 = new Cat();\na1.eat();  // 调用Dog的eat\na2.eat();  // 调用Cat的eat\n```\n\n### 抽象类与接口\n\n- **抽象类**（abstract class）：可以有构造方法、普通方法、抽象方法\n- **接口**（interface）：Java 8+ 可以有default方法和static方法\n\n```java\npublic interface Flyable {\n    void fly();\n    default void land() { System.out.println(\"Landing...\"); }\n}\n```\n\n### ⚠️ 常见误区\n1. 接口不是类，不能new实例化\n2. `super` 和 `this` 不能在static方法中使用\n3. 子类重写方法时，访问权限不能变得更严格' WHERE id = 2;

UPDATE knowledge_points SET learning_content = '## 异常处理机制\n\n异常是程序运行过程中发生的意外事件。Java通过异常处理机制来优雅地处理错误。\n\n### 异常体系\n\n```\nThrowable\n├── Error（严重错误，不建议捕获，如OutOfMemoryError）\n└── Exception\n    ├── RuntimeException（运行时异常，非必检）\n    │   ├── NullPointerException\n    │   ├── ArrayIndexOutOfBoundsException\n    │   └── ArithmeticException\n    └── 其他Exception（编译时异常，必须处理）\n        ├── IOException\n        ├── SQLException\n        └── FileNotFoundException\n```\n\n### try-catch-finally\n\n```java\ntry {\n    int result = 10 / 0;  // 可能抛出异常\n} catch (ArithmeticException e) {\n    System.out.println(\"除零错误: \" + e.getMessage());\n} catch (Exception e) {\n    System.out.println(\"其他异常\");\n} finally {\n    System.out.println(\"无论是否异常，都会执行\");\n}\n```\n\n### throw vs throws\n\n- `throw`：方法内部手动抛出异常对象\n- `throws`：方法声明，告知调用者可能抛出的异常\n\n```java\npublic void checkAge(int age) throws IllegalArgumentException {\n    if (age < 0) {\n        throw new IllegalArgumentException(\"年龄不能为负数\");\n    }\n}\n```\n\n### try-with-resources (Java 7+)\n\n自动关闭实现了AutoCloseable接口的资源。\n\n```java\ntry (FileReader fr = new FileReader(\"test.txt\");\n     BufferedReader br = new BufferedReader(fr)) {\n    String line = br.readLine();\n} catch (IOException e) {\n    e.printStackTrace();\n}\n// 无需手动close，自动调用\n```\n\n### 自定义异常\n\n```java\npublic class BusinessException extends RuntimeException {\n    private int code;\n    public BusinessException(int code, String msg) {\n        super(msg);\n        this.code = code;\n    }\n}\n```\n\n### ⚠️ 常见误区\n1. 不要用异常控制正常业务流程（性能差）\n2. catch后什么都不做（吞掉异常）是坏习惯\n3. finally中有return会覆盖try中的return值' WHERE id = 3;

UPDATE knowledge_points SET learning_content = '## 集合框架\n\nJava集合框架提供了统一的数据结构操作接口。\n\n### 整体结构\n\n```\nCollection\n├── List（有序、可重复）\n│   ├── ArrayList（数组实现，查快）\n│   ├── LinkedList（双向链表，增删快）\n│   └── Vector（线程安全，已过时）\n├── Set（无序、不可重复）\n│   ├── HashSet（哈希表，O(1)）\n│   ├── LinkedHashSet（哈希+链表，保持插入顺序）\n│   └── TreeSet（红黑树，自动排序）\n└── Queue（队列）\n    ├── LinkedList\n    └── PriorityQueue（优先队列）\n\nMap（键值对，独立接口）\n├── HashMap（数组+链表+红黑树，JDK8+）\n├── LinkedHashMap（保持插入顺序）\n├── TreeMap（红黑树，按key排序）\n└── Hashtable（线程安全，已过时）\n```\n\n### 常用操作\n\n```java\n// List\nList<String> list = new ArrayList<>();\nlist.add(\"a\"); list.get(0); list.remove(0);\nlist.contains(\"a\"); list.size();\n\n// Set\nSet<String> set = new HashSet<>();\nset.add(\"a\"); set.contains(\"a\"); set.remove(\"a\");\n\n// Map\nMap<String, Integer> map = new HashMap<>();\nmap.put(\"apple\", 1);\nmap.get(\"apple\");  // 返回1\nmap.getOrDefault(\"banana\", 0);  // key不存在返回默认值\nmap.containsKey(\"apple\");\nmap.remove(\"apple\");\n\n// 遍历Map\nfor (Map.Entry<String, Integer> entry : map.entrySet()) {\n    System.out.println(entry.getKey() + \": \" + entry.getValue());\n}\n```\n\n### 选型指南\n\n| 场景 | 推荐 |\n|------|------|\n| 频繁随机访问 | ArrayList |\n| 频繁增删头部 | LinkedList |\n| 去重 | HashSet |\n| 排序+去重 | TreeSet |\n| 键值对存储 | HashMap |\n\n### ⚠️ 常见误区\n1. `HashSet`依赖`equals()`和`hashCode()`方法，自定义对象必须同时重写\n2. 遍历时删除元素要用Iterator的`remove()`，否则ConcurrentModificationException\n3. `HashMap`线程不安全，并发场景用`ConcurrentHashMap`' WHERE id = 4;

UPDATE knowledge_points SET learning_content = '## 多线程编程\n\n多线程允许程序同时执行多个任务，提高CPU利用率。\n\n### 创建线程的三种方式\n\n```java\n// 方式1：继承Thread\nclass MyThread extends Thread {\n    public void run() { System.out.println(\"Thread running\"); }\n}\nnew MyThread().start();\n\n// 方式2：实现Runnable（推荐）\nclass MyTask implements Runnable {\n    public void run() { System.out.println(\"Task running\"); }\n}\nnew Thread(new MyTask()).start();\n\n// 方式3：实现Callable（有返回值）\nclass MyCallable implements Callable<String> {\n    public String call() { return \"result\"; }\n}\nFutureTask<String> ft = new FutureTask<>(new MyCallable());\nnew Thread(ft).start();\nString result = ft.get();  // 阻塞等待结果\n```\n\n### 线程同步\n\n```java\n// synchronized关键字\npublic synchronized void add() { count++; }\n\n// synchronized代码块（更细粒度）\nsynchronized (lock) {\n    // 临界区代码\n}\n\n// Lock接口（更灵活）\nLock lock = new ReentrantLock();\nlock.lock();\ntry {\n    // 临界区代码\n} finally {\n    lock.unlock();  // 必须在finally中释放\n}\n```\n\n### 线程池 (ExecutorService)\n\n```java\nExecutorService pool = Executors.newFixedThreadPool(5);\npool.submit(() -> System.out.println(\"Task\"));\npool.shutdown();  // 不再接受新任务\n```\n\n### ⚠️ 常见误区\n1. `run()` 不会启动新线程，`start()` 才会\n2. `wait()`/`notify()` 必须在synchronized块中调用\n3. `Thread.stop()` 已废弃（不安全），用interrupt()优雅终止\n4. 线程池用完要shutdown，否则程序不会退出\n5. `SimpleDateFormat` 线程不安全，用 `DateTimeFormatter`' WHERE id = 5;

UPDATE knowledge_points SET learning_content = '## JDBC数据库连接\n\nJDBC (Java Database Connectivity) 是Java连接数据库的标准API。\n\n### 基本步骤\n\n```java\n// 1. 加载驱动（JDBC4+自动加载，可省略）\nClass.forName(\"com.mysql.cj.jdbc.Driver\");\n\n// 2. 建立连接\nConnection conn = DriverManager.getConnection(\n    \"jdbc:mysql://localhost:3306/test?serverTimezone=UTC\",\n    \"root\", \"password\"\n);\n\n// 3. 创建Statement\nPreparedStatement ps = conn.prepareStatement(\"SELECT * FROM users WHERE id = ?\");\nps.setInt(1, 1);\n\n// 4. 执行查询\nResultSet rs = ps.executeQuery();\nwhile (rs.next()) {\n    System.out.println(rs.getString(\"name\"));\n}\n\n// 5. 释放资源（倒序关闭）\nrs.close();\nps.close();\nconn.close();\n```\n\n### Statement vs PreparedStatement\n\n- **Statement**：拼接SQL，有SQL注入风险\n- **PreparedStatement**：预编译SQL，防注入，性能更好\n\n```java\n// ❌ 危险：SQL注入\nString sql = \"SELECT * FROM users WHERE name = ''\" + userName + \"''\";\n\n// ✅ 安全：参数化查询\nPreparedStatement ps = conn.prepareStatement(\n    \"SELECT * FROM users WHERE name = ?\");\nps.setString(1, userName);\n```\n\n### 事务管理\n\n```java\nconn.setAutoCommit(false);  // 关闭自动提交\ntry {\n    // 执行多条SQL\n    conn.commit();\n} catch (Exception e) {\n    conn.rollback();\n}\n```\n\n### 连接池\n\n常用连接池：HikariCP、Druid、C3P0（Spring Boot默认HikariCP）。\n\n### ⚠️ 常见误区\n1. 忘关连接导致连接池耗尽\n2. SQL拼接引发SQL注入\n3. 大数据量查询不用分页，导致OOM' WHERE id = 6;

UPDATE knowledge_points SET learning_content = '## Spring框架基础\n\nSpring是Java最流行的企业级应用框架，核心是IoC容器和AOP。\n\n### IoC (控制反转)\n\n对象创建和依赖关系不再由程序员控制，而是交给Spring容器管理。\n\n```java\n// 传统方式：自己new\nUserService service = new UserService(new UserDao());\n\n// Spring IoC：容器注入\n@Autowired\nprivate UserService service;  // 容器自动注入\n```\n\n### DI (依赖注入) 三种方式\n\n```java\n// 1. 构造器注入（推荐）\n@Service\npublic class UserService {\n    private final UserDao userDao;\n    public UserService(UserDao userDao) {\n        this.userDao = userDao;\n    }\n}\n\n// 2. Setter注入\n@Autowired\npublic void setUserDao(UserDao userDao) { this.userDao = userDao; }\n\n// 3. 字段注入（不推荐，测试困难）\n@Autowired\nprivate UserDao userDao;\n```\n\n### Spring Boot自动配置\n\n`@SpringBootApplication` 包含：\n- `@Configuration`：标记配置类\n- `@EnableAutoConfiguration`：根据依赖自动配置\n- `@ComponentScan`：扫描@Component等注解\n\n### AOP (面向切面编程)\n\n将横切关注点（日志、事务、安全）与业务逻辑分离。\n\n```java\n@Aspect\n@Component\npublic class LogAspect {\n    @Before(\"execution(* com.example.service.*.*(..))\") \n    public void before(JoinPoint jp) {\n        System.out.println(\"调用方法: \" + jp.getSignature().getName());\n    }\n}\n```\n\n### Spring MVC请求流程\n\n```\nRequest → DispatcherServlet → HandlerMapping → Controller\n                                                    ↓\nResponse ← ViewResolver ← ModelAndView ← 业务处理\n```\n\n### ⚠️ 常见误区\n1. `@Autowired`字段注入导致循环依赖难发现\n2. AOP切面只对Spring管理的Bean生效\n3. `@Transactional` 只有在public方法上才生效（proxy模式）\n4. 同一个类中方法互调，事务不生效（绕过代理）' WHERE id = 7;

UPDATE knowledge_points SET learning_content = '## 数组与链表\n\n数组和链表是最基础的两种线性数据结构。\n\n### 数组 (Array)\n\n**特点**：连续内存空间、固定大小、随机访问O(1)\n\n```\n索引:  0   1   2   3   4\n值:   [10, 20, 30, 40, 50]\n地址: 100 104 108 112 116 (假设int占4字节)\n```\n\n**时间复杂度**：\n- 访问：O(1) — 直接通过索引\n- 插入/删除（末尾）：O(1)\n- 插入/删除（中间）：O(n) — 需要移动元素\n- 查找：O(n) — 遍历\n\n### 链表 (Linked List)\n\n**特点**：非连续内存、动态大小、节点间通过指针连接\n\n```\n单向链表: [data|next] → [data|next] → [data|next] → null\n双向链表: null ← [prev|data|next] ⇄ [prev|data|next] ⇄ [prev|data|next] → null\n```\n\n**时间复杂度**：\n- 访问：O(n) — 需要遍历\n- 插入/删除（头部）：O(1)\n- 插入/删除（中间）：O(n) — 先找到位置\n- 查找：O(n)\n\n### 对比\n\n| 操作 | 数组 | 链表 |\n|------|------|------|\n| 随机访问 | O(1) | O(n) |\n| 头部插入 | O(n) | O(1) |\n| 尾部插入 | O(1) | O(1)/O(n)* |\n| 内存占用 | 连续，可能有浪费 | 每节点多存指针 |\n\n*单向链表O(n)，双向+tail指针O(1)\n\n### ⚠️ 常见误区\n1. 数组越界：`arr[arr.length]` 抛出 ArrayIndexOutOfBounds\n2. 链表操作时忘更新prev/next导致断链\n3. 删除链表节点后内存泄漏（C/C++），Java中GC自动回收' WHERE id = 8;

UPDATE knowledge_points SET learning_content = '## 栈与队列\n\n栈和队列是受限的线性结构，操作分别在特定端进行。\n\n### 栈 (Stack)\n\nLIFO（后进先出），像一摞盘子。\n\n```\n操作：push(1), push(2), push(3), pop()\n\n    ↓ push    ↑ pop\n    | 3 | ← 栈顶\n    | 2 |\n    | 1 | ← 栈底\n```\n\n**核心操作**：\n- `push(x)`：入栈，O(1)\n- `pop()`：出栈，O(1)\n- `peek()`：查看栈顶，不出栈，O(1)\n- `isEmpty()`：判空\n\n**应用场景**：\n- 函数调用栈\n- 括号匹配：`{[()]}`\n- 撤销操作（Undo）\n- 表达式求值（后缀表达式）\n\n### 队列 (Queue)\n\nFIFO（先进先出），像排队。\n\n```\n出队 ← [ A | B | C | D ] ← 入队\n     队头               队尾\n```\n\n**核心操作**：\n- `enqueue(x)`：入队，O(1)\n- `dequeue()`：出队，O(1)\n- `front()`：查看队头，不出队\n- `isEmpty()`\n\n**变种**：\n- **循环队列**：数组实现，头尾指针循环使用空间\n- **双端队列（Deque）**：两端都能进出\n- **优先队列（PriorityQueue）**：每次出队优先级最高的元素\n\n### ⚠️ 常见误区\n1. 普通数组实现队列时\"假溢出\"问题（用循环队列解决）\n2. Java中Stack类继承Vector（已过时），建议用LinkedList或ArrayDeque\n3. 链表实现队列时，忘更新head/tail指针' WHERE id = 9;

UPDATE knowledge_points SET learning_content = '## 树与二叉树\n\n树是一种非线性层次结构。二叉树每个节点最多有两个子节点。\n\n### 基本概念\n\n- **根节点**（root）：树的起点\n- **叶子节点**（leaf）：没有子节点的节点\n- **深度/高度**：从根到最远叶子的边数\n- **满二叉树**：所有层都填满\n- **完全二叉树**：除最后一层外都填满，最后一层从左到右\n\n### 二叉树遍历\n\n```\n       A\n     /   \\\n    B     C\n   / \\   / \\\n  D   E F   G\n\n前序（根左右）：A B D E C F G\n中序（左根右）：D B E A F C G\n后序（左右根）：D E B F G C A\n层序（BFS）：A B C D E F G\n```\n\n```java\n// 前序遍历递归实现\nvoid preorder(TreeNode root) {\n    if (root == null) return;\n    System.out.print(root.val);\n    preorder(root.left);\n    preorder(root.right);\n}\n```\n\n### 二叉搜索树 (BST)\n\n**性质**：左子树所有节点 < 根 < 右子树所有节点\n\n- 查找/插入/删除：平均O(log n)，最坏O(n)（退化为链表）\n- 中序遍历BST得到有序序列\n\n### 平衡二叉树 (AVL)\n\n- 任意节点左右子树高度差不超过1\n- 插入/删除后通过旋转恢复平衡\n\n### 堆 (Heap)\n\n- **最小堆**：父节点 ≤ 子节点\n- **最大堆**：父节点 ≥ 子节点\n- 用数组存储，`left(i) = 2i+1, right(i) = 2i+2`\n- 插入/删除：O(log n)，取最值：O(1)\n\n### ⚠️ 常见误区\n1. BST删除节点有3种情况（叶子/单子/双子）\n2. 堆排序不稳定\n3. 完全二叉树的高度严格为⌊log₂n⌋\n4. Huffman树的WPL是最小的带权路径和' WHERE id = 10;

UPDATE knowledge_points SET learning_content = '## 排序算法\n\n排序是最基本的算法操作，理解每种排序的思想和复杂度很重要。\n\n### 排序对比表\n\n| 算法 | 平均时间 | 最坏时间 | 空间 | 稳定性 |\n|------|----------|----------|------|--------|\n| 冒泡 | O(n²) | O(n²) | O(1) | 稳定 |\n| 选择 | O(n²) | O(n²) | O(1) | 不稳定 |\n| 插入 | O(n²) | O(n²) | O(1) | 稳定 |\n| 希尔 | O(n^1.3) | O(n²) | O(1) | 不稳定 |\n| 归并 | O(nlogn) | O(nlogn) | O(n) | 稳定 |\n| 快速 | O(nlogn) | O(n²) | O(logn) | 不稳定 |\n| 堆 | O(nlogn) | O(nlogn) | O(1) | 不稳定 |\n\n### 快速排序思想\n\n1. 选基准（pivot）\n2. 分区（partition）：小于pivot的放左边，大于的放右边\n3. 递归排序左右两部分\n\n```java\nvoid quickSort(int[] arr, int low, int high) {\n    if (low >= high) return;\n    int pivot = partition(arr, low, high);\n    quickSort(arr, low, pivot - 1);\n    quickSort(arr, pivot + 1, high);\n}\n```\n\n### 归并排序思想\n\n1. 递归将数组分成两半\n2. 合并（merge）两个有序子数组\n\n### 选型建议\n\n- 数据量小（< 50）：插入排序\n- 需要稳定：归并排序\n- 通用场景：快速排序（实际中最快）\n- 外部排序：归并排序\n- 取Top K：堆排序/快排partition\n\n### ⚠️ 常见误区\n1. 快排最坏O(n²)发生在数组已有序且pivot选最左时（随机pivot避免）\n2. 基数排序不是比较排序，只能排整数\n3. \"稳定\"指相等元素的相对顺序不变' WHERE id = 11;

UPDATE knowledge_points SET learning_content = '## 图论基础\n\n图由顶点(Vertex)和边(Edge)组成。G = (V, E)\n\n### 图的分类\n\n- **有向图/无向图**：边是否有方向\n- **有权图**：边带权值\n- **连通图**：任意两点可达\n- **完全图**：每对顶点都有边\n\n### 存储方式\n\n**邻接矩阵**：`graph[i][j] = 1`表示i→j有边\n- 优点：O(1)判断边是否存在\n- 缺点：O(V²)空间，稀疏图浪费\n\n**邻接表**：每个顶点存一个邻居列表\n- 优点：O(V+E)空间\n- 缺点：判断边是否存在O(degree)\n\n### DFS (深度优先搜索)\n\n```\n  1 → 2 → 4 (回溯)\n  ↓\n  3 → 5\n\nDFS: 1 → 2 → 4 → 3 → 5\n```\n\n用栈（递归/手动栈）实现，常用于连通性判断、拓扑排序、找环。\n\n### BFS (广度优先搜索)\n\n```\n层级: 1\n     / \\\n    2   3\n   /     \\\n  4       5\n\nBFS: 1 → 2 → 3 → 4 → 5\n```\n\n用队列实现，常用于最短路径（无权图）、层次遍历。\n\n### 最短路径\n\n- **Dijkstra**：单源、非负权、贪心、O(E log V)\n- **Floyd-Warshall**：多源、DP、O(V³)\n- **Bellman-Ford**：单源、可负权（不能有负环）、O(VE)\n\n### 最小生成树\n\n- **Prim**：选点、适合稠密图\n- **Kruskal**：选边+并查集、适合稀疏图\n\n### ⚠️ 常见误区\n1. Dijkstra不能处理负权边（会错误标记已确定最短路）\n2. BFS/DFS不记录visited会死循环\n3. 邻接矩阵初始化为∞而非0表示无边' WHERE id = 12;

UPDATE knowledge_points SET learning_content = '## 动态规划\n\n动态规划(DP)通过将问题分解为重叠子问题来优化计算。\n\n### 核心思想\n\n1. **最优子结构**：问题的最优解包含子问题的最优解\n2. **重叠子问题**：子问题被重复计算（区别于分治）\n3. **状态转移方程**：定义状态及状态间的递推关系\n\n### DP vs 分治 vs 贪心\n\n| 方法 | 子问题关系 | 记录中间结果 |\n|------|-----------|-------------|\n| 分治 | 独立 | 否 |\n| 动态规划 | 重叠 | 是（记忆化/DP表） |\n| 贪心 | 每次选最优 | 否 |\n\n### 经典问题\n\n**1. 0-1背包**\n\n`dp[i][w]`：前i件物品，容量w，最大价值\n```\nif weight[i] > w: dp[i][w] = dp[i-1][w]\nelse: dp[i][w] = max(dp[i-1][w], dp[i-1][w-weight[i]] + value[i])\n```\n\n**2. 最长公共子序列 (LCS)**\n\n`dp[i][j]`：x[0..i]和y[0..j]的LCS长度\n```\nif x[i] == y[j]: dp[i][j] = dp[i-1][j-1] + 1\nelse: dp[i][j] = max(dp[i-1][j], dp[i][j-1])\n```\n\n**3. 编辑距离 (Edit Distance)**\n\n`dp[i][j]`：将x[0..i]转换为y[0..j]的最小操作数\n\n### 解题步骤\n\n1. 定义dp数组含义\n2. 写出状态转移方程\n3. 确定初始条件和边界\n4. 确定遍历顺序\n5. 举例验证\n\n### ⚠️ 常见误区\n1. 不是所有递推都是DP（斐波那契不算DP，只是递推）\n2. 状态定义不清晰导致转移方程错误\n3. 二维dp可优化为一维（注意遍历顺序）\n4. 贪心和DP的区别：贪心是DP的特殊情况，但贪心不保证全局最优' WHERE id = 13;

UPDATE knowledge_points SET learning_content = '## 贪心算法\n\n贪心算法每步选择当前看起来最好的方案，不求全局最优，只求当场最优。\n\n### 适用条件\n\n贪心算法正确需要满足贪心选择性质：局部最优选择能导致全局最优。\n\n### 经典问题\n\n**1. 活动安排（区间调度）**\n\nn个活动，每个有开始和结束时间，求最多能参加多少个。\n\n贪心策略：**按结束时间排序**，每次选最早结束且不冲突的活动。\n\n**为什么正确？**选最早结束的给后面留最多的时间。\n\n**2. 哈夫曼编码**\n\n用变长编码压缩数据，频率高的字符用短编码。\n\n贪心策略：每次选频率最小的两个节点合并。\n\n**3. 最小生成树**\n\n- **Kruskal**：每次选权值最小的边，不构成环。\n- **Prim**：每次选到当前生成树最近的顶点。\n\n**4. Dijkstra最短路**\n\n贪心：每次选距离最短且未处理的顶点。\n\n### 贪心 vs DP\n\n| | 贪心 | DP |\n|------|------|-----|\n| 选择 | 每步做一个不可撤销的选择 | 考虑所有可能，选最优 |\n| 效率 | 通常更快 | 通常更慢 |\n| 正确性 | 需要证明 | 保证最优 |\n\n**例子**：零钱兑换\n- 硬币面值 [1, 5, 10, 25] 找零36 → 贪心有效（25+10+1）\n- 硬币面值 [1, 3, 4] 找零6 → 贪心选4+1+1=3个，最优是3+3=2个！\n\n### ⚠️ 常见误区\n1. 贪心不总是正确，没有充分验证之前不要用\n2. 区间问题中按开始时间排序贪心是错误的\n3. 贪心算法通常需要排序预处理' WHERE id = 14;

UPDATE knowledge_points SET learning_content = '## Python基础语法\n\nPython是一种解释型、动态类型的语言，语法简洁优雅。\n\n### 变量与数据类型\n\n```python\n# 数字\nx = 42          # int\npi = 3.14       # float\nc = 3 + 4j      # complex\n\n# 字符串\nname = \"Python\"\nmulti = \"\"\"多行\n字符串\"\"\"\n\n# 布尔\nis_ok = True\nis_empty = False\n```\n\n### 列表/元组/字典/集合\n\n```python\n# 列表（可变）\nfruits = [\"apple\", \"banana\", \"orange\"]\nfruits.append(\"grape\")\nfruits[0]  # \"apple\"\nfruits[-1]  # 最后一个元素\nfruits[1:3]  # 切片：[\"banana\", \"orange\"]\n\n# 元组（不可变）\npoint = (3, 4)\nx, y = point  # 解包\n\n# 字典\nstudent = {\"name\": \"张三\", \"age\": 20}\nstudent[\"score\"] = 95\nstudent.get(\"grade\", \"N/A\")  # 安全访问\n\n# 集合\nunique = {1, 2, 3, 3}  # {1, 2, 3}\n```\n\n### 函数定义\n\n```python\ndef greet(name, greeting=\"Hello\"):\n    \"\"\"返回问候语\"\"\"\n    return f\"{greeting}, {name}!\"\n\ngreet(\"World\")  # \"Hello, World!\"\n\n# lambda表达式\nsquare = lambda x: x ** 2\n```\n\n### 文件IO\n\n```python\n# 读文件\nwith open(\"data.txt\", \"r\", encoding=\"utf-8\") as f:\n    content = f.read()\n\n# 写文件\nwith open(\"output.txt\", \"w\") as f:\n    f.write(\"Hello\")\n```\n\n### ⚠️ 常见误区\n1. 可变对象作为默认参数：`def f(lst=[])` 会在多次调用间共享\n2. `is` vs `==`：前者比较身份，后者比较值\n3. Python中缩进是语法，不是风格选择' WHERE id = 15;

UPDATE knowledge_points SET learning_content = '## NumPy数组操作\n\nNumPy是Python科学计算的基础库，高效的多维数组对象。\n\n### ndarray创建\n\n```python\nimport numpy as np\n\narr = np.array([1, 2, 3, 4, 5])\nzeros = np.zeros((3, 4))       # 3×4全0\nones = np.ones((2, 3))         # 2×3全1\narrange = np.arange(0, 10, 2)  # [0, 2, 4, 6, 8]\nlin = np.linspace(0, 1, 5)     # [0, 0.25, 0.5, 0.75, 1]\nrand = np.random.rand(3, 3)    # 3×3随机[0,1)\n```\n\n### 数组属性\n\n```python\narr.shape    # 形状 (行, 列)\narr.dtype    # 数据类型\narr.ndim     # 维度数\narr.size     # 元素总数\n```\n\n### 广播机制 (Broadcasting)\n\n不同形状的数组进行算术运算时的自动扩展规则：\n\n1. 从后向前比较shape\n2. 维度相等或为1即可广播\n\n```python\na = np.array([[1,2,3],[4,5,6]])  # shape (2, 3)\nb = np.array([10, 20, 30])       # shape (3,)\nc = a + b  # b被广播为(2, 3)：[[10,20,30],[10,20,30]]\n\n# 结果：[[11,22,33],[14,25,36]]\n```\n\n### 切片与索引\n\n```python\narr = np.array([[1,2,3],[4,5,6],[7,8,9]])\narr[0, 1]     # 第0行第1列 → 2\narr[:, 0]     # 第一列 → [1,4,7]\narr[1:, :2]   # 第1行开始，前2列 → [[4,5],[7,8]]\n\n# 布尔索引\narr[arr > 5]  # [6, 7, 8, 9]\n```\n\n### 常用运算\n\n```python\nnp.sum(arr, axis=0)    # 按列求和\nnp.mean(arr, axis=1)   # 按行求均值\nnp.dot(a, b)           # 矩阵乘法\narr.T                  # 转置\nnp.sort(arr)           # 排序\n```\n\n### ⚠️ 常见误区\n1. 切片返回视图（view），修改会影响原数组；用`.copy()`创建副本\n2. 广播规则：shape从右对齐比较\n3. `np.append`返回新数组，不修改原数组' WHERE id = 16;

UPDATE knowledge_points SET learning_content = '## Pandas数据处理\n\nPandas是数据分析的利器，提供了DataFrame和Series两种核心数据结构。\n\n### Series与DataFrame\n\n```python\nimport pandas as pd\n\n# Series：一维带标签数组\ns = pd.Series([10, 20, 30], index=[''a'', ''b'', ''c''])\ns[''a'']  # 10\n\n# DataFrame：二维表格\ndf = pd.DataFrame({\n    ''name'': [''张三'', ''李四'', ''王五''],\n    ''age'': [20, 22, 21],\n    ''score'': [85, 92, 78]\n})\n```\n\n### 数据读取与写入\n\n```python\ndf = pd.read_csv(''data.csv'', encoding=''utf-8'')\ndf = pd.read_excel(''data.xlsx'', sheet_name=''Sheet1'')\ndf.to_csv(''output.csv'', index=False)\ndf.to_excel(''output.xlsx'', index=False)\n```\n\n### 数据查看\n\n```python\ndf.head(5)        # 前5行\ndf.info()         # 列信息、数据类型\ndf.describe()     # 统计摘要\n```\n\n### 缺失值处理\n\n```python\ndf.isnull().sum()           # 统计缺失值\ndf.dropna()                 # 删除含缺失值的行\ndf.fillna(0)                # 用0填充\ndf.fillna(df.mean())        # 用均值填充\n```\n\n### 数据操作\n\n```python\n# 过滤\ndf[df[''score''] > 80]\n\n# 排序\ndf.sort_values(''score'', ascending=False)\n\n# groupby聚合\ndf.groupby(''department'')[''salary''].mean()\n\n# merge连接\npd.merge(df1, df2, on=''id'', how=''inner'')\n\n# 新增列\ndf[''grade''] = df[''score''].apply(lambda x: ''A'' if x >= 90 else ''B'')\n```\n\n### ⚠️ 常见误区\n1. `df.loc[]` 用标签索引（闭区间），`df.iloc[]` 用整数索引（半开区间）\n2. merge时注意重复列名（suffixes参数处理）\n3. 链式赋值可能产生SettingWithCopyWarning' WHERE id = 17;

UPDATE knowledge_points SET learning_content = '## Matplotlib可视化\n\nMatplotlib是Python最基础的数据可视化库。\n\n### 基本图表\n\n```python\nimport matplotlib.pyplot as plt\nimport numpy as np\n\nx = np.linspace(0, 10, 100)\ny1 = np.sin(x)\ny2 = np.cos(x)\n\n# 折线图\nplt.plot(x, y1, ''b-'', label=''sin(x)'')\nplt.plot(x, y2, ''r--'', label=''cos(x)'')\nplt.xlabel(''X轴'')\nplt.ylabel(''Y轴'')\nplt.title(''三角函数'')\nplt.legend()\nplt.grid(True, alpha=0.3)\nplt.show()\n```\n\n### 其他图表\n\n```python\n# 柱状图\nplt.bar(categories, values, color=''steelblue'')\n\n# 散点图\nplt.scatter(x, y, c=colors, s=sizes, alpha=0.6)\n\n# 饼图\nplt.pie(sizes, labels=labels, autopct=''%1.1f%%'')\n\n# 直方图\nplt.hist(data, bins=20, color=''skyblue'', edgecolor=''white'')\n```\n\n### 子图布局\n\n```python\nfig, axes = plt.subplots(2, 2, figsize=(10, 8))\naxes[0, 0].plot(x, y1)\naxes[0, 1].bar(cats, vals)\naxes[1, 0].scatter(x, y)\naxes[1, 1].hist(data)\nplt.tight_layout()\nplt.show()\n```\n\n### Seaborn增强\n\n```python\nimport seaborn as sns\nsns.set_theme(style=''darkgrid'')\nsns.boxplot(x=''category'', y=''value'', data=df)\nsns.heatmap(df.corr(), annot=True, cmap=''coolwarm'')\nsns.pairplot(df, hue=''target'')\n```\n\n### ⚠️ 常见误区\n1. 中文显示方块：需设置中文字体\n2. 保存图片在`plt.show()`之后会得到空白图（show()后清除了）\n3. 不调用`plt.tight_layout()`导致标签被裁剪' WHERE id = 18;

UPDATE knowledge_points SET learning_content = '## 机器学习基础\n\n机器学习让计算机从数据中学习规律，做出预测或决策。\n\n### 三大范式\n\n- **监督学习**（Supervised）：有标签数据，学习X→Y的映射\n  - 分类（Classification）：预测类别，如垃圾邮件检测\n  - 回归（Regression）：预测数值，如房价预测\n- **无监督学习**（Unsupervised）：无标签，发现数据中的模式\n  - 聚类（Clustering）：K-means、DBSCAN\n  - 降维（Dimensionality Reduction）：PCA\n- **强化学习**（Reinforcement Learning）：通过奖励信号学习策略\n\n### 训练流程\n\n```python\nfrom sklearn.model_selection import train_test_split\nfrom sklearn.linear_model import LogisticRegression\nfrom sklearn.metrics import accuracy_score, classification_report\n\n# 划分训练集/测试集（通常8:2或7:3）\nX_train, X_test, y_train, y_test = train_test_split(\n    X, y, test_size=0.2, random_state=42)\n\n# 训练\nmodel = LogisticRegression()\nmodel.fit(X_train, y_train)\n\n# 预测\ny_pred = model.predict(X_test)\n\n# 评估\naccuracy = accuracy_score(y_test, y_pred)\nprint(classification_report(y_test, y_pred))\n```\n\n### 常用算法\n\n| 算法 | 场景 | 特点 |\n|------|------|------|\n| 线性回归 | 回归 | 简单、可解释、假设线性关系 |\n| 逻辑回归 | 二分类 | 输出概率、可解释 |\n| KNN | 分类/回归 | 惰性学习、不需要训练 |\n| 决策树 | 分类/回归 | 可解释、容易过拟合 |\n| SVM | 分类 | 适合高维数据 |\n\n### 评估指标\n\n- **准确率**（Accuracy）：`(TP+TN)/(TP+TN+FP+FN)`\n- **精确率**（Precision）：`TP/(TP+FP)` — 判为正的里面多少是真\n- **召回率**（Recall）：`TP/(TP+FN)` — 真正的正例被找出了多少\n- **F1-Score**：精确率和召回率的调和平均\n\n### ⚠️ 常见误区\n1. 数据泄露（leakage）：测试集信息\"污染\"了训练\n2. 类别不平衡时准确率有欺骗性（99%正例，全猜正例=99%准确率但无用）\n3. 过拟合：训练集表现好但测试集差（解决：交叉验证、正则化、更多数据）\n4. 不做特征缩放导致SVM/KNN等距离型算法失效' WHERE id = 19;

UPDATE knowledge_points SET learning_content = '## 关系模型基础\n\n关系模型由Edgar Codd于1970年提出，是现代数据库的理论基础。\n\n### 核心概念\n\n- **关系（Relation）**：一张二维表\n- **元组（Tuple）**：表中的一行（记录）\n- **属性（Attribute）**：表中的一列（字段）\n- **域（Domain）**：属性的取值范围\n- **码（Key）**：\n  - **候选码**：能唯一标识一个元组的属性（组）\n  - **主码**（Primary Key）：被选中的候选码\n  - **外码**（Foreign Key）：引用另一关系的码\n\n### 关系代数运算\n\n| 运算 | 符号 | 说明 |\n|------|------|------|\n| 选择（Select） | σ | 选择满足条件的行 |\n| 投影（Project） | π | 选择需要的列 |\n| 连接（Join） | ⋈ | 按条件连接两个表 |\n| 并（Union） | ∪ | 合并两个结构相同的表 |\n| 交（Intersect） | ∩ | 取两个表的公共行 |\n| 差（Difference） | - | 在A中但不在B中的行 |\n| 笛卡尔积 | × | 所有可能的组合 |\n\n**SQL对应关系**：\n- `σ → WHERE`\n- `π → SELECT 列名`\n- `⋈ → JOIN ... ON`\n\n### 完整性约束\n\n1. **实体完整性**：主码不能为空\n2. **参照完整性**：外码必须引用存在的主码或为NULL\n3. **用户定义完整性**：业务规则（如年龄>0）\n\n### 数据独立性\n\n- **物理独立性**：修改存储结构不影响应用程序\n- **逻辑独立性**：修改表结构不影响其他表的使用\n\n### ⚠️ 常见误区\n1. 关系模型中的\"关系\"不是指表之间的关联，而是指表本身\n2. 笛卡尔积不加筛选条件会产生巨大结果集\n3. NULL参与运算结果都是NULL（用IS NULL判断，不能用=NULL）' WHERE id = 20;

UPDATE knowledge_points SET learning_content = '## SQL查询语言\n\nSQL (Structured Query Language) 是关系数据库的标准查询语言。\n\n### SELECT基本结构\n\n```sql\nSELECT [DISTINCT] 列名\nFROM 表名\n[JOIN 其他表 ON 条件]\nWHERE 过滤条件\nGROUP BY 分组列\nHAVING 分组后过滤\nORDER BY 排序列 [ASC|DESC]\nLIMIT 条数\n```\n\n### 条件筛选\n\n```sql\nWHERE age > 18 AND city = ''北京''\nWHERE name LIKE ''张%''       -- %匹配任意字符，_匹配单个字符\nWHERE id IN (1, 2, 3)\nWHERE age BETWEEN 18 AND 25\nWHERE email IS NULL\nWHERE EXISTS (子查询)\n```\n\n### 聚合函数\n\n```sql\nCOUNT(*)        -- 行数\nCOUNT(列名)     -- 非NULL行数\nSUM(列名)       -- 求和\nAVG(列名)       -- 平均值\nMAX(列名)       -- 最大值\nMIN(列名)       -- 最小值\n```\n\n### 多表连接\n\n```sql\n-- INNER JOIN：只返回匹配的行\nSELECT * FROM students s\nINNER JOIN courses c ON s.course_id = c.id\n\n-- LEFT JOIN：保留左表所有行，右表无匹配填充NULL\nSELECT * FROM students s\nLEFT JOIN courses c ON s.course_id = c.id\n\n-- 自连接：同一张表连接自己\nSELECT e1.name AS employee, e2.name AS manager\nFROM emp e1 LEFT JOIN emp e2 ON e1.manager_id = e2.id\n```\n\n### 子查询\n\n```sql\n-- WHERE子查询\nSELECT * FROM users WHERE salary > (SELECT AVG(salary) FROM users)\n\n-- FROM子查询（派生表）\nSELECT dept, avg_sal FROM\n(SELECT dept, AVG(salary) AS avg_sal FROM users GROUP BY dept) t\nWHERE avg_sal > 5000\n```\n\n### ⚠️ 常见误区\n1. WHERE不能过滤聚合结果，要用HAVING\n2. GROUP BY后SELECT中只能出现分组列和聚合函数\n3. JOIN不加ON条件变成笛卡尔积\n4. `= NULL` 是错的，要用 `IS NULL`' WHERE id = 21;

UPDATE knowledge_points SET learning_content = '## 索引与查询优化\n\n索引是提高数据库查询速度的数据结构，类似书的目录。\n\n### B+树索引\n\nMySQL InnoDB默认使用B+树索引：\n\n```\n         [30|60]\n        /   |   \\\n    [10|20] [40|50] [70|80]\n    /  |  \\\n (5)(15)(25)\n```\n\n- 所有叶子节点在同一层\n- 叶子节点之间有双向链表连接（支持范围查询）\n- 非叶子节点只存索引键，叶子节点存完整数据\n\n### 索引类型\n\n| 类型 | 说明 |\n|------|------|\n| 主键索引 | 自动创建，聚簇索引 |\n| 唯一索引 | 值唯一，可为NULL |\n| 普通索引 | 加速查询 |\n| 联合索引 | 多列索引，最左匹配 |\n| 覆盖索引 | 查询列全在索引中，不回表 |\n\n### 最左前缀原则\n\n联合索引 `(a, b, c)`：\n- `WHERE a=1` → 用索引 ✓\n- `WHERE a=1 AND b=2` → 用索引 ✓  \n- `WHERE b=2` → 不用索引 ✗\n- `WHERE a=1 AND c=3` → 只用a列 ✓\n\n### EXPLAIN执行计划\n\n```sql\nEXPLAIN SELECT * FROM users WHERE email = ''test@test.com''\n```\n\n关注字段：\n- **type**：访问类型（ALL全表<index<range<ref<const最优）\n- **key**：实际使用的索引\n- **rows**：预估扫描行数\n- **Extra**：Using index（覆盖索引）、Using filesort（需要额外排序）\n\n### 优化建议\n\n1. WHERE/JOIN/ORDER BY列建索引\n2. 避免在索引列上使用函数：`WHERE DATE(created) = ''2024-01-01''` 不走索引\n3. 避免前缀模糊：`LIKE ''%abc''` 不走索引\n4. 定期分析和重建索引\n\n### ⚠️ 常见误区\n1. 索引不是越多越好，每次INSERT/UPDATE都要维护索引\n2. 区分度低的列（如性别）建索引效果差\n3. 联合索引顺序很重要，区分度高的列放前面' WHERE id = 22;

UPDATE knowledge_points SET learning_content = '## 事务与并发控制\n\n事务是一组要么全部成功、要么全部失败的操作。\n\n### ACID特性\n\n- **原子性（Atomicity）**：事务是不可分割的最小单元，全部执行或全部不执行\n- **一致性（Consistency）**：事务前后数据保持一致性状态\n- **隔离性（Isolation）**：并发事务互不干扰\n- **持久性（Durability）**：已提交的事务永久保存\n\n### 并发问题\n\n| 问题 | 描述 |\n|------|------|\n| 脏读 | 读到其他事务未提交的修改 |\n| 不可重复读 | 同一事务两次读取结果不同（被其他事务UPDATE） |\n| 幻读 | 同一事务两次查询行数不同（被其他事务INSERT/DELETE） |\n\n### 四种隔离级别\n\n| 级别 | 脏读 | 不可重复读 | 幻读 |\n|------|------|-----------|------|\n| READ UNCOMMITTED | ✓ | ✓ | ✓ |\n| READ COMMITTED | ✗ | ✓ | ✓ |\n| REPEATABLE READ（MySQL默认） | ✗ | ✗ | ✓* |\n| SERIALIZABLE | ✗ | ✗ | ✗ |\n\n*InnoDB通过MVCC+间隙锁在RR级别解决了幻读\n\n### MVCC (多版本并发控制)\n\nInnoDB通过undo log保存数据的历史版本，实现非阻塞读：\n- 每个事务看到的是事务开始时的数据快照\n- 写操作不阻塞读，读操作不阻塞写\n- 通过隐藏列（DB_TRX_ID、DB_ROLL_PTR）实现\n\n### 锁机制\n\n- **共享锁（S锁）**：允许读，SELECT ... LOCK IN SHARE MODE\n- **排他锁（X锁）**：不允许读写，UPDATE/DELETE自动加\n- **间隙锁（Gap Lock）**：锁定索引记录之间的间隙，防幻读\n\n### ⚠️ 常见误区\n1. 事务不要过长，否则锁持有时间过长\n2. MySQL中RR隔离级别使用间隙锁可能导致死锁\n3. 不是所有存储引擎都支持事务（MyISAM不支持，InnoDB支持）' WHERE id = 23;

UPDATE knowledge_points SET learning_content = '## 数据库设计范式\n\n范式是数据库表结构设计的规范，目的在于减少数据冗余和异常。\n\n### 为什么需要范式化？\n\n未范式化的表存在以下问题（异常）：\n- **插入异常**：想录入一个新课程但还没有学生选课，无法插入\n- **删除异常**：删除最后一个学生时，课程信息也丢失了\n- **更新异常**：修改课程名称需要更新所有选了该课的学生行\n\n### 各范式定义\n\n**1NF（第一范式）**：列不可再分（原子性）\n\n❌ 违反1NF：\n```\n| 姓名 | 电话1     | 电话2     |\n```\n✅ 满足1NF：拆分到不同行或用JSON字段\n\n**2NF（第二范式）**：满足1NF + 非主属性完全依赖于候选码（消除部分依赖）\n\n也就是说，不能有\"只依赖主键一部分\"的列。\n\n**3NF（第三范式）**：满足2NF + 非主属性不传递依赖于候选码\n\n也就是说，非主键列之间不能有依赖关系。\n\n❌ 违反3NF：\n```\n| 学号 | 姓名 | 系编号 | 系名称 |\n                  ↑ 系名称依赖于系编号，而非直接依赖主键\n```\n\n**BCNF**：更严格的3NF，消除主属性对非主属性的依赖。\n\n### 反范式化\n\n实际生产环境中，为了查询性能有时会故意违反范式：\n- 冗余常用数据，避免JOIN\n- 存储计算好的汇总值\n- 典型场景：数据仓库、报表系统\n\n### 设计原则\n\n1. 先规范化到3NF\n2. 根据查询模式和性能需求做反范式化\n3. 保持数据一致性（通过触发器/程序逻辑维护冗余数据）\n\n### ⚠️ 常见误区\n1. 范式越高不一定越好（过度范式化导致查询要JOIN多张表）\n2. 不是每个表都要到3NF（日志表、配置表不一定要范式化）\n3. 范式化解决的是数据冗余，但不是性能问题的银弹' WHERE id = 24;

UPDATE knowledge_points SET learning_content = '## OSI七层模型\n\nOSI（开放系统互联）模型将网络通信分为7层，每层有明确的功能和协议。\n\n### 七层从下到上\n\n```\n应用层 (7)   ← HTTP, FTP, SMTP, DNS\n ↑\n表示层 (6)   ← 加密/解密, 压缩, 编码转换(UTF-8)\n ↑\n会话层 (5)   ← 建立/管理/终止会话\n ↑\n传输层 (4)   ← TCP, UDP（端口到端口）\n ↑\n网络层 (3)   ← IP, ICMP, 路由（主机到主机）\n ↑\n数据链路层(2) ← MAC地址, 交换机, 帧\n ↑\n物理层 (1)   ← 网线, 光纤, 无线电波, 比特流\n```\n\n### 各层功能详解\n\n| 层 | PDU（数据单元） | 地址 | 设备 |\n|------|----------------|------|------|\n| 传输层 | 段（Segment） | 端口号 | - |\n| 网络层 | 包（Packet） | IP地址 | 路由器 |\n| 数据链路层 | 帧（Frame） | MAC地址 | 交换机 |\n| 物理层 | 比特（Bit） | - | 集线器 |\n\n### 封装流程\n\n```\n发送方：应用数据 → TCP头+数据 → IP头+TCP头+数据 → 帧头+IP包+帧尾\n接收方：去帧头帧尾 → 去IP头 → 去TCP头 → 应用数据\n```\n\n### TCP/IP vs OSI\n\n| OSI (7层) | TCP/IP (4层) |\n|-----------|-------------|\n| 应用层+表示层+会话层 | 应用层 |\n| 传输层 | 传输层 |\n| 网络层 | 网络层 |\n| 数据链路层+物理层 | 网络接口层 |\n\nOSI是理论模型，TCP/IP是实际使用的协议栈。\n\n### ⚠️ 常见误区\n1. OSI是参考模型不是协议\n2. 交换机不读IP地址（工作在数据链路层，看MAC地址）\n3. 路由器不看端口号（工作在网络层，看IP地址）' WHERE id = 25;

UPDATE knowledge_points SET learning_content = '## TCP/IP协议栈\n\nTCP/IP是互联网的核心协议栈。\n\n### TCP三次握手\n\n```\nClient                    Server\n  |----SYN(seq=x)-------->|  (1) 客户端请求连接\n  |<---SYN+ACK(seq=y,ack=x+1)---|  (2) 服务端确认并请求\n  |----ACK(ack=y+1)------>|  (3) 客户端确认\n  |                        |\n 连接建立！                |\n```\n\n为什么是三次而不是两次？防止已失效的连接请求到达服务端，导致服务端建立无用连接。\n\n### TCP四次挥手\n\n```\nClient                    Server\n  |----FIN(seq=u)-------->|  (1) \"我没有数据要发了\"\n  |<---ACK(ack=u+1)------|  (2) \"知道了\"\n  |<---FIN(seq=v)--------|  (3) \"我也没有数据要发了\"\n  |----ACK(ack=v+1)------>|  (4) \"知道了\"\n  |                        |\n TIME_WAIT 2MSL后关闭     CLOSED\n```\n\nTIME_WAIT持续2MSL（约60秒），确保最后的ACK能到达服务器。\n\n### 流量控制与拥塞控制\n\n- **流量控制**：滑动窗口，接收方告诉发送方自己能收多少\n- **拥塞控制**：慢启动、拥塞避免、快重传、快恢复\n\n### IP地址\n\n- **IPv4**（32位）：`192.168.1.1`\n- **子网掩码**：`255.255.255.0` → `/24` → 256个地址\n- **CIDR（无类域间路由）**：`10.0.0.0/8`\n- **私有地址**：`10.x.x.x`、`172.16-31.x.x`、`192.168.x.x`\n\n### ⚠️ 常见误区\n1. 为什么挥手需要四次？因为TCP是全双工的，双方可以独立关闭发送方向\n2. TIME_WAIT过多会导致端口耗尽\n3. UDP不保证可靠性但速度更快，用于视频/游戏/DNS' WHERE id = 26;

UPDATE knowledge_points SET learning_content = '## HTTP协议\n\nHTTP（超文本传输协议）是Web的基础，基于请求-响应模型。\n\n### 请求格式\n\n```\nGET /api/users HTTP/1.1\nHost: example.com\nUser-Agent: Mozilla/5.0\nAccept: application/json\nAuthorization: Bearer token123\n```\n\n### 请求方法\n\n| 方法 | 含义 | 幂等 |\n|------|------|------|\n| GET | 获取资源 | 是 |\n| POST | 创建资源 | 否 |\n| PUT | 更新资源（全量） | 是 |\n| PATCH | 更新资源（部分） | 否 |\n| DELETE | 删除资源 | 是 |\n\n### 状态码\n\n| 范围 | 含义 | 常见 |\n|------|------|------|\n| 1xx | 信息 | 101 Switching Protocols |\n| 2xx | 成功 | 200 OK, 201 Created, 204 No Content |\n| 3xx | 重定向 | 301永久, 302临时, 304 Not Modified |\n| 4xx | 客户端错误 | 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 422 Unprocessable Entity |\n| 5xx | 服务端错误 | 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable |\n\n### HTTPS / TLS\n\nHTTPS = HTTP + TLS（传输层安全）：\n1. 客户端发起HTTPS请求\n2. 服务端返回数字证书（含公钥）\n3. 客户端验证证书\n4. 协商对称加密密钥\n5. 后续通信使用对称加密\n\n### Cookie / Session\n\n- **Cookie**：客户端存储（浏览器），自动随请求发送，有大小(4KB)和数量限制\n- **Session**：服务端存储，通过SessionID（通常存在Cookie中）关联\n- **Token（JWT）**：无状态认证，服务端不存储，适合分布式系统\n\n### ⚠️ 常见误区\n1. GET请求不应修改服务端数据（安全性约定，不是协议强制的）\n2. POST请求不是天生安全的（要用HTTPS保护）\n3. 状态码200不代表业务处理成功（业务错误也会返回200+error code）' WHERE id = 27;

UPDATE knowledge_points SET learning_content = '## DNS域名解析\n\nDNS（域名系统）将人类可读的域名转换为机器可读的IP地址。\n\n### 域名层级\n\n```\nwww.example.com.\n ↑    ↑      ↑  ↑\n |    |      |  根域（.）\n |    |      顶级域（TLD: com）\n |    二级域（example）\n 子域（www）\n```\n\n### 查询过程\n\n以访问 `www.example.com` 为例：\n\n1. 浏览器缓存 → 2. OS缓存（hosts文件） → 3. 本地DNS服务器\n4. 本地DNS → 根DNS服务器（.） → 返回com的NS\n5. 本地DNS → com顶级域服务器 → 返回example.com的NS\n6. 本地DNS → example.com权威服务器 → 返回www.example.com的IP\n7. 返回给浏览器，缓存结果\n\n- **递归查询**：DNS服务器替你一层层查到结果\n- **迭代查询**：DNS服务器告诉你\"问谁去\"\n\n### DNS记录类型\n\n| 类型 | 用途 | 示例 |\n|------|------|------|\n| A | 域名→IPv4 | example.com → 93.184.216.34 |\n| AAAA | 域名→IPv6 | example.com → 2606:2800:220:1:248:1893:25c8:1946 |\n| CNAME | 别名指向 | www.example.com → example.com |\n| MX | 邮件服务器 | example.com → mail.example.com (priority 10) |\n| NS | 权威DNS服务器 | example.com → ns1.example.com |\n| TXT | 文本记录 | 常用于域名验证、SPF |\n\n### CDN原理\n\nCDN通过DNS智能解析，将用户请求导向最近的缓存节点。\n\n### ⚠️ 常见误区\n1. DNS缓存导致修改记录后需要等待TTL过期\n2. CNAME不能用于裸域（根域）\n3. 域名解析不是即时的，全球DNS传播需要时间' WHERE id = 28;

UPDATE knowledge_points SET learning_content = '## 网络安全基础\n\n网络安全涉及保护信息的机密性、完整性和可用性。\n\n### 加密基础\n\n- **对称加密**：同一个密钥加解密\n  - 代表：AES（高级加密标准）、DES（已过时）\n  - 优点：速度快；缺点：密钥分发困难\n- **非对称加密**：公钥加密，私钥解密\n  - 代表：RSA、ECC（椭圆曲线）\n  - 优点：密钥分发安全；缺点：速度慢\n\n实际应用中常结合使用：用非对称加密传递对称密钥（HTTPS的TLS握手）。\n\n### 数字签名\n\n用发送方的私钥对消息摘要加密：\n1. 计算消息的哈希值\n2. 用私钥加密哈希 → 数字签名\n3. 接收方用公钥解密，对比哈希 → 验证身份和完整性\n\n### 数字证书\n\n由CA（证书颁发机构）签发，绑定身份和公钥。X.509格式。\n\n### 常见攻击与防御\n\n| 攻击 | 防御 |\n|------|------|\n| SQL注入 | 参数化查询(PreparedStatement) |\n| XSS跨站脚本 | HTML实体编码、CSP头 |\n| CSRF跨站请求伪造 | CSRF Token、SameSite Cookie |\n| DDoS | 流量清洗、CDN |\n| MITM中间人攻击 | HTTPS、证书验证 |\n\n### 防火墙\n\n- **包过滤防火墙**：检查IP头和TCP头\n- **状态检测防火墙**：维护连接状态表\n- **应用层防火墙（WAF）**：分析HTTP流量，防Web攻击\n\n### ⚠️ 常见误区\n1. HTTPS加密的是传输过程，不保护客户端或服务端本地的数据\n2. 加密算法本身安全，但实现和使用不当是主要漏洞来源\n3. \"通过隐藏实现安全\"（Security by Obscurity）不可靠\n4. 拥有HTTPS不等于网站绝对安全（其他漏洞如XSS依然存在）' WHERE id = 29;

-- ========== Learning Content for new KPs (30-53) ==========
UPDATE knowledge_points SET learning_content = '## JVM与内存模型\n\nJVM（Java虚拟机）是Java"一次编写，到处运行"的基石。理解JVM是高级Java开发的必备技能。\n\n### 运行时数据区\n\n```\nJVM内存结构：\n┌─────────────────┐\n│   方法区(Metaspace)  │ ← 类信息、常量、静态变量 (JDK8+ 元空间替代永久代)\n├─────────────────┤\n│      堆(Heap)       │ ← 对象实例、数组 (GC主要区域)\n├──────┬──────┤\n│ 虚拟机栈  │ 本地方法栈 │ ← 栈帧(局部变量表/操作数栈/返回地址)\n├──────┴──────┤\n│    程序计数器(PC)    │ ← 当前线程执行的字节码行号\n└─────────────────┘\n```\n\n- **堆**：所有线程共享，分新生代(Eden+S0+S1)和老年代\n- **栈**：线程私有，每个方法对应一个栈帧，方法结束自动释放\n- **方法区**：存储类元信息，JDK8+使用本地内存的Metaspace\n\n### 垃圾回收 (GC)\n\n**判断对象死亡**：\n1. 引用计数法（无法解决循环引用）\n2. 可达性分析（GC Roots出发，不可达则回收）\n\n**GC Roots包括**：栈中局部变量、静态变量、JNI引用等\n\n**回收算法**：\n- **标记-清除**：标记垃圾→清除，产生碎片\n- **复制算法**：新生代常用，Eden→Survivor，浪费空间\n- **标记-整理**：老年代常用，移动存活对象消除碎片\n- **分代收集**：新生代用复制，老年代用标记清除/整理\n\n**经典垃圾收集器**：\n- Serial/Serial Old：单线程，适合客户端\n- Parallel Scavenge/Parallel Old：吞吐量优先\n- CMS（Concurrent Mark Sweep）：低延迟，已废弃\n- G1（Garbage First）：JDK9+默认，兼顾吞吐量和延迟\n- ZGC/Shenandoah：超低延迟(<10ms停顿)\n\n### 类加载机制\n\n**双亲委派模型**：\n```\nBootstrap ClassLoader (加载rt.jar核心类)\n    ↑\nExtension ClassLoader (加载ext目录)\n    ↑\nApplication ClassLoader (加载classpath)\n    ↑\n自定义ClassLoader\n```\n\n**流程**：收到加载请求→先委派给父加载器→父加载器找不到→自己加载。\n目的：保证核心类的安全（如String类只能由Bootstrap加载）。\n\n### ⚠️ 常见误区\n1. `-Xms`和`-Xmx`不设置相同值会导致堆频繁扩缩容\n2. GC不是越频繁越好，FULL GC应尽量避免\n3. 对象不一定在堆中分配（逃逸分析→栈上分配/标量替换）' WHERE id = 30;

UPDATE knowledge_points SET learning_content = '## 设计模式\n\n设计模式是软件开发中常见问题的可复用解决方案。GoF（Gang of Four）总结了23种经典设计模式。\n\n### 六大设计原则 (SOLID)\n\n- **S** 单一职责：一个类只负责一件事\n- **O** 开闭原则：对扩展开放，对修改关闭\n- **L** 里氏替换：子类可以替换父类\n- **I** 接口隔离：不应强迫类实现不需要的接口\n- **D** 依赖倒置：依赖抽象而非具体实现\n\n### 创建型模式 (Creational)\n\n**单例模式（Singleton）**：确保类只有一个实例。\n\n```java\n// 双重检查锁（DCL）- 推荐写法\npublic class Singleton {\n    private static volatile Singleton instance;\n    private Singleton() {}\n    public static Singleton getInstance() {\n        if (instance == null) {\n            synchronized (Singleton.class) {\n                if (instance == null) {\n                    instance = new Singleton();\n                }\n            }\n        }\n        return instance;\n    }\n}\n```\n\n**工厂方法模式**：定义创建对象的接口，子类决定实例化哪个类。\n\n### 结构型模式 (Structural)\n\n**代理模式（Proxy）**：为对象提供替身，控制对该对象的访问。\n- Spring AOP基于动态代理实现\n- JDK动态代理（基于接口）vs CGLIB（基于继承）\n\n**装饰器模式（Decorator）**：动态给对象添加额外职责。\n- Java IO流（BufferedReader装饰Reader）\n\n### 行为型模式 (Behavioral)\n\n**观察者模式（Observer）**：一对多依赖，当对象状态改变时通知所有观察者。\n- Spring事件机制（ApplicationEvent/ApplicationListener）\n\n**策略模式（Strategy）**：定义算法族，可以互相替换。\n- `Comparator`接口、线程池的拒绝策略\n\n### Spring中的设计模式\n\n| 设计模式 | Spring中的应用 |\n|----------|---------------|\n| 单例 | Bean默认scope=singleton |\n| 工厂 | BeanFactory/ApplicationContext |\n| 代理 | AOP面向切面编程 |\n| 模板方法 | JdbcTemplate/RestTemplate |\n| 观察者 | ApplicationEvent事件机制 |\n\n### ⚠️ 常见误区\n1. 设计模式不是银弹，过度使用会让代码复杂化\n2. 单例模式的双重检查锁必须用volatile（禁止指令重排）\n3. 代理模式和装饰器模式的区别：前者控访问，后者加功能' WHERE id = 31;

UPDATE knowledge_points SET learning_content = '## Java 8+ 新特性\n\nJava 8是Java历史上最大的版本更新之一，引入了函数式编程范式。\n\n### Lambda表达式\n\n```java\n// 传统匿名内部类\nRunnable r1 = new Runnable() {\n    public void run() { System.out.println("Hello"); }\n};\n\n// Lambda（语法糖）\nRunnable r2 = () -> System.out.println("Hello");\n\n// 带参数\nComparator<String> c = (a, b) -> a.length() - b.length();\n```\n\n### 函数式接口\n\n只有一个抽象方法的接口，可用@FunctionalInterface标注。\n\n```java\n// 四大核心函数式接口\nPredicate<T>  // boolean test(T t)       用于判断\nConsumer<T>   // void accept(T t)        用于消费\nFunction<T,R> // R apply(T t)           用于转换\nSupplier<T>   // T get()                用于生产\n\n// 使用示例\nlist.stream()\n    .filter(s -> s.length() > 3)       // Predicate\n    .map(String::toUpperCase)          // Function\n    .forEach(System.out::println);     // Consumer\n```\n\n### Stream API\n\n流式处理集合数据，支持链式操作。\n\n```java\nList<Integer> result = list.stream()\n    .filter(x -> x > 10)        // 过滤\n    .map(x -> x * 2)            // 映射\n    .sorted()                   // 排序\n    .distinct()                 // 去重\n    .limit(5)                   // 截断\n    .collect(Collectors.toList()); // 收集\n\n// 聚合操作\nlong count = list.stream().count();\nint sum = list.stream().mapToInt(Integer::intValue).sum();\nOptional<Integer> max = list.stream().max(Integer::compareTo);\n```\n\n**惰性求值**：中间操作（filter/map/sorted）不立即执行，遇到终止操作（collect/forEach/count）才触发计算。\n\n### Optional类\n\n优雅处理null值，避免NullPointerException。\n\n```java\nOptional<String> opt = Optional.ofNullable(value);\nopt.map(String::trim)\n   .filter(s -> !s.isEmpty())\n   .ifPresent(System.out::println);\nString result = opt.orElse("default");\nString result2 = opt.orElseThrow(() -> new RuntimeException("值为空"));\n```\n\n### ⚠️ 常见误区\n1. Stream不能复用（用完就关闭，再操作抛IllegalStateException）\n2. Optional不要用作方法参数或字段（只用于返回值）\n3. Lambda中引用的外部变量必须是effectively final的' WHERE id = 32;

UPDATE knowledge_points SET learning_content = '## 反射与注解\n\n反射（Reflection）让Java程序在运行时检查和操作类、方法、字段。\n\n### Class类\n\n获取Class对象的三种方式：\n```java\nClass<?> c1 = String.class;              // 类字面量\nClass<?> c2 = "hello".getClass();        // 对象.getClass()\nClass<?> c3 = Class.forName("java.lang.String"); // 动态加载\n```\n\n### 反射操作\n\n```java\nClass<?> clz = Class.forName("com.example.User");\n\n// 创建实例\nObject obj = clz.getDeclaredConstructor().newInstance();\n\n// 获取字段\nField field = clz.getDeclaredField("name");\nfield.setAccessible(true);  // 突破私有权限\nString name = (String) field.get(obj);\nfield.set(obj, "newName");\n\n// 获取方法\nMethod method = clz.getDeclaredMethod("sayHello", String.class);\nmethod.setAccessible(true);\nmethod.invoke(obj, "World");\n```\n\n### 自定义注解\n\n```java\n// 定义注解\n@Target(ElementType.METHOD)  // 注解位置\n@Retention(RetentionPolicy.RUNTIME)  // 保留到运行时\npublic @interface Log {\n    String value() default "";\n}\n\n// 使用注解\n@Log("用户登录")\npublic void login() { ... }\n```\n\n### 动态代理\n\n**JDK动态代理**（基于接口）：\n```java\nInvocationHandler handler = (proxy, method, args) -> {\n    System.out.println("before: " + method.getName());\n    Object result = method.invoke(target, args);\n    System.out.println("after: " + method.getName());\n    return result;\n};\nMyInterface proxy = (MyInterface) Proxy.newProxyInstance(\n    target.getClass().getClassLoader(),\n    target.getClass().getInterfaces(),\n    handler\n);\n```\n\n**CGLIB**（基于继承，不需要接口）。Spring在目标类无接口时自动使用CGLIB。\n\n### ⚠️ 常见误区\n1. 反射性能差于直接调用（JIT优化后可接近）\n2. `setAccessible(true)`破坏封装，在JDK17+模块化系统中受限制\n3. `Class.forName()`会触发类初始化，`ClassLoader.loadClass()`不会' WHERE id = 33;

UPDATE knowledge_points SET learning_content = '## ORM与MyBatis\n\nORM（对象关系映射）在对象和数据库表之间建立映射关系。MyBatis是国内最流行的轻量级ORM框架。\n\n### ORM核心概念\n\n- 将Java对象的属性映射到数据库表的列\n- 自动生成SQL或半自动编写SQL\n- 管理对象的生命周期和缓存\n\n### MyBatis核心组件\n\n```java\n// 1. 读取配置\nInputStream in = Resources.getResourceAsStream("mybatis-config.xml");\nSqlSessionFactory factory = new SqlSessionFactoryBuilder().build(in);\n\n// 2. 获取SqlSession\nSqlSession session = factory.openSession();\n\n// 3. 获取Mapper接口\nUserMapper mapper = session.getMapper(UserMapper.class);\nUser user = mapper.findById(1L);\n\nsession.commit();\nsession.close();\n```\n\n### Mapper XML映射\n\n```xml\n<mapper namespace="com.example.mapper.UserMapper">\n    <resultMap id="userMap" type="User">\n        <id property="id" column="id"/>\n        <result property="userName" column="user_name"/>\n    </resultMap>\n\n    <select id="findById" resultMap="userMap">\n        SELECT * FROM users WHERE id = #{id}\n    </select>\n</mapper>\n```\n\n### 动态SQL\n\n```xml\n<select id="findByCondition" resultType="User">\n    SELECT * FROM users\n    <where>\n        <if test="name != null">AND name LIKE CONCAT(''%'', #{name}, ''%'')</if>\n        <if test="age != null">AND age = #{age}</if>\n    </where>\n</select>\n```\n\n- `#{param}`：预编译占位符（防SQL注入）\n- `${param}`：字符串拼接（有注入风险，仅用于动态表名等场景）\n\n### 缓存机制\n\n- **一级缓存（SqlSession级别）**：默认开启，同一个SqlSession内查询同一数据只查一次DB\n- **二级缓存（Mapper级别）**：跨SqlSession共享，需手动开启\n\n### ⚠️ 常见误区\n1. `#{ }`和`${ }`的区别 —— 前者安全，后者可能SQL注入\n2. 一级缓存在SqlSession关闭/更新操作后失效\n3. MyBatis不是完整的ORM（不像Hibernate自动建表），是SQL Mapping框架' WHERE id = 34;

UPDATE knowledge_points SET learning_content = '## 测试与构建工具\n\n单元测试和构建管理是软件工程的基础实践。\n\n### JUnit 5\n\n```java\nimport org.junit.jupiter.api.*;\n\nclass CalculatorTest {\n    private Calculator calc;\n\n    @BeforeEach  // 每个@Test前执行（替代JUnit4的@Before）\n    void setUp() { calc = new Calculator(); }\n\n    @Test\n    @DisplayName("加法测试")\n    void testAdd() {\n        assertEquals(4, calc.add(2, 2));\n    }\n\n    @Test\n    void testDivide_shouldThrow() {\n        assertThrows(ArithmeticException.class,\n            () -> calc.divide(1, 0));\n    }\n\n    @ParameterizedTest  // 参数化测试\n    @CsvSource({"1,1,2", "2,3,5", "-1,1,0"})\n    void testAddWithParams(int a, int b, int expected) {\n        assertEquals(expected, calc.add(a, b));\n    }\n}\n```\n\n### Mockito\n\n模拟依赖对象，隔离测试目标。\n\n```java\n@ExtendWith(MockitoExtension.class)\nclass UserServiceTest {\n    @Mock\n    private UserRepository userRepo;  // 模拟数据库访问\n\n    @InjectMocks\n    private UserService userService;   // 注入模拟对象\n\n    @Test\n    void testGetUser() {\n        when(userRepo.findById(1L)).thenReturn(Optional.of(new User("张三")));\n        User user = userService.getUser(1L);\n        assertEquals("张三", user.getName());\n        verify(userRepo, times(1)).findById(1L);  // 验证调用次数\n    }\n}\n```\n\n### Maven\n\n**核心概念**：\n- **GAV坐标**：groupId（组织）+ artifactId（项目）+ version（版本）\n- **生命周期（Lifecycle）**：clean → compile → test → package → verify → install → deploy\n- **依赖管理**：pom.xml中声明，自动传递依赖\n\n```xml\n<dependency>\n    <groupId>org.springframework.boot</groupId>\n    <artifactId>spring-boot-starter-web</artifactId>\n    <version>3.2.0</version>\n</dependency>\n```\n\n**依赖传递原则**：最短路径优先、最先声明优先。\n\n### ⚠️ 常见误区\n1. 测试不覆盖边界条件（0、null、空字符串、负数）\n2. `@Mock` vs `@Spy`：前者全方法模拟，后者部分模拟（保留原逻辑）\n3. Maven的scope=provided在编译有效但运行时不打包（如servlet-api）' WHERE id = 35;

UPDATE knowledge_points SET learning_content = '## 哈希表\n\n哈希表（Hash Table）是最重要的数据结构之一，提供O(1)平均时间的查找。\n\n### 核心原理\n\n哈希函数`hash(key)`将键映射到数组索引：\n```\nkey → hash(key) → index → value\n```\n\n### 哈希函数设计\n\n好的哈希函数：\n1. 计算快速\n2. 分布均匀（减少冲突）\n3. 相同输入→相同输出\n\n```java\n// JDK HashMap的哈希函数\nstatic final int hash(Object key) {\n    int h;\n    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);\n}\n// 高16位异或低16位，让高位也参与寻址\n```\n\n### 冲突解决方法\n\n**1. 拉链法（Chaining）**\n\n每个槽位放一个链表/红黑树。JDK HashMap使用此法：\n- 链表长度<8：链表\n- 链表长度≥8且数组长度≥64：转为红黑树（O(logn)）\n\n**2. 开放寻址法（Open Addressing）**\n\n冲突时按探测序列找下一个空位：\n- 线性探测：`(index + i) % size`（有聚集问题）\n- 二次探测：`(index + i²) % size`\n- 双重哈希：`(index + i * hash2(key)) % size`\n\n### 负载因子(Load Factor)\n\n`loadFactor = 元素数量 / 数组长度`\n\nJDK HashMap默认负载因子0.75：\n- 超过0.75 → 扩容为原来的2倍 → rehash所有元素\n- 扩容代价高，初始容量预估很重要\n\n### HashMap JDK源码要点\n\n- JDK7：数组+链表，头插法（可能导致死循环）\n- JDK8+：数组+链表+红黑树，尾插法\n- 容量始终是2的幂（`n & (n-1)`代替`%`运算）\n- 线程不安全（JDK7扩容死循环，JDK8数据覆盖）→ 用ConcurrentHashMap\n\n### ⚠️ 常见误区\n1. 作为key的对象必须重写`equals()`和`hashCode()`\n2. HashMap线程不安全，多线程用ConcurrentHashMap\n3. 不设初始容量会导致频繁扩容（预估大小/0.75+1）' WHERE id = 36;

UPDATE knowledge_points SET learning_content = '## 二分查找\n\n二分查找（Binary Search）在有序数组中每次排除一半数据，时间复杂度O(log n)。\n\n### 标准模板\n\n```java\n// 在有序数组nums中找target，返回索引，-1表示不存在\nint binarySearch(int[] nums, int target) {\n    int left = 0, right = nums.length - 1;\n    while (left <= right) {\n        int mid = left + (right - left) / 2;  // 防溢出\n        if (nums[mid] == target) return mid;\n        else if (nums[mid] < target) left = mid + 1;\n        else right = mid - 1;\n    }\n    return -1;\n}\n```\n\n### 变体\n\n**查找第一个等于target的位置**（左边界）：\n```java\nint left_bound(int[] nums, int target) {\n    int left = 0, right = nums.length - 1;\n    while (left <= right) {\n        int mid = left + (right - left) / 2;\n        if (nums[mid] < target) left = mid + 1;\n        else right = mid - 1;  // 等于时也向左缩小\n    }\n    if (left >= nums.length || nums[left] != target) return -1;\n    return left;\n}\n```\n\n**查找最后一个等于target的位置**（右边界）：\n```java\n// 类似，nums[mid] <= target时left = mid + 1，最后返回right\n```\n\n### 经典题目\n\n- **搜索旋转排序数组**：`[4,5,6,7,0,1,2]`找target，利用部分有序性\n- **寻找峰值**：`nums[mid] < nums[mid+1]` → 峰值在右边\n- **二分答案**：\"最小的最大值\"类型 → 二分枚举答案后验证\n\n### 边界条件注意\n\n- `left <= right` vs `left < right`\n- `mid`计算避免溢出：`left + (right - left) / 2`\n- 搜索区间包含`right`还是`right-1`\n\n### ⚠️ 常见误区\n1. 二分查找的前提是有序（或部分有序）\n2. 循环条件`left <= right`对应闭区间`[left, right]`\n3. 边界不熟时推荐背标准模板，不要现场推导' WHERE id = 37;

UPDATE knowledge_points SET learning_content = '## 字符串算法\n\n字符串处理是编程中的高频操作，面试常考模式匹配和前缀树。\n\n### KMP算法\n\n在O(n+m)时间内完成字符串匹配（模式串p在文本串s中查找）。\n\n**核心思想**：利用已匹配部分的信息，匹配失败时不回溯文本串指针。\n\n```java\n// 构建next数组：next[j] = p[0..j-1]最长相等前后缀长度\nint[] getNext(String p) {\n    int[] next = new int[p.length()];\n    int j = 0;  // 指向前缀末尾\n    for (int i = 1; i < p.length(); i++) {\n        while (j > 0 && p.charAt(i) != p.charAt(j))\n            j = next[j - 1];  // 回退\n        if (p.charAt(i) == p.charAt(j)) j++;\n        next[i] = j;\n    }\n    return next;\n}\n```\n\n### Trie（前缀树）\n\n高效存储和查找字符串集合，时间复杂度O(L)，L为字符串长度。\n\n```\n插入 "abc", "abd", "ac"：\n       root\n       /  \\\n      a    ...\n     /\n    b\n   / \\\n  c   d\n```\n\n**应用**：自动补全、拼写检查、IP路由（最长前缀匹配）\n\n### 最长回文子串\n\n- **中心扩展法**：枚举每个字符作为中心向两边扩展（O(n²)）\n- **Manacher算法**：O(n)，利用回文对称性预处理\n\n### 其他重要算法\n\n- **Rabin-Karp**：滚动哈希（O(n)平均），多模式匹配\n- **最长公共前缀(LCP)**：横向扫描/纵向扫描/二分\n\n### ⚠️ 常见误区\n1. KMP的next数组不同教材定义不同（有的减1，有的不减）\n2. Trie树空间消耗大（每个节点可能存26个孩子指针）\n3. Java中频繁字符串拼接用StringBuilder而非+（避免创建大量中间对象）' WHERE id = 38;

UPDATE knowledge_points SET learning_content = '## 递归与回溯\n\n递归是函数调用自身的编程技巧，回溯是穷举搜索的一种策略。\n\n### 递归三要素\n\n1. **终止条件（Base Case）**：防止无限递归\n2. **递推公式**：问题规模如何缩小\n3. **返回值**：子问题结果如何合并\n\n```java\n// 计算n的阶乘\nint factorial(int n) {\n    if (n <= 1) return 1;              // 终止条件\n    return n * factorial(n - 1);       // 递推公式\n}\n```\n\n### 回溯算法模板\n\n```java\nvoid backtrack(路径, 选择列表) {\n    if (满足终止条件) {\n        收集结果;\n        return;\n    }\n    for (选择 : 选择列表) {\n        做选择;\n        backtrack(路径, 新的选择列表);\n        撤销选择;  // 关键：恢复现场\n    }\n}\n```\n\n### 经典问题\n\n**全排列**：\n```java\nvoid backtrack(int[] nums, boolean[] used, List<Integer> path) {\n    if (path.size() == nums.length) {\n        result.add(new ArrayList<>(path)); return;\n    }\n    for (int i = 0; i < nums.length; i++) {\n        if (used[i]) continue;\n        path.add(nums[i]); used[i] = true;\n        backtrack(nums, used, path);   // 递归\n        path.remove(path.size()-1); used[i] = false;  // 回溯\n    }\n}\n```\n\n**N皇后**：每行每列每条对角线最多一个皇后\n**子集/组合**：注意start索引去重\n\n### 剪枝优化\n\n- **可行性剪枝**：当前路径已不可能产生合法解\n- **最优性剪枝**：当前路径已不可能优于已知最优解\n- **对称性剪枝**：对称解只搜一次\n\n### ⚠️ 常见误区\n1. 递归过深导致栈溢出（StackOverflow）- 考虑用迭代或尾递归\n2. 忘记回溯（撤销选择）导致结果错误\n3. 排列和组合的回溯区别：排列从头开始遍历，组合用start索引去重\n4. 存在重复元素时需要先排序再剪枝去重' WHERE id = 39;

UPDATE knowledge_points SET learning_content = '## Redis核心数据结构\n\nRedis是高性能键值存储数据库，常用作缓存、消息队列、分布式锁。\n\n### 5种基本数据类型\n\n**String（字符串）**\n```\nSET key value [EX seconds]\nGET key\nINCR key          -- 原子递增（计数器/限流）\nSETNX key value   -- 不存在才设置（分布式锁）\n```\n\n**Hash（哈希表）**\n```\nHSET user:1 name "张三" age 25\nHGET user:1 name\nHGETALL user:1    -- 存储对象信息\n```\n\n**List（列表）**：双向链表\n```\nLPUSH queue task  -- 左侧入队\nRPOP queue        -- 右侧出队 → 简单消息队列\nLRANGE key 0 -1   -- 获取所有元素\n```\n\n**Set（集合）**：无序不重复\n```\nSADD tags:article1 "Java" "Redis"\nSINTER tag:1 tag:2   -- 交集（共同标签）\nSUNION tag:1 tag:2   -- 并集\n```\n\n**ZSet（有序集合）**：按score排序\n```\nZADD leaderboard 95 "张三"\nZRANGE leaderboard 0 9 REV  -- Top10排行榜\n```\n\n### 缓存策略\n\n| 策略 | 读 | 写 | 适用场景 |\n|------|-----|-----|----------|\n| Cache-Aside | 先读缓存（miss读DB+写缓存） | 先写DB，再删缓存 | 最常用，读多写少 |\n| Read-Through | 缓存层自动读DB | - | 对应用透明 |\n| Write-Through | - | 同时写缓存和DB | 数据一致性高 |\n| Write-Behind | - | 先写缓存，异步写DB | 写密集场景 |\n\n### 过期删除策略\n\n- **惰性删除**：访问key时检查是否过期\n- **定期删除**：每秒10次，随机抽查一批key删除\n\n### 持久化\n\n- **RDB**：快照，某个时间点的全量数据\n- **AOF**：追加每条写命令，可每秒fsync\n- **混合持久化**（Redis 4.0+）：RDB + AOF增量\n\n### ⚠️ 常见误区\n1. Redis是单线程执行命令（6.0+ IO多线程，但命令执行仍是单线程）\n2. 缓存穿透（查不存在的数据→布隆过滤器）vs 缓存击穿（热点key过期→互斥锁）vs 缓存雪崩（大量key同时过期→过期时间加随机）\n3. ZSet跳表+哈希表组合实现，不是红黑树' WHERE id = 40;

UPDATE knowledge_points SET learning_content = '## MySQL存储引擎\n\nInnoDB是MySQL 5.5+的默认存储引擎，支持事务、行锁、MVCC。\n\n### InnoDB内存架构\n\n```\n内存：\nBuffer Pool（缓冲池）  ←→  Change Buffer（写缓冲）\n    ↓                          ↓\nAdaptive Hash Index        Log Buffer（日志缓冲）\n\n磁盘：\n数据文件(.ibd)  redo log  undo log  binlog\n```\n\n**Buffer Pool**：缓存数据页和索引页，默认128MB，占内存70-80%。\n**Change Buffer**：缓存对非唯一二级索引的修改，减少磁盘IO。\n\n### 三大日志\n\n**redo log（重做日志）**：\n- 记录\"数据页做了什么修改\"\n- WAL（Write-Ahead Log）先写日志再写磁盘\n- 保证崩溃恢复（crash-safe）\n- 循环写（固定大小，不归档）\n\n**undo log（回滚日志）**：\n- 记录\"修改前的数据\"\n- 实现MVCC（多版本并发控制）\n- 实现事务回滚\n\n**binlog（归档日志）**：\n- Server层日志，所有引擎通用\n- 用于主从复制和增量备份\n- 追加写（不固定大小）\n\n### MVCC原理\n\n每条记录有隐藏列：\n- `DB_TRX_ID`：最后修改的事务ID\n- `DB_ROLL_PTR`：回滚指针，指向undo log\n- `DB_ROW_ID`：无主键时自动生成\n\n**ReadView**：快照读时创建的视图，判断数据版本对当前事务是否可见。\n\n### InnoDB锁\n\n| 锁类型 | 范围 | 防什么 |\n|--------|------|--------|\n| Record Lock | 单行记录 | - |\n| Gap Lock | 索引间隙 | 防幻读(INSERT) |\n| Next-Key Lock | Record+Gap | 防幻读+不可重复读 |\n\n### ⚠️ 常见误区\n1. `SELECT COUNT(*)`在InnoDB中慢（全表扫描），MyISAM快（存了总行数）\n2. 非唯一二级索引包含主键列（避免回表：覆盖索引）\n3. RR隔离级别下，UPDATE的当前读可能导致数据不一致（用SELECT ... FOR UPDATE锁定）' WHERE id = 41;

UPDATE knowledge_points SET learning_content = '## RESTful API设计\n\nREST（Representational State Transfer）是目前最流行的API设计风格。\n\n### 核心原则\n\n1. **资源导向**：URL表示资源，名词复数形式\n2. **无状态**：每个请求包含所有需要的信息\n3. **统一接口**：HTTP方法定义操作语义\n\n### URL命名规范\n\n```\nGET    /api/users           # 获取用户列表\nGET    /api/users/123       # 获取单个用户\nPOST   /api/users           # 创建用户\nPUT    /api/users/123       # 全量更新用户\nPATCH  /api/users/123       # 部分更新用户\nDELETE /api/users/123       # 删除用户\n\n# 关联资源\nGET    /api/users/123/orders\nGET    /api/orders?userId=123&status=PAID\n```\n\n### HTTP方法语义\n\n| 方法 | 语义 | 幂等 | 安全 |\n|------|------|------|------|\n| GET | 获取 | ✓ | ✓ |\n| POST | 创建 | ✗ | ✗ |\n| PUT | 全量替换 | ✓ | ✗ |\n| PATCH | 部分更新 | ✗ | ✗ |\n| DELETE | 删除 | ✓ | ✗ |\n\n幂等：多次请求效果相同（GET获取多次不会改变资源状态）\n\n### 版本管理\n\n- URL版本：`/api/v1/users`（直观，最常用）\n- Header版本：`Accept: application/vnd.api.v1+json`\n- Query版本：`/api/users?version=1`\n\n### 分页设计\n\n```json\n{\n  "data": [...],\n  "meta": {\n    "page": 1,\n    "pageSize": 20,\n    "total": 156,\n    "totalPages": 8\n  }\n}\n```\n\n### ⚠️ 常见误区\n1. URL中不要用动词：`/getUser`、`/createOrder`（用HTTP方法代替）\n2. GET请求应有幂等性，不修改服务端状态\n3. 响应状态码使用2xx/4xx/5xx完整语义，不要所有错误返回200\n4. JSON key用camelCase或snake_case，保持统一' WHERE id = 42;

UPDATE knowledge_points SET learning_content = '## 认证与授权\n\n认证（Authentication）确认你是谁，授权（Authorization）确定你能做什么。\n\n### JWT (JSON Web Token)\n\n**结构**：`Header.Payload.Signature`\n\n```\neyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjEyM30.signature_here\n     Header              Payload              Signature\n```\n\n**Payload包含**：\n- 签发者(iss)、过期时间(exp)、用户ID(sub)等声明\n- 不存敏感信息（Payload是Base64编码，可解码）\n\n**验证流程**：\n1. 用户登录 → 服务端验证用户名密码 → 签发JWT\n2. 客户端存储JWT（localStorage/Cookie）\n3. 后续请求带`Authorization: Bearer <token>`\n4. 服务端验签 → 提取用户信息 → 处理请求\n\n### OAuth 2.0\n\n四种授权模式：\n\n| 模式 | 场景 |\n|------|------|\n| 授权码（Authorization Code） | 服务端应用，最安全，需要client_secret |\n| 密码（Password） | 信任的应用（如自家App） |\n| 客户端凭证（Client Credentials） | 服务间调用 |\n| 简化（Implicit） | 已废弃，改用PKCE |\n\n### RBAC权限模型\n\n```\n用户(User) → 角色(Role) → 权限(Permission)\n例: 张三 → ADMIN → [user:read, user:write, user:delete]\n```\n\n### SSO单点登录\n\n一次登录，访问多个系统：\n1. 用户访问A系统 → 重定向到SSO认证中心\n2. SSO验证 → 签发token\n3. 返回A系统 → 用户再访问B系统 → 已登录，直接通过\n\n### ⚠️ 常见误区\n1. JWT不加密（只签名），不要存密码等敏感信息\n2. JWT一旦签发无法撤销（除非加黑名单机制）\n3. 加密≠认证：HTTPS防窃听，但不能替代用户身份验证' WHERE id = 43;

UPDATE knowledge_points SET learning_content = '## 进程与线程\n\n进程和线程是操作系统中最基本的执行单位概念。\n\n### 进程（Process）\n\n进程是资源分配的基本单位，拥有独立的地址空间。\n\n**PCB（进程控制块）**包含：\n- 进程ID(PID)、进程状态、程序计数器(PC)\n- 打开文件列表、内存管理信息\n\n**五状态模型**：\n```\n创建 → 就绪 → 运行 → 终止\n        ↑      ↓\n        └── 阻塞 ←┘\n```\n\n**上下文切换开销**：保存当前进程状态 → 加载下一进程状态\n- 包括：寄存器、PC、栈指针、页表等\n- 是纯开销操作\n\n### 线程（Thread）\n\n线程是CPU调度的基本单位，同一进程的线程共享内存空间。\n\n**线程共享**：代码段、数据段、堆、打开文件\n**线程独享**：栈、寄存器、PC、线程局部存储\n\n### 进程间通信 (IPC)\n\n| 方式 | 说明 |\n|------|------|\n| 管道(Pipe) | 父子进程间单向数据流 |\n| 命名管道(FIFO) | 任意进程间 |\n| 共享内存 | 最快（直接映射到地址空间） |\n| 消息队列 | 异步、持久化消息 |\n| 信号(Signal) | 通知事件（SIGKILL/SIGTERM） |\n| Socket | 跨网络进程通信 |\n\n### 多线程 vs 多进程\n\n| 对比 | 多线程 | 多进程 |\n|------|--------|--------|\n| 创建开销 | 小 | 大 |\n| 通信 | 共享内存简单 | IPC复杂 |\n| 隔离性 | 差（一个线程崩溃可能影响整个进程） | 好 |\n| 适用 | IO密集型 | CPU密集型 |\n\n### ⚠️ 常见误区\n1. 线程越多不一定越快（上下文切换开销，CPU密集型=N核即可）\n2. 多线程不自动等于并行（单核CPU是并发，多核才是并行）\n3. 协程≠线程：协程是用户态调度，更轻量' WHERE id = 44;

UPDATE knowledge_points SET learning_content = '## 内存管理\n\n操作系统内存管理负责分配、回收和虚拟化物理内存。\n\n### 虚拟内存\n\n将逻辑地址（虚拟地址）映射到物理地址，让每个进程以为自己拥有独立的大内存。\n\n**MMU（内存管理单元）**：CPU芯片内，负责地址翻译。\n\n### 分页（Paging）\n\n将内存分为固定大小的页（Page，通常4KB）。\n\n```\n虚拟地址 = 页号 | 页内偏移\n物理地址 = 帧号 | 页内偏移\n\n页表：页号 → 帧号\n```\n\n**多级页表**：节省页表占用空间（32位→二级，64位→四级/五级）\n\n**TLB（快表）**：页表缓存，命中率99%+\n\n### 页面置换算法\n\n当内存满时，需要换出页面腾出空间：\n\n| 算法 | 策略 | 特点 |\n|------|------|------|\n| OPT（最优） | 淘汰将来最晚使用的页 | 理论最优，无法实现 |\n| LRU | 淘汰最久未使用的页 | 接近最优，实现开销大 |\n| Clock（NRU） | 循环扫描，淘汰访问位=0的页 | 实用近似LRU |\n| FIFO | 淘汰最先加载的页 | 简单但有Belady异常 |\n\n### 分段 vs 分页\n\n- **分段**：按逻辑单元划分（代码段/数据段/栈段），段长可变，有外部碎片\n- **分页**：固定大小，无外部碎片但有内部碎片（最后一页没填满）\n\n### ⚠️ 常见误区\n1. 虚拟内存≠磁盘交换空间（swap），虚拟内存是地址空间抽象\n2. 页表本身也占用内存（大页HugePage减少页表项）\n3. 颠簸（Thrashing）：频繁缺页中断，CPU大部分时间在换页 → 减少并发度' WHERE id = 45;

UPDATE knowledge_points SET learning_content = '## 死锁\n\n死锁是两个或多个进程无限期等待对方持有的资源。\n\n### 四个必要条件\n\n1. **互斥**：资源同时只能被一个进程使用\n2. **占有并等待**：持有资源的同时等待其他资源\n3. **不可剥夺**：资源不能被强制释放\n4. **循环等待**：进程间形成头尾相接的资源等待环\n\n四个条件缺一不可，破坏其中一个即可预防死锁。\n\n### 死锁预防\n\n- 破坏互斥：SPOOLing技术（打印机假脱机）\n- 破坏占有等待：一次性申请所有资源\n- 破坏不可剥夺：允许抢占资源\n- 破坏循环等待：资源编号，按顺序申请（如必须先申请锁A再申请锁B）\n\n### 死锁避免：银行家算法\n\n动态判断分配资源后系统是否处于安全状态：\n\n```\nAvailable：每种资源可用数量\nMax：每个进程最大需求量\nAllocation：已分配量\nNeed = Max - Allocation\n\n安全检查：是否存在一个安全序列，所有进程都能完成\n```\n\n### 死锁检测与恢复\n\n- **检测**：资源分配图 → 是否存在环\n- **恢复**：\n  - 终止进程（全部终止 / 逐个终止直到死锁解除）\n  - 抢占资源（从某些进程中回收资源）\n\n### Java中的死锁\n\n```java\n// 死锁示例：两把锁交叉持有\nThread A: synchronized(lock1) { synchronized(lock2) {} }\nThread B: synchronized(lock2) { synchronized(lock1) {} }\n```\n\n**排查**：`jstack PID` 查看线程栈，搜索\"deadlock\"\n\n### ⚠️ 常见误区\n1. 死锁不是只有两个线程才会发生\n2. 解决死锁最实用的方式是统一加锁顺序\n3. 银行家算法实际很少使用（需要预知最大需求，开销大）' WHERE id = 46;

UPDATE knowledge_points SET learning_content = '## IO模型\n\nIO模型决定了应用程序如何与内核交互读写数据。\n\n### 两阶段IO\n\n任何IO操作都分为两个阶段：\n1. **等待数据**（数据从设备到内核缓冲区）\n2. **复制数据**（从内核缓冲区到用户空间）\n\n### 五种IO模型\n\n**1. 阻塞IO（BIO）**\n```\n应用调read() → 阻塞等待数据就绪 → 数据复制 → 返回\n```\n特点：一个线程一个连接，线程阻塞期间不消耗CPU。\n\n**2. 非阻塞IO（NIO）**\n```\n应用调read() → 立即返回EWOULDBLOCK → 轮询 → 直到数据就绪 → 复制返回\n```\n特点：轮询浪费CPU，很少单独使用。\n\n**3. IO多路复用（IO Multiplexing）**\n```\nselect/poll/epoll → 阻塞等待 → 任意fd就绪 → 返回 → read数据\n```\n特点：一个线程管理多个连接，Reactor模式的基础。\n\n**4. 信号驱动IO**\n数据就绪时内核发SIGIO信号，不常用。\n\n**5. 异步IO（AIO）**\n```\n调aio_read → 立即返回 → 内核完成全部两个阶段 → 回调通知\n```\n特点：真正异步，但Linux AIO实现不完善（主要对磁盘IO有效）。\n\n### select / poll / epoll\n\n| | select | poll | epoll |\n|------|--------|------|-------|\n| 数据结构 | 位图(最大1024) | 链表(无上限) | 红黑树+就绪链表 |\n| 效率 | O(n)遍历所有fd | O(n)遍历 | O(1)获取就绪fd |\n| 触发方式 | 水平触发 | 水平触发 | 水平/边缘触发 |\n\n**epoll优势**：\n- 不随fd数量增加而线性下降（适合10K+连接）\n- 边缘触发(ET)减少重复通知\n\n### Netty与Reactor模式\n\nNetty基于NIO + epoll，使用Reactor模式：\n- Boss线程：接收连接\n- Worker线程：处理IO读写\n\n### ⚠️ 常见误区\n1. NIO的\"非阻塞\"是指read调用立即返回，不是不阻塞线程\n2. epoll的边缘触发(ET)要求必须一次性读完数据\n3. Java NIO不等于不阻塞（Selector.select()是阻塞的）' WHERE id = 47;

UPDATE knowledge_points SET learning_content = '## 常用命令\n\nLinux命令行是后端开发的必备技能。掌握以下命令可以处理90%的日常工作。\n\n### 文件操作\n\n```bash\nls -la          # 列出所有文件（含隐藏）\ncd /path        # 切换目录 (~=home, -=上次)\npwd             # 打印当前路径\ncp -r src dst   # 递归复制\nmv old new      # 移动/重命名\nrm -rf path     # 强制递归删除（慎用！）\nfind . -name "*.java"  # 按文件名查找\n```\n\n### 文本处理\n\n```bash\ncat file.txt           # 查看文件全部内容\ntail -f app.log        # 实时跟踪日志\nhead -n 10 file.txt    # 前10行\ngrep -r "ERROR" logs/  # 递归搜索\ngrep -c "pattern" file # 统计匹配行数\nawk ''{print $1, $3}''  # 打印第1列和第3列\nsed ''s/old/new/g'' file # 替换文本\n```\n\n### 进程管理\n\n```bash\nps aux                  # 查看所有进程\ntop / htop              # 实时进程监控\nkill -9 PID             # 强制终止\nkill -15 PID            # 优雅终止\nnohup java -jar app.jar &  # 后台运行，不受终端关闭影响\njobs / fg / bg          # 管理后台任务\n```\n\n### 网络工具\n\n```bash\nnetstat -tlnp           # 查看监听端口\nlsof -i :8080           # 查看占用8080端口的进程\ncurl -X GET http://localhost/api  # HTTP请求测试\nping host               # 连通性测试\ntelnet host port        # 端口通不通\n```\n\n### 管道与重定向\n\n```bash\n# 管道：前一个命令的输出作为后一个命令的输入\nps aux | grep java | wc -l\n\n# 重定向\nls > output.txt         # 覆盖写入\nls >> output.txt        # 追加写入\ncmd 2>&1                # 错误输出重定向到标准输出\ncmd > /dev/null 2>&1    # 丢弃所有输出\n```\n\n### ⚠️ 常见误区\n1. `rm -rf /` 会删掉整个系统（生产环境加--preserve-root也危险）\n2. `kill -9` 不给程序清理资源的机会，优先用`kill -15`\n3. `>` 会覆盖文件，用`>>`来追加' WHERE id = 48;

UPDATE knowledge_points SET learning_content = '## 文件权限\n\nLinux多用户系统通过权限模型控制文件和目录的访问。\n\n### rwx权限\n\n```bash\n$ ls -l file.txt\n-rwxr-xr-- 1 zhangsan dev 1024 Jul 20 10:00 file.txt\n│└┬┘└┬┘└┬┘\n│ │  │  └── 其他用户权限(r-- = 只读)\n│ │  └── 组权限(r-x = 读+执行)\n│ └── 所有者权限(rwx = 读+写+执行)\n└── 文件类型(-文件/d目录/l链接)\n```\n\n**权限含义**：\n- **文件**：r=可读内容，w=可修改，x=可执行\n- **目录**：r=可列出文件名，w=可创建/删除文件，x=可cd进入\n\n### chmod修改权限\n\n```bash\n# 符号模式\nchmod u+x file.sh      # 所有者加执行\nchmod g-w file.txt     # 组去写权限\nchmod o=r file.txt     # 其他人设为只读\nchmod a+x script.sh    # 所有人加执行\n\n# 数字模式(r=4, w=2, x=1)\nchmod 755 file.sh      # rwxr-xr-x\nchmod 644 file.txt     # rw-r--r--\nchmod 777 file         # 危险：所有人都能读写执行\n```\n\n### chown / chgrp\n\n```bash\nchown zhangsan file.txt              # 改所有者\nchown zhangsan:dev file.txt          # 同时改所有者和组\nchgrp dev file.txt                   # 只改组\n```\n\n### 特殊权限\n\n| 权限 | 数字 | 说明 |\n|------|------|------|\n| SUID | 4000 | 执行时以文件所有者权限运行（如passwd命令） |\n| SGID | 2000 | 执行时以文件组权限运行 |\n| Sticky Bit | 1000 | 只有文件所有者能删除（/tmp目录） |\n\n### umask\n\n默认权限掩码：创建文件时的默认权限 = 最大权限 - umask\n- 文件最大权限666（rw-rw-rw-），目录777（rwxrwxrwx）\n- umask默认022 → 文件默认644，目录默认755\n\n### ⚠️ 常见误区\n1. 目录要有x权限才能cd进去\n2. root用户不受任何权限限制\n3. 脚本文件需要同时有r和x权限才能执行' WHERE id = 49;

UPDATE knowledge_points SET learning_content = '## Shell脚本\n\nShell脚本将命令行操作自动化，提高工作效率。\n\n### 基本结构\n\n```bash\n#!/bin/bash\n# 这是一个注释\nset -e  # 任何命令失败立即退出\nset -u  # 使用未定义变量报错\n\nNAME=$1  # 第一个参数\n```\n\n### 变量\n\n```bash\nname="zhangsan"\necho "Hello, ${name}"     # 推荐加花括号\necho ''$name''              # 单引号不解析变量\n\n# 特殊变量\necho $0   # 脚本名\necho $1   # 第一个参数\necho $#   # 参数个数\necho $?   # 上一条命令退出码（0=成功）\necho $$   # 当前进程PID\n```\n\n### 条件判断\n\n```bash\nif [ "$name" = "zhangsan" ]; then\n    echo "yes"\nelif [ -f "$file" ]; then  # 文件是否存在\n    echo "file exists"\nelse\n    echo "no"\nfi\n\n# 数字比较：[ $a -gt $b ] (greater than)\n# 字符串比较：[ "$a" = "$b" ] 或 [ -z "$a" ] (为空)\n```\n\n### 循环\n\n```bash\nfor i in {1..10}; do\n    echo $i\ndone\n\nfor file in *.txt; do\n    echo "Processing $file"\ndone\n\nwhile read line; do\n    echo $line\ndone < data.txt\n```\n\n### 函数\n\n```bash\nsay_hello() {\n    local name=$1   # local限定作用域\n    echo "Hello, $name"\n}\n\nsay_hello "World"  # 调用函数\n```\n\n### crontab定时任务\n\n```bash\n# 格式：分 时 日 月 周 命令\n0 2 * * * /opt/backup.sh      # 每天凌晨2点执行\n*/5 * * * * /opt/monitor.sh   # 每5分钟执行\n```\n\n### ⚠️ 常见误区\n1. 变量赋值等号两边不能有空格（`name="a"` 正确，`name = "a"` 错误）\n2. `[ $a == $b ]` 需要变量加双引号防空格和空值：`[ "$a" == "$b" ]`\n3. 管道中前命令失败不会自动终止（`set -o pipefail` 解决）' WHERE id = 50;

UPDATE knowledge_points SET learning_content = '## 系统设计方法\n\n系统设计面试考察分析问题和设计大规模系统的能力。\n\n### 面试框架（4步法）\n\n**Step 1：澄清需求（3-5分钟）**\n- 功能需求：核心功能是什么？\n- 非功能需求：一致性/可用性/延迟要求？\n- 规模估算：DAU/QPS/存储量？\n\n**Step 2：高层设计（5-10分钟）**\n- 画出系统的主要组件\n- 确定数据流向\n- 选择架构模式\n\n**Step 3：深入设计（10-15分钟）**\n- 数据模型设计（表结构/索引）\n- API接口设计\n- 关键功能的技术方案\n- 扩展性考量（分库分表/缓存/异步）\n\n**Step 4：总结（2-3分钟）**\n- 识别系统瓶颈\n- 讨论可能的改进方向\n\n### 容量估算\n\n**常用数据**：\n- 单机QPS：Web服务~1000-10000、数据库~1000、Redis~10W\n- 网络带宽：千兆网卡~125MB/s\n- 存储：字符1B、数字4-8B、UUID约36B\n\n```\n例子：设计短链接系统\n- 日写入100万条\n- 平均QPS = 100万/86400 ≈ 12 QPS\n- 峰值QPS = 12 × 5 = 60 QPS\n- 5年存储 = 100万 × 365 × 5 × 1KB ≈ 1.8TB\n```\n\n### 数据模型选型\n\n| 场景 | 推荐 |\n|------|------|\n| 结构化+事务 | MySQL/PostgreSQL |\n| 大文本/日志 | Elasticsearch |\n| 缓存 | Redis |\n| 文件存储 | S3/OSS/MinIO |\n| 消息队列 | Kafka/RabbitMQ |\n\n### ⚠️ 常见误区\n1. 一开始就深入细节 → 先画全貌再深入\n2. 不考虑扩展性 → 单机存储有上限\n3. 不估算就假设系统能行 → 用数据说话\n4. 忽略边缘情况 → 失败重试/幂等/一致性' WHERE id = 51;

UPDATE knowledge_points SET learning_content = '## 常见架构模式\n\n软件架构模式是可复用的高层设计方案，不同场景选择不同模式。\n\n### 分层架构（Layered）\n\n最常见的后端架构模式：\n\n```\nController（接口层） → Service（业务层） → DAO（数据访问层）\n```\n\n优点：职责清晰，易于开发和测试。\n缺点：层与层之间耦合，修改一层可能影响其他层。\n\n### 微服务 vs 单体\n\n| 对比 | 单体架构 | 微服务 |\n|------|---------|--------|\n| 部署 | 一个包 | 多个独立服务 |\n| 通信 | 方法调用 | RPC/HTTP |\n| 数据库 | 共享 | 每个服务独立 |\n| 扩展 | 整体扩缩 | 按服务扩缩 |\n| 复杂度 | 低 | 高（分布式问题） |\n| 适合 | 小团队/早期项目 | 大团队/复杂业务 |\n\n**微服务拆分原则**：按业务域拆分（DDD限界上下文），不是按技术层拆分。\n\n### 事件驱动架构\n\n通过消息队列解耦生产者和消费者：\n\n```\n订单服务 → [消息队列/Kafka] → 库存服务\n                            → 通知服务\n                            → 数据分析\n```\n\n优点：解耦、削峰填谷、异步处理。\n缺点：消息顺序性、事务一致性复杂。\n\n### 缓存策略\n\n**多级缓存**：\n```\n浏览器缓存 → CDN → Nginx本地缓存 → Redis → 数据库\n```\n\n**缓存预热**：系统启动时预先加载热点数据。\n\n### 读写分离与分库分表\n\n**读写分离**：主库写 + 从库读，通过中间件路由（ShardingSphere/MyCat）\n**分库分表**：\n- 垂直拆分：按业务（用户库/订单库）\n- 水平拆分：按主键范围或哈希（单表数据量过大）\n\n### ⚠️ 常见误区\n1. 不要为了微服务而微服务（增加分布式事务、网络延迟等复杂度）\n2. 消息队列不保证消息不丢失（需ack+持久化+死信队列）\n3. 缓存不是越多越好（内存成本+一致性问题）' WHERE id = 52;

UPDATE knowledge_points SET learning_content = '## 分布式基础\n\n分布式系统是多台计算机通过网络协作完成共同任务的系统。\n\n### CAP定理\n\n分布式系统最多同时满足：\n- **C（Consistency）一致性**：所有节点同一时刻数据相同\n- **A（Availability）可用性**：每次请求都能得到非错误响应\n- **P（Partition Tolerance）分区容错性**：网络分区时系统仍能工作\n\n由于网络分区不可避免，通常是在CP和AP之间选择：\n- 银行转账 → CP（一致性优先）\n- 社交动态 → AP（可用性优先）\n\n### BASE理论\n\n对CAP的折中（AP的一种实现）：\n- **BA**（Basically Available）：基本可用\n- **S**（Soft State）：软状态，允许中间状态\n- **E**（Eventually Consistent）：最终一致性\n\n### 一致性哈希\n\n分布式系统经典负载均衡算法：\n\n```\n问题：节点数变化时如何最小化数据迁移？\n\n传统哈希：hash(key) % N → N变化，大部分数据需迁移\n一致性哈希：\n1. 哈希空间构成环 [0, 2^32-1]\n2. 节点映射到环上\n3. key映射到环上，顺时针找到第一个节点\n4. 节点增减只影响相邻节点\n\n虚拟节点：一个物理节点对应多个虚拟节点，使数据分布更均匀\n```\n\n### 分布式ID生成\n\n**雪花算法（Snowflake）**：\n```\n64位ID = 1位(未用) + 41位(毫秒) + 10位(机器) + 12位(序列号)\n```\n- 趋势递增、不依赖DB\n- 依赖系统时钟（时钟回拨需要处理）\n\n**号段模式**：从数据库批量获取ID号段（如每次取1000个），减少DB访问。\n\n### 分布式事务\n\n| 方案 | 说明 |\n|------|------|\n| 2PC | 两阶段提交，强一致但阻塞 |\n| TCC | Try-Confirm-Cancel，补偿型 |\n| Saga | 长事务拆分为多个本地事务+补偿 |\n| 本地消息表 | 通过本地DB保证消息+业务原子性 |\n\n### ⚠️ 常见误区\n1. CAP说的是网络分区故障时的取舍，不是日常运行都要二选一\n2. 分布式锁要考虑续期（redisson看门狗）、可重入、集群故障\n3. 分布式事务尽量避免，优先设计成可幂等的最终一致性方案' WHERE id = 53;

-- ========== Prerequisites ==========
INSERT IGNORE INTO kp_prerequisites (kp_id, prerequisite_kp_id) VALUES
-- Java
(2, 1),   -- OOP需要基础语法
(3, 1),   -- 异常处理需要基础语法
(4, 2),   -- 集合需要OOP
(5, 2),   -- 多线程需要OOP
(6, 4),   -- JDBC需要集合
(7, 5),   -- Spring需要多线程
(7, 6),   -- Spring也需要JDBC
-- 数据结构
(9, 8),   -- 栈队列需要数组链表
(10, 8),  -- 树需要数组链表
(11, 8),  -- 排序需要数组链表
(12, 9),  -- 图需要栈队列
(12, 10), -- 图也需要树
(13, 11), -- 动态规划需要排序
(14, 11), -- 贪心需要排序
-- Python
(16, 15), -- NumPy需要Python基础
(17, 16), -- Pandas需要NumPy
(18, 17), -- 绘图需要Pandas
(19, 17), -- 机器学习需要Pandas
-- 数据库
(21, 20), -- SQL需要关系模型
(22, 21), -- 索引需要SQL
(23, 21), -- 事务需要SQL
(24, 20), -- 设计范式需要关系模型
-- 网络
(26, 25), -- TCP/IP需要OSI
(27, 26), -- HTTP需要TCP/IP
(28, 26), -- DNS需要TCP/IP
(29, 27); -- 网络安全需要HTTP

INSERT IGNORE INTO kp_prerequisites (kp_id, prerequisite_kp_id) VALUES
-- Java扩展 (30-35)
(30, 1),   -- JVM需要Java基础语法
(31, 2),   -- 设计模式需要OOP
(32, 1),   -- Java 8+需要Java基础语法
(32, 4),   -- Java 8+需要集合
(33, 2),   -- 反射与注解需要OOP
(34, 6),   -- MyBatis需要JDBC
(34, 7),   -- MyBatis需要Spring
(35, 1),   -- 测试与构建工具需要Java基础语法
-- 数据结构扩展 (36-39)
(36, 8),   -- 哈希表需要数组链表
(37, 8),   -- 二分查找需要数组链表
(38, 8),   -- 字符串算法需要数组链表
(38, 13),  -- 字符串算法需要动态规划
(39, 13),  -- 递归与回溯需要动态规划
-- 数据库扩展 (40-41)
(40, 21),  -- Redis需要SQL基础
(41, 22),  -- MySQL存储引擎需要索引
(41, 23),  -- MySQL存储引擎需要事务
-- 网络扩展 (42-43)
(42, 27),  -- RESTful API设计需要HTTP
(43, 27),  -- 认证与授权需要HTTP
(43, 29),  -- 认证与授权需要网络安全
-- 操作系统 (44-47)
(44, 5),   -- 进程与线程需要多线程(Java)
(45, 44),  -- 内存管理需要进程与线程
(46, 44),  -- 死锁需要进程与线程
(47, 44),  -- IO模型需要进程与线程
-- Linux (48-50)
(48, 44),  -- 常用命令需要进程与线程
(49, 48),  -- 文件权限需要常用命令
(50, 48),  -- Shell脚本需要常用命令
-- 系统设计 (51-53)
(51, 7),   -- 系统设计方法需要Spring
(51, 21),  -- 系统设计方法需要SQL
(51, 27),  -- 系统设计方法需要HTTP
(52, 51),  -- 常见架构模式需要系统设计方法
(53, 51);  -- 分布式基础需要系统设计方法

-- ========== Learning Plans ==========
INSERT IGNORE INTO learning_plans (id, user_id, title, description, start_date, end_date, status) VALUES
(1, 2, 'Java工程师进阶计划', '系统学习Java核心技术栈，从基础语法到Spring框架，为后续企业级项目开发打下坚实基础。', '2026-07-01', '2026-09-30', 'ACTIVE'),
(2, 2, '数据结构与算法刷题计划', '跟随课程系统学习数据结构与算法，每周完成5道LeetCode相关题目练习。', '2026-07-15', '2026-10-15', 'ACTIVE'),
(3, 3, '数据分析师学习路径', '从Python基础到机器学习，掌握数据分析全流程技能。', '2026-06-20', '2026-08-31', 'ACTIVE'),
(4, 2, '计算机网络协议学习', '深入理解网络协议栈和HTTP协议，为后端开发打好网络基础。', '2026-06-01', '2026-07-15', 'COMPLETED');

-- ========== Plan Items ==========
INSERT IGNORE INTO plan_items (id, plan_id, course_id, kp_id, item_type, sort_order, completed) VALUES
-- Plan 1 (Java)
(1, 1, NULL, 1, 'KNOWLEDGE_POINT', 1, TRUE),
(2, 1, NULL, 2, 'KNOWLEDGE_POINT', 2, TRUE),
(3, 1, NULL, 3, 'KNOWLEDGE_POINT', 3, TRUE),
(4, 1, NULL, 4, 'KNOWLEDGE_POINT', 4, FALSE),
(5, 1, NULL, 5, 'KNOWLEDGE_POINT', 5, FALSE),
(6, 1, NULL, 6, 'KNOWLEDGE_POINT', 6, FALSE),
(7, 1, NULL, 7, 'KNOWLEDGE_POINT', 7, FALSE),
-- Plan 2 (DS & Algo)
(8, 2, NULL, 8, 'KNOWLEDGE_POINT', 1, TRUE),
(9, 2, NULL, 9, 'KNOWLEDGE_POINT', 2, TRUE),
(10, 2, NULL, 11, 'KNOWLEDGE_POINT', 3, FALSE),
(11, 2, NULL, 13, 'KNOWLEDGE_POINT', 4, FALSE),
-- Plan 3 (Data Analysis)
(12, 3, NULL, 15, 'KNOWLEDGE_POINT', 1, TRUE),
(13, 3, NULL, 16, 'KNOWLEDGE_POINT', 2, TRUE),
(14, 3, NULL, 17, 'KNOWLEDGE_POINT', 3, FALSE),
(15, 3, NULL, 18, 'KNOWLEDGE_POINT', 4, FALSE),
-- Plan 4 (Network - completed)
(16, 4, NULL, 25, 'KNOWLEDGE_POINT', 1, TRUE),
(17, 4, NULL, 26, 'KNOWLEDGE_POINT', 2, TRUE);

-- ========== Learning Records ==========
INSERT IGNORE INTO learning_records (id, user_id, course_id, kp_id, duration_minutes, mastery_level, notes, record_date) VALUES
-- User zhangsan's records
(1, 2, 1, 1, 60, 85, 'Java基础语法掌握较好，数组和循环熟练习', '2026-07-05'),
(2, 2, 1, 1, 45, 90, '复习了变量作用域和方法重载', '2026-07-07'),
(3, 2, 1, 2, 90, 75, 'OOP概念理解，多态部分需要加强', '2026-07-10'),
(4, 2, 1, 2, 60, 82, '重新练习了接口和抽象类的区别', '2026-07-12'),
(5, 2, 1, 3, 45, 88, '异常处理try-catch-finally掌握熟练', '2026-07-14'),
(6, 2, 2, 8, 60, 90, '链表反转和环检测写得很顺利', '2026-07-16'),
(7, 2, 2, 9, 50, 78, '优先队列的堆实现需要多练', '2026-07-18'),
(8, 2, 5, 25, 40, 75, 'OSI七层模型各层功能已理解', '2026-06-05'),
(9, 2, 5, 26, 60, 80, 'TCP三次握手四次挥手已掌握', '2026-06-10'),
(10, 2, 1, 4, 45, 55, 'HashMap底层原理和红黑树较难，需要重点学习', '2026-07-20'),
-- User lisi's records
(11, 3, 3, 15, 60, 88, 'Python基础语法较简单，列表推导式已掌握', '2026-06-25'),
(12, 3, 3, 16, 75, 70, 'NumPy广播机制需要多动手练习', '2026-07-02'),
(13, 3, 3, 17, 90, 60, 'groupby分组聚合语法复杂，练习了几个数据集', '2026-07-08'),
(14, 3, 3, 17, 60, 72, '重新练习了merge和join的区别', '2026-07-15'),
(15, 3, 3, 18, 50, 65, '学习了折线图和柱状图的样式定制', '2026-07-19'),
-- More records for zhangsan (recent)
(16, 2, 4, 20, 50, 82, '关系代数和ER图设计基础已掌握', '2026-07-21'),
(17, 2, 4, 21, 70, 70, '复杂子查询和多表join需要加强', '2026-07-22'),
(18, 2, 2, 10, 60, 55, '二叉树遍历的递归和非递归实现需要多练', '2026-07-23');

-- ========== User KP Mastery (system calculated) ==========
INSERT IGNORE INTO user_kp_mastery (user_id, kp_id, mastery_score, learn_count, last_learn_at) VALUES
-- Zhangsan's mastery
(2, 1, 88, 2, '2026-07-07 10:00:00'),
(2, 2, 79, 2, '2026-07-12 14:30:00'),
(2, 3, 88, 1, '2026-07-14 09:00:00'),
(2, 4, 55, 1, '2026-07-20 16:00:00'),
(2, 8, 90, 1, '2026-07-16 10:30:00'),
(2, 9, 78, 1, '2026-07-18 15:00:00'),
(2, 10, 55, 1, '2026-07-23 20:00:00'),
(2, 20, 82, 1, '2026-07-21 09:30:00'),
(2, 21, 70, 1, '2026-07-22 14:00:00'),
(2, 25, 75, 1, '2026-06-05 10:00:00'),
(2, 26, 80, 1, '2026-06-10 11:00:00'),
-- Lisi's mastery
(3, 15, 88, 1, '2026-06-25 09:00:00'),
(3, 16, 70, 1, '2026-07-02 14:00:00'),
(3, 17, 66, 2, '2026-07-15 16:00:00'),
(3, 18, 65, 1, '2026-07-19 10:00:00');

-- ========== Questions ==========

-- Java基础语法 (kp_id=1)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(1, 1, 'SINGLE_CHOICE', 'Java中，以下哪个不是基本数据类型？',
 '[{"key":"A","text":"int"},{"key":"B","text":"float"},{"key":"C","text":"String"},{"key":"D","text":"boolean"}]',
 'C', 'String是引用类型，不是基本数据类型。Java的8种基本类型：byte/short/int/long/float/double/char/boolean。', 1),
(2, 1, 'TRUE_FALSE', 'Java中数组的长度可以通过length属性获取。',
 null, 'true', '数组的length是属性不是方法，所以直接使用 array.length，而不是 array.length()。', 1),
(3, 1, 'SINGLE_CHOICE', '以下代码输出是什么？ int x=5; System.out.println(x++);',
 '[{"key":"A","text":"5"},{"key":"B","text":"6"},{"key":"C","text":"编译错误"},{"key":"D","text":"0"}]',
 'A', 'x++是后置自增，先使用x的值(5)再执行+1，所以输出5。如果是++x则输出6。', 1),
(4, 1, 'SINGLE_CHOICE', '以下哪个关键字用于定义常量？',
 '[{"key":"A","text":"const"},{"key":"B","text":"static"},{"key":"C","text":"final"},{"key":"D","text":"define"}]',
 'C', 'Java中用final关键字定义常量。const是保留字但不能使用。define是C语言的。', 1),
(5, 1, 'MULTI_CHOICE', '以下哪些是合法的Java标识符？(多选)',
 '[{"key":"A","text":"_name"},{"key":"B","text":"2value"},{"key":"C","text":"$price"},{"key":"D","text":"my-var"}]',
 'AC', 'Java标识符可以以下划线_和$开头，但不能以数字开头，不能包含连字符-。', 1);

-- 面向对象编程 (kp_id=2)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(6, 2, 'SINGLE_CHOICE', '关于Java接口(interface)，以下说法正确的是？',
 '[{"key":"A","text":"接口可以包含构造方法"},{"key":"B","text":"一个类只能实现一个接口"},{"key":"C","text":"接口中的方法默认是public abstract的"},{"key":"D","text":"接口不能被其他接口继承"}]',
 'C', '接口中方法默认是public abstract的。接口可以多实现，接口之间可以继承(extends)。接口不能有构造方法。', 2),
(7, 2, 'MULTI_CHOICE', '以下哪些是OOP的三大特性？(多选)',
 '[{"key":"A","text":"封装"},{"key":"B","text":"继承"},{"key":"C","text":"多态"},{"key":"D","text":"抽象"}]',
 'ABC', 'OOP三大特性是封装(Encapsulation)、继承(Inheritance)、多态(Polymorphism)。抽象是重要概念但不是三大特性之一。', 1),
(8, 2, 'TRUE_FALSE', 'Java中一个子类可以同时继承多个父类。',
 null, 'false', 'Java只支持单继承，一个类只能有一个直接父类。但可以通过实现多个接口来达到类似多继承的效果。', 1),
(9, 2, 'SINGLE_CHOICE', '以下哪个关键字表示一个方法不能被重写？',
 '[{"key":"A","text":"static"},{"key":"B","text":"final"},{"key":"C","text":"private"},{"key":"D","text":"abstract"}]',
 'B', 'final方法不能被子类重写。private方法也不能被重写(因为不可见)。static方法可以被隐藏但不能被重写。', 2);

-- 异常处理机制 (kp_id=3)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(10, 3, 'SINGLE_CHOICE', '以下哪个是受检异常(checked exception)？',
 '[{"key":"A","text":"NullPointerException"},{"key":"B","text":"ArrayIndexOutOfBoundsException"},{"key":"C","text":"IOException"},{"key":"D","text":"ArithmeticException"}]',
 'C', 'IOException及其子类属于受检异常，编译时必须处理。其他三个都是运行时异常(RuntimeException)，不需要强制处理。', 2),
(11, 3, 'TRUE_FALSE', 'finally块中的代码在任何情况下都会执行，包括在try块中执行了return语句。',
 null, 'true', 'finally块在return之前执行。唯一例外是调用System.exit(0)导致JVM终止。', 2),
(12, 3, 'SINGLE_CHOICE', '以下代码的执行顺序是？ try{ A }catch(Exception e){ B }finally{ C }',
 '[{"key":"A","text":"A→B→C"},{"key":"B","text":"A→C"},{"key":"C","text":"B→C"},{"key":"D","text":"A→B"}]',
 'A', '如果try中发生异常匹配到catch，执行顺序是try→catch→finally。如果没异常则是try→finally。', 1),
(13, 3, 'TRUE_FALSE', 'catch块可以没有参数，直接写成 catch { }。',
 null, 'false', 'catch块必须指定异常类型参数，如 catch(Exception e)。但JDK 7+支持多异常捕获：catch(IOException | SQLException e)。', 2);

-- 集合框架 (kp_id=4)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(14, 4, 'SINGLE_CHOICE', '以下哪个集合类底层使用数组实现？',
 '[{"key":"A","text":"LinkedList"},{"key":"B","text":"ArrayList"},{"key":"C","text":"TreeSet"},{"key":"D","text":"PriorityQueue"}]',
 'B', 'ArrayList底层是Object[]数组。LinkedList底层是双向链表。TreeSet使用红黑树。PriorityQueue使用二叉堆(数组实现的完全二叉树)。', 1),
(15, 4, 'SINGLE_CHOICE', 'HashMap在JDK8中当链表长度超过多少时会转为红黑树？',
 '[{"key":"A","text":"6"},{"key":"B","text":"7"},{"key":"C","text":"8"},{"key":"D","text":"10"}]',
 'C', '当链表长度>=8且数组长度>=64时，链表转为红黑树。当树节点数<=6时转回链表。', 2),
(16, 4, 'TRUE_FALSE', 'HashSet允许存储重复元素。',
 null, 'false', 'HashSet基于HashMap实现，key是元素本身，value是一个固定的Object。HashMap的key不能重复，所以HashSet也不能有重复元素。', 1),
(17, 4, 'MULTI_CHOICE', '以下哪些集合类是线程安全的？(多选)',
 '[{"key":"A","text":"Vector"},{"key":"B","text":"ArrayList"},{"key":"C","text":"ConcurrentHashMap"},{"key":"D","text":"CopyOnWriteArrayList"}]',
 'ACD', 'Vector是古老的线程安全类(synchronized方法)。ConcurrentHashMap是JDK5引入的高并发Map。CopyOnWriteArrayList通过写时复制实现线程安全。ArrayList不是线程安全的。', 3);

-- 多线程编程 (kp_id=5)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(18, 5, 'SINGLE_CHOICE', '创建线程的推荐方式是什么？',
 '[{"key":"A","text":"继承Thread类"},{"key":"B","text":"实现Runnable接口"},{"key":"C","text":"使用线程池"},{"key":"D","text":"直接new Thread().start()"}]',
 'C', '推荐使用线程池(ExecutorService)管理线程，可以复用线程、控制并发数、减少创建销毁开销。', 2),
(19, 5, 'SINGLE_CHOICE', 'synchronized关键字修饰非静态方法时，锁住的是什么？',
 '[{"key":"A","text":"类对象(Class对象)"},{"key":"B","text":"当前实例对象(this)"},{"key":"C","text":"方法本身"},{"key":"D","text":"代码块"}]',
 'B', 'synchronized修饰非静态方法时，锁是当前实例对象this。修饰静态方法时，锁是类对象(XXX.class)。', 2),
(20, 5, 'TRUE_FALSE', 'volatile关键字能保证原子性。',
 null, 'false', 'volatile只能保证可见性和禁止指令重排，但不能保证原子性。例如i++这种复合操作，volatile无法保证线程安全。需要用synchronized或AtomicInteger。', 3),
(21, 5, 'SINGLE_CHOICE', '以下哪个不是Java线程池的拒绝策略？',
 '[{"key":"A","text":"AbortPolicy"},{"key":"B","text":"CallerRunsPolicy"},{"key":"C","text":"RetryPolicy"},{"key":"D","text":"DiscardPolicy"}]',
 'C', 'ThreadPoolExecutor内置4种拒绝策略：AbortPolicy(抛异常)、CallerRunsPolicy(调用者执行)、DiscardPolicy(丢弃)、DiscardOldestPolicy(丢弃最旧的)。没有RetryPolicy。', 3);

-- JDBC数据库连接 (kp_id=6)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(22, 6, 'SINGLE_CHOICE', '以下哪个用于执行预编译的SQL语句，防止SQL注入？',
 '[{"key":"A","text":"Statement"},{"key":"B","text":"PreparedStatement"},{"key":"C","text":"CallableStatement"},{"key":"D","text":"ResultSet"}]',
 'B', 'PreparedStatement预编译SQL，使用占位符?传参，能有效防止SQL注入。Statement拼接字符串存在注入风险。', 1),
(23, 6, 'TRUE_FALSE', 'JDBC中ResultSet默认是可以向前和向后滚动的。',
 null, 'false', '默认创建的Statement/PreparedStatement产生的ResultSet只能向前滚动(TYPE_FORWARD_ONLY)。需要指定ResultSet.TYPE_SCROLL_INSENSITIVE才能双向滚动。', 2),
(24, 6, 'SINGLE_CHOICE', 'JDBC操作的正确关闭顺序是什么？',
 '[{"key":"A","text":"Connection→Statement→ResultSet"},{"key":"B","text":"ResultSet→Statement→Connection"},{"key":"C","text":"Statement→Connection→ResultSet"},{"key":"D","text":"顺序无关"}]',
 'B', '关闭顺序应与打开顺序相反：先关ResultSet，再关Statement，最后关Connection。通常写在finally块中确保一定执行。', 1);

-- Spring框架基础 (kp_id=7)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(25, 7, 'SINGLE_CHOICE', 'Spring IoC容器的核心是什么？',
 '[{"key":"A","text":"DispatcherServlet"},{"key":"B","text":"ApplicationContext"},{"key":"C","text":"JdbcTemplate"},{"key":"D","text":"ModelAndView"}]',
 'B', 'ApplicationContext是Spring IoC容器的核心接口，负责bean的创建、配置和管理。BeanFactory是其父接口。', 1),
(26, 7, 'TRUE_FALSE', '@Autowired默认按名称注入。',
 null, 'false', '@Autowired默认按类型(byType)注入。当有多个同类型bean时，可以配合@Qualifier指定名称。', 2),
(27, 7, 'MULTI_CHOICE', 'Spring Boot相比传统Spring的优势有哪些？(多选)',
 '[{"key":"A","text":"自动配置"},{"key":"B","text":"内嵌服务器"},{"key":"C","text":"不需要写任何代码"},{"key":"D","text":"starter依赖简化"}]',
 'ABD', 'Spring Boot通过自动配置、starter依赖和嵌入式服务器简化开发，但仍需要写业务代码。C选项夸大其词。', 1),
(28, 7, 'SINGLE_CHOICE', '@Transactional注解默认在什么异常时回滚？',
 '[{"key":"A","text":"所有异常"},{"key":"B","text":"RuntimeException和Error"},{"key":"C","text":"只有SQLException"},{"key":"D","text":"受检异常"}]',
 'B', '@Transactional默认只对RuntimeException和Error回滚。对受检异常(checked exceptions)不回滚。可以通过rollbackFor属性指定。', 3);

-- 数组与链表 (kp_id=8)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(29, 8, 'SINGLE_CHOICE', '数组和链表在随机访问时的性能对比？',
 '[{"key":"A","text":"数组O(1)，链表O(n)"},{"key":"B","text":"数组O(n)，链表O(1)"},{"key":"C","text":"都是O(1)"},{"key":"D","text":"都是O(n)"}]',
 'A', '数组通过下标随机访问是O(1)。链表需要从头遍历到目标位置，O(n)。但链表插入删除是O(1)(已知位置)，数组插入删除是O(n)。', 1),
(30, 8, 'TRUE_FALSE', '单向链表只能从前往后遍历，不能从后往前遍历。',
 null, 'true', '单向链表每个节点只有指向下一个节点的指针，只能单向遍历。双向链表有两个指针，可以双向遍历。', 1),
(31, 8, 'SINGLE_CHOICE', '在长度为n的数组中，在开头插入一个元素的时间复杂度是？',
 '[{"key":"A","text":"O(1)"},{"key":"B","text":"O(log n)"},{"key":"C","text":"O(n)"},{"key":"D","text":"O(n²)"}]',
 'C', '在数组开头插入需要将所有元素后移一位，O(n)。在末尾插入(容量够)是O(1)。', 2);

-- 栈与队列 (kp_id=9)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(32, 9, 'SINGLE_CHOICE', '栈(Stack)的特点是什么？',
 '[{"key":"A","text":"先进先出FIFO"},{"key":"B","text":"先进后出LIFO"},{"key":"C","text":"随机访问"},{"key":"D","text":"按键值访问"}]',
 'B', '栈是先进后出(LIFO)，像叠盘子。队列是先进先出(FIFO)，像排队。', 1),
(33, 9, 'SINGLE_CHOICE', '以下哪个场景最适合用栈？',
 '[{"key":"A","text":"打印任务排队"},{"key":"B","text":"函数递归调用"},{"key":"C","text":"消息队列"},{"key":"D","text":"广度优先搜索"}]',
 'B', '函数递归调用的调用栈(Call Stack)就是栈结构。BFS用队列，DFS用栈。打印任务和消息队列是队列场景。', 2),
(34, 9, 'TRUE_FALSE', '队列可以用两个栈来模拟实现。',
 null, 'true', '用两个栈可以模拟队列：入队时push到栈A，出队时若栈B为空则将栈A全部pop并push到栈B，再从栈B pop。均摊时间复杂度O(1)。', 3);

-- 树与二叉树 (kp_id=10)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(35, 10, 'SINGLE_CHOICE', '二叉树的前序遍历顺序是什么？',
 '[{"key":"A","text":"左→根→右"},{"key":"B","text":"根→左→右"},{"key":"C","text":"左→右→根"},{"key":"D","text":"根→右→左"}]',
 'B', '前序(先序)遍历：根→左→右。中序：左→根→右。后序：左→右→根。层序：从上到下逐层。', 1),
(36, 10, 'TRUE_FALSE', '二叉搜索树(BST)的中序遍历结果是有序的。',
 null, 'true', 'BST性质：左子树<根<右子树。中序遍历(左→根→右)恰好按从小到大顺序访问所有节点。', 2),
(37, 10, 'SINGLE_CHOICE', '平衡二叉树(AVL)的平衡因子范围是多少？',
 '[{"key":"A","text":"0"},{"key":"B","text":"-1到+1"},{"key":"C","text":"-2到+2"},{"key":"D","text":"任意值"}]',
 'B', 'AVL树要求任意节点左右子树高度差(平衡因子)在-1、0、+1之间。超出时需要旋转调整。', 2);

-- 排序算法 (kp_id=11)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(38, 11, 'SINGLE_CHOICE', '快速排序的平均时间复杂度是？',
 '[{"key":"A","text":"O(n)"},{"key":"B","text":"O(n log n)"},{"key":"C","text":"O(n²)"},{"key":"D","text":"O(log n)"}]',
 'B', '快速排序平均O(n log n)，最坏O(n²)(数组已有序且每次选第一个为基准)。归并排序稳定O(n log n)。', 1),
(39, 11, 'TRUE_FALSE', '归并排序是稳定的排序算法。',
 null, 'true', '归并排序是稳定的(相等元素保持原顺序)。快速排序和堆排序是不稳定的。', 2),
(40, 11, 'SINGLE_CHOICE', '对几乎有序的数组，以下哪种排序效率最高？',
 '[{"key":"A","text":"快速排序"},{"key":"B","text":"插入排序"},{"key":"C","text":"选择排序"},{"key":"D","text":"堆排序"}]',
 'B', '插入排序在数组基本有序时接近O(n)。快速排序在基本有序时可能退化为O(n²)(如果pivot选择不好)。', 3),
(41, 11, 'MULTI_CHOICE', '以下哪些排序算法基于比较？(多选)',
 '[{"key":"A","text":"快速排序"},{"key":"B","text":"计数排序"},{"key":"C","text":"堆排序"},{"key":"D","text":"归并排序"}]',
 'ACD', '计数排序和基数排序是非比较排序(基于数据范围)。快速、堆、归并排序都是基于比较的，下界O(n log n)。', 2);

-- 图论基础 (kp_id=12)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(42, 12, 'SINGLE_CHOICE', 'DFS遍历图使用的辅助数据结构是？',
 '[{"key":"A","text":"队列"},{"key":"B","text":"栈"},{"key":"C","text":"堆"},{"key":"D","text":"哈希表"}]',
 'B', 'DFS(深度优先)使用栈(递归隐式用系统栈)。BFS(广度优先)使用队列。Dijkstra使用优先队列(堆)。', 1),
(43, 12, 'SINGLE_CHOICE', 'Dijkstra算法不能处理什么情况？',
 '[{"key":"A","text":"有向图"},{"key":"B","text":"稀疏图"},{"key":"C","text":"负权边"},{"key":"D","text":"无向图"}]',
 'C', 'Dijkstra算法要求边权非负。有负权边需要用Bellman-Ford或SPFA算法。', 2),
(44, 12, 'SINGLE_CHOICE', '图的邻接矩阵中，第i行第j列的元素表示什么？',
 '[{"key":"A","text":"顶点i到顶点j的边"},{"key":"B","text":"顶点j到顶点i的边"},{"key":"C","text":"顶点i和j的距离"},{"key":"D","text":"顶点i的度"}]',
 'A', '邻接矩阵中matrix[i][j]表示从顶点i到顶点j的边(或权值)。无向图的邻接矩阵是对称的。', 1);

-- 动态规划 (kp_id=13)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(45, 13, 'SINGLE_CHOICE', '动态规划的两个核心要素是什么？',
 '[{"key":"A","text":"递归和分治"},{"key":"B","text":"最优子结构和重叠子问题"},{"key":"C","text":"贪心选择和排序"},{"key":"D","text":"回溯和剪枝"}]',
 'B', 'DP需要：(1)最优子结构(大问题最优解包含子问题最优解)，(2)重叠子问题(子问题被多次计算)。用记忆化或迭代避免重复计算。', 1),
(46, 13, 'SINGLE_CHOICE', '0/1背包问题用动态规划的时间复杂度是？',
 '[{"key":"A","text":"O(n)"},{"key":"B","text":"O(nW) - n物品数,W容量"},{"key":"C","text":"O(n²)"},{"key":"D","text":"O(2ⁿ)"}]',
 'B', '0/1背包DP复杂度O(nW)，是伪多项式时间(与W相关)。暴力枚举是O(2ⁿ)。', 2),
(47, 13, 'TRUE_FALSE', '所有能用贪心算法解决的问题都能用动态规划解决。',
 null, 'true', '贪心是DP的特例——当贪心选择性质成立时，DP可以不考虑所有子问题，只需贪心选择。一般能用贪心的都能用DP(但DP可能更慢)。', 3);

-- 贪心算法 (kp_id=14)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(48, 14, 'SINGLE_CHOICE', '贪心算法每一步的选择依据是什么？',
 '[{"key":"A","text":"考虑全局最优"},{"key":"B","text":"当时看起来最好的选择"},{"key":"C","text":"随机选择"},{"key":"D","text":"回溯试探"}]',
 'B', '贪心算法每步做出当前看起来最优的选择(局部最优)，期望最终得到全局最优。贪心不能回退。', 1),
(49, 14, 'SINGLE_CHOICE', '以下哪个问题可以用贪心算法得到最优解？',
 '[{"key":"A","text":"0/1背包问题"},{"key":"B","text":"哈夫曼编码"},{"key":"C","text":"最长公共子序列"},{"key":"D","text":"旅行商问题"}]',
 'B', '哈夫曼编码是经典贪心算法。0/1背包贪心不一定最优(需要DP)。最长公共子序列用DP。旅行商问题是NP-hard。', 2);

-- Python基础语法 (kp_id=15)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(50, 15, 'SINGLE_CHOICE', 'Python中列表和元组的主要区别是什么？',
 '[{"key":"A","text":"列表有序，元组无序"},{"key":"B","text":"列表可变，元组不可变"},{"key":"C","text":"列表能用for循环，元组不能"},{"key":"D","text":"没有区别"}]',
 'B', '列表(list)可变(可增删改)，元组(tuple)不可变(创建后不能修改)。两者都支持索引和for循环。', 1),
(51, 15, 'TRUE_FALSE', 'Python中字典的key可以是列表。',
 null, 'false', '字典的key必须是可哈希(hashable)的不可变类型，如字符串、数字、元组。列表是可变的不能做key。', 1),
(52, 15, 'SINGLE_CHOICE', '以下代码输出什么？ print(type(3/2))',
 '[{"key":"A","text":"<class ''int''>"},{"key":"B","text":"<class ''float''>"},{"key":"C","text":"<class ''str''>"},{"key":"D","text":"报错"}]',
 'B', 'Python3中除法/始终返回float。整除//返回int。3/2=1.5是float类型。', 1),
(53, 15, 'MULTI_CHOICE', 'Python中以下哪些是可变类型？(多选)',
 '[{"key":"A","text":"list"},{"key":"B","text":"tuple"},{"key":"C","text":"dict"},{"key":"D","text":"set"}]',
 'ACD', 'list、dict、set是可变的。tuple和str(字符串)是不可变的。', 2);

-- NumPy数组操作 (kp_id=16)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(54, 16, 'SINGLE_CHOICE', '创建一个全零的3×3 NumPy数组用哪个函数？',
 '[{"key":"A","text":"np.ones((3,3))"},{"key":"B","text":"np.zeros((3,3))"},{"key":"C","text":"np.empty((3,3))"},{"key":"D","text":"np.full((3,3),0)"}]',
 'B', 'np.zeros创建全0数组。np.ones创建全1。np.empty创建未初始化数组。np.full((3,3),0)也可以但B最直接。', 1),
(55, 16, 'SINGLE_CHOICE', 'NumPy广播机制允许什么操作？',
 '[{"key":"A","text":"不同形状数组间的运算"},{"key":"B","text":"数组在网络上发送"},{"key":"C","text":"多线程并行计算"},{"key":"D","text":"GPU加速运算"}]',
 'A', '广播(broadcasting)允许不同形状的数组进行算术运算，沿缺失维度扩展复制。如(3,1)+(1,4)→(3,4)。', 2),
(56, 16, 'TRUE_FALSE', 'NumPy数组中的所有元素必须是同一数据类型。',
 null, 'true', 'NumPy ndarray是同质的，所有元素类型相同(dtype)。这与Python的list不同，list可以混合类型。', 1);

-- Pandas数据处理 (kp_id=17)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(57, 17, 'SINGLE_CHOICE', 'Pandas中读取CSV文件使用哪个函数？',
 '[{"key":"A","text":"pd.read_excel()"},{"key":"B","text":"pd.read_csv()"},{"key":"C","text":"pd.read_json()"},{"key":"D","text":"pd.load_csv()"}]',
 'B', 'read_csv()读取CSV，read_excel()读取Excel，read_json()读取JSON。没有load_csv()。', 1),
(58, 17, 'SINGLE_CHOICE', '如何对DataFrame的缺失值进行填充？',
 '[{"key":"A","text":"df.dropna()"},{"key":"B","text":"df.fillna(value)"},{"key":"C","text":"df.replace(na,value)"},{"key":"D","text":"df.clean(value)"}]',
 'B', 'fillna()填充缺失值，dropna()删除含缺失值的行列。replace()用于替换指定值，不是专门处理缺失值的。', 1),
(59, 17, 'SINGLE_CHOICE', 'Pandas中groupby().agg()的作用是什么？',
 '[{"key":"A","text":"数据排序"},{"key":"B","text":"数据过滤"},{"key":"C","text":"分组聚合"},{"key":"D","text":"数据连接"}]',
 'C', 'groupby分组后agg()对每组应用聚合函数(如sum/mean/count)。类似SQL的GROUP BY+聚合函数。', 2);

-- Matplotlib可视化 (kp_id=18)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(60, 18, 'SINGLE_CHOICE', 'Matplotlib中plt.subplot(2,2,1)表示什么？',
 '[{"key":"A","text":"创建2x2网格，选择第1个"},{"key":"B","text":"创建2行2列共22个子图"},{"key":"C","text":"缩放比例为2:2:1"},{"key":"D","text":"创建2个子图"}]',
 'A', 'subplot(行,列,序号)：2行2列共4个子图，当前选择第1个(从左到右从上到下编号)。', 2),
(61, 18, 'SINGLE_CHOICE', '绘制折线图使用哪个函数？',
 '[{"key":"A","text":"plt.bar()"},{"key":"B","text":"plt.scatter()"},{"key":"C","text":"plt.plot()"},{"key":"D","text":"plt.pie()"}]',
 'C', 'plot()画折线图。bar()画柱状图。scatter()画散点图。pie()画饼图。', 1),
(62, 18, 'TRUE_FALSE', 'Matplotlib默认支持中文显示，不需要额外配置字体。',
 null, 'false', 'Matplotlib默认不支持中文，会显示方框。需要设置中文字体，如 plt.rcParams["font.sans-serif"]=["SimHei"]。', 2);

-- 机器学习基础 (kp_id=19)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(63, 19, 'SINGLE_CHOICE', '监督学习和无监督学习的主要区别是什么？',
 '[{"key":"A","text":"是否有GPU"},{"key":"B","text":"数据是否有标签"},{"key":"C","text":"数据量大小"},{"key":"D","text":"是否用神经网络"}]',
 'B', '监督学习有标签(如分类、回归)，无监督学习没有标签(如聚类、降维)。', 1),
(64, 19, 'SINGLE_CHOICE', '过拟合(overfitting)的表现是什么？',
 '[{"key":"A","text":"训练集和测试集都表现差"},{"key":"B","text":"训练集表现好但测试集表现差"},{"key":"C","text":"训练集表现差但测试集表现好"},{"key":"D","text":"两者表现一样好"}]',
 'B', '过拟合：模型在训练集上表现很好但泛化能力差(测试集表现差)。欠拟合：训练集和测试集都差。', 2),
(65, 19, 'SINGLE_CHOICE', 'KNN算法的K值过大会导致什么？',
 '[{"key":"A","text":"过拟合"},{"key":"B","text":"欠拟合"},{"key":"C","text":"计算更快"},{"key":"D","text":"没有影响"}]',
 'B', 'K过小容易过拟合(对噪声敏感)。K过大导致欠拟合(模型过于简单，决策边界过于平滑)。常用交叉验证选K。', 3);

-- 关系模型基础 (kp_id=20)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(66, 20, 'SINGLE_CHOICE', '关系数据库中，关系代数中的选择运算σ对应SQL的什么？',
 '[{"key":"A","text":"FROM子句"},{"key":"B","text":"WHERE子句"},{"key":"C","text":"SELECT子句"},{"key":"D","text":"JOIN子句"}]',
 'B', 'σ(选择)：选取满足条件的行→WHERE。π(投影)：选取指定列→SELECT。⋈(连接)：表关联→JOIN。', 1),
(67, 20, 'SINGLE_CHOICE', '在关系模型中，元组(tuple)对应什么？',
 '[{"key":"A","text":"表中的一行数据"},{"key":"B","text":"表中的一列"},{"key":"C","text":"表名"},{"key":"D","text":"索引"}]',
 'A', '元组是关系数据库中的一行记录。属性(attribute)对应一列。关系(relation)对应一张表。', 1),
(68, 20, 'TRUE_FALSE', '关系数据库的主键可以为NULL。',
 null, 'false', '主键必须满足实体完整性：非空且唯一。外键可以为NULL(表示不存在关联)。', 1);

-- SQL查询语言 (kp_id=21)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(69, 21, 'SINGLE_CHOICE', 'SQL中HAVING和WHERE的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"WHERE过滤行，HAVING过滤分组"},{"key":"C","text":"HAVING过滤行，WHERE过滤分组"},{"key":"D","text":"WHERE只能用于UPDATE"}]',
 'B', 'WHERE在GROUP BY之前过滤行。HAVING在GROUP BY之后过滤分组。HAVING可以使用聚合函数(SUM/COUNT等)，WHERE不能。', 1),
(70, 21, 'SINGLE_CHOICE', 'LEFT JOIN的结果包含什么？',
 '[{"key":"A","text":"只包含两表匹配的行"},{"key":"B","text":"左表全部行+右表匹配行(不匹配为NULL)"},{"key":"C","text":"右表全部行+左表匹配行"},{"key":"D","text":"两表全部行"}]',
 'B', 'LEFT JOIN保留左表全部记录，右表无匹配时填充NULL。RIGHT JOIN相反。FULL JOIN保留两表全部。', 1),
(71, 21, 'SINGLE_CHOICE', 'SQL中哪个函数用于统计行数？',
 '[{"key":"A","text":"SUM()"},{"key":"B","text":"AVG()"},{"key":"C","text":"COUNT()"},{"key":"D","text":"TOTAL()"}]',
 'C', 'COUNT(*)统计所有行。COUNT(列名)统计该列非NULL的行数。SUM/AVG用于求和/求平均。', 1);

-- 索引与查询优化 (kp_id=22)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(72, 22, 'SINGLE_CHOICE', 'MySQL InnoDB引擎默认使用什么索引结构？',
 '[{"key":"A","text":"哈希索引"},{"key":"B","text":"B+树索引"},{"key":"C","text":"倒排索引"},{"key":"D","text":"位图索引"}]',
 'B', 'InnoDB使用B+树作为默认索引结构。B+树所有数据存在叶子节点，叶子节点通过链表连接，支持范围查询。哈希索引只支持等值查询。', 1),
(73, 22, 'SINGLE_CHOICE', 'EXPLAIN命令的作用是什么？',
 '[{"key":"A","text":"导出数据"},{"key":"B","text":"查看SQL执行计划"},{"key":"C","text":"备份数据库"},{"key":"D","text":"修复表"}]',
 'B', 'EXPLAIN显示SQL执行计划，包括使用的索引、扫描行数、连接方式等，用于SQL优化。', 2),
(74, 22, 'TRUE_FALSE', '为所有列都建索引可以提高查询性能。',
 null, 'false', '索引太多会降低写入性能(每次INSERT/UPDATE/DELETE都要维护索引)，且占用大量磁盘空间。只为高频查询的WHERE/JOIN/ORDER BY列建索引。', 2);

-- 事务与并发控制 (kp_id=23)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(75, 23, 'SINGLE_CHOICE', 'ACID中的I代表什么？',
 '[{"key":"A","text":"Isolation(隔离性)"},{"key":"B","text":"Index(索引)"},{"key":"C","text":"InnoDB"},{"key":"D","text":"Integrity(完整性)"}]',
 'A', 'ACID：Atomicity原子性、Consistency一致性、Isolation隔离性、Durability持久性。', 1),
(76, 23, 'SINGLE_CHOICE', 'MySQL默认的事务隔离级别是什么？',
 '[{"key":"A","text":"READ UNCOMMITTED"},{"key":"B","text":"READ COMMITTED"},{"key":"C","text":"REPEATABLE READ"},{"key":"D","text":"SERIALIZABLE"}]',
 'C', 'MySQL InnoDB默认REPEATABLE READ(可重复读)。Oracle/PostgreSQL默认READ COMMITTED。', 2),
(77, 23, 'SINGLE_CHOICE', 'MVCC主要解决什么问题？',
 '[{"key":"A","text":"读-写冲突(读写不阻塞)"},{"key":"B","text":"写-写冲突"},{"key":"C","text":"磁盘IO优化"},{"key":"D","text":"网络延迟"}]',
 'A', 'MVCC(多版本并发控制)通过保存数据的多个版本，使得读操作不加锁，写操作也不阻塞读，提高并发性能。', 2),
(78, 23, 'MULTI_CHOICE', '以下哪些是死锁的必要条件？(多选)',
 '[{"key":"A","text":"互斥条件"},{"key":"B","text":"请求保持"},{"key":"C","text":"不可剥夺"},{"key":"D","text":"循环等待"}]',
 'ABCD', '死锁四个必要条件：互斥、请求保持(占有并等待)、不可剥夺、循环等待。破坏任意一个即可预防死锁。', 3);

-- 数据库设计范式 (kp_id=24)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(79, 24, 'SINGLE_CHOICE', '第一范式(1NF)要求什么？',
 '[{"key":"A","text":"没有部分函数依赖"},{"key":"B","text":"每个属性都是原子的不可再分"},{"key":"C","text":"没有传递函数依赖"},{"key":"D","text":"至少有一个主键"}]',
 'B', '1NF：属性原子性，每个字段不可再分(如不能在一个字段存多个电话号码)。消除部分依赖是2NF。消除传递依赖是3NF。', 1),
(80, 24, 'SINGLE_CHOICE', '第三范式(3NF)消除了什么？',
 '[{"key":"A","text":"重复数据"},{"key":"B","text":"部分函数依赖"},{"key":"C","text":"传递函数依赖"},{"key":"D","text":"多值依赖"}]',
 'C', '3NF消除非主属性对主键的传递函数依赖。2NF消除非主属性对主键的部分函数依赖。', 2),
(81, 24, 'TRUE_FALSE', '在实际项目中，有时故意违反范式化(反范式化)来提升查询性能。',
 null, 'true', '反范式化(denormalization)通过增加冗余减少JOIN，用空间换时间。常见于读多写少的OLAP场景。但需要维护数据一致性。', 2);

-- OSI七层模型 (kp_id=25)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(82, 25, 'SINGLE_CHOICE', 'OSI七层模型中，哪一层负责路由选择？',
 '[{"key":"A","text":"数据链路层"},{"key":"B","text":"网络层"},{"key":"C","text":"传输层"},{"key":"D","text":"应用层"}]',
 'B', '网络层(第3层)负责路由选择和逻辑寻址(IP地址)。数据链路层(第2层)负责MAC寻址。传输层(第4层)负责端到端通信。', 1),
(83, 25, 'SINGLE_CHOICE', '以下从下到上正确的OSI层次顺序是？',
 '[{"key":"A","text":"物理层→数据链路层→网络层→传输层→会话层→表示层→应用层"},{"key":"B","text":"应用层→传输层→网络层→数据链路层→物理层"},{"key":"C","text":"物理层→网络层→数据链路层→传输层→应用层"},{"key":"D","text":"物理层→数据链路层→传输层→网络层→会话层→表示层→应用层"}]',
 'A', 'OSI七层从下到上：物理层(1)、数据链路层(2)、网络层(3)、传输层(4)、会话层(5)、表示层(6)、应用层(7)。', 1),
(84, 25, 'TRUE_FALSE', 'TCP/IP模型只有4层，比OSI模型少了3层。',
 null, 'true', 'TCP/IP模型为4层：网络接口层、网络层、传输层、应用层。OSI为7层。TCP/IP没有单独的会话层和表示层，其功能合并到应用层。', 2);

-- TCP/IP协议栈 (kp_id=26)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(85, 26, 'SINGLE_CHOICE', 'TCP三次握手中，第一次握手客户端发送什么标志位？',
 '[{"key":"A","text":"ACK"},{"key":"B","text":"SYN"},{"key":"C","text":"FIN"},{"key":"D","text":"RST"}]',
 'B', '第一次：客户端→服务器 SYN。第二次：服务器→客户端 SYN+ACK。第三次：客户端→服务器 ACK。SYN用于建立连接，FIN用于断开连接。', 2),
(86, 26, 'SINGLE_CHOICE', 'TCP四次挥手时，TIME_WAIT状态持续多久？',
 '[{"key":"A","text":"1秒"},{"key":"B","text":"2MSL(最长报文段寿命的两倍)"},{"key":"C","text":"30秒"},{"key":"D","text":"永久"}]',
 'B', 'TIME_WAIT持续2MSL(通常约1-4分钟)，确保最后的ACK能到达服务器，也确保该连接的旧数据包在网络中消失。', 3),
(87, 26, 'SINGLE_CHOICE', '子网掩码255.255.255.0对应的CIDR表示是？',
 '[{"key":"A","text":"/8"},{"key":"B","text":"/16"},{"key":"C","text":"/24"},{"key":"D","text":"/32"}]',
 'C', '255.255.255.0 = 11111111.11111111.11111111.0 = 24个1 = /24。255.0.0.0=/8，255.255.0.0=/16。', 1);

-- HTTP协议 (kp_id=27)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(88, 27, 'SINGLE_CHOICE', 'HTTP状态码404表示什么？',
 '[{"key":"A","text":"服务器内部错误"},{"key":"B","text":"资源未找到(Not Found)"},{"key":"C","text":"请求未授权"},{"key":"D","text":"重定向"}]',
 'B', '404=Not Found资源未找到。500=服务器内部错误。401=未授权。403=禁止访问。301/302=重定向。', 1),
(89, 27, 'SINGLE_CHOICE', 'HTTP和HTTPS的主要区别是什么？',
 '[{"key":"A","text":"HTTPS使用443端口且基于TLS加密"},{"key":"B","text":"HTTPS速度更快"},{"key":"C","text":"HTTPS不用DNS"},{"key":"D","text":"没有区别"}]',
 'A', 'HTTPS=HTTP+TLS/SSL，默认端口443(HTTP是80)，提供加密、身份验证和数据完整性。', 1),
(90, 27, 'SINGLE_CHOICE', 'GET和POST请求的主要区别是什么？',
 '[{"key":"A","text":"GET可缓存可收藏，POST通常不缓存"},{"key":"B","text":"GET更快"},{"key":"C","text":"POST可以传参GET不能"},{"key":"D","text":"没有区别"}]',
 'A', 'GET是幂等的(可缓存/书签)，参数在URL中(有长度限制)。POST数据在请求体，适合提交数据。GET也能传参只是在URL中。', 2),
(91, 27, 'TRUE_FALSE', 'Cookie和Session的主要区别是Cookie存在客户端，Session存在服务器端。',
 null, 'true', 'Cookie存储在浏览器(客户端)，Session存储在服务器。Session通常通过Cookie中的SessionID来识别用户。', 2);

-- DNS域名解析 (kp_id=28)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(92, 28, 'SINGLE_CHOICE', 'DNS解析中A记录的作用是什么？',
 '[{"key":"A","text":"域名→IPv4地址"},{"key":"B","text":"域名→IPv6地址"},{"key":"C","text":"域名→邮件服务器"},{"key":"D","text":"域名→别名"}]',
 'A', 'A记录：域名→IPv4地址。AAAA记录：域名→IPv6。MX记录：邮件服务器。CNAME：别名指向。', 1),
(93, 28, 'SINGLE_CHOICE', 'CDN利用什么机制将用户导向最近的节点？',
 '[{"key":"A","text":"ARP协议"},{"key":"B","text":"DNS智能解析"},{"key":"C","text":"ICMP协议"},{"key":"D","text":"DHCP协议"}]',
 'B', 'CDN通过DNS智能解析，根据用户IP返回最近的边缘节点IP，减少延迟。', 2),
(94, 28, 'TRUE_FALSE', 'DNS通常使用TCP协议进行域名解析。',
 null, 'false', 'DNS默认使用UDP协议(端口53)，因为查询报文小、速度快。区域传输(zone transfer)和大响应(>512字节)使用TCP。', 2);

-- 网络安全基础 (kp_id=29)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(95, 29, 'SINGLE_CHOICE', '对称加密和非对称加密的主要区别是什么？',
 '[{"key":"A","text":"对称加密用同一密钥加密解密"},{"key":"B","text":"非对称加密更快"},{"key":"C","text":"对称加密更安全"},{"key":"D","text":"没有区别"}]',
 'A', '对称加密：加密解密用同一密钥(如AES)，速度快。非对称：公钥加密私钥解密(如RSA)，速度慢但解决密钥分发问题。', 1),
(96, 29, 'SINGLE_CHOICE', 'SQL注入攻击的根本原因是什么？',
 '[{"key":"A","text":"数据库版本太旧"},{"key":"B","text":"用户输入被当作SQL代码执行"},{"key":"C","text":"使用了MySQL"},{"key":"D","text":"防火墙配置错误"}]',
 'B', 'SQL注入因拼接用户输入到SQL语句中。防御：使用PreparedStatement/参数化查询，输入校验，最小权限原则。', 1),
(97, 29, 'SINGLE_CHOICE', 'HTTPS中使用的数字证书由谁签发？',
 '[{"key":"A","text":"浏览器"},{"key":"B","text":"CA(证书颁发机构)"},{"key":"C","text":"网站自己"},{"key":"D","text":"ISP"}]',
 'B', '数字证书由CA(Certificate Authority，如Let''s Encrypt、DigiCert)签发。自签名证书可自己签发但浏览器不信任。', 2),
(98, 29, 'MULTI_CHOICE', '以下哪些是防御XSS攻击的有效方法？(多选)',
 '[{"key":"A","text":"对用户输入进行HTML转义"},{"key":"B","text":"使用CSP(内容安全策略)"},{"key":"C","text":"设置HttpOnly Cookie"},{"key":"D","text":"使用telnet代替HTTP"}]',
 'ABC', 'XSS防御：输入输出转义、CSP限制资源来源、HttpOnly防JS读取Cookie。CSP是HTTP头，HttpOnly是Cookie属性。', 3);

-- ========== Additional Questions (from verified sources) ==========

-- Java基础语法 补充 (kp_id=1)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(99, 1, 'SINGLE_CHOICE', '以下代码的输出是什么？System.out.println(1+2+"3"+4+5);',
 '[{"key":"A","text":"3345"},{"key":"B","text":"12345"},{"key":"C","text":"15"},{"key":"D","text":"编译错误"}]',
 'A', '表达式从左到右计算：1+2=3，3+"3"="33"，"33"+4="334"，"334"+5="3345"。遇到字符串后全部转为字符串拼接。', 2),
(100, 1, 'SINGLE_CHOICE', '以下哪个不是Java的关键字？',
 '[{"key":"A","text":"goto"},{"key":"B","text":"const"},{"key":"C","text":"true"},{"key":"D","text":"sizeof"}]',
 'D', 'goto和const是Java的保留关键字(未使用)。true是布尔字面量。sizeof不是Java关键字(C/C++才有)。', 1),
(101, 1, 'SINGLE_CHOICE', '基本数据类型中，int占几个字节？',
 '[{"key":"A","text":"1"},{"key":"B","text":"2"},{"key":"C","text":"4"},{"key":"D","text":"8"}]',
 'C', 'int占4字节(32位)。byte=1字节，short=2字节，long=8字节，float=4字节，double=8字节，char=2字节。', 1),
(102, 1, 'SINGLE_CHOICE', '以下哪个是正确的变量命名？',
 '[{"key":"A","text":"class"},{"key":"B","text":"2name"},{"key":"C","text":"_value"},{"key":"D","text":"my-name"}]',
 'C', '变量名不能是关键字(class)，不能以数字开头(2name)，不能包含连字符(my-name)。下划线开头是合法的。', 1),
(103, 1, 'TRUE_FALSE', 'Java中的char类型使用ASCII编码，每个字符占1个字节。',
 null, 'false', 'Java的char使用Unicode(UTF-16)编码，占2个字节(16位)，可以表示65536个字符。', 2),
(104, 1, 'SINGLE_CHOICE', '以下哪个不是Java的基本数据类型？',
 '[{"key":"A","text":"byte"},{"key":"B","text":"short"},{"key":"C","text":"long"},{"key":"D","text":"Long"}]',
 'D', 'Long是包装类(引用类型)，基本类型是long(小写)。8种基本类型：byte/short/int/long/float/double/char/boolean。', 1),
(105, 1, 'SINGLE_CHOICE', '以下代码的输出结果是什么？int a=10; int b=a++ + ++a; System.out.println(b);',
 '[{"key":"A","text":"20"},{"key":"B","text":"21"},{"key":"C","text":"22"},{"key":"D","text":"23"}]',
 'C', 'a++返回10然后a变成11，++a先加再返回，a变成12返回12，10+12=22。', 2),
(106, 1, 'SINGLE_CHOICE', 'switch语句中，case后面可以跟什么类型的值？',
 '[{"key":"A","text":"double"},{"key":"B","text":"float"},{"key":"C","text":"String"},{"key":"D","text":"boolean"}]',
 'C', 'switch支持byte/short/int/char及其包装类、String(JDK7+)、枚举。不支持float/double/boolean。', 2);

-- 面向对象编程 补充 (kp_id=2)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(107, 2, 'SINGLE_CHOICE', '关于抽象类和接口的区别，以下说法错误的是？',
 '[{"key":"A","text":"抽象类可以有构造方法，接口不能"},{"key":"B","text":"一个类可以实现多个接口"},{"key":"C","text":"接口中的方法必须有方法体"},{"key":"D","text":"抽象类可以有非抽象方法"}]',
 'C', '接口中的抽象方法没有方法体(默认public abstract)。JDK8后接口可以有default方法(有方法体)和static方法。', 2),
(108, 2, 'SINGLE_CHOICE', '以下哪个修饰符表示子类可以访问但其他包不能访问？',
 '[{"key":"A","text":"private"},{"key":"B","text":"default"},{"key":"C","text":"protected"},{"key":"D","text":"public"}]',
 'C', 'protected：同一个包+不同包的子类可访问。private：仅本类。default：仅同包。public：全部可访问。', 1),
(109, 2, 'SINGLE_CHOICE', '以下代码是否正确？class A { private A() {} } class B extends A {}',
 '[{"key":"A","text":"正确，B可以继承A"},{"key":"B","text":"编译错误，B无法调用A的构造方法"},{"key":"C","text":"正确，B自动生成构造方法"},{"key":"D","text":"运行时错误"}]',
 'B', 'B的构造方法隐式调用super()但A的构造方法是private的，B无法访问，编译错误。', 2),
(110, 2, 'SINGLE_CHOICE', '关于方法重载(Overload)，以下说法正确的是？',
 '[{"key":"A","text":"必须改变返回值类型"},{"key":"B","text":"参数列表必须不同"},{"key":"C","text":"可以仅通过返回值类型区分"},{"key":"D","text":"方法名必须不同"}]',
 'B', '重载要求方法名相同、参数列表不同(个数/类型/顺序)。返回值类型不能作为重载的区分依据。', 1),
(111, 2, 'TRUE_FALSE', '子类重写父类方法时，访问权限可以比父类更严格。',
 null, 'false', '重写时访问权限不能比父类更严格(只能更宽松)。如父类protected，子类可以是protected或public，不能是private。', 2),
(112, 2, 'SINGLE_CHOICE', '以下关于static的说法，哪个是错误的？',
 '[{"key":"A","text":"静态方法中不能使用this关键字"},{"key":"B","text":"静态变量在类加载时初始化"},{"key":"C","text":"静态方法可以直接调用非静态方法"},{"key":"D","text":"静态代码块在类加载时执行"}]',
 'C', '静态方法不能直接调用非静态方法，因为非静态方法需要实例对象。需要通过对象引用调用。', 2),
(113, 2, 'SINGLE_CHOICE', '以下代码输出什么？class A{static void f(){System.out.println("A");}} class B extends A{static void f(){System.out.println("B");}} A a=new B(); a.f();',
 '[{"key":"A","text":"A"},{"key":"B","text":"B"},{"key":"C","text":"编译错误"},{"key":"D","text":"AB"}]',
 'A', '静态方法不能被重写(只能被隐藏)。调用时看引用类型(A)，不看实际对象类型(B)。所以输出A。', 3);

-- 异常处理机制 补充 (kp_id=3)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(114, 3, 'SINGLE_CHOICE', '以下哪个是运行时异常(RuntimeException)？',
 '[{"key":"A","text":"IOException"},{"key":"B","text":"SQLException"},{"key":"C","text":"ClassNotFoundException"},{"key":"D","text":"ArrayIndexOutOfBoundsException"}]',
 'D', 'ArrayIndexOutOfBoundsException是RuntimeException子类。前三个都是受检异常(checked exception)。', 1),
(115, 3, 'SINGLE_CHOICE', '以下代码finally块会执行吗？try{System.exit(0);}finally{System.out.println("end");}',
 '[{"key":"A","text":"会执行，输出end"},{"key":"B","text":"不会执行"},{"key":"C","text":"编译错误"},{"key":"D","text":"取决于异常"}]',
 'B', 'System.exit(0)会导致JVM立即终止，finally块不会执行。这是finally不执行的唯一情况(除JVM崩溃)。', 2),
(116, 3, 'TRUE_FALSE', 'try块后面可以只跟finally块，不跟catch块。',
 null, 'true', 'try-finally是合法的，如try{...}finally{...}。用于不需要捕获异常但需要释放资源的场景。', 1),
(117, 3, 'SINGLE_CHOICE', '关于throw和throws，以下说法正确的是？',
 '[{"key":"A","text":"throw用于方法声明，throws用于抛出异常"},{"key":"B","text":"throw用于抛出异常，throws用于方法声明"},{"key":"C","text":"两者功能完全相同"},{"key":"D","text":"throws只能用于受检异常"}]',
 'B', 'throw用于方法体内抛出异常对象。throws用于方法签名声明可能抛出的异常类型。throws可用于任何异常类型。', 1),
(118, 3, 'MULTI_CHOICE', '以下哪些是Error的子类？(多选)',
 '[{"key":"A","text":"StackOverflowError"},{"key":"B","text":"OutOfMemoryError"},{"key":"C","text":"NoClassDefFoundError"},{"key":"D","text":"NullPointerException"}]',
 'ABC', '前三个都是Error(严重问题，程序通常无法处理)。NullPointerException是RuntimeException。', 2);

-- 集合框架 补充 (kp_id=4)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(119, 4, 'SINGLE_CHOICE', 'TreeMap的底层数据结构是什么？',
 '[{"key":"A","text":"数组"},{"key":"B","text":"链表"},{"key":"C","text":"红黑树"},{"key":"D","text":"哈希表"}]',
 'C', 'TreeMap基于红黑树实现，可以按key自然排序或自定义Comparator排序。HashMap基于数组+链表+红黑树。', 1),
(120, 4, 'SINGLE_CHOICE', '以下哪个集合不允许null元素？',
 '[{"key":"A","text":"ArrayList"},{"key":"B","text":"HashMap"},{"key":"C","text":"HashSet"},{"key":"D","text":"Hashtable"}]',
 'D', 'Hashtable不允许null的key和value。HashMap允许一个null key和多个null value。ArrayList和HashSet允许null元素。', 2),
(121, 4, 'SINGLE_CHOICE', '以下关于HashMap的说法，错误的是？',
 '[{"key":"A","text":"允许null键和null值"},{"key":"B","text":"线程不安全"},{"key":"C","text":"元素有序"},{"key":"D","text":"默认初始容量16"}]',
 'C', 'HashMap元素无序。LinkedHashMap用双向链表维护插入顺序。TreeMap按键排序。', 1),
(122, 4, 'MULTI_CHOICE', '以下哪些是List接口的实现类？(多选)',
 '[{"key":"A","text":"ArrayList"},{"key":"B","text":"LinkedList"},{"key":"C","text":"HashSet"},{"key":"D","text":"Vector"}]',
 'ABD', 'ArrayList、LinkedList、Vector(以及Stack)都实现了List接口。HashSet实现了Set接口。', 1),
(123, 4, 'SINGLE_CHOICE', 'ArrayList的默认初始容量是多少？',
 '[{"key":"A","text":"8"},{"key":"B","text":"10"},{"key":"C","text":"16"},{"key":"D","text":"0"}]',
 'B', 'ArrayList默认初始容量为10(JDK6-)。JDK7+中new ArrayList()初始为空数组，第一次add时扩容到10。HashMap默认16。', 2),
(124, 4, 'SINGLE_CHOICE', '使用Iterator遍历ArrayList时删除元素，正确的方式是？',
 '[{"key":"A","text":"list.remove(obj)"},{"key":"B","text":"iterator.remove()"},{"key":"C","text":"list.remove(index)"},{"key":"D","text":"直接赋值null"}]',
 'B', '遍历时删除必须用Iterator的remove()方法，否则会抛ConcurrentModificationException。或者用removeIf()(JDK8+)。', 2),
(125, 4, 'SINGLE_CHOICE', '以下代码输出什么？List<Integer> list=new ArrayList<>(); list.add(1); list.add(2); list.add(1); System.out.println(list.size());',
 '[{"key":"A","text":"1"},{"key":"B","text":"2"},{"key":"C","text":"3"},{"key":"D","text":"4"}]',
 'C', 'ArrayList允许重复元素，List的size()返回元素个数。如果是不允许重复的Set则size=2。', 1);

-- 多线程编程 补充 (kp_id=5)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(126, 5, 'SINGLE_CHOICE', '线程的start()方法和run()方法的区别是？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"start()创建新线程，run()在当前线程执行"},{"key":"C","text":"run()创建新线程，start()在当前线程执行"},{"key":"D","text":"start()是静态方法"}]',
 'B', 'start()会创建新线程并在新线程中执行run()。直接调用run()只会在当前线程执行，不会创建新线程。', 1),
(127, 5, 'SINGLE_CHOICE', '以下哪个方法可以让线程进入等待状态？',
 '[{"key":"A","text":"Thread.sleep()"},{"key":"B","text":"Thread.run()"},{"key":"C","text":"Thread.notify()"},{"key":"D","text":"Thread.interrupt()"}]',
 'A', 'Thread.sleep()让当前线程休眠指定毫秒。wait()让线程等待直到被notify。notify()唤醒等待线程。interrupt()中断线程。', 1),
(128, 5, 'TRUE_FALSE', '一个Java程序至少有一个线程在运行。',
 null, 'true', 'JVM启动时会创建main线程(运行main方法)以及GC线程、Finalizer线程等后台线程。', 1),
(129, 5, 'SINGLE_CHOICE', '以下哪个关键字用于解决线程间的可见性问题？',
 '[{"key":"A","text":"final"},{"key":"B","text":"static"},{"key":"C","text":"volatile"},{"key":"D","text":"abstract"}]',
 'C', 'volatile保证变量的可见性(修改后立即刷新到主内存)和禁止指令重排序。但不保证原子性。', 2),
(130, 5, 'SINGLE_CHOICE', 'Deadlock(死锁)的四个必要条件不包括以下哪个？',
 '[{"key":"A","text":"互斥条件"},{"key":"B","text":"请求保持"},{"key":"C","text":"优先级抢占"},{"key":"D","text":"循环等待"}]',
 'C', '死锁四条件：互斥、请求保持(占有并等待)、不可剥夺、循环等待。优先级抢占不是死锁的必要条件。', 2),
(131, 5, 'MULTI_CHOICE', '以下哪些是创建线程池的方式？(多选)',
 '[{"key":"A","text":"Executors.newFixedThreadPool()"},{"key":"B","text":"Executors.newCachedThreadPool()"},{"key":"C","text":"new ThreadPoolExecutor()"},{"key":"D","text":"new Thread()"}]',
 'ABC', '前三种是创建线程池的方式。new Thread()创建单个线程不创建线程池。推荐用ThreadPoolExecutor构造函数自定义参数。', 2),
(132, 5, 'SINGLE_CHOICE', 'synchronized和Lock的主要区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"Lock可以尝试非阻塞获取锁"},{"key":"C","text":"synchronized更灵活"},{"key":"D","text":"Lock自动释放锁"}]',
 'B', 'Lock接口提供tryLock()(非阻塞)、lockInterruptibly()(可中断)、tryLock(timeout)(超时)。synchronized自动释放，Lock需要finally中unlock。', 2);

-- JDBC数据库连接 补充 (kp_id=6)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(133, 6, 'SINGLE_CHOICE', 'JDBC中加载数据库驱动使用哪个方法？',
 '[{"key":"A","text":"Class.forName()"},{"key":"B","text":"DriverManager.getConnection()"},{"key":"C","text":"Class.load()"},{"key":"D","text":"Class.newInstance()"}]',
 'A', 'JDBC4.0之前需要显式Class.forName("com.mysql.cj.jdbc.Driver")加载驱动。JDBC4.0+通过SPI机制自动加载。', 2),
(134, 6, 'TRUE_FALSE', 'JDBC中的Statement是线程安全的。',
 null, 'false', 'Statement和ResultSet都不是线程安全的。每个线程应该使用自己的Statement实例，或用ThreadLocal管理。', 2),
(135, 6, 'SINGLE_CHOICE', '使用JDBC连接池的主要目的是什么？',
 '[{"key":"A","text":"提高SQL执行速度"},{"key":"B","text":"复用数据库连接，减少创建销毁开销"},{"key":"C","text":"自动生成SQL"},{"key":"D","text":"代替JDBC驱动"}]',
 'B', '连接池(如HikariCP/Druid)复用连接，避免频繁创建/销毁TCP连接的开销。常用连接池：HikariCP、Druid、C3P0。', 1),
(136, 6, 'SINGLE_CHOICE', 'PreparedStatement相比Statement的优势不包括？',
 '[{"key":"A","text":"防止SQL注入"},{"key":"B","text":"预编译提高效率"},{"key":"C","text":"代码更简洁"},{"key":"D","text":"自动关闭连接"}]',
 'D', 'PreparedStatement不会自动关闭连接。优势：防SQL注入、预编译(同一SQL多次执行更快)、类型安全(setInt/setString)。', 1);

-- Spring框架基础 补充 (kp_id=7)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(137, 7, 'SINGLE_CHOICE', 'Spring中Bean的默认作用域(scope)是什么？',
 '[{"key":"A","text":"prototype"},{"key":"B","text":"singleton"},{"key":"C","text":"request"},{"key":"D","text":"session"}]',
 'B', 'Spring Bean默认是singleton(单例)，整个IoC容器中只有一个实例。prototype每次获取都创建新实例。', 1),
(138, 7, 'SINGLE_CHOICE', '@Autowired和@Resource的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"@Autowired默认按类型，@Resource默认按名称"},{"key":"C","text":"@Autowired默认按名称，@Resource默认按类型"},{"key":"D","text":"@Autowired只能用于字段"}]',
 'B', '@Autowired是Spring注解，默认按类型注入。@Resource是JDK注解，默认按名称注入。', 2),
(139, 7, 'SINGLE_CHOICE', '以下哪个不是Spring AOP的通知类型？',
 '[{"key":"A","text":"@Before"},{"key":"B","text":"@After"},{"key":"C","text":"@Around"},{"key":"D","text":"@Middle"}]',
 'D', 'Spring AOP有5种通知：@Before(前置)、@After(后置)、@AfterReturning(返回后)、@AfterThrowing(异常后)、@Around(环绕)。没有@Middle。', 2),
(140, 7, 'SINGLE_CHOICE', 'Spring Boot的自动配置是通过哪个注解实现的？',
 '[{"key":"A","text":"@Configuration"},{"key":"B","text":"@EnableAutoConfiguration"},{"key":"C","text":"@Component"},{"key":"D","text":"@Service"}]',
 'B', '@EnableAutoConfiguration(或@SpringBootApplication中包含的)通过spring.factories加载自动配置类，根据条件决定是否生效。', 2),
(141, 7, 'TRUE_FALSE', 'Spring中，@Component和@Bean的作用完全相同。',
 null, 'false', '@Component用于类上让Spring扫描并注册为Bean。@Bean用于@Configuration类的方法上，手动声明Bean。@Component是类级别自动扫描，@Bean是方法级别手动声明。', 2),
(142, 7, 'SINGLE_CHOICE', 'Spring MVC中，@RequestMapping的作用是什么？',
 '[{"key":"A","text":"注入Bean"},{"key":"B","text":"映射HTTP请求到处理方法"},{"key":"C","text":"配置数据库"},{"key":"D","text":"管理事务"}]',
 'B', '@RequestMapping(及其快捷注解@GetMapping/@PostMapping等)将HTTP请求URL、方法映射到Controller的处理方法上。', 1);

-- 数组与链表 补充 (kp_id=8)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(143, 8, 'SINGLE_CHOICE', '在单链表中删除一个已知指针的节点，时间复杂度是多少？',
 '[{"key":"A","text":"O(1)"},{"key":"B","text":"O(n)"},{"key":"C","text":"O(log n)"},{"key":"D","text":"O(n²)"}]',
 'B', '单链表中删除节点需要找到前驱节点，需要从头遍历，O(n)。但如果已知前驱节点，删除是O(1)。双向链表已知节点删除是O(1)。', 2),
(144, 8, 'SINGLE_CHOICE', '稀疏矩阵常用的压缩存储方式是什么？',
 '[{"key":"A","text":"二维数组"},{"key":"B","text":"三元组表和十字链表"},{"key":"C","text":"邻接矩阵"},{"key":"D","text":"哈希表"}]',
 'B', '稀疏矩阵非零元素少，用三元组(行,列,值)或十字链表压缩存储可以节省空间。', 2),
(145, 8, 'TRUE_FALSE', '数组的存储地址必须是连续的，链表的存储地址可以不连续。',
 null, 'true', '数组在内存中需要连续空间，支持O(1)随机访问。链表节点可以分散存储，通过指针连接，不需要连续空间。', 1),
(146, 8, 'SINGLE_CHOICE', '循环链表的主要优点是什么？',
 '[{"key":"A","text":"节省存储空间"},{"key":"B","text":"从任意节点出发可以遍历整个链表"},{"key":"C","text":"查找速度更快"},{"key":"D","text":"插入删除更简单"}]',
 'B', '循环链表的最后一个节点指向第一个节点，从任意节点出发都能遍历整个链表。其他优点与普通链表相同。', 1);

-- 栈与队列 补充 (kp_id=9)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(147, 9, 'SINGLE_CHOICE', '以下哪个不是栈的典型应用？',
 '[{"key":"A","text":"函数调用"},{"key":"B","text":"括号匹配"},{"key":"C","text":"表达式求值"},{"key":"D","text":"任务调度"}]',
 'D', '任务调度通常用队列(FCFS/FIFO)或优先队列。函数调用(调用栈)、括号匹配、表达式求值(后缀表达式)都是栈的典型应用。', 2),
(148, 9, 'SINGLE_CHOICE', '循环队列相对于普通顺序队列的优势是什么？',
 '[{"key":"A","text":"速度更快"},{"key":"B","text":"可以充分利用数组空间避免假溢出"},{"key":"C","text":"实现更简单"},{"key":"D","text":"支持随机访问"}]',
 'B', '循环队列通过取模运算重复利用数组空间，避免了顺序队列的"假溢出"问题(队尾到达数组末尾但队头前还有空间)。', 2),
(149, 9, 'TRUE_FALSE', '栈可以用两个队列来模拟实现。',
 null, 'true', '用两个队列可以模拟栈：push时加入非空队列；pop时将非空队列前n-1个元素移到另一个队列，剩下那个出队。', 3),
(150, 9, 'SINGLE_CHOICE', '以下哪种数据结构最适合实现浏览器的"后退"功能？',
 '[{"key":"A","text":"队列"},{"key":"B","text":"栈"},{"key":"C","text":"链表"},{"key":"D","text":"树"}]',
 'B', '浏览器后退是后进先出(LIFO)的典型场景。每次访问新页面push，后退时pop。也可以用两个栈实现前进/后退。', 1);

-- 树与二叉树 补充 (kp_id=10)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(151, 10, 'SINGLE_CHOICE', '一棵完全二叉树有100个节点，叶子节点数是多少？',
 '[{"key":"A","text":"49"},{"key":"B","text":"50"},{"key":"C","text":"51"},{"key":"D","text":"52"}]',
 'B', '完全二叉树中n0=n2+1，n=n0+n1+n2。完全二叉树n1=0或1。100=n0+n1+(n0-1)，若n1=0则n0=50.5不合法，若n1=1则n0=50。', 3),
(152, 10, 'SINGLE_CHOICE', '哈夫曼树(Huffman Tree)主要用于什么？',
 '[{"key":"A","text":"数据压缩编码"},{"key":"B","text":"数据加密"},{"key":"C","text":"排序"},{"key":"D","text":"查找"}]',
 'A', '哈夫曼树是一种带权路径长度最短的二叉树，用于哈夫曼编码(数据压缩)。频率高的字符用短编码，频率低的用长编码。', 1),
(153, 10, 'TRUE_FALSE', '二叉搜索树中删除一个节点总是需要O(log n)的时间。',
 null, 'false', '二叉搜索树删除操作的时间复杂度取决于树的高度。最坏情况(退化为链表)是O(n)，平均情况(平衡树)是O(log n)。', 2),
(154, 10, 'SINGLE_CHOICE', '某二叉树的前序遍历为ABCDEF，中序遍历为CBAEDF，后序遍历是什么？',
 '[{"key":"A","text":"CBEFDA"},{"key":"B","text":"CBEDFA"},{"key":"C","text":"FEDCBA"},{"key":"D","text":"CBEFAD"}]',
 'A', '由前序知A为根，中序中A左边CB为左子树右边EDF为右子树。递归构建：左子树前序BC中序CB，B为根C为左子；右子树前序DEF中序EDF，D为根E左F右。后序：CBE FDA→CBEFDA。', 3),
(155, 10, 'SINGLE_CHOICE', '堆(Heap)通常用哪种数据结构实现？',
 '[{"key":"A","text":"链表"},{"key":"B","text":"数组"},{"key":"C","text":"树节点"},{"key":"D","text":"图"}]',
 'B', '堆通常用数组实现完全二叉树。节点i的左孩子是2i+1，右孩子2i+2(0-index)。数组实现比树节点更节省空间。', 1);

-- 排序算法 补充 (kp_id=11)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(156, 11, 'SINGLE_CHOICE', '冒泡排序在最好情况下的时间复杂度是多少？',
 '[{"key":"A","text":"O(n)"},{"key":"B","text":"O(n log n)"},{"key":"C","text":"O(n²)"},{"key":"D","text":"O(1)"}]',
 'A', '冒泡排序最好情况(已经有序)只需一趟比较，无交换，O(n)。但需要设置flag判断是否有交换才能达到O(n)。', 1),
(157, 11, 'SINGLE_CHOICE', '希尔排序是以下哪种排序的改进版本？',
 '[{"key":"A","text":"冒泡排序"},{"key":"B","text":"插入排序"},{"key":"C","text":"选择排序"},{"key":"D","text":"归并排序"}]',
 'B', '希尔排序是插入排序的改进，通过分组(增量序列)让元素大步移动，减少最终插入排序的比较和移动次数。', 2),
(158, 11, 'TRUE_FALSE', '选择排序在任何情况下的时间复杂度都是O(n²)。',
 null, 'true', '选择排序无论数据是否有序，每趟都要在剩余n-i个元素中找最小/大值，始终执行n(n-1)/2次比较。', 1),
(159, 11, 'MULTI_CHOICE', '以下哪些排序算法平均时间复杂度为O(n log n)？(多选)',
 '[{"key":"A","text":"快速排序"},{"key":"B","text":"堆排序"},{"key":"C","text":"归并排序"},{"key":"D","text":"插入排序"}]',
 'ABC', '快排、堆排、归并排序平均都是O(n log n)。插入排序平均和最坏都是O(n²)。', 1),
(160, 11, 'SINGLE_CHOICE', '在文件基本有序的情况下，最佳排序算法是？',
 '[{"key":"A","text":"快速排序"},{"key":"B","text":"插入排序"},{"key":"C","text":"堆排序"},{"key":"D","text":"归并排序"}]',
 'B', '插入排序在基本有序时接近O(n)。快排在基本有序时若pivot选第一个会退化为O(n²)。', 2),
(161, 11, 'SINGLE_CHOICE', '外部排序常用的算法是什么？',
 '[{"key":"A","text":"快速排序"},{"key":"B","text":"归并排序"},{"key":"C","text":"插入排序"},{"key":"D","text":"计数排序"}]',
 'B', '外部排序(数据量大无法全部载入内存)常用多路归并排序，配合败者树/置换-选择排序优化。', 3);

-- 图论基础 补充 (kp_id=12)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(162, 12, 'SINGLE_CHOICE', 'n个顶点的无向完全图有多少条边？',
 '[{"key":"A","text":"n(n-1)"},{"key":"B","text":"n(n-1)/2"},{"key":"C","text":"n²"},{"key":"D","text":"2n"}]',
 'B', '无向完全图每对顶点之间都有一条边，共C(n,2)=n(n-1)/2条。有向完全图是n(n-1)条(两个方向各一条)。', 1),
(163, 12, 'SINGLE_CHOICE', '最小生成树的Kruskal算法和Prim算法的时间复杂度分别是？(V顶点,E边)',
 '[{"key":"A","text":"Kruskal:O(E log E), Prim:O(V²)"},{"key":"B","text":"Kruskal:O(V²), Prim:O(E log E)"},{"key":"C","text":"都是O(V²)"},{"key":"D","text":"都是O(E log E)"}]',
 'A', 'Kruskal用排序+并查集，O(E log E)。Prim朴素实现O(V²)，用优先队列优化为O((V+E)log V)≈O(E log V)。', 2),
(164, 12, 'TRUE_FALSE', '一个连通图的生成树可能不唯一。',
 null, 'true', '连通图通常有多个生成树。例如三角形的3个顶点有3种不同的生成树。最小生成树在边权各不相同时唯一。', 1),
(165, 12, 'SINGLE_CHOICE', '拓扑排序适用于什么样的图？',
 '[{"key":"A","text":"无向图"},{"key":"B","text":"有向无环图(DAG)"},{"key":"C","text":"完全图"},{"key":"D","text":"任意图"}]',
 'B', '拓扑排序只适用于有向无环图(DAG)，用于安排有依赖关系的任务顺序。有环的图无法拓扑排序。', 1);

-- 动态规划 补充 (kp_id=13)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(166, 13, 'SINGLE_CHOICE', '以下哪个问题不能用动态规划高效求解？',
 '[{"key":"A","text":"最长公共子序列"},{"key":"B","text":"0/1背包问题"},{"key":"C","text":"旅行商问题(TSP)"},{"key":"D","text":"斐波那契数列"}]',
 'C', 'TSP是NP-hard问题，DP求解复杂度O(n²2ⁿ)仅适用于小规模n。前三者都可用DP在多项式/伪多项式时间内求解。', 2),
(167, 13, 'SINGLE_CHOICE', '动态规划的两种实现方式是什么？',
 '[{"key":"A","text":"递归和循环"},{"key":"B","text":"自顶向下(记忆化)和自底向上(递推)"},{"key":"C","text":"BFS和DFS"},{"key":"D","text":"贪心和回溯"}]',
 'B', '自顶向下=递归+记忆化搜索(如用map缓存)。自底向上=从最小子问题迭代求解(如填DP表)。两者时间复杂度相同。', 1),
(168, 13, 'SINGLE_CHOICE', '最长公共子序列(LCS)问题的DP时间复杂度是？(m,n为两序列长度)',
 '[{"key":"A","text":"O(m+n)"},{"key":"B","text":"O(mn)"},{"key":"C","text":"O(mlog n)"},{"key":"D","text":"O(2^m)"}]',
 'B', 'LCS经典DP解法：dp[i][j]表示前i和前j个字符的LCS长度，O(mn)填表。空间可优化为O(min(m,n))。', 2),
(169, 13, 'TRUE_FALSE', '最优子结构性质是指：问题的最优解包含子问题的最优解。',
 null, 'true', '最优子结构是DP适用的必要条件之一。另一个是重叠子问题(子问题被重复求解)。如果子问题不重叠就是分治法。', 1);

-- 贪心算法 补充 (kp_id=14)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(170, 14, 'SINGLE_CHOICE', '贪心算法与动态规划的主要区别是什么？',
 '[{"key":"A","text":"贪心更快但可能得不到最优解"},{"key":"B","text":"贪心总是能得到最优解"},{"key":"C","text":"没有区别"},{"key":"D","text":"DP更快"}]',
 'A', '贪心每步做局部最优选择，不一定全局最优。DP穷举所有可能(但通过记忆化避免重复计算)保证全局最优。贪心比DP快但适用范围更窄。', 1),
(171, 14, 'SINGLE_CHOICE', '以下哪个是贪心算法的典型应用？',
 '[{"key":"A","text":"最长公共子序列"},{"key":"B","text":"活动选择问题"},{"key":"C","text":"0/1背包问题"},{"key":"D","text":"矩阵链乘法"}]',
 'B', '活动选择问题(选择最多的不冲突活动)可用贪心(按结束时间排序每次选最早结束的)。0/1背包贪心不保证最优(需DP)。', 2),
(172, 14, 'TRUE_FALSE', '贪心算法一定比动态规划执行速度快。',
 null, 'false', '一般贪心更快，但不总是。如果贪心选择需要排序等预处理(如Kruskal需要排序边)，开销可能比较大。', 2);

-- Python基础语法 补充 (kp_id=15)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(173, 15, 'SINGLE_CHOICE', 'Python中以下哪个不是合法的数据类型？',
 '[{"key":"A","text":"int"},{"key":"B","text":"float"},{"key":"C","text":"char"},{"key":"D","text":"str"}]',
 'C', 'Python没有char类型，单个字符也用str表示(长度为1的字符串)。Java/C语言才有char类型。', 1),
(174, 15, 'SINGLE_CHOICE', '以下代码输出什么？print(0.1+0.2==0.3)',
 '[{"key":"A","text":"True"},{"key":"B","text":"False"},{"key":"C","text":"报错"},{"key":"D","text":"None"}]',
 'B', '浮点数精度问题：0.1+0.2=0.30000000000000004≠0.3。这是IEEE 754浮点数的固有问题，不是Python特有的。', 2),
(175, 15, 'SINGLE_CHOICE', 'Python中列表推导式[x*2 for x in range(5) if x%2==0]的结果是什么？',
 '[{"key":"A","text":"[0, 2, 4, 6, 8]"},{"key":"B","text":"[0, 4, 8]"},{"key":"C","text":"[2, 6]"},{"key":"D","text":"报错"}]',
 'B', 'range(5)=[0,1,2,3,4]，筛选偶数[0,2,4]，乘以2得[0,4,8]。', 1),
(176, 15, 'SINGLE_CHOICE', '以下哪个关键字用于Python中的异常处理？',
 '[{"key":"A","text":"try-except"},{"key":"B","text":"try-catch"},{"key":"C","text":"begin-rescue"},{"key":"D","text":"try-finally(没有except)"}]',
 'A', 'Python用try-except-finally，Java用try-catch-finally，Ruby用begin-rescue。', 1),
(177, 15, 'MULTI_CHOICE', '以下哪些是Python中创建空列表的正确方式？(多选)',
 '[{"key":"A","text":"[]"},{"key":"B","text":"list()"},{"key":"C","text":"{}"},{"key":"D","text":"new List()"}]',
 'AB', '[]和list()都可创建空列表。{}创建空字典。Python没有new关键字。', 1),
(178, 15, 'SINGLE_CHOICE', 'Python中的lambda函数是什么？',
 '[{"key":"A","text":"一种类定义"},{"key":"B","text":"匿名函数"},{"key":"C","text":"循环结构"},{"key":"D","text":"模块导入方式"}]',
 'B', 'lambda是匿名函数，语法：lambda 参数: 表达式。通常用于需要简单函数的地方如map(lambda x: x*2, lst)。', 2),
(179, 15, 'SINGLE_CHOICE', '以下代码输出什么？print(type([1,2,3]) == list)',
 '[{"key":"A","text":"True"},{"key":"B","text":"False"},{"key":"C","text":"报错"},{"key":"D","text":"None"}]',
 'A', 'type()返回对象的类型，与list比较为True。也可以用isinstance([1,2,3], list)。', 1);

-- NumPy数组操作 补充 (kp_id=16)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(180, 16, 'SINGLE_CHOICE', '以下哪个是NumPy创建等差数组的函数？',
 '[{"key":"A","text":"np.arange()"},{"key":"B","text":"np.zeros()"},{"key":"C","text":"np.ones()"},{"key":"D","text":"np.full()"}]',
 'A', 'np.arange(start,stop,step)创建等差数组。np.linspace(start,stop,num)创建等间距数组(指定元素个数)。', 1),
(181, 16, 'SINGLE_CHOICE', 'NumPy中ndarray.shape属性返回什么？',
 '[{"key":"A","text":"数组的数据类型"},{"key":"B","text":"数组各维度的长度元组"},{"key":"C","text":"数组的元素个数"},{"key":"D","text":"数组的字节大小"}]',
 'B', 'shape返回各维度长度元组如(3,4)表示3行4列。ndim返回维度数。size返回总元素数。dtype返回数据类型。', 1),
(182, 16, 'TRUE_FALSE', 'NumPy的广播机制要求两个数组在每一个维度上长度相同或其中一个为1。',
 null, 'true', '广播规则：从末尾维度开始比较，两个维度相等或其中一个为1则可广播。缺失的维度视为1。', 2),
(183, 16, 'SINGLE_CHOICE', 'np.reshape(arr, (2, -1))中，-1代表什么？',
 '[{"key":"A","text":"无效值"},{"key":"B","text":"自动计算该维度长度"},{"key":"C","text":"该维度长度为1"},{"key":"D","text":"扁平化"}]',
 'B', '-1表示该维度长度由NumPy自动推算，保证总元素数不变。只能有一个维度用-1。', 2),
(184, 16, 'SINGLE_CHOICE', 'NumPy中布尔索引arr[arr > 5]的作用是什么？',
 '[{"key":"A","text":"将大于5的元素替换为5"},{"key":"B","text":"返回所有大于5的元素组成的一维数组"},{"key":"C","text":"返回布尔数组"},{"key":"D","text":"报错"}]',
 'B', '布尔索引返回满足条件的元素组成的一维数组。arr>5生成布尔数组，arr[bool_arr]提取True位置的元素。', 2);

-- Pandas数据处理 补充 (kp_id=17)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(185, 17, 'SINGLE_CHOICE', 'Pandas中df.head(n)的作用是什么？',
 '[{"key":"A","text":"返回最后n行"},{"key":"B","text":"返回前n行(默认5)"},{"key":"C","text":"返回第n行"},{"key":"D","text":"删除前n行"}]',
 'B', 'head(n)返回前n行。tail(n)返回后n行。默认n=5。常用于快速预览数据。', 1),
(186, 17, 'SINGLE_CHOICE', '如何删除DataFrame中的缺失值所在的行？',
 '[{"key":"A","text":"df.fillna(0)"},{"key":"B","text":"df.dropna()"},{"key":"C","text":"df.replace(NaN, 0)"},{"key":"D","text":"df.remove_na()"}]',
 'B', 'dropna()删除含NaN的行(默认axis=0)或列(axis=1)。fillna()填充缺失值。没有remove_na()方法。', 1),
(187, 17, 'TRUE_FALSE', 'Pandas中iloc和loc的主要区别是iloc按标签索引，loc按位置索引。',
 null, 'false', '正好相反。loc按标签(label)索引(如df.loc["row_label", "col_label"])，iloc按整数位置(position)索引(如df.iloc[0, 1])。', 2),
(188, 17, 'SINGLE_CHOICE', 'Pandas中merge()函数的how参数默认值是什么？',
 '[{"key":"A","text":"left"},{"key":"B","text":"right"},{"key":"C","text":"inner"},{"key":"D","text":"outer"}]',
 'C', 'merge()默认how="inner"(内连接)，只保留两表都匹配的行。left/right/outer分别对应左连接/右连接/全连接。', 2),
(189, 17, 'SINGLE_CHOICE', '以下哪个方法可以将Series转换为Python列表？',
 '[{"key":"A","text":"series.to_list()"},{"key":"B","text":"series.to_csv()"},{"key":"C","text":"series.to_dict()"},{"key":"D","text":"series.values"}]',
 'A', 'to_list()或tolist()返回Python list。values返回NumPy数组。to_dict()返回字典。to_csv()导出文件。', 1);

-- Matplotlib可视化 补充 (kp_id=18)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(190, 18, 'SINGLE_CHOICE', 'plt.savefig("fig.png", dpi=300)中dpi参数控制什么？',
 '[{"key":"A","text":"图片颜色深度"},{"key":"B","text":"图片分辨率(每英寸点数)"},{"key":"C","text":"图片文件大小上限"},{"key":"D","text":"图片格式"}]',
 'B', 'dpi(dots per inch)控制图片分辨率。dpi=300表示每英寸300像素，值越大图片越清晰、文件越大。', 2),
(191, 18, 'SINGLE_CHOICE', 'plt.legend()的作用是什么？',
 '[{"key":"A","text":"设置图表标题"},{"key":"B","text":"显示图例"},{"key":"C","text":"设置坐标轴标签"},{"key":"D","text":"添加网格线"}]',
 'B', 'legend()显示图例。title()设置标题。xlabel()/ylabel()设置坐标轴标签。grid()添加网格线。', 1),
(192, 18, 'TRUE_FALSE', '使用Seaborn可以绘制比Matplotlib更美观的统计图形。',
 null, 'true', 'Seaborn基于Matplotlib封装，提供更美观的默认样式和更高级的统计图形(如boxplot、violinplot、heatmap等)。', 1),
(193, 18, 'SINGLE_CHOICE', '以下哪个函数用来创建散点图？',
 '[{"key":"A","text":"plt.plot()"},{"key":"B","text":"plt.scatter()"},{"key":"C","text":"plt.hist()"},{"key":"D","text":"plt.bar()"}]',
 'B', 'scatter()创建散点图。plot()是折线图(也可以通过marker参数显示散点)。hist()是直方图。bar()是柱状图。', 1);

-- 机器学习基础 补充 (kp_id=19)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(194, 19, 'SINGLE_CHOICE', '训练集(train)和测试集(test)的划分比例通常是多少？',
 '[{"key":"A","text":"5:5"},{"key":"B","text":"7:3或8:2"},{"key":"C","text":"1:9"},{"key":"D","text":"9.5:0.5"}]',
 'B', '通常7:3或8:2划分训练集和测试集。数据量小时可用交叉验证(如K-fold)更充分利用数据。', 1),
(195, 19, 'TRUE_FALSE', '准确率(accuracy)越高模型越好。',
 null, 'false', '准确率不适合类别不均衡的数据集。如正样本占95%时全判正类准确率95%但模型无用。需要综合精确率(precision)、召回率(recall)、F1-score评估。', 2),
(196, 19, 'SINGLE_CHOICE', '特征归一化(如MinMax到[0,1])的主要原因是什么？',
 '[{"key":"A","text":"减少数据量"},{"key":"B","text":"消除量纲影响加速收敛"},{"key":"C","text":"加密数据"},{"key":"D","text":"增加特征数量"}]',
 'B', '不同特征量纲不同(如年龄0-100，收入0-100000)，归一化后消除量纲影响，梯度下降收敛更快。树模型不需要归一化。', 2),
(197, 19, 'SINGLE_CHOICE', '以下哪个不是监督学习算法？',
 '[{"key":"A","text":"线性回归"},{"key":"B","text":"KNN"},{"key":"C","text":"K-Means"},{"key":"D","text":"决策树"}]',
 'C', 'K-Means是无监督学习(聚类)。线性回归、KNN(分类/回归)、决策树都是有监督学习。', 1),
(198, 19, 'SINGLE_CHOICE', '交叉验证(Cross Validation)的主要目的是什么？',
 '[{"key":"A","text":"加快训练速度"},{"key":"B","text":"更可靠地评估模型泛化能力"},{"key":"C","text":"减少特征数量"},{"key":"D","text":"增加训练数据"}]',
 'B', '交叉验证将数据分为K份，轮流用K-1份训练1份验证，取平均值。能更可靠地评估模型在新数据上的表现。', 2);

-- 关系模型基础 补充 (kp_id=20)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(199, 20, 'SINGLE_CHOICE', '关系数据库中的外键(Foreign Key)作用是什么？',
 '[{"key":"A","text":"唯一标识一行"},{"key":"B","text":"建立表与表之间的关联"},{"key":"C","text":"加速查询"},{"key":"D","text":"加密数据"}]',
 'B', '外键引用另一张表的主键，建立表间关联(参照完整性)。主键唯一标识一行。索引加速查询。', 1),
(200, 20, 'SINGLE_CHOICE', '关系代数中的投影运算π对应SQL的什么操作？',
 '[{"key":"A","text":"WHERE"},{"key":"B","text":"SELECT 列名"},{"key":"C","text":"JOIN"},{"key":"D","text":"GROUP BY"}]',
 'B', 'π(投影)选取指定列→SELECT col1,col2。σ(选择)选取行→WHERE。⋈(连接)表关联→JOIN。', 1),
(201, 20, 'TRUE_FALSE', '在关系模型中，属性的顺序是有意义的。',
 null, 'false', '关系(表)中属性的顺序没有意义，属性由名称标识不是由位置标识。元组(行)的顺序也没有意义。', 2),
(202, 20, 'SINGLE_CHOICE', '候选键(Candidate Key)和主键(Primary Key)的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"候选键可能有多个，主键是选中的那个"},{"key":"C","text":"主键可以有多个"},{"key":"D","text":"候选键可以是NULL"}]',
 'B', '候选键是能唯一标识元组的最小属性集(可能有多个)。主键是从候选键中选定的一个，不能为NULL。', 2);

-- SQL查询语言 补充 (kp_id=21)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(203, 21, 'SINGLE_CHOICE', 'SQL中UNION和UNION ALL的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"UNION去重，UNION ALL保留所有"},{"key":"C","text":"UNION ALL更快但结果不同"},{"key":"D","text":"UNION只能合并两张表"}]',
 'B', 'UNION去重(需要排序比较，较慢)。UNION ALL保留所有行(不排序，较快)。如果确定结果不重复优先用UNION ALL。', 2),
(204, 21, 'SINGLE_CHOICE', '以下哪个SQL语句会删除表结构和数据？',
 '[{"key":"A","text":"DELETE FROM table"},{"key":"B","text":"TRUNCATE TABLE table"},{"key":"C","text":"DROP TABLE table"},{"key":"D","text":"REMOVE TABLE table"}]',
 'C', 'DROP删除表结构和数据。DELETE删除数据(可回滚，有where子句)。TRUNCATE快速清空表数据(不可回滚，重置自增ID)。', 1),
(205, 21, 'TRUE_FALSE', 'GROUP BY子句中可以使用SELECT中定义的别名。',
 null, 'false', 'SQL执行顺序：FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY。GROUP BY在SELECT之前执行，不能使用别名。ORDER BY可以使用别名。', 2),
(206, 21, 'SINGLE_CHOICE', 'SQL中IN和EXISTS的区别是什么？',
 '[{"key":"A","text":"完全相同"},{"key":"B","text":"IN用于子查询结果集小的情况，EXISTS用于大的情况"},{"key":"C","text":"IN只能用于数字"},{"key":"D","text":"EXISTS只能用于关联子查询"}]',
 'B', 'IN先执行子查询生成结果集再比较。EXISTS逐行检查子查询是否有返回行(关联子查询)。当外表小内表大时EXISTS更高效。', 3),
(207, 21, 'SINGLE_CHOICE', '以下哪个不是SQL的聚合函数？',
 '[{"key":"A","text":"COUNT()"},{"key":"B","text":"MAX()"},{"key":"C","text":"SUM()"},{"key":"D","text":"CONCAT()"}]',
 'D', 'CONCAT()是字符串函数(拼接)。COUNT/SUM/AVG/MAX/MIN是聚合函数，通常与GROUP BY配合使用。', 1);

-- 索引与查询优化 补充 (kp_id=22)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(208, 22, 'SINGLE_CHOICE', '以下哪种情况索引可能失效？',
 '[{"key":"A","text":"WHERE col = 123"},{"key":"B","text":"WHERE col LIKE ''abc%'''},{"key":"C","text":"WHERE col LIKE ''%abc'''},{"key":"D","text":"WHERE col > 100"}]',
 'C', 'LIKE以%开头时索引失效(无法使用B+树的有序性)。LIKE ''abc%''可以使用索引。对列进行函数操作(WHERE YEAR(date)=2024)也会导致索引失效。', 2),
(209, 22, 'SINGLE_CHOICE', 'MySQL中EXPLAIN的type列显示ALL表示什么？',
 '[{"key":"A","text":"使用了唯一索引"},{"key":"B","text":"全表扫描"},{"key":"C","text":"使用了主键索引"},{"key":"D","text":"使用了覆盖索引"}]',
 'B', 'type=ALL是全表扫描，性能最差。type=const/eq_ref/ref是使用索引，range是范围扫描。目标是将type优化到range或更好。', 2),
(210, 22, 'SINGLE_CHOICE', '覆盖索引(Covering Index)是什么意思？',
 '[{"key":"A","text":"索引覆盖了所有列"},{"key":"B","text":"查询需要的列都在索引中，不需要回表"},{"key":"C","text":"一个索引覆盖多个表"},{"key":"D","text":"索引自动更新"}]',
 'B', '覆盖索引指查询列都在索引中，直接从索引获取数据不需要回表查聚簇索引。Using index in Extra表示使用了覆盖索引。', 2),
(211, 22, 'TRUE_FALSE', '联合索引(a,b,c)中，查询条件WHERE b=1 AND c=2无法使用该索引。',
 null, 'true', '联合索引遵循最左前缀原则。查询条件必须包含最左列a才能使用索引。WHERE a=1 AND c=2可用a列，但c无法用到索引。', 2);

-- 事务与并发控制 补充 (kp_id=23)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(212, 23, 'SINGLE_CHOICE', '事务的隔离级别中，哪个级别可以防止所有并发问题？',
 '[{"key":"A","text":"READ UNCOMMITTED"},{"key":"B","text":"READ COMMITTED"},{"key":"C","text":"REPEATABLE READ"},{"key":"D","text":"SERIALIZABLE"}]',
 'D', 'SERIALIZABLE(可串行化)最高隔离级别，防止脏读、不可重复读、幻读。但并发性能最低。MySQL InnoDB的REPEATABLE READ通过MVCC+间隙锁也能防止幻读。', 2),
(213, 23, 'SINGLE_CHOICE', '以下哪个场景会导致"不可重复读"？',
 '[{"key":"A","text":"事务A读到事务B未提交的数据"},{"key":"B","text":"事务A两次读取间，事务B修改了数据并提交"},{"key":"C","text":"事务A两次读取间，事务B插入了新数据并提交"},{"key":"D","text":"事务A修改了事务B的数据"}]',
 'B', '不可重复读：同一事务内两次读同一条数据结果不同(被其他事务修改)。幻读：两次范围查询结果集不同(被其他事务插入/删除了行)。', 2),
(214, 23, 'TRUE_FALSE', 'MySQL InnoDB在REPEATABLE READ隔离级别下使用MVCC解决了幻读问题。',
 null, 'true', 'InnoDB通过MVCC(快照读)和Next-Key Lock(当前读时的间隙锁)在RR级别解决幻读。这是MySQL特有的，标准的RR级别不能完全解决幻读。', 3),
(215, 23, 'SINGLE_CHOICE', '死锁的预防策略不包括以下哪种？',
 '[{"key":"A","text":"所有事务按相同顺序获取锁"},{"key":"B","text":"设置锁超时时间"},{"key":"C","text":"使用死锁检测和回滚"},{"key":"D","text":"使用更大粒度的锁"}]',
 'D', '更大粒度的锁会降低并发性且不一定能防止死锁。预防死锁：有序加锁、锁超时、死锁检测+回滚(MySQL InnoDB自动检测并回滚代价小的事务)。', 3);

-- 数据库设计范式 补充 (kp_id=24)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(216, 24, 'SINGLE_CHOICE', 'E-R图中，实体用哪种图形表示？',
 '[{"key":"A","text":"圆形"},{"key":"B","text":"矩形"},{"key":"C","text":"菱形"},{"key":"D","text":"椭圆形"}]',
 'B', 'E-R图：实体=矩形，属性=椭圆，关系=菱形。连线表示实体参与关系。', 1),
(217, 24, 'SINGLE_CHOICE', '第二范式(2NF)消除了哪种依赖？',
 '[{"key":"A","text":"传递函数依赖"},{"key":"B","text":"部分函数依赖"},{"key":"C","text":"多值依赖"},{"key":"D","text":"所有依赖"}]',
 'B', '2NF消除非主属性对候选键的部分函数依赖(即非主属性不能只依赖主键的一部分)。前提是满足1NF。', 2),
(218, 24, 'TRUE_FALSE', 'BCNF比3NF的要求更严格。',
 null, 'true', 'BCNF(巴斯-科德范式)是3NF的加强版。3NF允许主属性对候选键的传递依赖，BCNF不允许。大多数情况下3NF的表也满足BCNF。', 2);

-- OSI七层模型 补充 (kp_id=25)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(219, 25, 'SINGLE_CHOICE', '以下哪个设备工作在OSI第二层(数据链路层)？',
 '[{"key":"A","text":"路由器"},{"key":"B","text":"交换机"},{"key":"C","text":"集线器"},{"key":"D","text":"网关"}]',
 'B', '交换机根据MAC地址转发帧，工作在数据链路层(L2)。路由器工作在网络层(L3)。集线器工作在物理层(L1)。网关在应用层。', 1),
(220, 25, 'SINGLE_CHOICE', 'OSI七层中，哪一层负责数据的加密和解密？',
 '[{"key":"A","text":"应用层"},{"key":"B","text":"表示层"},{"key":"C","text":"会话层"},{"key":"D","text":"传输层"}]',
 'B', '表示层(Presentation Layer)负责数据格式转换、加密解密、压缩解压。在TCP/IP模型中该功能合并到应用层。', 2),
(221, 25, 'SINGLE_CHOICE', '传输层的主要功能是什么？',
 '[{"key":"A","text":"路由选择"},{"key":"B","text":"端到端的可靠通信"},{"key":"C","text":"物理信号传输"},{"key":"D","text":"域名解析"}]',
 'B', '传输层提供端到端(进程到进程)的通信服务。TCP提供可靠传输，UDP提供不可靠传输。路由选择是网络层的功能。', 1);

-- TCP/IP协议栈 补充 (kp_id=26)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(222, 26, 'SINGLE_CHOICE', 'TCP三次握手中，第二次握手SYN+ACK中ACK的值是多少？',
 '[{"key":"A","text":"0"},{"key":"B","text":"客户端初始序列号"},{"key":"C","text":"客户端初始序列号+1"},{"key":"D","text":"随机值"}]',
 'C', '第二次握手：服务器发送SYN+ACK。ACK号=客户端SYN的seq+1，SYN seq=服务器自己的初始序列号。ACK确认号表示期望收到的下一个字节序号。', 3),
(223, 26, 'SINGLE_CHOICE', 'TCP拥塞控制中，发生超时后拥塞窗口(cwnd)会怎么变化？',
 '[{"key":"A","text":"保持不变"},{"key":"B","text":"减半"},{"key":"C","text":"重置为1个MSS"},{"key":"D","text":"加倍"}]',
 'C', 'TCP超时重传后，慢启动门限(ssthresh)设为当前cwnd的一半，cwnd重置为1个MSS，重新进入慢启动阶段。快重传/快恢复时cwnd减半。', 3),
(224, 26, 'TRUE_FALSE', 'IPv4地址有32位，IPv6地址有128位。',
 null, 'true', 'IPv4=32位(约43亿地址)。IPv6=128位(约3.4×10³⁸地址)。IPv4地址已耗尽，IPv6逐步普及。', 1),
(225, 26, 'SINGLE_CHOICE', '子网掩码255.255.255.128对应的CIDR前缀长度是多少？',
 '[{"key":"A","text":"/24"},{"key":"B","text":"/25"},{"key":"C","text":"/26"},{"key":"D","text":"/27"}]',
 'B', '255.255.255.128=128+64+32+16+8+4+2+1=... 即前25位为1(255.255.255 = 24位 + 128 = 1位=25位)。', 2);

-- HTTP协议 补充 (kp_id=27)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(226, 27, 'SINGLE_CHOICE', 'HTTP/2相比HTTP/1.1的主要改进是什么？',
 '[{"key":"A","text":"使用UDP传输"},{"key":"B","text":"多路复用(一个TCP连接并发多个请求)"},{"key":"C","text":"去掉了Cookie"},{"key":"D","text":"只支持GET请求"}]',
 'B', 'HTTP/2主要改进：多路复用、头部压缩(HPACK)、服务器推送、二进制分帧。HTTP/3基于QUIC(UDP)。', 2),
(227, 27, 'SINGLE_CHOICE', 'HTTP状态码301和302的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"301永久重定向，302临时重定向"},{"key":"C","text":"301临时，302永久"},{"key":"D","text":"301用于HTTPS，302用于HTTP"}]',
 'B', '301永久重定向(浏览器缓存新URL)。302临时重定向(浏览器不缓存)。搜索引擎：301会传递权重到新URL，302不会。', 2),
(228, 27, 'SINGLE_CHOICE', 'RESTful API中，PUT方法和PATCH方法的主要区别？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"PUT全量更新，PATCH部分更新"},{"key":"C","text":"PATCH全量更新，PUT部分更新"},{"key":"D","text":"PUT创建，PATCH删除"}]',
 'B', 'PUT是幂等的全量替换。PATCH是非幂等的部分修改。POST创建资源。DELETE删除资源。', 2),
(229, 27, 'TRUE_FALSE', 'HTTP协议本身是无状态的，但可以通过Cookie和Session来维护状态。',
 null, 'true', 'HTTP是无状态协议(每个请求独立)。Cookie(客户端)和Session(服务端)机制可以在应用层实现状态管理。', 1);

-- DNS域名解析 补充 (kp_id=28)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(230, 28, 'SINGLE_CHOICE', 'DNS递归查询和迭代查询的区别是什么？',
 '[{"key":"A","text":"递归查询由DNS服务器代为完成查询，迭代查询由客户端逐级查询"},{"key":"B","text":"两者完全相同"},{"key":"C","text":"迭代查询更快"},{"key":"D","text":"递归查询不安全"}]',
 'A', '递归：DNS服务器代为完成全部查询返回最终结果。迭代：DNS服务器返回下一级服务器地址，客户端继续查询。通常客户端→本地DNS是递归，本地DNS→其他服务器是迭代。', 2),
(231, 28, 'SINGLE_CHOICE', 'DNS的MX记录用于什么？',
 '[{"key":"A","text":"IPv4地址解析"},{"key":"B","text":"邮件服务器定位"},{"key":"C","text":"别名指向"},{"key":"D","text":"反向解析"}]',
 'B', 'MX(Mail eXchange)记录指定邮件服务器。A记录→IPv4，AAAA→IPv6，CNAME→别名，PTR→反向解析(IP→域名)。', 1),
(232, 28, 'TRUE_FALSE', 'DNS查询使用UDP协议，端口号是53。',
 null, 'true', 'DNS默认使用UDP 53端口(查询快速)。区域传输(zone transfer)和大响应(>512B)使用TCP 53端口。', 1),
(233, 28, 'SINGLE_CHOICE', '以下哪个顶级域名用于中国？',
 '[{"key":"A","text":".com"},{"key":"B","text":".org"},{"key":"C","text":".cn"},{"key":"D","text":".net"}]',
 'C', '.cn是中国国家顶级域名(ccTLD)。.com/.org/.net是通用顶级域名(gTLD)。', 1);

-- 网络安全基础 补充 (kp_id=29)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(234, 29, 'SINGLE_CHOICE', '以下哪个攻击属于社会工程学攻击？',
 '[{"key":"A","text":"SQL注入"},{"key":"B","text":"钓鱼邮件"},{"key":"C","text":"DDoS攻击"},{"key":"D","text":"缓冲区溢出"}]',
 'B', '钓鱼邮件利用人的信任心理获取敏感信息，属于社会工程学攻击。SQL注入、DDoS、缓冲区溢出都是技术型攻击。', 1),
(235, 29, 'SINGLE_CHOICE', 'CSRF(跨站请求伪造)攻击的防御方法是什么？',
 '[{"key":"A","text":"使用PreparedStatement"},{"key":"B","text":"使用CSRF Token"},{"key":"C","text":"对HTML实体编码"},{"key":"D","text":"使用HTTPS"}]',
 'B', 'CSRF Token(随机令牌验证请求来源)是主要防御方式。PreparedStatement防SQL注入。HTML实体编码防XSS。HTTPS防中间人攻击。', 2),
(236, 29, 'TRUE_FALSE', 'HTTPS可以完全防止中间人攻击(MITM)。',
 null, 'false', 'HTTPS可以大幅减少MITM风险但不能完全防止。如果用户忽略证书警告或证书被伪造(如CA被攻破)，仍可能遭受MITM攻击。', 3),
(237, 29, 'SINGLE_CHOICE', '公钥基础设施(PKI)的核心组件是什么？',
 '[{"key":"A","text":"防火墙"},{"key":"B","text":"CA(证书颁发机构)"},{"key":"C","text":"IDS(入侵检测系统)"},{"key":"D","text":"VPN"}]',
 'B', 'PKI的核心是CA(证书颁发机构)，负责签发和管理数字证书。通过证书链建立信任关系，实现身份认证和数据加密。', 2),
(238, 29, 'MULTI_CHOICE', '以下哪些属于OWASP Top 10安全风险？(多选)',
 '[{"key":"A","text":"SQL注入"},{"key":"B","text":"XSS跨站脚本"},{"key":"C","text":"失效的身份认证"},{"key":"D","text":"CPU过载"}]',
 'ABC', 'SQL注入、XSS、失效的身份认证都是OWASP Top 10。CPU过载是性能问题不属于安全风险分类。', 2);

-- ========== Questions for new KPs (30-53) ==========

-- KP 30: JVM与内存模型 (6 questions, IDs 239-244)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(239, 30, 'SINGLE_CHOICE', 'JVM运行时数据区中，哪个区域是线程私有的？',
 '[{"key":"A","text":"堆(Heap)"},{"key":"B","text":"方法区(Method Area)"},{"key":"C","text":"虚拟机栈(VM Stack)"},{"key":"D","text":"元空间(Metaspace)"}]',
 'C', '虚拟机栈、本地方法栈和程序计数器是线程私有的。堆和方法区(元空间)是所有线程共享的。', 1),
(240, 30, 'SINGLE_CHOICE', 'JDK8中，永久代(PermGen)被什么替代？',
 '[{"key":"A","text":"堆内存"},{"key":"B","text":"元空间(Metaspace)"},{"key":"C","text":"本地内存"},{"key":"D","text":"栈内存"}]',
 'B', 'JDK8使用元空间(Metaspace)替代永久代，元空间使用本地内存而非JVM堆内存，不再有OOM PermGen问题。', 1),
(241, 30, 'SINGLE_CHOICE', '以下哪个不是GC Roots？',
 '[{"key":"A","text":"虚拟机栈中引用的对象"},{"key":"B","text":"方法区中静态变量引用的对象"},{"key":"C","text":"堆中对象引用的其他对象"},{"key":"D","text":"JNI引用的对象"}]',
 'C', 'GC Roots包括：栈中局部变量、静态变量、常量池引用、JNI引用等。堆中对象之间的引用不属于GC Roots，它们决定的是对象的可达路径。', 2),
(242, 30, 'SINGLE_CHOICE', '新生代垃圾回收通常使用什么算法？',
 '[{"key":"A","text":"标记-清除"},{"key":"B","text":"复制算法"},{"key":"C","text":"标记-整理"},{"key":"D","text":"分代收集"}]',
 'B', '新生代对象大多朝生夕死，使用复制算法效率高（Eden→Survivor→Old）。老年代存活率高，常用标记-清除或标记-整理。', 1),
(243, 30, 'MULTI_CHOICE', '以下哪些是JVM的垃圾收集器？(多选)',
 '[{"key":"A","text":"G1"},{"key":"B","text":"CMS"},{"key":"C","text":"ZGC"},{"key":"D","text":"CGLIB"}]',
 'ABC', 'G1、CMS、ZGC都是JVM垃圾收集器。CGLIB是动态代理库，与GC无关。', 1),
(244, 30, 'SINGLE_CHOICE', '类加载的双亲委派模型中，加载请求首先交给谁？',
 '[{"key":"A","text":"Application ClassLoader"},{"key":"B","text":"Extension ClassLoader"},{"key":"C","text":"Bootstrap ClassLoader"},{"key":"D","text":"自定义ClassLoader"}]',
 'C', '双亲委派模型：类加载请求从下向上委派，最顶层的Bootstrap ClassLoader优先尝试加载，加载不了才向下传递。', 2);

-- KP 31: 设计模式 (6 questions, IDs 245-250)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(245, 31, 'SINGLE_CHOICE', '以下哪种设计模式确保一个类只有一个实例？',
 '[{"key":"A","text":"工厂模式"},{"key":"B","text":"单例模式"},{"key":"C","text":"原型模式"},{"key":"D","text":"建造者模式"}]',
 'B', '单例模式(Singleton)确保类只有一个实例，并提供一个全局访问点。Spring的Bean默认scope就是singleton。', 1),
(246, 31, 'SINGLE_CHOICE', 'Spring AOP基于什么设计模式实现？',
 '[{"key":"A","text":"观察者模式"},{"key":"B","text":"策略模式"},{"key":"C","text":"代理模式"},{"key":"D","text":"装饰器模式"}]',
 'C', 'Spring AOP基于代理模式实现。当目标类实现了接口时使用JDK动态代理，否则使用CGLIB基于继承的代理。', 1),
(247, 31, 'SINGLE_CHOICE', 'Java IO中的BufferedReader使用了什么设计模式？',
 '[{"key":"A","text":"代理模式"},{"key":"B","text":"装饰器模式"},{"key":"C","text":"适配器模式"},{"key":"D","text":"外观模式"}]',
 'B', 'BufferedReader(Reader)装饰了Reader，增加缓冲功能，是典型的装饰器模式。代理模式控制访问，装饰器模式增强功能。', 2),
(248, 31, 'MULTI_CHOICE', '以下哪些属于创建型设计模式？(多选)',
 '[{"key":"A","text":"单例模式"},{"key":"B","text":"工厂方法"},{"key":"C","text":"观察者模式"},{"key":"D","text":"建造者模式"}]',
 'ABD', '单例、工厂方法、建造者都属于创建型模式。观察者模式属于行为型模式。', 2),
(249, 31, 'SINGLE_CHOICE', '以下哪个设计原则强调"对扩展开放，对修改关闭"？',
 '[{"key":"A","text":"单一职责原则"},{"key":"B","text":"里氏替换原则"},{"key":"C","text":"开闭原则"},{"key":"D","text":"依赖倒置原则"}]',
 'C', '开闭原则(Open-Closed Principle)：软件实体应对扩展开放，对修改关闭。应通过增加新代码来扩展功能，而非修改已有代码。', 1),
(250, 31, 'TRUE_FALSE', 'JDK动态代理不需要目标类实现接口。',
 null, 'false', 'JDK动态代理要求目标类必须实现接口。如果目标类没有实现接口，应使用CGLIB动态代理（基于继承）。', 2);

-- KP 32: Java 8+ 新特性 (6 questions, IDs 251-256)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(251, 32, 'SINGLE_CHOICE', 'Lambda表达式 `() -> "hello"` 对应哪个函数式接口？',
 '[{"key":"A","text":"Consumer<T>"},{"key":"B","text":"Supplier<T>"},{"key":"C","text":"Function<T,R>"},{"key":"D","text":"Runnable"}]',
 'B', 'Supplier<T>的抽象方法是 T get()，无参数有返回值，与`() -> "hello"`匹配。Consumer有参数无返回值，Function有参数有返回值。', 2),
(252, 32, 'SINGLE_CHOICE', 'Stream的中间操作和终止操作的区别是什么？',
 '[{"key":"A","text":"中间操作立即执行，终止操作延迟执行"},{"key":"B","text":"中间操作延迟执行，终止操作触发计算"},{"key":"C","text":"两种操作都立即执行"},{"key":"D","text":"两种操作都延迟执行"}]',
 'B', 'Stream中间操作(filter/map/sorted)是惰性的，只有遇到终止操作(collect/forEach/count)时才触发整个流水线执行。', 1),
(253, 32, 'SINGLE_CHOICE', 'Optional类的主要目的是什么？',
 '[{"key":"A","text":"提高代码执行效率"},{"key":"B","text":"替代所有null判断"},{"key":"C","text":"优雅处理可能为null的值，避免NullPointerException"},{"key":"D","text":"作为方法的参数类型"}]',
 'C', 'Optional用于表示可能为null的值，提供链式API优雅处理null，避免显式null检查。但不应用作方法参数或类字段。', 1),
(254, 32, 'TRUE_FALSE', '同一个Stream对象可以被多次使用（多次调用forEach等终止操作）。',
 null, 'false', 'Stream只能被消费一次。对已操作的Stream再次调用终止操作会抛出IllegalStateException: stream has already been operated upon or closed。', 2),
(255, 32, 'MULTI_CHOICE', '以下哪些是Java 8的新特性？(多选)',
 '[{"key":"A","text":"Lambda表达式"},{"key":"B","text":"Stream API"},{"key":"C","text":"模块化系统(Jigsaw)"},{"key":"D","text":"新的日期时间API(java.time)"}]',
 'ABD', 'Lambda、Stream API和新的日期时间API(java.time)都是Java 8引入的。模块化系统(Jigsaw)是Java 9引入的。', 2),
(256, 32, 'SINGLE_CHOICE', '在Stream中，`map`和`flatMap`的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"map用于转换，flatMap用于过滤"},{"key":"C","text":"map一对一映射，flatMap将嵌套结构展平"},{"key":"D","text":"map是中间操作，flatMap是终止操作"}]',
 'C', 'map将每个元素转换为另一个对象（一对一），flatMap将每个元素转换为一个Stream并将所有Stream合并（展平）。常用于处理嵌套集合。', 3);

-- KP 33: 反射与注解 (5 questions, IDs 257-261)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(257, 33, 'SINGLE_CHOICE', '以下哪个方法用于获取Class对象？',
 '[{"key":"A","text":"Class.forName(\"java.lang.String\")"},{"key":"B","text":"new Class(\"String\")"},{"key":"C","text":"String.class()"},{"key":"D","text":"getClass().forName(\"String\")"}]',
 'A', '获取Class对象有三种方式：Class.forName("全限定类名")、类名.class（如String.class）、对象.getClass()。', 1),
(258, 33, 'SINGLE_CHOICE', '反射中，调用私有方法前需要做什么？',
 '[{"key":"A","text":"使用newInstance"},{"key":"B","text":"调用method.setAccessible(true)"},{"key":"C","text":"将方法声明为public"},{"key":"D","text":"使用特殊JVM参数"}]',
 'B', '访问私有方法前需要调用`method.setAccessible(true)`来突破Java的访问控制检查。', 1),
(259, 33, 'SINGLE_CHOICE', '`@Retention(RetentionPolicy.RUNTIME)` 的作用是什么？',
 '[{"key":"A","text":"注解只在源码中有效"},{"key":"B","text":"注解在class文件中有效"},{"key":"C","text":"注解在运行时可通过反射读取"},{"key":"D","text":"注解在编译时处理"}]',
 'C', 'RetentionPolicy.RUNTIME表示注解信息保留到运行时，可通过反射读取。SOURCE只在源码有效(如@Override)，CLASS在class文件有效但运行时不可见。', 2),
(260, 33, 'TRUE_FALSE', 'JDK动态代理不要求目标类实现接口。',
 null, 'false', 'JDK动态代理基于接口创建代理（Proxy.newProxyInstance），目标类必须实现至少一个接口。没有实现接口的类需要用CGLIB代理。', 1),
(261, 33, 'TRUE_FALSE', '反射会降低性能，但JIT编译优化后差距可以缩小。',
 null, 'true', '反射调用比直接调用慢（类型检查、安全检查等开销）。但JVM的JIT编译器可以优化热路径中的反射调用（如用MethodHandle内联），缩小性能差距。', 2);

-- KP 34: ORM与MyBatis (6 questions, IDs 262-267)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(262, 34, 'SINGLE_CHOICE', 'MyBatis中，`#{ }`和`${ }`的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"#{ }是预编译占位符(安全)，${ }是字符串替换(有SQL注入风险)"},{"key":"C","text":"${ }是预编译占位符(安全)，#{ }是字符串替换(有SQL注入风险)"},{"key":"D","text":"#{ }用于SELECT，${ }用于INSERT"}]',
 'B', '#{ }使用PreparedStatement的参数占位符，安全防注入。${ }直接拼接SQL字符串，有注入风险，仅用于动态表名/列名等场景。', 1),
(263, 34, 'SINGLE_CHOICE', 'MyBatis的一级缓存作用范围是什么？',
 '[{"key":"A","text":"全局Application级别"},{"key":"B","text":"Mapper(Namespace)级别"},{"key":"C","text":"SqlSession级别"},{"key":"D","text":"JVM级别"}]',
 'C', '一级缓存是SqlSession级别的，同一个SqlSession内查询相同数据只会查一次数据库。SqlSession关闭/更新操作后缓存失效。', 2),
(264, 34, 'SINGLE_CHOICE', 'ORM的核心作用是什么？',
 '[{"key":"A","text":"加密数据库连接"},{"key":"B","text":"建立对象与关系数据库表的映射"},{"key":"C","text":"优化SQL查询性能"},{"key":"D","text":"替代数据库"}]',
 'B', 'ORM(Object-Relational Mapping)的核心是在Java对象和数据库表之间建立映射关系，让开发者可以用面向对象的方式操作数据库。', 1),
(265, 34, 'MULTI_CHOICE', '以下哪些是MyBatis的特点？(多选)',
 '[{"key":"A","text":"SQL与Java代码分离"},{"key":"B","text":"支持动态SQL"},{"key":"C","text":"自动创建数据库表"},{"key":"D","text":"与Spring Boot无缝整合"}]',
 'ABD', 'MyBatis将SQL写在XML或注解中与Java代码分离，支持动态SQL（if/foreach等），与Spring Boot有starter自动配置。Hibernate才会自动建表，MyBatis不会。', 2),
(266, 34, 'TRUE_FALSE', 'MyBatis的二级缓存默认开启。',
 null, 'false', 'MyBatis二级缓存默认关闭，需要在Mapper XML中通过`<cache/>`标签手动开启。二级缓存是Mapper(namespace)级别的，跨SqlSession共享。', 2),
(267, 34, 'SINGLE_CHOICE', '以下哪个是MyBatis动态SQL中用于遍历集合的标签？',
 '[{"key":"A","text":"<if>"},{"key":"B","text":"<choose>"},{"key":"C","text":"<foreach>"},{"key":"D","text":"<where>"}]',
 'C', '<foreach>标签用于遍历集合，常用于IN查询。如`SELECT * FROM users WHERE id IN <foreach collection="ids" item="id" open="(" separator="," close=")">#{id}</foreach>`。', 1);

-- KP 35: 测试与构建工具 (5 questions, IDs 268-272)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(268, 35, 'SINGLE_CHOICE', 'JUnit5中，`@BeforeEach`注解的方法何时执行？',
 '[{"key":"A","text":"类加载时执行一次"},{"key":"B","text":"每个@Test方法之前执行"},{"key":"C","text":"所有@Test方法之后执行一次"},{"key":"D","text":"只在第一个@Test前执行一次"}]',
 'B', '@BeforeEach在每个@Test方法之前执行。类似的@BeforeAll是所有测试前执行一次(需为static方法)。JUnit4中对应的是@Before。', 1),
(269, 35, 'SINGLE_CHOICE', 'Mockito中，`@Mock`和`@Spy`的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"@Mock全方法默认返回null，@Spy保留原逻辑"},{"key":"C","text":"@Spy全方法默认返回null，@Mock保留原逻辑"},{"key":"D","text":"@Mock用于类，@Spy用于接口"}]',
 'B', '@Mock创建的对象所有方法都被模拟（默认返回null/0/false）。@Spy创建的对象保留原逻辑，只模拟被stub的方法。', 2),
(270, 35, 'SINGLE_CHOICE', 'Maven的`compile`生命周期阶段负责什么？',
 '[{"key":"A","text":"运行测试"},{"key":"B","text":"编译源代码"},{"key":"C","text":"打包成JAR/WAR"},{"key":"D","text":"部署到远程仓库"}]',
 'B', 'Maven生命周期：compile(编译) → test(测试) → package(打包) → install(安装到本地仓库) → deploy(部署到远程仓库)。', 1),
(271, 35, 'SINGLE_CHOICE', 'Maven依赖中`scope=provided`的含义是什么？',
 '[{"key":"A","text":"依赖在编译和运行时都可用"},{"key":"B","text":"依赖只在编译时可用，运行时由容器提供(如Servlet API)"},{"key":"C","text":"依赖只在测试时可用"},{"key":"D","text":"依赖不可传递"}]',
 'B', 'scope=provided表示依赖在编译和测试时需要，但运行时由JDK或容器提供，不会被打包。典型例子：servlet-api、lombok。', 2),
(272, 35, 'TRUE_FALSE', '单元测试应该覆盖所有可能的边界条件和异常情况。',
 null, 'true', '好的单元测试不仅覆盖正常路径（happy path），还应包括：边界值(null/空集合/零/负数)、异常情况、并发场景等。', 1);

-- KP 36: 哈希表 (5 questions, IDs 273-277)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(273, 36, 'SINGLE_CHOICE', 'HashMap中解决哈希冲突的主要方法是什么？',
 '[{"key":"A","text":"开放寻址法"},{"key":"B","text":"拉链法(链表+红黑树)"},{"key":"C","text":"再哈希法"},{"key":"D","text":"线性探测"}]',
 'B', 'JDK的HashMap使用拉链法。JDK7是纯链表，JDK8+优化为链表长度≥8且数组长度≥64时转为红黑树（O(n)→O(logn)）。', 1),
(274, 36, 'SINGLE_CHOICE', 'HashMap的默认负载因子是多少？',
 '[{"key":"A","text":"0.5"},{"key":"B","text":"0.75"},{"key":"C","text":"1.0"},{"key":"D","text":"0.25"}]',
 'B', 'HashMap默认负载因子0.75，是空间和时间折中的选择。值太小浪费空间（频繁扩容），值太大增加冲突概率（查找变慢）。', 1),
(275, 36, 'SINGLE_CHOICE', '作为HashMap的key，自定义类必须重写哪些方法？',
 '[{"key":"A","text":"toString()和clone()"},{"key":"B","text":"equals()和hashCode()"},{"key":"C","text":"compareTo()和toString()"},{"key":"D","text":"finalize()和equals()"}]',
 'B', '作为HashMap key的类必须同时重写equals()和hashCode()。两个对象equals相等则hashCode必须相等（反之不一定）。如果只重写其一，可能导致"丢失"元素。', 1),
(276, 36, 'TRUE_FALSE', 'HashMap是线程安全的。',
 null, 'false', 'HashMap不是线程安全的。JDK7中多线程put可能导致死循环（头插法+并发扩容），JDK8中可能导致数据覆盖。多线程环境使用ConcurrentHashMap。', 2),
(277, 36, 'SINGLE_CHOICE', 'HashMap中数组长度为什么是2的幂次？',
 '[{"key":"A","text":"为了节省内存"},{"key":"B","text":"为了让`hash & (length-1)`替代取模运算"},{"key":"C","text":"为了让元素有序"},{"key":"D","text":"这是HashMap规范要求"}]',
 'B', '当length是2的幂时，`hash & (length-1)`等价于`hash % length`，位运算效率远高于取模。这也是为什么HashMap扩容是乘以2。', 3);

-- KP 37: 二分查找 (5 questions, IDs 278-282)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(278, 37, 'SINGLE_CHOICE', '二分查找的时间复杂度是多少？',
 '[{"key":"A","text":"O(1)"},{"key":"B","text":"O(n)"},{"key":"C","text":"O(log n)"},{"key":"D","text":"O(n log n)"}]',
 'C', '二分查找每次将搜索范围缩小一半，最坏和平均时间复杂度都是O(log n)。前提是数据有序。', 1),
(279, 37, 'SINGLE_CHOICE', '计算mid时，为什么推荐 `left + (right - left) / 2` 而非 `(left + right) / 2`？',
 '[{"key":"A","text":"前者更快"},{"key":"B","text":"前者更准确"},{"key":"C","text":"防止整数溢出"},{"key":"D","text":"没有区别"}]',
 'C', '当left和right都很大时，`left+right`可能超过int最大值(2147483647)导致溢出变为负数。`left+(right-left)/2`避免了这个问题。', 2),
(280, 37, 'SINGLE_CHOICE', '在旋转排序数组 [4,5,6,7,0,1,2] 中查找target，核心思路是什么？',
 '[{"key":"A","text":"直接二分查找"},{"key":"B","text":"先恢复原数组再查找"},{"key":"C","text":"二分时判断哪一半有序，在有序半边判断target是否在范围内"},{"key":"D","text":"只能线性查找"}]',
 'C', '旋转数组虽然整体不是完全有序，但二分后至少有一半是有序的。通过比较nums[mid]和nums[left]确定有序半边，再判断target是否在其中。O(log n)。', 2),
(281, 37, 'TRUE_FALSE', '二分查找只能在数组中实现，不能用于查找答案范围（如"最小的最大值"）。',
 null, 'false', '二分查找也可以"二分答案"：在可能的答案范围内二分，然后验证中间值是否可行。常用于"最大的最小值"、"最小的最大值"等优化问题。', 2),
(282, 37, 'SINGLE_CHOICE', '在二分查找中，while循环条件`left <= right`对应的搜索区间是什么？',
 '[{"key":"A","text":"左开右开区间"},{"key":"B","text":"左闭右闭区间[left, right]"},{"key":"C","text":"左闭右开区间[left, right)"},{"key":"D","text":"无限区间"}]',
 'B', '`left <= right`对应闭区间[left, right]（当left=right时还有一个元素需检查）。`left < right`对应左闭右开区间[left, right)。', 3);

-- KP 38: 字符串算法 (5 questions, IDs 283-287)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(283, 38, 'SINGLE_CHOICE', 'KMP字符串匹配算法的时间复杂度是多少？',
 '[{"key":"A","text":"O(n*m)"},{"key":"B","text":"O(n+m)"},{"key":"C","text":"O(n log m)"},{"key":"D","text":"O(log n)"}]',
 'B', 'KMP通过预处理模式串构建next数组，避免了匹配失败时回溯文本串。时间复杂度O(n+m)，其中n是文本长度，m是模式串长度。', 1),
(284, 38, 'SINGLE_CHOICE', 'Trie（前缀树）最适合用于什么场景？',
 '[{"key":"A","text":"排序字符串"},{"key":"B","text":"前缀匹配和自动补全"},{"key":"C","text":"计算字符串哈希"},{"key":"D","text":"压缩字符串"}]',
 'B', 'Trie树的核心优势是前缀共享，非常适合自动补全、拼写检查、IP路由最长前缀匹配等场景。每个节点的路径代表一个字符串前缀。', 1),
(285, 38, 'SINGLE_CHOICE', '在字符串匹配中，Rabin-Karp算法使用什么技巧加速匹配？',
 '[{"key":"A","text":"二分查找"},{"key":"B","text":"滚动哈希(Rolling Hash)"},{"key":"C","text":"动态规划"},{"key":"D","text":"贪心匹配"}]',
 'B', 'Rabin-Karp使用滚动哈希：O(1)时间从上一次哈希值计算当前窗口哈希值。平均O(n)时间复杂度，可以同时匹配多个模式串。', 2),
(286, 38, 'TRUE_FALSE', '在Java中，频繁字符串拼接应使用StringBuilder而不是+运算符。',
 null, 'true', 'Java字符串是不可变对象，每次+都创建新字符串。在循环中频繁拼接使用StringBuilder（非线程安全/更快）或StringBuffer（线程安全）避免大量临时对象。', 1),
(287, 38, 'MULTI_CHOICE', '以下哪些方法可以求最长回文子串？(多选)',
 '[{"key":"A","text":"中心扩展法"},{"key":"B","text":"Manacher算法"},{"key":"C","text":"动态规划"},{"key":"D","text":"冒泡排序"}]',
 'ABC', '最长回文子串的三种常见解法：中心扩展法(O(n²))、动态规划(O(n²))、Manacher算法(O(n))。', 3);

-- KP 39: 递归与回溯 (5 questions, IDs 288-292)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(288, 39, 'SINGLE_CHOICE', '递归函数必须包含什么来防止无限递归？',
 '[{"key":"A","text":"for循环"},{"key":"B","text":"终止条件(Base Case)"},{"key":"C","text":"全局变量"},{"key":"D","text":"try-catch块"}]',
 'B', '递归函数必须有一个终止条件（base case），当满足条件时不再递归调用，直接返回。没有终止条件会导致栈溢出(StackOverflowError)。', 1),
(289, 39, 'SINGLE_CHOICE', '回溯算法和暴力枚举的主要区别是什么？',
 '[{"key":"A","text":"回溯比暴力枚举慢"},{"key":"B","text":"回溯通过剪枝跳过无效路径，减少搜索空间"},{"key":"C","text":"回溯不需要递归"},{"key":"D","text":"回溯保证找到最优解"}]',
 'B', '回溯通过剪枝（可行性剪枝、最优性剪枝等）提前排除不可能产生有效解的路径，比纯暴力枚举效率高。但最坏情况仍是O(n!)。', 2),
(290, 39, 'SINGLE_CHOICE', 'N皇后问题的经典解法是什么？',
 '[{"key":"A","text":"贪心算法"},{"key":"B","text":"回溯(Backtracking)"},{"key":"C","text":"二分查找"},{"key":"D","text":"动态规划"}]',
 'B', 'N皇后问题使用回溯法：逐行放置皇后，检查列和两条对角线是否有冲突，冲突则回溯。是回溯算法的经典例题。', 1),
(291, 39, 'TRUE_FALSE', '递归实现都可以转换为迭代实现（如使用栈模拟）。',
 null, 'true', '理论上所有递归都可以转换为迭代，通过手动维护栈（或队列）模拟函数调用栈。但有些转换复杂度高（如树遍历简单，DFS递归转迭代需要显式栈）。', 3),
(292, 39, 'MULTI_CHOICE', '以下哪些问题适合用回溯算法解决？(多选)',
 '[{"key":"A","text":"全排列"},{"key":"B","text":"N皇后"},{"key":"C","text":"最短路径"},{"key":"D","text":"组合总和"}]',
 'ABD', '全排列、N皇后、组合总和都是经典回溯问题（穷举所有可能+剪枝）。最短路径通常用BFS/Dijkstra等动态规划或图算法解决，不是回溯的最佳场景。', 2);

-- KP 40: Redis核心数据结构 (6 questions, IDs 293-298)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(293, 40, 'SINGLE_CHOICE', 'Redis中适合做排行榜的数据类型是什么？',
 '[{"key":"A","text":"String"},{"key":"B","text":"Hash"},{"key":"C","text":"Sorted Set(ZSet)"},{"key":"D","text":"List"}]',
 'C', 'ZSet通过score来排序，`ZADD`添加用户分数，`ZRANGE ... REV`获取排名，天然适合排行榜场景。', 1),
(294, 40, 'SINGLE_CHOICE', 'Redis中`SETNX`命令常用于实现什么？',
 '[{"key":"A","text":"缓存穿透"},{"key":"B","text":"分布式锁"},{"key":"C","text":"消息队列"},{"key":"D","text":"计数器"}]',
 'B', 'SETNX(Set if Not eXists)是实现分布式锁的关键命令。仅当key不存在时才设置成功，利用这一特性实现互斥。生产环境通常用Redisson的看门狗机制。', 2),
(295, 40, 'SINGLE_CHOICE', '什么是缓存穿透？',
 '[{"key":"A","text":"大量缓存同时过期"},{"key":"B","text":"查询不存在的数据，绕过缓存直接打DB"},{"key":"C","text":"热点缓存key过期导致大量请求打到DB"},{"key":"D","text":"缓存服务器宕机"}]',
 'B', '缓存穿透：查询数据库中也不存在的数据，缓存中没有，查询直接打到DB。解决方法：布隆过滤器（判断key是否存在）、空值缓存、参数校验。', 2),
(296, 40, 'SINGLE_CHOICE', 'Redis的持久化方式RDB和AOF的区别是什么？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"RDB是快照(全量)，AOF是追加命令(增量)"},{"key":"C","text":"RDB是增量，AOF是全量"},{"key":"D","text":"二者不能同时使用"}]',
 'B', 'RDB(Snapshot)定期对数据做全量快照（二进制，恢复快）。AOF(Append Only File)记录每条写命令（可读文本，数据更安全）。Redis 4.0+支持混合持久化。', 1),
(297, 40, 'MULTI_CHOICE', '以下哪些场景适合使用Redis？(多选)',
 '[{"key":"A","text":"会话缓存(Session)"},{"key":"B","text":"排行榜"},{"key":"C","text":"消息队列"},{"key":"D","text":"大文件存储"}]',
 'ABC', 'Redis适合做会话缓存、排行榜（ZSet）、轻量消息队列（List/Stream）。大文件存储不适合Redis（内存昂贵且有大小限制），应使用对象存储。', 1),
(298, 40, 'TRUE_FALSE', 'Redis是单线程执行所有命令的。',
 null, 'true', 'Redis 6.0之前所有命令执行都是单线程的（IO多线程在6.0加入但命令执行仍是单线程）。单线程避免了锁竞争，配合内存操作实现极高吞吐。', 2);

-- KP 41: MySQL存储引擎 (6 questions, IDs 299-304)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(299, 41, 'SINGLE_CHOICE', 'MySQL InnoDB的默认隔离级别是什么？',
 '[{"key":"A","text":"READ UNCOMMITTED"},{"key":"B","text":"READ COMMITTED"},{"key":"C","text":"REPEATABLE READ"},{"key":"D","text":"SERIALIZABLE"}]',
 'C', 'MySQL InnoDB默认隔离级别是REPEATABLE READ（可重复读），但InnoDB通过Next-Key Lock在此级别下也能防幻读。', 1),
(300, 41, 'SINGLE_CHOICE', 'InnoDB中，redo log的作用是什么？',
 '[{"key":"A","text":"记录数据修改前的值，用于回滚"},{"key":"B","text":"记录数据修改后的值，用于崩溃恢复(crash-safe)"},{"key":"C","text":"主从复制的日志"},{"key":"D","text":"记录DDL操作"}]',
 'B', 'redo log记录"做了什么修改"（物理日志），用于崩溃恢复。保证事务的持久性。undo log记录修改前的值用于回滚和MVCC，binlog用于主从复制。', 2),
(301, 41, 'SINGLE_CHOICE', 'InnoDB的Next-Key Lock是如何防幻读的？',
 '[{"key":"A","text":"锁定所有表"},{"key":"B","text":"行锁(Record Lock) + 间隙锁(Gap Lock)"},{"key":"C","text":"仅使用MVCC"},{"key":"D","text":"使用序列化调度"}]',
 'B', 'Next-Key Lock = Record Lock（锁定已有行）+ Gap Lock（锁定索引间隙），防止其他事务在间隙中INSERT新行，从而在RR级别下也防止了幻读。', 3),
(302, 41, 'SINGLE_CHOICE', 'MVCC（多版本并发控制）主要依赖什么实现？',
 '[{"key":"A","text":"redo log"},{"key":"B","text":"undo log和隐藏列(DB_TRX_ID/DB_ROLL_PTR)"},{"key":"C","text":"binlog"},{"key":"D","text":"共享锁"}]',
 'B', 'MVCC通过undo log保存数据的历史版本，隐藏列DB_TRX_ID（事务ID）和DB_ROLL_PTR（回滚指针）串联版本链，ReadView判断数据可见性。', 2),
(303, 41, 'SINGLE_CHOICE', 'InnoDB中，执行`SELECT COUNT(*) FROM big_table`为什么可能比较慢？',
 '[{"key":"A","text":"COUNT(*)算法复杂"},{"key":"B","text":"InnoDB不存储总行数，需要遍历聚簇索引"},{"key":"C","text":"MySQL不支持COUNT(*)"},{"key":"D","text":"COUNT(*)有bug"}]',
 'B', 'InnoDB不存储表的总行数（MVCC导致不同事务看到行数不同），每次COUNT(*)都需要扫描聚簇索引。MyISAM存储了总行数所以COUNT(*)很快，但不支持事务。', 3),
(304, 41, 'TRUE_FALSE', 'InnoDB在没有主键的情况下会自动创建隐藏聚簇索引。',
 null, 'true', '如果表没有定义主键，InnoDB会选择第一个非空唯一索引作为聚簇索引；如果也没有，则自动创建一个6字节的隐藏列DB_ROW_ID作为聚簇索引。', 2);

-- KP 42: RESTful API设计 (5 questions, IDs 305-309)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(305, 42, 'SINGLE_CHOICE', 'RESTful API中，创建资源应该使用什么HTTP方法？',
 '[{"key":"A","text":"GET"},{"key":"B","text":"POST"},{"key":"C","text":"PUT"},{"key":"D","text":"PATCH"}]',
 'B', 'POST用于创建新资源（非幂等）。PUT用于全量替换已有资源（幂等），PATCH用于部分更新。GET用于获取资源。', 1),
(306, 42, 'SINGLE_CHOICE', '以下哪个URL最符合RESTful规范？',
 '[{"key":"A","text":"/api/getUser?id=1"},{"key":"B","text":"/api/users/1"},{"key":"C","text":"/api/createUser"},{"key":"D","text":"/api/deleteUser?id=1"}]',
 'B', 'RESTful URL使用名词复数表示资源，通过HTTP方法表达操作。`GET /api/users/1`（获取）、`DELETE /api/users/1`（删除）。不要在URL中用动词。', 1),
(307, 42, 'SINGLE_CHOICE', 'HTTP状态码401和403有什么区别？',
 '[{"key":"A","text":"没有区别"},{"key":"B","text":"401=未认证(没登录)，403=已认证但无权限"},{"key":"C","text":"403=未认证，401=无权限"},{"key":"D","text":"401=客户端错误，403=服务端错误"}]',
 'B', '401 Unauthorized：用户没有登录/认证（需要提供凭据）。403 Forbidden：用户已认证但没有权限访问该资源（身份已知但权限不足）。', 1),
(308, 42, 'SINGLE_CHOICE', '以下哪个选项表示HTTP DELETE操作的幂等性正确含义？',
 '[{"key":"A","text":"多次DELETE同一资源，每次效果相同（资源最终不存在）"},{"key":"B","text":"DELETE后资源自动恢复"},{"key":"C","text":"DELETE不能重复调用"},{"key":"D","text":"DELETE的响应总是相同的"}]',
 'A', 'DELETE是幂等的：第一次删除返回200，后续删除返回404（资源已不存在），服务端状态一致。POST不是幂等的（多次创建会产生多个资源）。', 2),
(309, 42, 'TRUE_FALSE', 'RESTful API中，所有请求都应该返回HTTP 200状态码，错误信息通过响应体传递。',
 null, 'false', '应正确使用HTTP状态码：成功2xx、客户端错误4xx、服务端错误5xx。所有错误返回200会让客户端难以区分成功和失败，也不符合HTTP标准。', 1);

-- KP 43: 认证与授权 (5 questions, IDs 310-314)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(310, 43, 'SINGLE_CHOICE', 'JWT由哪三部分组成？',
 '[{"key":"A","text":"Header.User.Signature"},{"key":"B","text":"Header.Payload.Signature"},{"key":"C","text":"Token.Key.Value"},{"key":"D","text":"Public.Private.Secret"}]',
 'B', 'JWT格式为`xxxx.yyyy.zzzz`，三部分：Header（算法信息）、Payload（声明数据，Base64编码）、Signature（签名，用于验签）。', 1),
(311, 43, 'SINGLE_CHOICE', 'JWT的主要优势是什么？',
 '[{"key":"A","text":"加密传输数据"},{"key":"B","text":"无状态、服务端不需要存储会话信息"},{"key":"C","text":"比Session更快"},{"key":"D","text":"可以无限续期"}]',
 'B', 'JWT的最大优势是无状态（自包含所有用户信息），服务端只需验签不需要查数据库，适合分布式/微服务架构。缺点是无法主动失效。', 1),
(312, 43, 'SINGLE_CHOICE', 'OAuth2.0中，哪种授权模式最安全（用于服务端应用）？',
 '[{"key":"A","text":"简化模式(Implicit)"},{"key":"B","text":"密码模式(Password)"},{"key":"C","text":"授权码模式(Authorization Code)"},{"key":"D","text":"客户端凭证模式(Client Credentials)"}]',
 'C', '授权码模式最安全：用户授权后返回code，应用后端用code+client_secret换token，token不暴露给浏览器。简化模式已废弃（token暴露在URL中）。', 2),
(313, 43, 'TRUE_FALSE', 'JWT的Payload是加密的，可以安全地存放密码等敏感信息。',
 null, 'false', 'JWT的Payload只是Base64编码（可轻易解码），不是加密。绝对不能存放密码、信用卡等敏感信息。如果需要加密Payload，应使用JWE(JSON Web Encryption)。', 2),
(314, 43, 'SINGLE_CHOICE', 'RBAC权限模型中，权限是如何分配的？',
 '[{"key":"A","text":"直接分配给用户"},{"key":"B","text":"用户→角色→权限（通过角色关联）"},{"key":"C","text":"通过URL分配"},{"key":"D","text":"随机分配"}]',
 'B', 'RBAC(Role-Based Access Control)：用户属于角色，角色拥有权限。通过中间层角色简化权限管理（用户变动不改权限，权限变动不改用户）。', 1);

-- KP 44-47: 操作系统基础 (20 questions, IDs 315-334)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(315, 44, 'SINGLE_CHOICE', '进程从"运行状态"变为"就绪状态"的原因是什么？',
 '[{"key":"A","text":"进程获得了IO设备"},{"key":"B","text":"时间片用完（被CPU调度器剥夺CPU）"},{"key":"C","text":"进程等待IO完成"},{"key":"D","text":"进程被终止"}]',
 'B', '运行→就绪：时间片用完或更高优先级进程抢占CPU。运行→阻塞：等待IO操作/资源。阻塞→就绪：IO完成。', 1),
(316, 44, 'SINGLE_CHOICE', '以下哪个不是进程间通信(IPC)方式？',
 '[{"key":"A","text":"管道(Pipe)"},{"key":"B","text":"共享内存"},{"key":"C","text":"全局变量"},{"key":"D","text":"Socket"}]',
 'C', '全局变量不能用于IPC，因为每个进程有独立的地址空间，无法共享全局变量。线程间可以通过全局变量通信（共享同一进程内存）。', 1),
(317, 44, 'SINGLE_CHOICE', '同一进程中的多个线程共享哪些资源？',
 '[{"key":"A","text":"各自独立的栈"},{"key":"B","text":"堆内存和全局变量"},{"key":"C","text":"各自独立的寄存器"},{"key":"D","text":"所有资源都不共享"}]',
 'B', '同一进程的线程共享：堆、全局变量、静态变量、文件描述符、代码段。线程独享：栈、寄存器、程序计数器(PC)。', 1),
(318, 44, 'SINGLE_CHOICE', '协程(Coroutine)和线程的主要区别是什么？',
 '[{"key":"A","text":"协程需要硬件支持"},{"key":"B","text":"协程是用户态调度，线程是内核态调度"},{"key":"C","text":"协程比线程更重"},{"key":"D","text":"协程不能并发"}]',
 'B', '协程在用户态由程序自身调度（如Go的goroutine、Python的asyncio），切换开销远小于线程。线程由内核调度，涉及用户态←→内核态切换。', 3),
(319, 44, 'TRUE_FALSE', '多线程程序在多核CPU上一定比单线程快。',
 null, 'false', '不一定。线程有创建/销毁/上下文切换开销，如果任务量小或存在锁竞争/资源争用，多线程可能更慢。IO密集型适合多线程，CPU密集型线程数≈核数即可。', 2),
(320, 45, 'SINGLE_CHOICE', '虚拟内存的主要作用是什么？',
 '[{"key":"A","text":"提高CPU速度"},{"key":"B","text":"让每个进程以为自己有独立的、连续的大内存空间"},{"key":"C","text":"替代物理内存"},{"key":"D","text":"防止内存泄漏"}]',
 'B', '虚拟内存通过地址映射，让每个进程拥有独立的虚拟地址空间，简化编程模型，同时提供内存隔离和保护。', 1),
(321, 45, 'SINGLE_CHOICE', 'LRU页面置换算法的核心思想是什么？',
 '[{"key":"A","text":"淘汰最先加载的页面"},{"key":"B","text":"淘汰最久未被访问的页面"},{"key":"C","text":"淘汰访问次数最少的页面"},{"key":"D","text":"随机淘汰"}]',
 'B', 'LRU(Least Recently Used)：淘汰最长时间没被访问的页面。基于"最近被访问的页面将来更可能被访问"的局部性原理。', 1),
(322, 45, 'SINGLE_CHOICE', 'TLB(Translation Lookaside Buffer)的作用是什么？',
 '[{"key":"A","text":"加速磁盘IO"},{"key":"B","text":"缓存页表项，加速虚拟地址到物理地址的转换"},{"key":"C","text":"替代页表"},{"key":"D","text":"缓存文件内容"}]',
 'B', 'TLB是MMU内部的高速缓存，存储最近使用的页表项。TLB命中时可避免访问内存中的页表（慢），地址转换速度大幅提升。', 2),
(323, 45, 'SINGLE_CHOICE', '以下哪种情况会导致缺页中断(Page Fault)？',
 '[{"key":"A","text":"访问的页面不在内存中（在磁盘交换区）"},{"key":"B","text":"访问的页面被其他进程占用"},{"key":"C","text":"访问越界"},{"key":"D","text":"CPU缓存未命中"}]',
 'A', '缺页中断：访问的页不在物理内存中（在swap区），需要从磁盘加载。这是正常现象（按需加载），但频繁发生会导致颠簸(thrashing)。', 1),
(324, 45, 'TRUE_FALSE', '虚地址空间的大小由物理内存大小决定。',
 null, 'false', '虚拟地址空间大小由CPU位数决定（32位CPU为4GB，64位CPU理论上为2^64）。32位系统即使有16GB物理内存，每个进程也只能看到4GB。', 2),
(325, 46, 'SINGLE_CHOICE', '死锁的四个必要条件中不包括哪一个？',
 '[{"key":"A","text":"互斥条件"},{"key":"B","text":"请求与保持条件"},{"key":"C","text":"资源可用条件"},{"key":"D","text":"循环等待条件"}]',
 'C', '死锁四个条件：互斥、占有等待(请求与保持)、不可剥夺、循环等待。破坏其中任何一个即可预防死锁。"资源可用条件"不是死锁必要条件。', 1),
(326, 46, 'SINGLE_CHOICE', '银行家算法属于哪种死锁处理策略？',
 '[{"key":"A","text":"死锁预防"},{"key":"B","text":"死锁避免"},{"key":"C","text":"死锁检测"},{"key":"D","text":"死锁恢复"}]',
 'B', '银行家算法是典型的死锁避免算法：每次分配资源前判断分配后系统是否处于安全状态（存在一个安全序列）。如果分配后系统不安全，则拒绝分配。', 2),
(327, 46, 'SINGLE_CHOICE', '破坏"循环等待"条件的最实用方法是什么？',
 '[{"key":"A","text":"为资源编号，按顺序申请"},{"key":"B","text":"一次性申请所有资源"},{"key":"C","text":"允许抢占资源"},{"key":"D","text":"不使用任何锁"}]',
 'A', '按顺序申请资源（如锁A→锁B→锁C，不能反向）是最实用的破坏循环等待的方法。一次性申请所有资源会降低并发度，抢占资源实现复杂。', 2),
(328, 46, 'TRUE_FALSE', 'Java中用jstack命令可以检测线程死锁。',
 null, 'true', '`jstack PID`可以输出JVM所有线程的堆栈信息，并自动检测死锁（在输出末尾显示"Found one Java-level deadlock"及死锁线程的详细信息）。', 1),
(329, 46, 'SINGLE_CHOICE', '在Linux系统中，哪个场景最可能触发死锁？',
 '[{"key":"A","text":"进程持续运行超过1小时"},{"key":"B","text":"两个进程互相等待对方持有的锁"},{"key":"C","text":"内存不够用"},{"key":"D","text":"CPU温度过高"}]',
 'B', '死锁的典型场景：进程A持有锁1等待锁2，进程B持有锁2等待锁1，双方互相等待形成循环等待，谁都得不到所有需要的资源。', 1),
(330, 47, 'SINGLE_CHOICE', '以下哪种IO模型使用`select/poll/epoll`？',
 '[{"key":"A","text":"阻塞IO(BIO)"},{"key":"B","text":"非阻塞IO(NIO)"},{"key":"C","text":"IO多路复用"},{"key":"D","text":"异步IO(AIO)"}]',
 'C', 'IO多路复用通过select/poll/epoll等系统调用，一个线程同时监控多个文件描述符，任意就绪则处理。Java NIO的Selector底层就是epoll。', 1),
(331, 47, 'SINGLE_CHOICE', 'epoll相比select的主要优势是什么？',
 '[{"key":"A","text":"epoll更简单"},{"key":"B","text":"epoll不随fd数量增加而线性下降(O(1)获取就绪fd)"},{"key":"C","text":"epoll只能在Windows上使用"},{"key":"D","text":"epoll不能用于网络编程"}]',
 'B', 'select/poll需要遍历所有fd（O(n)），epoll通过回调机制+就绪链表直接返回就绪fd（O(1)），适合高并发场景（10K+连接）。', 2),
(332, 47, 'SINGLE_CHOICE', 'Java NIO中的Selector对应哪种IO模型？',
 '[{"key":"A","text":"阻塞IO"},{"key":"B","text":"IO多路复用"},{"key":"C","text":"信号驱动IO"},{"key":"D","text":"异步IO"}]',
 'B', 'Java NIO的Selector（多路复用器）底层使用epoll(Linux)/kqueue(macOS)/select(Windows)，一个Selector管理多个Channel，是IO多路复用模型。', 2),
(333, 47, 'MULTI_CHOICE', '以下哪些是IO多路复用的实现方式？(多选)',
 '[{"key":"A","text":"select"},{"key":"B","text":"poll"},{"key":"C","text":"epoll"},{"key":"D","text":"mmap"}]',
 'ABC', 'select、poll、epoll都是IO多路复用的系统调用。mmap是内存映射（文件映射到内存），与IO多路复用无关。', 1),
(334, 47, 'TRUE_FALSE', '异步IO(AIO)和IO多路复用的最大区别是：AIO在内核完成数据复制到用户空间后才通知应用。',
 null, 'true', '异步IO：应用发起aio_read后立即返回，内核完成所有操作(等待数据+复制到用户空间)后通知应用。IO多路复用：只通知数据就绪，应用还需自己read复制数据。', 3);

-- KP 48-50: Linux基础 (15 questions, IDs 335-349)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(335, 48, 'SINGLE_CHOICE', 'Linux中，`ls -la`命令的`-a`参数表示什么？',
 '[{"key":"A","text":"显示文件大小"},{"key":"B","text":"显示所有文件（包含隐藏文件）"},{"key":"C","text":"按字母排序"},{"key":"D","text":"显示访问时间"}]',
 'B', '`ls -a`显示所有文件包括以`.`开头的隐藏文件（如.gitignore）。`-l`表示长格式显示详细信息。不加`-a`则只显示非隐藏文件。', 1),
(336, 48, 'SINGLE_CHOICE', '`grep -r "ERROR" logs/` 命令中`-r`参数的含义是什么？',
 '[{"key":"A","text":"显示行号"},{"key":"B","text":"递归搜索子目录"},{"key":"C","text":"忽略大小写"},{"key":"D","text":"反向匹配"}]',
 'B', '`grep -r`(recursive)递归搜索目录下所有文件和子目录。`-i`忽略大小写，`-n`显示行号，`-v`反向匹配。', 1),
(337, 48, 'SINGLE_CHOICE', '以下哪个命令可以实时查看日志文件的新增内容？',
 '[{"key":"A","text":"cat app.log"},{"key":"B","text":"tail -f app.log"},{"key":"C","text":"head app.log"},{"key":"D","text":"less app.log"}]',
 'B', '`tail -f`(follow)实时追踪文件尾部新增内容（Ctrl+C退出）。`cat`显示全部，`head`显示头部，`less`分页浏览。', 1),
(338, 48, 'MULTI_CHOICE', '以下哪些命令可以查看Linux系统进程信息？(多选)',
 '[{"key":"A","text":"ps aux"},{"key":"B","text":"top"},{"key":"C","text":"df -h"},{"key":"D","text":"htop"}]',
 'ABD', 'ps/top/htop都用于查看进程信息。df -h用于查看磁盘空间使用情况，与进程无关。', 2),
(339, 48, 'SINGLE_CHOICE', 'Linux管道`|`的作用是什么？',
 '[{"key":"A","text":"将命令输出保存到文件"},{"key":"B","text":"将前一个命令的标准输出作为后一个命令的标准输入"},{"key":"C","text":"在后台运行命令"},{"key":"D","text":"合并多个文件"}]',
 'B', '管道`|`连接两个命令，将左边命令的stdout传递给右边命令的stdin。例如：`ps aux | grep java | wc -l`。重定向`>`将输出写入文件。', 1),
(340, 49, 'SINGLE_CHOICE', '`chmod 755 file.sh`设置的文件权限是什么？',
 '[{"key":"A","text":"rwxrwxrwx"},{"key":"B","text":"rwxr-xr-x"},{"key":"C","text":"rw-r--r--"},{"key":"D","text":"r--r--r--"}]',
 'B', '755 = rwx(7=4+2+1) + r-x(5=4+1) + r-x(5=4+1)。所有者可读写执行，组用户和其他用户可读可执行但不可写。', 1),
(341, 49, 'SINGLE_CHOICE', 'Linux中，文件权限`rwx`中的`x`（执行权限）对目录意味着什么？',
 '[{"key":"A","text":"可以列出目录中的文件名"},{"key":"B","text":"可以查看文件内容"},{"key":"C","text":"可以cd进入目录"},{"key":"D","text":"可以修改目录中的文件"}]',
 'C', '对目录而言：r=可以ls列出文件名，w=可以创建/删除文件，x=可以cd进入目录。没有x权限即使有r权限也无法进入目录查看文件详情。', 2),
(342, 49, 'SINGLE_CHOICE', '`chown zhangsan:dev file.txt`命令的作用是什么？',
 '[{"key":"A","text":"修改文件权限"},{"key":"B","text":"修改文件所属用户为zhangsan，所属组为dev"},{"key":"C","text":"修改文件内容"},{"key":"D","text":"修改文件名"}]',
 'B', 'chown(change owner)同时修改所有者（zhangsan）和组（dev）。chgrp只修改组，chmod修改权限。', 1),
(343, 49, 'TRUE_FALSE', 'root用户可以不受任何文件权限限制，读写任何文件。',
 null, 'true', 'root用户(UIT=0)绕过所有权限检查，可以读写任何文件。x权限例外：root执行脚本也需要x权限（但root执行二进制文件不需要）。', 2),
(344, 49, 'SINGLE_CHOICE', 'umask 022的含义是什么？',
 '[{"key":"A","text":"新建文件默认权限为022"},{"key":"B","text":"从最大权限中减去022，即新建文件默认为644"},{"key":"C","text":"所有文件权限都是022"},{"key":"D","text":"不允许创建文件"}]',
 'B', 'umask是权限掩码：新建文件默认权限=666-umask=644(rw-r--r--)，新建目录默认权限=777-umask=755(rwxr-xr-x)。umask 022去除了组的w和其他人的w。', 2),
(345, 50, 'SINGLE_CHOICE', 'Shell脚本第一行`#!/bin/bash`的作用是什么？',
 '[{"key":"A","text":"注释"},{"key":"B","text":"指定使用/bin/bash解释器执行该脚本"},{"key":"C","text":"导入bash库"},{"key":"D","text":"声明变量"}]',
 'B', '`#!/bin/bash`称为shebang，告诉系统用哪个解释器执行该脚本。也可以写`#!/bin/sh`、`#!/usr/bin/env python3`等。', 1),
(346, 50, 'SINGLE_CHOICE', 'Shell中，`$?`表示什么？',
 '[{"key":"A","text":"当前进程PID"},{"key":"B","text":"上一条命令的退出状态码（0=成功）"},{"key":"C","text":"脚本参数个数"},{"key":"D","text":"当前Shell名称"}]',
 'B', '`$?`是上一条命令的退出码（0成功，非0失败）。`$$`是当前PID，`$#`是参数个数，`$0`是脚本名。', 1),
(347, 50, 'TRUE_FALSE', 'Shell脚本中，变量赋值`name = "zhangsan"`是正确的写法。',
 null, 'false', 'Shell变量赋值等号两边不能有空格！正确写法是`name="zhangsan"`。如果加空格，Shell会把name当作命令执行。', 2),
(348, 50, 'SINGLE_CHOICE', 'crontab中`0 2 * * *`表示什么意思？',
 '[{"key":"A","text":"每2分钟执行一次"},{"key":"B","text":"每天凌晨2:00执行"},{"key":"C","text":"每个月2号执行"},{"key":"D","text":"每2小时执行一次"}]',
 'B', 'crontab格式：分 时 日 月 周。`0 2 * * *`即每天02:00执行。`*/5 * * * *`表示每5分钟执行一次。', 1),
(349, 50, 'SINGLE_CHOICE', 'Shell脚本中`set -e`的作用是什么？',
 '[{"key":"A","text":"开启调试模式"},{"key":"B","text":"任何命令返回非0退出码时脚本立即终止"},{"key":"C","text":"导出所有变量"},{"key":"D","text":"执行空命令"}]',
 'B', '`set -e`(errexit)：任何命令失败(退出码非0)则脚本立即退出，避免错误累积。`set -u`使用未定义变量时报错。`set -x`开启调试输出。', 2);

-- KP 51-53: 系统设计基础 (15 questions, IDs 350-364)
INSERT IGNORE INTO questions (id, kp_id, question_type, content, options, answer, explanation, difficulty) VALUES
(350, 51, 'SINGLE_CHOICE', '系统设计面试第一步应该做什么？',
 '[{"key":"A","text":"开始画架构图"},{"key":"B","text":"澄清需求、明确功能和非功能需求"},{"key":"C","text":"选择数据库"},{"key":"D","text":"估算服务器数量"}]',
 'B', '系统设计面试应先澄清需求：功能需求（做什么）、非功能需求（可用性/一致性/延迟）、规模估算（DAU/QPS）。理解问题才能提出方案。', 1),
(351, 51, 'TRUE_FALSE', '系统设计面试中，QPS(每秒查询数)估算可以使用公式：QPS = DAU × 人均请求数 / 86400。',
 null, 'true', 'QPS估算：QPS ≈ (DAU × 人均请求数) / 86400。需考虑80-20规则（峰值QPS ≈ 平均QPS × 3~5倍）。这是面试中的常用估算方法。', 1),
(352, 51, 'SINGLE_CHOICE', '在系统设计的数据量估算中，1KB约等于多少字符？',
 '[{"key":"A","text":"约10字符"},{"key":"B","text":"约1024字符（一个字符约1字节）"},{"key":"C","text":"约100字符"},{"key":"D","text":"约10000字符"}]',
 'B', '1B≈1个英文字母或数字（ASCII），1个中文字符≈3B(UTF-8)。1KB≈1024B，约1000个英文字符或约300个中文字符。', 1),
(353, 51, 'SINGLE_CHOICE', '设计短链接系统(tiny URL)时，短码生成通常用什么技术？',
 '[{"key":"A","text":"随机数+去重"},{"key":"B","text":"ID自增+Base62编码"},{"key":"C","text":"仅使用MD5"},{"key":"D","text":"手动分配"}]',
 'B', '常用方案：自增ID转为62进制编码（0-9,a-z,A-Z），7位长度可表示62^7≈3.5万亿个链接。如ID=12345→短码"dnh"。', 2),
(354, 51, 'TRUE_FALSE', '设计系统时应该一开始就考虑所有扩展性和优化，确保系统完美。',
 null, 'false', '遵循简单原则：先设计能工作的版本，再逐步优化。过度设计(YAGNI-Ain''t Gonna Need It)浪费时间，但关键路径要考虑扩展性。', 2),
(355, 52, 'SINGLE_CHOICE', '微服务架构相比单体架构的主要优势是什么？',
 '[{"key":"A","text":"开发更简单"},{"key":"B","text":"各服务可独立部署、独立扩展、技术栈灵活"},{"key":"C","text":"不需要网络通信"},{"key":"D","text":"不需要数据库"}]',
 'B', '微服务将应用拆分为独立服务：独立部署（改动影响小）、独立扩展（按需扩容热点服务）、技术栈多样化（不同服务可用不同语言/数据库）。代价是分布式复杂性。', 1),
(356, 52, 'SINGLE_CHOICE', '消息队列在系统中的主要作用是什么？',
 '[{"key":"A","text":"存储数据"},{"key":"B","text":"解耦、异步处理、削峰填谷"},{"key":"C","text":"替代数据库"},{"key":"D","text":"加密通信"}]',
 'B', '消息队列三大作用：解耦（生产消费独立）、异步（不等待响应）、削峰（高峰期消息堆积，消费端匀速处理）。Kafka/RabbitMQ/RocketMQ是常用选型。', 1),
(357, 52, 'SINGLE_CHOICE', '以下哪种缓存策略中，应用先查缓存，缓存未命中时查数据库并回填缓存？',
 '[{"key":"A","text":"Cache-Aside（旁路缓存）"},{"key":"B","text":"Read-Through"},{"key":"C","text":"Write-Through"},{"key":"D","text":"Write-Behind"}]',
 'A', 'Cache-Aside是最常用的缓存模式：应用负责读缓存→缓存miss→读DB→写缓存。缓存层不直接与DB交互，由应用串联。', 2),
(358, 52, 'MULTI_CHOICE', '以下哪些是微服务架构面临的挑战？(多选)',
 '[{"key":"A","text":"分布式事务一致性"},{"key":"B","text":"服务间网络延迟"},{"key":"C","text":"部署和运维复杂度增加"},{"key":"D","text":"无法使用数据库"}]',
 'ABC', '微服务面临：分布式事务、网络延迟/超时、服务发现/负载均衡、部署运维(CICD/K8s)复杂度。微服务仍然可以使用数据库（每个服务通常有独立数据库）。', 2),
(359, 52, 'TRUE_FALSE', '读写分离架构中，主库负责写，从库负责读，可以线性扩展读能力。',
 null, 'true', '读写分离通过主从复制(Master→多个Slave)，主库写+从库读，可以水平扩展读能力。需要注意主从延迟导致的短暂数据不一致。', 1),
(360, 53, 'SINGLE_CHOICE', 'CAP定理中，当发生网络分区(P)时，必须在哪两者之间做选择？',
 '[{"key":"A","text":"性能(Performance)和一致性(Consistency)"},{"key":"B","text":"一致性(Consistency)和可用性(Availability)"},{"key":"C","text":"可靠性(Reliability)和安全性(Security)"},{"key":"D","text":"一致性和持久性"}]',
 'B', 'CAP定理：发生网络分区故障(P)时，必须在C(一致性)和A(可用性)之间权衡。选择CP（保证一致性，牺牲可用性）或AP（保证可用性，接受最终一致）。', 1),
(361, 53, 'SINGLE_CHOICE', '一致性哈希(Consistent Hashing)主要解决什么问题？',
 '[{"key":"A","text":"数据加密"},{"key":"B","text":"节点增减时最小化数据迁移量"},{"key":"C","text":"提高网络速度"},{"key":"D","text":"压缩数据"}]',
 'B', '一致性哈希：节点数变化时，只有哈希环上相邻的一小段区间的数据需要迁移（而非像取模法那样全部重新分布）。虚拟节点使分布更均衡。', 1),
(362, 53, 'SINGLE_CHOICE', '雪花算法(Snowflake)生成的分布式ID是严格全局递增的吗？',
 '[{"key":"A","text":"是严格全局递增"},{"key":"B","text":"是趋势递增但不保证严格全局递增"},{"key":"C","text":"是随机无序的"},{"key":"D","text":"是递减的"}]',
 'B', '雪花算法在同一毫秒内不同机器生成的ID不保证严格递增（机器号不同导致顺序错乱），只能保证趋势递增。需要严格递增的场景用数据库自增或号段模式。', 3),
(363, 53, 'SINGLE_CHOICE', '分布式事务的Saga模式的核心思想是什么？',
 '[{"key":"A","text":"一个事务锁定所有资源"},{"key":"B","text":"将长事务拆分为多个本地事务，每个事务有对应的补偿操作"},{"key":"C","text":"所有操作全部分配到一个数据库"},{"key":"D","text":"使用分布式锁"}]',
 'B', 'Saga将一个大事务拆分为多个有序的本地事务（步骤），每个步骤执行成功则触发下一步，失败则执行补偿操作（逆操作）回滚。最终一致性方案。', 2),
(364, 53, 'TRUE_FALSE', 'BASE理论是对CAP中AP方案的实践总结：基本可用、软状态、最终一致性。',
 null, 'true', 'BASE=Basically Available(基本可用)+Soft State(软状态/允许中间不一致)+Eventually Consistent(最终一致性)，是AP方案的具体实现思路，与ACID(CP)相对。', 1);

-- ========== Recommendation Logs ==========
INSERT IGNORE INTO recommendation_logs (user_id, kp_id, reason, clicked, created_at) VALUES
(2, 3, '前置知识点Java基础语法已掌握(88%), 建议学习异常处理', TRUE, '2026-07-13'),
(2, 4, '前置知识点OOP已掌握(79%), 建议学习集合框架', FALSE, '2026-07-19'),
(2, 10, '前置知识点数组与链表已掌握(90%), 推荐学习树与二叉树', TRUE, '2026-07-22'),
(3, 17, '前置知识点NumPy已掌握(70%), 推荐学习Pandas数据处理', TRUE, '2026-07-06'),
(3, 18, '前置知识点Pandas已掌握(66%), 建议学习数据可视化', FALSE, '2026-07-17');
