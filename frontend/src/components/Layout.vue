<template>
  <el-container class="app-layout">
    <!-- 侧边栏 -->
    <el-aside width="236px" class="app-sidebar">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <svg viewBox="0 0 40 40" fill="none" width="36" height="36">
            <rect width="40" height="40" rx="10" fill="#0f766e"/>
            <path d="M12 27V13L20 18L28 13V27L20 32L12 27Z" fill="white" opacity="0.92"/>
            <path d="M12 13L20 18L28 13L20 8L12 13Z" fill="white"/>
          </svg>
        </div>
        <div class="sidebar-title-wrap">
          <span class="sidebar-title">智能学习</span>
          <span class="sidebar-subtitle">AI 学习平台</span>
        </div>
      </div>

      <div class="menu-section-label">学习空间</div>
      <el-menu
        :default-active="activeMenu"
        background-color="transparent"
        text-color="rgba(255,255,255,0.6)"
        active-text-color="#fff"
        router
        class="sidebar-menu"
      >
        <el-menu-item index="/dashboard">
          <span class="menu-dot"></span><span>学习看板</span>
        </el-menu-item>

        <template v-if="userStore.user?.role === 'ADMIN'">
          <el-menu-item index="/courses">
            <span class="menu-dot"></span><span>课程管理</span>
          </el-menu-item>
          <el-menu-item index="/knowledge-graph">
            <span class="menu-dot"></span><span>知识图谱</span>
          </el-menu-item>
          <el-menu-item index="/questions">
            <span class="menu-dot"></span><span>题库管理</span>
          </el-menu-item>
        </template>

        <template v-if="userStore.user?.role === 'STUDENT'">
          <el-menu-item index="/courses">
            <span class="menu-dot"></span><span>课程浏览</span>
          </el-menu-item>
          <el-menu-item index="/knowledge-graph">
            <span class="menu-dot"></span><span>知识图谱</span>
          </el-menu-item>
          <el-menu-item index="/plans">
            <span class="menu-dot"></span><span>学习计划</span>
          </el-menu-item>
          <el-menu-item index="/self-test">
            <span class="menu-dot"></span><span>知识点自测</span>
          </el-menu-item>
          <el-menu-item index="/records">
            <span class="menu-dot"></span><span>学习记录</span>
          </el-menu-item>
          <el-menu-item index="/recommendations">
            <span class="menu-dot"></span><span>智能推荐</span>
          </el-menu-item>
          <el-menu-item index="/assistant">
            <span class="menu-dot"></span><span>AI 助手</span>
          </el-menu-item>
        </template>
      </el-menu>

      <div class="sidebar-footer">
        <div class="user-info">
          <div class="avatar">{{ avatarChar }}</div>
          <div class="user-detail">
            <div class="user-name">{{ userStore.user?.realName || userStore.user?.username }}</div>
            <div class="user-role">{{ userStore.user?.role === 'ADMIN' ? '管理员' : '学生' }}</div>
          </div>
        </div>
      </div>
    </el-aside>

    <!-- 主区域 -->
    <el-container class="app-body">
      <el-header class="app-header">
        <div class="header-left">
          <span class="header-title">{{ pageTitle }}</span>
          <span class="header-greeting">{{ greeting }}好，{{ userStore.user?.realName || userStore.user?.username }}</span>
        </div>
        <div class="header-right">
          <el-button text class="logout-btn" @click="handleLogout">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
            退出
          </el-button>
        </div>
      </el-header>
      <el-main class="app-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)

const pageTitles = {
  '/dashboard': '学习看板',
  '/courses': '课程',
  '/knowledge-graph': '知识图谱',
  '/plans': '学习计划',
  '/records': '学习记录',
  '/self-test': '知识点自测',
  '/recommendations': '智能推荐',
  '/questions': '题库管理',
  '/assistant': 'AI 助手'
}
const pageTitle = computed(() => pageTitles[route.path] || '智能学习平台')
const avatarChar = computed(() => (userStore.user?.realName || userStore.user?.username || 'U')[0])

const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '凌晨'
  if (h < 12) return '上午'
  if (h < 18) return '下午'
  return '晚上'
})

function handleLogout() {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.app-layout { min-height: 100vh; }

/* ---- 侧边栏：深色墨感 ---- */
.app-sidebar {
  background:
    radial-gradient(420px 200px at 18% 0%, rgba(124, 58, 237, 0.16), transparent 60%),
    radial-gradient(420px 200px at 82% 0%, rgba(15, 118, 110, 0.14), transparent 60%),
    #0e0e10;
  border-right: 1px solid rgba(255, 255, 255, 0.06);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: sticky;
  top: 0;
  height: 100vh;
}
.sidebar-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 22px 20px 18px;
}
.sidebar-title-wrap { display: flex; flex-direction: column; }
.sidebar-title { font-size: 17px; font-weight: 650; color: #fff; letter-spacing: 0.5px; }
.sidebar-subtitle { font-size: 11px; color: rgba(255,255,255,0.38); margin-top: 2px; letter-spacing: 1.5px; }

.menu-section-label {
  font-size: 11px;
  color: rgba(255,255,255,0.3);
  padding: 10px 24px 6px;
  letter-spacing: 1.5px;
}

.sidebar-menu { border-right: none; flex: 1; overflow-y: auto; }
.sidebar-menu .el-menu-item {
  height: 42px;
  line-height: 42px;
  margin: 1px 10px;
  padding-left: 18px !important;
  border-radius: 8px;
  font-size: 13.5px;
  transition: background 0.15s ease;
  gap: 10px;
}
.sidebar-menu .el-menu-item:hover { background: rgba(255, 255, 255, 0.05); color: #fff; }
.sidebar-menu .el-menu-item.is-active {
  background: rgba(255, 255, 255, 0.09);
  color: #fff;
  font-weight: 550;
}
.sidebar-menu .el-menu-item.is-active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 20px;
  border-radius: 2px;
  background: #14b8a6;
}
.menu-dot { width: 5px; height: 5px; border-radius: 50%; background: currentColor; opacity: 0.5; flex-shrink: 0; }

.sidebar-footer { padding: 14px 16px; border-top: 1px solid rgba(255,255,255,0.06); }
.user-info { display: flex; align-items: center; gap: 12px; }
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: #0f766e;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 650;
  font-size: 14px;
  flex-shrink: 0;
}
.user-name { font-size: 13px; font-weight: 550; color: #fff; }
.user-role { font-size: 11px; color: rgba(255,255,255,0.4); margin-top: 2px; }

/* ---- 主区域 ---- */
.app-body { min-width: 0; }
.app-header {
  height: 60px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 28px;
  position: sticky;
  top: 0;
  z-index: 10;
}
.header-left { display: flex; align-items: baseline; gap: 14px; }
.header-title { font-size: 16px; font-weight: 600; color: var(--text-1); }
.header-greeting { font-size: 13px; color: var(--text-3); }
.logout-btn { color: var(--text-2); gap: 6px; font-size: 13px; }
.logout-btn:hover { color: var(--danger); background: transparent; }

.app-main { padding: 24px 28px; }

@media (max-width: 900px) {
  .app-sidebar { width: 200px !important; }
  .header-greeting { display: none; }
}
</style>
