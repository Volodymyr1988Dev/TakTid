import axios from 'axios';
import { useAuthStore } from '../stores/auth.store';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
});

api.interceptors.request.use((config) => {
  const authStore = useAuthStore()

  if (authStore.accessToken && !config.headers.Authorization) {
    config.headers.Authorization = `Bearer ${authStore.accessToken}`
  }

  return config
})

export default api;