import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '../types/userInterface'
import * as authApi from '../api/auth.api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const accessToken = ref<string | null>(null)
  const isLoading = ref(false)
  const isInitialized = ref(false)

  const refreshToken = ref<string | null>(null)

  const isAuthenticated = computed(() => !!user.value)

   function clearAuth() {
    user.value = null

    accessToken.value = null
    refreshToken.value = null
  }

  async function initAuth() {
  try {
    await authApi.refresh()
    const {data} = await authApi.me()
    user.value = data
  } catch {
    clearAuth()
  } finally {
    isInitialized.value = true
  }
}
/*
  async function initialize() {
    try {
      await authApi.refresh //api.post('/auth/refresh')
      this.isAuthenticated = true
    } catch {
      this.clearAuth()
    } finally {
      this.isInitialized = true
    }
  }
 */   
  async function fetchMe() {
    //if (isInitialized.value) return

    try {
      isLoading.value = true
      const { data } = await authApi.me()
      user.value = data
    } catch {
      clearAuth()
    } finally {
      isLoading.value = false
      isInitialized.value = true
    }
  }
  async function login(payload: { email: string, password: string }) {
    await authApi.login(payload)
    const { data } = await authApi.me()
    user.value = data

    accessToken.value = data.accessToken
    refreshToken.value = data.refreshToken
  }
  function setUser(newUser: User) {
    user.value = newUser
  }
  

  async function logout() {
    try {
      await authApi.logout()
    } finally {
      clearAuth()
    }
  }

  return {
    user,
    accessToken,
    isLoading,
    isAuthenticated,
    isInitialized,
    fetchMe,
    initAuth,
    setUser,
    logout,
    login,
    clearAuth,
  }
})