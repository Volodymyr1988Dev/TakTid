<script setup lang="ts">
import { computed, ref } from 'vue'
import axios from 'axios'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import api from '../api/axios.ts'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const success = ref(false)
const error = ref('')

const token = computed(() => {
  const value = route.query.token
  return typeof value === 'string' ? value : ''
})

async function submit() {
  error.value = ''

  if (!token.value || token.value.length !== 64) {
    error.value = t('auth.resetLinkInvalid')
    return
  }

  if (password.value.length < 6) {
    error.value = t('auth.passwordTooShort')
    return
  }

  if (password.value !== confirmPassword.value) {
    error.value = t('auth.passwordsDoNotMatch')
    return
  }

  loading.value = true

  try {
    await api.post('/auth/password-reset/confirm', {
      token: token.value,
      password: password.value,
      confirmPassword: confirmPassword.value,
    })

    success.value = true
    password.value = ''
    confirmPassword.value = ''
    await router.replace('/login');
  } catch (e) {
    if (axios.isAxiosError(e)) {
      const message = e.response?.data?.message

      if (Array.isArray(message) && message.length) {
        error.value = message[0]
      } else if (
        message === 'Invalid or expired reset link'
      ) {
        error.value = t('auth.resetLinkInvalid')
      } else if (message === 'Passwords do not match') {
        error.value = t('auth.passwordsDoNotMatch')
      } else {
        error.value = t('auth.resetFailed')
      }
    } else {
      error.value = t('auth.resetFailed')
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <LanguageSwitcher class="auth-lang" />

  <div class="auth">
    <h1>{{ t('auth.resetPasswordTitle') }}</h1>

    <template v-if="!success">
      <form @submit.prevent="submit">
        <input
          v-model="password"
          type="password"
          autocomplete="new-password"
          required
          minlength="6"
          maxlength="128"
          :placeholder="t('auth.newPassword')"
        >

        <input
          v-model="confirmPassword"
          type="password"
          autocomplete="new-password"
          required
          minlength="6"
          maxlength="128"
          :placeholder="t('auth.confirmNewPassword')"
        >

        <p
          v-if="confirmPassword && password !== confirmPassword"
          role="alert"
        >
          {{ t('auth.passwordsDoNotMatch') }}
        </p>

        <p v-if="error" role="alert">
          {{ error }}
        </p>

        <button type="submit" :disabled="loading">
          {{ loading ? t('common.loading') : t('auth.resetPasswordButton') }}
        </button>
      </form>
    </template>

    <template v-else>
      <p role="status">{{ t('auth.passwordResetSuccess') }}</p>

      <button type="button" @click="router.replace('/login')">
        {{ t('auth.backToLogin') }}
      </button>
    </template>
  </div>
</template>