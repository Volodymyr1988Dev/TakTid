import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../api/axios'
import type { User } from '../types/userInterface'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const accessToken = ref<string | null>(null)
  const isLoading = ref(false)
  const isInitialized = ref(false) // ✅ FIX

  const isAuthenticated = computed(() => !!user.value)

   function clearAuth() {
    user.value = null
    accessToken.value = null
    localStorage.removeItem('access_token')
  }

  async function initAuth() {
    try {
      isLoading.value = true

      const { data } = await api.post('/auth/refresh')
      accessToken.value = data.accessToken
      user.value = data.user

      localStorage.setItem('access_token', data.accessToken)
    } catch {

      const storedToken = localStorage.getItem('access_token')

      if (storedToken) {
        accessToken.value = storedToken

        try {
          const { data } = await api.get('/auth/me')
          user.value = data
        } catch {
          clearAuth()
        }
      } else {
        clearAuth()
      }
    } finally {
      isLoading.value = false
      isInitialized.value = true
    }
  }

  async function fetchMe() {
    //if (isInitialized.value) return

    try {
      isLoading.value = true
      //const { data } = await api.get<User>('/auth/me')
      const { data } = await api.get('/auth/me')
      user.value = data
      console.log(data,'data from fetchMe');
    } catch {
      user.value = null
    } finally {
      isLoading.value = false
      isInitialized.value = true // ✅ FIX
    }
  }
  async function login(payload: { email: string, password: string }) {
  //async function login() {
    const { data } = await api.post('/auth/login', payload)

    //const refreshed = await api.post('/auth/refresh')

    //accessToken.value = data.token
    accessToken.value = data.token
    //user.value = data.user
    user.value = data.user
    localStorage.setItem('access_token', data.accessToken)
    console.log('access_token:', localStorage.getItem(data.accessToken))
  }
  function setUser(newUser: User) {
    user.value = newUser
  }

  async function logout() {
    try {
      await api.post('/auth/logout')
    } finally {
      //user.value = null
      //accessToken.value = null
      clearAuth()
    }
  }

  return {
    user,
    accessToken,
    isLoading,
    isAuthenticated,
    isInitialized, // ✅
    fetchMe,
    initAuth,
    setUser,
    logout,
    login,
  }
})