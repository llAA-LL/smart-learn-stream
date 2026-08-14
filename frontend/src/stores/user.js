import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi } from '../api'

/**
 * @typedef {import('../api/types.js').UserInfo} UserInfo
 */

/**
 * 从 localStorage 安全解析用户信息，避免脏数据导致 JSON.parse 崩溃。
 * @returns {UserInfo|null}
 */
function loadStoredUser() {
  try {
    const raw = localStorage.getItem('user')
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

/**
 * 用户状态：登录态、token 与本地持久化。
 *
 * @returns {{
 *   user: import('vue').Ref<UserInfo|null>,
 *   token: import('vue').Ref<string>,
 *   login: (username: string, password: string) => Promise<UserInfo>,
 *   logout: () => Promise<void>
 * }}
 */
export const useUserStore = defineStore('user', () => {
  /** @type {import('vue').Ref<UserInfo|null>} */
  const user = ref(loadStoredUser())
  /** @type {import('vue').Ref<string>} */
  const token = ref(localStorage.getItem('token') || '')

  /**
   * 登录并持久化 token 与用户信息。
   * @param {string} username
   * @param {string} password
   * @returns {Promise<UserInfo>}
   */
  async function login(username, password) {
    const res = await authApi.login({ username, password })
    const data = res.data.data
    const userData = {
      userId: data.userId,
      username: data.username,
      realName: data.realName,
      role: data.role
    }
    token.value = data.token
    user.value = userData
    localStorage.setItem('token', token.value)
    localStorage.setItem('user', JSON.stringify(userData))
    return userData
  }

  /**
   * 退出登录：先通知后端使 token 失效，再清理本地状态。
   * @returns {Promise<void>}
   */
  async function logout() {
    try {
      await authApi.logout()
    } catch {
      // 后端登出失败不阻塞本地清理
    }
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  return { user, token, login, logout }
})
