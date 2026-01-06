import type { User } from './userInterface'

export interface LoginResponse {
  message: string
  expiresAt: string
  user: User
}