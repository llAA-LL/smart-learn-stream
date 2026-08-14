import { createRouter, createWebHistory } from 'vue-router'

/**
 * @typedef {import('vue-router').RouteRecordRaw} RouteRecordRaw
 * @typedef {import('vue-router').RouteLocationNormalized} RouteLocationNormalized
 * @typedef {import('vue-router').NavigationGuardNext} NavigationGuardNext
 */

/**
 * 路由元信息扩展。
 * @typedef {Object} AppRouteMeta
 * @property {boolean} [noAuth] - 无需登录即可访问
 */

/** @type {RouteRecordRaw[]} */
const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { noAuth: true }
  },
  {
    path: '/',
    component: () => import('../components/Layout.vue'),
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard.vue') },
      { path: 'courses', name: 'Courses', component: () => import('../views/Courses.vue') },
      { path: 'knowledge-graph', name: 'KnowledgeGraph', component: () => import('../views/KnowledgeGraph.vue') },
      { path: 'plans', name: 'LearningPlans', component: () => import('../views/LearningPlans.vue') },
      { path: 'records', name: 'LearningRecords', component: () => import('../views/LearningRecords.vue') },
      { path: 'recommendations', name: 'Recommendations', component: () => import('../views/Recommendations.vue') },
      { path: 'self-test', name: 'SelfTest', component: () => import('../views/SelfTest.vue') },
      { path: 'questions', name: 'QuestionManager', component: () => import('../views/QuestionManager.vue') },
      { path: 'knowledge-point/:id', name: 'KnowledgePointDetail', component: () => import('../views/KnowledgePointDetail.vue') },
      { path: 'assistant', name: 'AgentChat', component: () => import('../views/AgentChat.vue') }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

/**
 * 全局前置守卫：无 token 一律重定向登录页。
 * @param {RouteLocationNormalized} to - 目标路由
 * @param {RouteLocationNormalized} from - 来源路由
 * @param {NavigationGuardNext} next
 */
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.noAuth || token) {
    next()
  } else {
    next('/login')
  }
})

export default router
