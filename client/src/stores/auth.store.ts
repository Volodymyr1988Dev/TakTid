import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../api/axios'
import type { User } from '../types/userInterface'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const isLoading = ref(false)
  const isInitialized = ref(false) // ✅ FIX

  const isAuthenticated = computed(() => !!user.value)

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
    const { data } = await api.post('/auth/login', payload)
    user.value = data.user
  }
  function setUser(newUser: User) {
    user.value = newUser
  }

  async function logout() {
    user.value = null
    await api.post('/auth/logout')
  }

  return {
    user,
    isLoading,
    isAuthenticated,
    isInitialized, // ✅
    fetchMe,
    setUser,
    logout,
    login,
  }
})