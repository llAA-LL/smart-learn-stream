<template>
  <el-container class="app-layout">
    <!-- 侧边栏 -->
    <el-aside width="236px" class="app-sidebar">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <svg viewBox="0 0 40 40" fill="none" width="36" height="36" aria-hidden="true">
            <defs>
              <linearGradient id="logoGrad" x1="0" y1="0" x2="40" y2="40">
                <stop offset="0%" stop-color="#0D9488"/>
                <stop offset="100%" stop-color="#2DD4BF"/>
              </linearGradient>
            </defs>
            <rect width="40" height="40" rx="11" fill="url(#logoGrad)"/>
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
        <div class="avatar" aria-hidden="true">{{ avatarChar }}</div>
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

/* ---- 侧边栏：深墨色 + 克制的 teal/violet 光晕 ---- */
.app-sidebar {
  background:
    radial-gradient(460px 240px at 20% -5%, rgba(13, 148, 136, 0.18), transparent 62%),
    radial-gradient(420px 220px at 90% 4%, rgba(124, 58, 237, 0.12), transparent 62%),
    #0b1210;
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
.sidebar-logo {
  filter: drop-shadow(0 2px 8px rgba(13, 148, 136, 0.35));
}
.sidebar-title-wrap { display: flex; flex-direction: column; }
.sidebar-title {
  font-size: 17px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.02em;
}
.sidebar-subtitle {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.38);
  margin-top: 2px;
  letter-spacing: 0.18em;
}

.menu-section-label {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.3);
  padding: 12px 24px 6px;
  letter-spacing: 0.14em;
}

.sidebar-menu { border-right: none; flex: 1; overflow-y: auto; padding: 2px 0; }
.sidebar-menu .el-menu-item {
  height: 42px;
  line-height: 42px;
  margin: 2px 12px;
  padding-left: 16px !important;
  border-radius: 10px;
  font-size: 13.5px;
  transition: background 0.16s ease, color 0.16s ease;
  gap: 10px;
}
.sidebar-menu .el-menu-item:hover {
  background: rgba(255, 255, 255, 0.06);
  color: #fff;
}
.sidebar-menu .el-menu-item.is-active {
  background: linear-gradient(90deg, rgba(13, 148, 136, 0.28), rgba(13, 148, 136, 0.08));
  color: #fff;
  font-weight: 600;
  box-shadow: inset 0 0 0 1px rgba(94, 234, 212, 0.14);
}
.sidebar-menu .el-menu-item.is-active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 22px;
  border-radius: 0 3px 3px 0;
  background: #2dd4bf;
}
.menu-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: currentColor;
  opacity: 0.45;
  flex-shrink: 0;
}

.sidebar-footer { padding: 14px 16px; border-top: 1px solid rgba(255, 255, 255, 0.06); }
.user-info { display: flex; align-items: center; gap: 12px; }
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: linear-gradient(135deg, var(--accent), #2dd4bf);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 650;
  font-size: 14px;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(13, 148, 136, 0.3);
}
.user-name { font-size: 13px; font-weight: 550; color: #fff; }
.user-role { font-size: 11px; color: rgba(255, 255, 255, 0.4); margin-top: 2px; }

/* ---- 主区域：毛玻璃顶栏 ---- */
.app-body { min-width: 0; }
.app-header {
  height: 60px;
  background: rgba(255, 255, 255, 0.78);
  backdrop-filter: blur(14px) saturate(1.4);
  -webkit-backdrop-filter: blur(14px) saturate(1.4);
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
.header-title {
  font-size: 16px;
  font-weight: 650;
  letter-spacing: -0.01em;
  color: var(--text-1);
}
.header-greeting { font-size: 13px; color: var(--text-3); }
.logout-btn { color: var(--text-2); gap: 6px; font-size: 13px; }
.logout-btn:hover { color: var(--danger); background: transparent; }

.app-main { padding: 24px 28px 48px; }

@media (max-width: 900px) {
  .app-sidebar { width: 208px !important; }
  .header-greeting { display: none; }
}
</style>
