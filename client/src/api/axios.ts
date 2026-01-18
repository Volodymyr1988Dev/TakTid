import axios from 'axios';
import { useAuthStore } from '../stores/auth.store';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
});

api.interceptors.response.use(
  res => res,
  async error => {
    const originalRequest = error.config;

    if (
      error.response?.status === 401 &&
      !originalRequest._retry &&
      !originalRequest.url.includes('/auth/refresh')
    ) {
      originalRequest._retry = true;

      try {
        await api.post('/auth/refresh', {}, { withCredentials: true });

        await new Promise(r => setTimeout(r, 50));

        return api(originalRequest);
      } catch {
        useAuthStore().clearAuth();
      }
    }

    return Promise.reject(error);
  }
);

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