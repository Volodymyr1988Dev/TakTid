<script setup lang="ts">
import { ref } from 'vue'
import axios from 'axios'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import api from '../api/axios.ts'

const { t, locale } = useI18n()
const router = useRouter()

const email = ref('')
const loading = ref(false)
const sent = ref(false)
const error = ref('')

async function submit() {
  error.value = ''
  loading.value = true

  try {
    await api.post('/auth/password-reset/request', {
      email: email.value,
      language: locale.value,
    })

    sent.value = true
  } catch (e) {
    if (axios.isAxiosError(e)) {
      error.value = t('auth.resetRequestError')
    } else {
      error.value = t('auth.resetRequestError')
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <LanguageSwitcher class="auth-lang" />

  <div class="auth">
    <h1>{{ t('auth.forgotPassword') }}</h1>

    <template v-if="!sent">
      <p>{{ t('auth.resetInstructions') }}</p>

      <form @submit.prevent="submit">
        <input
          v-model.trim="email"
          type="email"
          autocomplete="email"
          required
          :placeholder="t('auth.email')"
        >

        <button type="submit" :disabled="loading">
          {{ loading ? t('common.loading') : t('auth.sendResetLink') }}
        </button>
      </form>

      <p v-if="error" role="alert">{{ error }}</p>
    </template>

    <p v-else role="status">
      {{ t('auth.resetEmailSent') }}
    </p>

    <button type="button" @click="router.push('/login')">
      {{ t('auth.backToLogin') }}
    </button>
  </div>
</template>