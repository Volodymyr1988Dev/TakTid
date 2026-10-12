
import api from './axios'

//export type PasswordResetLanguage = 'en' | 'uk' | 'pl' | 'ro' | 'sv'

export interface RequestPasswordResetPayload {
  email: string
  //language: PasswordResetLanguage
}

export interface ConfirmPasswordResetPayload {
  token: string
  password: string
  confirmPassword: string
}

export function requestPasswordReset(
  payload: RequestPasswordResetPayload,
) {
  return api.post('/auth/password-reset/request', payload)
}

export function confirmPasswordReset(
  payload: ConfirmPasswordResetPayload,
) {
  return api.post('/auth/password-reset/confirm', payload)
}
