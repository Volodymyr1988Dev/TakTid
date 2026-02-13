import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '../stores/auth.store';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
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

    if (!originalRequest) {
      return Promise.reject(error)
    }

    const requestUrl = originalRequest.url ?? ''

    const isAuthRoute = requestUrl.startsWith('/auth/')

    if (isAuthRoute) {
      return Promise.reject(error)
    }

    if (!authStore.isAuthenticated) {
      return Promise.reject(error)
    }

    if (error.response?.status !== 401) {
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

        refreshPromise = api
          .post('/auth/refresh')
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

/*
api.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    const authStore = useAuthStore()

    const originalRequest = error.config as
      | (InternalAxiosRequestConfig & { _retry?: boolean })
      | undefined

    if (!originalRequest) {
      return Promise.reject(error)
    }

    const requestUrl = originalRequest.url ?? ''

    const publicRoutes = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
    ]

    const isPublicRoute = publicRoutes.some(route =>
      requestUrl.includes(route),
    )

    if (isPublicRoute) {
      return Promise.reject(error)
    }

    if (error.response?.status !== 401) {
      return Promise.reject(error)
    }

    if (originalRequest._retry) {
      authStore.clearAuth()
      window.location.href = '/login'
      return Promise.reject(error)
    }

    originalRequest._retry = true

    try {
      if (!isRefreshing) {
        isRefreshing = true
        refreshPromise = api
          .post('/auth/refresh')
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
      window.location.href = '/login'
      return Promise.reject(refreshError)
    }
  },
)*/
/*
api.interceptors.response.use(
  res => res,
  async error => {
    const authStore = useAuthStore()
    const originalRequest = error.config
    //if (!authStore.isAuthenticated) {
    //  return Promise.reject(error)
    //}

    if (
      error.response?.status === 401 &&
      authStore.isInitialized &&
      authStore.isAuthenticated &&
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
*/
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