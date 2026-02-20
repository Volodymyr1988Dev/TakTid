import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '../stores/auth.store';
import { refresh } from './auth.api';

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

    if (!originalRequest) {return Promise.reject(error)}
    //let isRefreshing = false
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
        //refreshPromise = api
        //  .post('/auth/refresh')
        //  .then(() => {})
        //  .finally(() => {
        //    isRefreshing = false
        //    refreshPromise = null
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
export default api;