import api from './axios';
import axios from 'axios';

export const register = (data: {
  email: string;
  password: string;
  name: string;
}) => api.post('/auth/register', data);

const authApiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
});

export const login = (data: { email: string; password: string }) =>
  api.post('/auth/login', data);
export const me = () => api.get('/auth/me');
export const logout = () => api.post('/auth/logout');
//export const refresh = () => api.post('/auth/refresh');
export const refresh = () => authApiClient.post('/auth/refresh');
