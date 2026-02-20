import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '../stores/auth.store';
import { refresh } from './auth.api';

const api = axios.create({
  //baseURL: import.meta.env.VITE_API_URL,
  baseURL: '/api',
  withCredentials: true,
});

let isRefreshing = false
let refreshPromise: Promise<void> | null = null

api.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    const authStore = useAuthStore()

    const originalRequest = error.config as
      | (InternalAxiosRequestConfig & { _retry?: boolean })
      | undefined

    if (!originalRequest) {return Promise.reject(error)}
    const requestUrl = originalRequest.url ?? ''

    if (requestUrl.startsWith('/auth/')) {
      return Promise.reject(error)
    }
    if (error.response?.status !== 401) {
      return Promise.reject(error)
    }
    if (!authStore.isInitialized || !authStore.isAuthenticated) {
      return Promise.reject(error)
    }

    if (originalRequest._retry) {
      authStore.clearAuth()
      return Promise.reject(error)
    }

    originalRequest._retry = true

    try {
      if (!isRefreshing) {
        isRefreshing = true
         refreshPromise = refresh()
         .then(() => {})  
         .finally(() => {
          isRefreshing = false
          refreshPromise = null
          })
      }

      await refreshPromise

      return api(originalRequest)
    } catch (refreshError) {
      authStore.clearAuth()
      return Promise.reject(refreshError)
    }
  },
)
export default api;