import { createRouter, createWebHistory } from 'vue-router'

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

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.noAuth || token) {
    next()
  } else {
    next('/login')
  }
})

export default router
