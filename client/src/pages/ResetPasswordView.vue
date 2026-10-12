
<script setup lang="ts">
import { computed, onUnmounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { usePasswordResetStore } from '../stores/passwordReset.store'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const resetStore = usePasswordResetStore()

const password = ref('')
const confirmPassword = ref('')

const token = computed(() => {
  const value = route.query.token
  return typeof value === 'string' ? value : ''
})

const passwordsMismatch = computed(
  () =>
    confirmPassword.value.length > 0 &&
    password.value !== confirmPassword.value,
)

async function submit() {
  resetStore.clearError()

  if (!token.value || token.value.length !== 64) {
    resetStore.errorKey = 'auth.resetLinkInvalid'
    return
  }

  if (password.value.length < 6) {
    resetStore.errorKey = 'auth.passwordTooShort'
    return
  }

  if (password.value !== confirmPassword.value) {
    resetStore.errorKey = 'auth.passwordsDoNotMatch'
    return
  }

  const success = await resetStore.resetPassword(
    token.value,
    password.value,
    confirmPassword.value,
  )

  if (success) {
    password.value = ''
    confirmPassword.value = ''

    await router.replace({
      path: '/login',
      query: { passwordReset: 'success' },
    })
  }
}

onUnmounted(() => {
  resetStore.clearState()
})
</script>

<template>
  <LanguageSwitcher class="auth-lang" />

  <div class="auth">
    <h1>{{ t('auth.resetPasswordTitle') }}</h1>

    <form @submit.prevent="submit">
      <input
        v-model="password"
        type="password"
        autocomplete="new-password"
        minlength="6"
        maxlength="128"
        required
        :placeholder="t('auth.newPassword')"
      >

      <input
        v-model="confirmPassword"
        type="password"
        autocomplete="new-password"
        minlength="6"
        maxlength="128"
        required
        :placeholder="t('auth.confirmNewPassword')"
      >

      <p v-if="passwordsMismatch" role="alert">
        {{ t('auth.passwordsDoNotMatch') }}
      </p>

      <p v-if="resetStore.errorKey" role="alert">
        {{ t(resetStore.errorKey) }}
      </p>

      <button
        type="submit"
        :disabled="resetStore.resetLoading"
      >
        {{
          resetStore.resetLoading
            ? t('common.loading')
            : t('auth.resetPasswordButton')
        }}
      </button>
    </form>

    <p>
      <router-link to="/login">
        {{ t('auth.backToLogin') }}
      </router-link>
    </p>
  </div>
</template>
