import api from './axios';

export const register = (data: {
  email: string;
  password: string;
  name: string;
}) => api.post('/auth/register', data);

export const login = (data: { email: string; password: string }) =>
  api.post('/auth/login', data);
export const me = () => api.get('/auth/me');
console.log (me,'me api');
export const logout = () => api.post('/auth/logout');
export const refresh = () => api.post('/auth/refresh');