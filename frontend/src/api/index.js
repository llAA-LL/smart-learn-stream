import axios from 'axios'
import { ElMessage } from 'element-plus'

/**
 * @typedef {import('./types.js').ApiEnvelope} ApiEnvelope
 * @typedef {import('./types.js').PagedResult} PagedResult
 * @typedef {import('./types.js').UserInfo} UserInfo
 * @typedef {import('./types.js').Course} Course
 * @typedef {import('./types.js').KnowledgeNode} KnowledgeNode
 * @typedef {import('./types.js').GraphData} GraphData
 * @typedef {import('./types.js').LearningPlan} LearningPlan
 * @typedef {import('./types.js').LearningStats} LearningStats
 * @typedef {import('./types.js').Recommendation} Recommendation
 * @typedef {import('./types.js').QuizQuestion} QuizQuestion
 * @typedef {import('./types.js').Question} Question
 * @typedef {import('axios').AxiosInstance} AxiosInstance
 * @typedef {import('axios').AxiosResponse} AxiosResponse
 * @typedef {import('axios').InternalAxiosRequestConfig} InternalAxiosRequestConfig
 */

/**
 * 统一 axios 实例：baseURL 走 Vite 代理（/api → 主后端），超时 10s。
 * @type {AxiosInstance}
 */
const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

/**
 * 请求拦截器：自动附加 JWT 到 Authorization 头。
 * @param {InternalAxiosRequestConfig} config
 * @returns {InternalAxiosRequestConfig}
 */
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

/**
 * 响应拦截器：401 清空登录态并跳转登录页；其余错误统一 toast 提示。
 * @returns {AxiosResponse}
 */
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    const msg = error.response?.data?.message || '请求失败'
    ElMessage.error(msg)
    return Promise.reject(error)
  }
)

/** 认证相关接口。 */
export const authApi = {
  /**
   * 登录。
   * @param {{username: string, password: string}} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  login: (data) => api.post('/auth/login', data),
  /**
   * 注册（服务端强制 STUDENT 角色）。
   * @param {{username: string, password: string, realName?: string}} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  register: (data) => api.post('/auth/register', data),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} 获取当前登录用户信息 */
  me: () => api.get('/auth/me'),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} 退出登录（后端使 token 失效） */
  logout: () => api.post('/auth/logout')
}

/** 课程相关接口。 */
export const courseApi = {
  /**
   * 分页查询课程。
   * @param {{page?: number, pageSize?: number, keyword?: string}} [params]
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: PagedResult<Course>
   */
  list: (params) => api.get('/courses', { params }),
  /**
   * 课程详情。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: Course
   */
  get: (id) => api.get(`/courses/${id}`),
  /**
   * 新建课程。
   * @param {Partial<Course>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  create: (data) => api.post('/courses', data),
  /**
   * 更新课程。
   * @param {number} id
   * @param {Partial<Course>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  update: (id, data) => api.put(`/courses/${id}`, data),
  /**
   * 删除课程。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  delete: (id) => api.delete(`/courses/${id}`)
}

/** 知识图谱相关接口。 */
export const kgApi = {
  /**
   * 知识点列表（可按课程过滤）。
   * @param {number} [courseId]
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: KnowledgeNode[]
   */
  listNodes: (courseId) => api.get('/knowledge-graph/nodes' + (courseId ? `?courseId=${courseId}` : '')),
  /**
   * 知识点详情。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: KnowledgeNode
   */
  getNode: (id) => api.get(`/knowledge-graph/nodes/${id}`),
  /**
   * 创建知识点。
   * @param {Partial<KnowledgeNode>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  createNode: (data) => api.post('/knowledge-graph/nodes', data),
  /**
   * 更新知识点。
   * @param {number} id
   * @param {Partial<KnowledgeNode>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  updateNode: (id, data) => api.put(`/knowledge-graph/nodes/${id}`, data),
  /**
   * 删除知识点。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  deleteNode: (id) => api.delete(`/knowledge-graph/nodes/${id}`),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} data: GraphData */
  graphData: () => api.get('/knowledge-graph/graph')
}

/** 学习计划相关接口。 */
export const planApi = {
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} data: LearningPlan[] */
  list: () => api.get('/plans'),
  /**
   * 计划详情。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: LearningPlan
   */
  get: (id) => api.get(`/plans/${id}`),
  /**
   * 创建计划。
   * @param {Partial<LearningPlan>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  create: (data) => api.post('/plans', data),
  /**
   * 更新计划。
   * @param {number} id
   * @param {Partial<LearningPlan>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  update: (id, data) => api.put(`/plans/${id}`, data),
  /**
   * 删除计划。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  delete: (id) => api.delete(`/plans/${id}`),
  /**
   * 勾选/取消计划项。
   * @param {number} itemId
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  toggleItem: (itemId) => api.put(`/plans/items/${itemId}/toggle`)
}

/** 学习记录相关接口。 */
export const recordApi = {
  /**
   * 记录一次学习行为。
   * @param {{kpId: number, minutes: number}} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  create: (data) => api.post('/records', data),
  /**
   * 分页查询学习记录。
   * @param {{page?: number, pageSize?: number, courseId?: number}} [params]
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: PagedResult
   */
  list: (params) => api.get('/records', { params }),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} data: LearningStats */
  stats: () => api.get('/records/stats'),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} 知识点掌握度 */
  mastery: () => api.get('/records/mastery')
}

/** 自测相关接口。 */
export const quizApi = {
  /**
   * 按知识点生成题目。
   * @param {number} kpId
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: QuizQuestion[]
   */
  generate: (kpId) => api.get('/quiz/generate', { params: { kpId } }),
  /**
   * 提交答卷。
   * @param {Object} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  submit: (data) => api.post('/quiz/submit', data),
  /**
   * 历史记录。
   * @param {{page?: number, pageSize?: number}} [params]
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  history: (params) => api.get('/quiz/history', { params }),
  /**
   * 答卷详情。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  getAttempt: (id) => api.get(`/quiz/attempts/${id}`)
}

/** 题库（管理端）接口。 */
export const questionApi = {
  /**
   * 分页查询题目。
   * @param {{page?: number, pageSize?: number, kpId?: number}} [params]
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: PagedResult<Question>
   */
  list: (params) => api.get('/questions', { params }),
  /**
   * 题目详情。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>} data: Question
   */
  get: (id) => api.get(`/questions/${id}`),
  /**
   * 新建题目。
   * @param {Partial<Question>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  create: (data) => api.post('/questions', data),
  /**
   * 更新题目。
   * @param {number} id
   * @param {Partial<Question>} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  update: (id, data) => api.put(`/questions/${id}`, data),
  /**
   * 删除题目。
   * @param {number} id
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  delete: (id) => api.delete(`/questions/${id}`)
}

/** 智能推荐接口。 */
export const recApi = {
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} data: Recommendation[] */
  recommend: () => api.get('/recommendations'),
  /** @returns {Promise<AxiosResponse<ApiEnvelope>>} 薄弱点列表 */
  weakPoints: () => api.get('/recommendations/weak-points'),
  /**
   * 上报推荐点击，用于效果统计。
   * @param {{kpId: number, type?: string}} data
   * @returns {Promise<AxiosResponse<ApiEnvelope>>}
   */
  click: (data) => api.post('/recommendations/click', data)
}

export default api
