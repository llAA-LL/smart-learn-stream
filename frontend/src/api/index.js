import axios from 'axios'
import { ElMessage } from 'element-plus'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

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

// Auth
export const authApi = {
  login: (data) => api.post('/auth/login', data),
  register: (data) => api.post('/auth/register', data),
  me: () => api.get('/auth/me')
}

// Courses
export const courseApi = {
  list: (params) => api.get('/courses', { params }),
  get: (id) => api.get(`/courses/${id}`),
  create: (data) => api.post('/courses', data),
  update: (id, data) => api.put(`/courses/${id}`, data),
  delete: (id) => api.delete(`/courses/${id}`)
}

// Knowledge Graph
export const kgApi = {
  listNodes: (courseId) => api.get('/knowledge-graph/nodes' + (courseId ? `?courseId=${courseId}` : '')),
  getNode: (id) => api.get(`/knowledge-graph/nodes/${id}`),
  createNode: (data) => api.post('/knowledge-graph/nodes', data),
  updateNode: (id, data) => api.put(`/knowledge-graph/nodes/${id}`, data),
  deleteNode: (id) => api.delete(`/knowledge-graph/nodes/${id}`),
  graphData: () => api.get('/knowledge-graph/graph')
}

// Learning Plans
export const planApi = {
  list: () => api.get('/plans'),
  get: (id) => api.get(`/plans/${id}`),
  create: (data) => api.post('/plans', data),
  update: (id, data) => api.put(`/plans/${id}`, data),
  delete: (id) => api.delete(`/plans/${id}`),
  toggleItem: (itemId) => api.put(`/plans/items/${itemId}/toggle`)
}

// Learning Records
export const recordApi = {
  create: (data) => api.post('/records', data),
  list: (params) => api.get('/records', { params }),
  stats: () => api.get('/records/stats'),
  mastery: () => api.get('/records/mastery')
}

// Quiz
export const quizApi = {
  generate: (kpId) => api.get('/quiz/generate', { params: { kpId } }),
  submit: (data) => api.post('/quiz/submit', data),
  history: (params) => api.get('/quiz/history', { params }),
  getAttempt: (id) => api.get(`/quiz/attempts/${id}`)
}

// Questions (admin)
export const questionApi = {
  list: (params) => api.get('/questions', { params }),
  get: (id) => api.get(`/questions/${id}`),
  create: (data) => api.post('/questions', data),
  update: (id, data) => api.put(`/questions/${id}`, data),
  delete: (id) => api.delete(`/questions/${id}`)
}

// Recommendations
export const recApi = {
  recommend: () => api.get('/recommendations'),
  weakPoints: () => api.get('/recommendations/weak-points'),
  click: (data) => api.post('/recommendations/click', data)
}

export default api
