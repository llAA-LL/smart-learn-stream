import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi } from '../api'

export const useUserStore = defineStore('user', () => {
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const token = ref(localStorage.getItem('token') || '')

  async function login(username, password) {
    const res = await authApi.login({ username, password })
    token.value = res.data.data.token
    const userData = {
      userId: res.data.data.userId,
      username: res.data.data.username,
      realName: res.data.data.realName,
      role: res.data.data.role
    }
    user.value = userData
    localStorage.setItem('token', token.value)
    localStorage.setItem('user', JSON.stringify(userData))
    return userData
  }

  async function logout() {
    try {
      await authApi.logout()
    } catch {
      // ignore
    }
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  return { user, token, login, logout }
})
