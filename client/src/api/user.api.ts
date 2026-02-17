import api from './axios'
import type { User } from '../types/userInterface'

export const getAllUsers = () =>
  api.get<User[]>('/users')

export const updateUser = (
  id: string,
  data: Partial<User> & { password?: string }
) =>
  api.put<User>(`/users/${id}`, data)

export const deleteUser = (id: string) =>
  api.delete(`/users/${id}`)

export const restoreUser = (id: string) =>
  api.put(`/users/${id}/restore`)