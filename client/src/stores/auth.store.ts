import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '../types/userInterface'
import * as authApi from '../api/auth.api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  //const accessToken = ref<string | null>(null)
  const isLoading = ref(false)
  const isInitialized = ref(false)

  const isAuthenticated = computed(() => !!user.value)

   function clearAuth() {
    user.value = null
  }
/*
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
*/
  async function initAuth(force = false) {
    if (isInitialized.value && !force) {
        return;
      }
    try {
      const { data } = await authApi.refresh()

      user.value = data.user
    } catch {
      clearAuth()
    } finally {
      isInitialized.value = true
    }
  }

  async function fetchMe() {

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
    //await authApi.login(payload)
    //const { data } = await authApi.me()
    //user.value = data
    try {
        isLoading.value = true;

        const { data } =
          await authApi.login(payload);

        user.value = data.user;
        isInitialized.value = true;
      } finally {
        isLoading.value = false;
      }
  }

  function resetAuth() {
      clearAuth();

      isInitialized.value =
        false;
    }

  function setUser(newUser: User) {
    user.value = newUser
     isInitialized.value = true;
  }

  async function logout() {
    try {
      await authApi.logout()
    } finally {
      clearAuth()
      isInitialized.value = true;
    }
  }

  return {
    user,
    //accessToken,
    isLoading,
    isAuthenticated,
    isInitialized,
    fetchMe,
    initAuth,
    setUser,
    logout,
    login,
    clearAuth,
    resetAuth
  }
})