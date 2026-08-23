import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '../stores/auth.store';
import { refresh } from './auth.api';
/*
type RetryConfig = InternalAxiosRequestConfig & {
  _retry?: boolean
}*/

type RetryableRequestConfig =
  InternalAxiosRequestConfig & {
    _retry?: boolean;
  };

const api = axios.create({
  //baseURL: import.meta.env.VITE_API_URL,
  baseURL: '/api',
  withCredentials: true,
});



//let isRefreshing = false
let refreshPromise: Promise<void> | null = null
let refreshFailed = false;

async function refreshAccessToken() {
  if (refreshFailed) {
    throw new Error('Refresh session is invalid');
  }
  if (!refreshPromise) {
    refreshPromise = refresh()
      //.then(() => undefined)
      .then(({ data }) => {
        const authStore = useAuthStore();

        if (data?.user) {
          authStore.setUser(data.user);
        }
        refreshFailed = false;
      })
      .catch(error => {
        refreshFailed = true;

        const authStore = useAuthStore();

        authStore.clearAuth();

        throw error;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }

  return refreshPromise;
}
/*
async function refreshOnce(): Promise<void> {
  if (!refreshPromise) {
    refreshPromise = refresh()
      .then(() => undefined)
      .finally(() => {
        refreshPromise = null
      })
  }

  return refreshPromise
}
*/
api.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    //const authStore = useAuthStore()

    const originalRequest = error.config as
      RetryableRequestConfig
      //RetryConfig
      //| (InternalAxiosRequestConfig & { _retry?: boolean })
      | undefined

    if (!originalRequest) {return Promise.reject(error)}
    const requestUrl = originalRequest.url ?? ''

    if (requestUrl.includes('/auth/')) {
      return Promise.reject(error)
    }

    const status = error.response?.status

    if (status !== 401) {
      return Promise.reject(error)
    }


    //if (requestUrl.startsWith('/auth/')) {
  /*
    if (error.response?.status !== 401) {
      return Promise.reject(error)
    }*/

    if (originalRequest._retry) {
      useAuthStore().clearAuth()
      return Promise.reject(error)
    }
    if (refreshFailed) {
      useAuthStore().clearAuth();

      return Promise.reject(error);
    }
    originalRequest._retry = true

    try {
      //await refreshOnce()
      await refreshAccessToken()

      return api(originalRequest)
    } catch (refreshError) {
      useAuthStore().clearAuth()

      return Promise.reject(refreshError)
    }
    /*
    if (!authStore.isInitialized) {
      try {
        await authStore.initAuth()
      } catch {
        return Promise.reject(error)
      }
    }

    if (!authStore.isAuthenticated) {
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
    }*/
  },
)
export default api;