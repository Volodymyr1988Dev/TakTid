
import { ref } from 'vue'
import { defineStore } from 'pinia'
import axios from 'axios'
import {
  requestPasswordReset,
  confirmPasswordReset,
} from '../api/passwordReset.api'
import { i18n } from '../i18n'

//import type { PasswordResetLanguage} from '../api/passwordReset.api'

const { t } = i18n.global
function getErrorMessage(error: unknown): string {
  if (!axios.isAxiosError(error)) return ''

  const message = error.response?.data?.message

  if (typeof message === 'string') return message
  if (Array.isArray(message) && message.every(
    (item) => typeof item === 'string',
  )) {
    return message.join(' ')
  }

  return ''
}

export const usePasswordResetStore = defineStore(
  'passwordReset',
  () => {
    const requestLoading = ref(false)
    const resetLoading = ref(false)
    const requestSent = ref(false)
    const resetSuccess = ref(false)
    const errorKey = ref('')

    async function requestReset(
      email: string,
      //language: PasswordResetLanguage,
    ): Promise<boolean> {
      requestLoading.value = true
      requestSent.value = false
      errorKey.value = ''

      try {
        await requestPasswordReset({ email/*, language */})
        requestSent.value = true
        return true
      } catch {
        errorKey.value = 'auth.resetRequestError'
        return false
      } finally {
        requestLoading.value = false
      }
    }

    async function resetPassword(
      token: string,
      password: string,
      confirmPassword: string,
    ): Promise<boolean> {
      resetLoading.value = true
      resetSuccess.value = false
      errorKey.value = ''

      try {
        await confirmPasswordReset({
          token,
          password,
          confirmPassword,
        })

        resetSuccess.value = true
        return true
      } catch (error) {
        const message = getErrorMessage(error)

        if (
          message === 'Invalid or expired reset link'
        ) {
          errorKey.value = t('auth.resetLinkInvalid')
        } else if (
          message === 'Passwords do not match'
        ) {
          errorKey.value = t('auth.passwordsDoNotMatch')
        } else {
          errorKey.value = t('auth.resetFailed')
        }

        return false
      } finally {
        resetLoading.value = false
      }
    }

    function clearError() {
      errorKey.value = ''
    }

    function clearState() {
      requestLoading.value = false
      resetLoading.value = false
      requestSent.value = false
      resetSuccess.value = false
      errorKey.value = ''
    }

    return {
      requestLoading,
      resetLoading,
      requestSent,
      resetSuccess,
      errorKey,
      requestReset,
      resetPassword,
      clearError,
      clearState,
    }
  },
)
