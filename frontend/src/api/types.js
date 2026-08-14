/**
 * 领域模型与接口类型定义（纯 JSDoc，无运行时代码）。
 *
 * 在其他文件中引用示例：
 * @typedef {import('./types.js').Course} Course
 * @param {import('./types.js').Course} course
 */

/**
 * 后端统一响应包裹。
 * @typedef {Object} ApiEnvelope
 * @property {number} code - 业务状态码（0 为成功）
 * @property {string} message - 提示信息
 * @property {*} data - 业务数据体
 */

/**
 * 分页结果。
 * @typedef {Object} PagedResult
 * @property {Array<*>} list - 当前页数据
 * @property {number} total - 总条数
 * @property {number} page - 当前页码
 * @property {number} pageSize - 每页条数
 */

/**
 * 登录用户信息。
 * @typedef {Object} UserInfo
 * @property {number} userId - 用户 ID
 * @property {string} username - 登录名
 * @property {string} realName - 真实姓名
 * @property {'ADMIN'|'STUDENT'} role - 角色
 */

/**
 * 课程。
 * @typedef {Object} Course
 * @property {number} id - 课程 ID
 * @property {string} name - 课程名称
 * @property {string} [description] - 简介
 * @property {string} [cover] - 封面 URL
 * @property {string} [category] - 分类标签
 * @property {number} [knowledgePointCount] - 知识点数量
 */

/**
 * 知识点。
 * @typedef {Object} KnowledgeNode
 * @property {number} id - 知识点 ID
 * @property {number} courseId - 所属课程 ID
 * @property {string} name - 知识点名称
 * @property {number} [level] - 层级（0 起，数字越小越基础）
 * @property {string} [category] - 分类标签
 * @property {string} [description] - 详细内容
 * @property {number[]} [prerequisiteIds] - 前置知识点 ID 列表
 */

/**
 * 知识图谱数据结构。
 * @typedef {Object} GraphData
 * @property {KnowledgeNode[]} nodes - 节点列表
 * @property {Array<{id: number, source: number, target: number}>} edges - 有向边列表
 */

/**
 * 学习计划项。
 * @typedef {Object} PlanItem
 * @property {number} id - 计划项 ID
 * @property {number} kpId - 知识点 ID
 * @property {string} kpName - 知识点名称
 * @property {boolean} done - 是否已完成
 */

/**
 * 学习计划。
 * @typedef {Object} LearningPlan
 * @property {number} id - 计划 ID
 * @property {string} title - 计划标题
 * @property {'ACTIVE'|'DONE'} [status] - 状态
 * @property {string} [startDate] - 开始日期（yyyy-MM-dd）
 * @property {string} [endDate] - 结束日期
 * @property {number} [progressPercent] - 完成百分比 0-100
 * @property {PlanItem[]} [items] - 计划项
 */

/**
 * 学习统计。
 * @typedef {Object} LearningStats
 * @property {number} [todayMinutes] - 今日学习分钟
 * @property {number} [weekMinutes] - 本周学习分钟
 * @property {number} [totalMinutes] - 累计学习分钟
 * @property {Array<{date: string, minutes: number}>} [dailyStats] - 每日学习趋势
 */

/**
 * 智能推荐项。
 * @typedef {Object} Recommendation
 * @property {number} kpId - 知识点 ID
 * @property {string} kpName - 知识点名称
 * @property {'REVIEW'|'NEXT'|'NEW'} [type] - 推荐类型
 * @property {string} [courseName] - 课程名
 * @property {string} [reason] - 推荐理由
 */

/**
 * 自测题目。
 * @typedef {Object} QuizQuestion
 * @property {number} id - 题目 ID
 * @property {string} question - 题干
 * @property {string[]} options - 选项列表
 * @property {number} [answerIndex] - 正确答案下标（提交回显用）
 * @property {string} [analysis] - 解析
 */

/**
 * 题库题目（管理端）。
 * @typedef {Object} Question
 * @property {number} id - 题目 ID
 * @property {number} kpId - 所属知识点 ID
 * @property {string} content - 题干
 * @property {string[]} options - 选项
 * @property {number} answer - 正确答案下标
 * @property {string} [analysis] - 解析
 * @property {string} [difficulty] - 难度
 */

export {}
