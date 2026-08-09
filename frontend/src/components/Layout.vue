<template>
  <el-container class="app-layout">
    <!-- Sidebar -->
    <el-aside width="240px" class="app-sidebar">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <svg viewBox="0 0 40 40" fill="none" width="36" height="36">
            <rect width="40" height="40" rx="10" fill="url(#sLogoGrad)"/>
            <path d="M12 27V13L20 18L28 13V27L20 32L12 27Z" fill="white" opacity="0.9"/>
            <path d="M12 13L20 18L28 13L20 8L12 13Z" fill="white"/>
            <defs>
              <linearGradient id="sLogoGrad" x1="0" y1="0" x2="40" y2="40">
                <stop offset="0%" stop-color="#667eea"/><stop offset="100%" stop-color="#764ba2"/>
              </linearGradient>
            </defs>
          </svg>
        </div>
        <span class="sidebar-title">智能学习</span>
      </div>

      <el-menu
        :default-active="activeMenu"
        background-color="transparent"
        text-color="rgba(255,255,255,0.6)"
        active-text-color="#fff"
        router
        class="sidebar-menu"
      >
        <el-menu-item index="/dashboard">
          <span>学习看板</span>
        </el-menu-item>

        <template v-if="userStore.user?.role === 'ADMIN'">
          <el-menu-item index="/courses">
            <span>课程管理</span>
          </el-menu-item>
          <el-menu-item index="/knowledge-graph">
            <span>知识图谱</span>
          </el-menu-item>
          <el-menu-item v-if="userStore.user?.role === 'ADMIN'" index="/questions">
            <span>题库管理</span>
          </el-menu-item>
        </template>

        <template v-if="userStore.user?.role === 'STUDENT'">
          <el-menu-item index="/courses">
            <span>课程浏览</span>
          </el-menu-item>
          <el-menu-item index="/knowledge-graph">
            <span>知识图谱</span>
          </el-menu-item>
          <el-menu-item index="/plans">
            <span>学习计划</span>
          </el-menu-item>
          <el-menu-item index="/self-test">
            <span>知识点自测</span>
          </el-menu-item>
          <el-menu-item index="/records">
            <span>学习记录</span>
          </el-menu-item>
          <el-menu-item index="/recommendations">
            <span>智能推荐</span>
          </el-menu-item>
          <el-menu-item index="/assistant">
            <span>AI 助手</span>
          </el-menu-item>
        </template>
      </el-menu>

      <div class="sidebar-footer">
        <div class="user-info">
          <div class="avatar">{{ (userStore.user?.realName || userStore.user?.username || 'U')[0] }}</div>
          <div class="user-detail">
            <div class="user-name">{{ userStore.user?.realName || userStore.user?.username }}</div>
            <div class="user-role">{{ userStore.user?.role === 'ADMIN' ? '管理员' : '学生' }}</div>
          </div>
        </div>
      </div>
    </el-aside>

    <!-- Main content -->
    <el-container>
      <el-header class="app-header">
        <div class="header-left">
          <span class="header-greeting">欢迎回来</span>
        </div>
        <div class="header-right">
          <el-button type="danger" size="small" plain @click="handleLogout">退出</el-button>
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

function handleLogout() {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.app-layout { min-height: 100vh; }

/* Sidebar */
.app-sidebar {
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.sidebar-header {
  display: flex; align-items: center; gap: 10px;
  padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.06);
}
.sidebar-title {
  font-size: 18px; font-weight: 700; color: #fff;
  letter-spacing: 2px;
}

/* el-menu overrides */
.sidebar-menu {
  flex: 1;
  border-right: none !important;
  padding: 8px 0;
  overflow-y: auto;
}
.sidebar-menu :deep(.el-menu-item) {
  margin: 2px 12px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  height: 44px;
  line-height: 44px;
}
.sidebar-menu :deep(.el-menu-item:hover) {
  background: rgba(255,255,255,0.06) !important;
}
.sidebar-menu :deep(.el-menu-item.is-active) {
  background: linear-gradient(135deg, #667eea44, #764ba244) !important;
  color: #fff !important;
  font-weight: 600;
}

.sidebar-footer {
  padding: 16px 20px; border-top: 1px solid rgba(255,255,255,0.06);
}
.user-info { display: flex; align-items: center; gap: 10px; }
.avatar {
  width: 36px; height: 36px; border-radius: 10px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-weight: 600; font-size: 15px;
}
.user-detail { flex: 1; min-width: 0; }
.user-name { font-size: 13px; color: #fff; font-weight: 500; }
.user-role { font-size: 11px; color: rgba(255,255,255,0.4); }

/* Header */
.app-header {
  background: #fff;
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 28px; height: 60px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.header-greeting { font-size: 15px; color: #333; font-weight: 500; }
.header-right { display: flex; align-items: center; gap: 16px; }

/* Main */
.app-main {
  background: #f0f2f5;
  padding: 24px;
  min-height: calc(100vh - 60px);
}
</style>
