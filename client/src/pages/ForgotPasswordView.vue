
<script setup lang="ts">
import { /*computed,*/ onUnmounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { usePasswordResetStore } from '../stores/passwordReset.store'
//import type { PasswordResetLanguage } from '../api/passwordReset.api'

const { t } = useI18n()
const resetStore = usePasswordResetStore()
const email = ref('')

async function submit() {
  const normalizedEmail = email.value.trim().toLowerCase()
  if (!normalizedEmail) return

  await resetStore.requestReset(
    normalizedEmail,
   // language.value,
  )
}

onUnmounted(() => {
  resetStore.clearState()
})
</script>

<template>
  <LanguageSwitcher class="auth-lang" />

  <div class="auth">
    <h1>{{ t('auth.forgotPassword') }}</h1>

    <template v-if="!resetStore.requestSent">
      <p>{{ t('auth.resetInstructions') }}</p>

      <form @submit.prevent="submit">
        <input
          v-model.trim="email"
          type="email"
          autocomplete="email"
          maxlength="254"
          required
          :placeholder="t('auth.email')"
        >

        <button
          type="submit"
          :disabled="resetStore.requestLoading"
        >
          {{
            resetStore.requestLoading
              ? t('common.loading')
              : t('auth.sendResetLink')
          }}
        </button>
      </form>

      <p v-if="resetStore.errorKey" role="alert">
        {{ t(resetStore.errorKey) }}
      </p>
    </template>

    <p v-else role="status">
      {{ t('auth.resetEmailSent') }}
    </p>

    <p>
      <router-link to="/login">
        {{ t('auth.backToLogin') }}
      </router-link>
    </p>
  </div>
</template>
