<template>
  <div class="login-container">
    <!-- Animated background particles -->
    <div class="bg-shapes">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
      <div class="shape shape-4"></div>
    </div>

    <!-- Login card -->
    <div class="login-card-wrapper">
      <div class="login-card">
        <!-- Logo area -->
        <div class="logo-section">
          <div class="logo-icon">
            <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="48" height="48" rx="12" fill="url(#logoGrad)"/>
              <path d="M14 32V16L24 22L34 16V32L24 38L14 32Z" fill="white" opacity="0.9"/>
              <path d="M14 16L24 22L34 16L24 10L14 16Z" fill="white"/>
              <defs>
                <linearGradient id="logoGrad" x1="0" y1="0" x2="48" y2="48">
                  <stop offset="0%" stop-color="#0D9488"/>
                  <stop offset="100%" stop-color="#2DD4BF"/>
                </linearGradient>
              </defs>
            </svg>
          </div>
          <h1 class="system-title">智能学习辅助系统</h1>
          <p class="system-subtitle">Smart Learning Assistant</p>
        </div>

        <!-- Form -->
        <el-form ref="formRef" :model="form" :rules="rules" class="login-form">
          <el-form-item prop="username">
            <el-input
              v-model="form.username"
              placeholder="请输入用户名"
              size="large"
              :prefix-icon="User"
              class="custom-input"
            />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              placeholder="请输入密码"
              size="large"
              :prefix-icon="Lock"
              show-password
              class="custom-input"
              @keyup.enter="handleLogin"
            />
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              size="large"
              class="login-btn"
              :loading="loading"
              @click="handleLogin"
            >
              <span v-if="!loading">登 录</span>
            </el-button>
          </el-form-item>
        </el-form>

        <div class="register-link">
          <span>还没有账号？</span>
          <el-button link type="primary" @click="showRegister = true">立即注册</el-button>
        </div>
      </div>
    </div>

    <!-- Register dialog -->
    <el-dialog v-model="showRegister" title="创建账号" width="420px" :close-on-click-modal="false" center>
      <el-form ref="regFormRef" :model="regForm" :rules="regRules" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="regForm.username" placeholder="请输入用户名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="regForm.realName" placeholder="请输入真实姓名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="regForm.password" type="password" placeholder="请设置密码" :prefix-icon="Lock" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRegister = false">取消</el-button>
        <el-button type="primary" :loading="regLoading" @click="handleRegister">
          注册
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { authApi } from '../api'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  loading.value = true
  try {
    await userStore.login(form.username, form.password)
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch {
    // error handled by interceptor
  } finally {
    loading.value = false
  }
}

const showRegister = ref(false)
const regLoading = ref(false)
const regForm = reactive({ username: '', realName: '', password: '' })
const regRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur', min: 4 }]
}

async function handleRegister() {
  regLoading.value = true
  try {
    await authApi.register({ ...regForm, role: 'STUDENT' })
    ElMessage.success('注册成功，请登录')
    showRegister.value = false
    form.username = regForm.username
    form.password = ''
  } catch {
    // error handled by interceptor
  } finally {
    regLoading.value = false
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(900px 520px at 85% -10%, rgba(13, 148, 136, 0.09), transparent 60%),
    radial-gradient(820px 460px at -10% 110%, rgba(217, 119, 6, 0.06), transparent 60%),
    radial-gradient(700px 420px at 55% 10%, rgba(79, 70, 229, 0.05), transparent 60%),
    #f7f8fa;
  overflow: hidden;
  position: relative;
}

/* Animated background shapes */
.bg-shapes { position: absolute; inset: 0; pointer-events: none; }
.shape {
  position: absolute; border-radius: 50%; opacity: 0.1;
  animation: float 20s infinite ease-in-out;
}
.shape-1 {
  width: 600px; height: 600px;
  background: rgba(13, 148, 136, 0.4);
  top: -200px; right: -100px;
  animation-delay: 0s;
}
.shape-2 {
  width: 400px; height: 400px;
  background: rgba(217, 119, 6, 0.32);
  bottom: -100px; left: -80px;
  animation-delay: 5s;
}
.shape-3 {
  width: 300px; height: 300px;
  background: rgba(79, 70, 229, 0.28);
  top: 50%; left: 60%;
  animation-delay: 10s;
}
.shape-4 {
  width: 200px; height: 200px;
  background: rgba(124, 58, 237, 0.28);
  bottom: 20%; right: 30%;
  animation-delay: 15s;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  25% { transform: translate(30px, -30px) rotate(5deg); }
  50% { transform: translate(-20px, 20px) rotate(-5deg); }
  75% { transform: translate(-30px, -20px) rotate(3deg); }
}

.login-card-wrapper {
  position: relative;
  z-index: 1;
  width: 420px;
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.login-card {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(18px) saturate(1.3);
  -webkit-backdrop-filter: blur(18px) saturate(1.3);
  border: 1px solid rgba(255, 255, 255, 0.7);
  border-radius: 20px;
  padding: 46px 42px;
  box-shadow: var(--shadow-lg), 0 0 0 1px rgba(15, 23, 42, 0.04);
}

.logo-section { text-align: center; margin-bottom: 36px; }
.logo-icon { width: 56px; height: 56px; margin: 0 auto 16px; }
.system-title {
  font-size: 23px; font-weight: 700; color: var(--text-1);
  margin: 0 0 4px; letter-spacing: 0.14em;
}
.system-subtitle {
  font-size: 12px; color: var(--text-3); margin: 0; letter-spacing: 0.22em;
  text-transform: uppercase;
}

.login-form { margin-top: 8px; }
.login-form :deep(.el-input__wrapper) {
  border-radius: 10px; padding: 2px 16px;
  box-shadow: 0 0 0 1px #e8e8e8 inset;
  transition: all 0.3s;
}
.login-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px var(--accent-border) inset;
}
.login-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 2px rgba(15, 118, 110, 0.2) inset;
}

.login-btn {
  width: 100%;
  height: 48px;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.3em;
  background: linear-gradient(135deg, #0d9488, #0f766e);
  border: none;
  box-shadow: 0 2px 10px rgba(13, 148, 136, 0.28);
  transition: transform 0.18s ease, box-shadow 0.18s ease, filter 0.18s ease;
}
.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 24px rgba(13, 148, 136, 0.32);
  filter: saturate(1.08);
}
.login-btn:active { transform: translateY(0); }

.register-link {
  text-align: center; margin-top: 24px;
  font-size: 13.5px; color: var(--text-3);
}

/* Dialog */
:deep(.el-dialog) { border-radius: 18px; }
:deep(.el-dialog__header) { text-align: center; font-size: 18px; font-weight: 600; }
</style>
