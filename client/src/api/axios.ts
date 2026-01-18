import axios from 'axios';
import { useAuthStore } from '../stores/auth.store';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
});

let isRefreshing = false
//let refreshPromise: Promise<void> | null = null
let refreshPromise: Promise<unknown> | null = null

api.interceptors.response.use(
  res => res,
  async error => {
    const authStore = useAuthStore()
    const originalRequest = error.config
    if (!authStore.isAuthenticated) {
      return Promise.reject(error)
    }

    if (
      error.response?.status === 401 &&
      !originalRequest._retry &&
      !originalRequest.url.includes('/auth/refresh')
    ) {
      originalRequest._retry = true

      if (!isRefreshing) {
        isRefreshing = true
        refreshPromise = api
          .post('/auth/refresh')
          .finally(() => {
            isRefreshing = false
            refreshPromise = null
          })
      }

      try {
        await refreshPromise
        return api(originalRequest)
      } catch {
        useAuthStore().clearAuth()
      }
    }
    return Promise.reject(error)
  }
)

/*
api.interceptors.request.use((config) => {
  const authStore = useAuthStore()

  let token = authStore.accessToken

  if (!token) {
    token = localStorage.getItem('access_token')
  }

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  else {
    delete config.headers.Authorization
  }

  return config
})
*/
export default api;