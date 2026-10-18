<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const router = useRouter()
const auth = useAuthStore()

const showPassword = ref(false)

const form = reactive({
  email: '',
  password: '',
})
/*
function forgotPassword() {
  router.push('/forgot-password')
}*/

async function login() {
  try {
    await auth.login(form)
    router.replace('/dashboard')
  } catch (e) {
    alert(t('auth.invalid'))
    console.log(e)
  }
}
</script>

<template>
  <LanguageSwitcher class="auth-lang"/>
  <div class="auth">
    <h1>{{ t('auth.login') }}</h1>

    <input
      v-model="form.email"
      type="email"
      :placeholder="t('auth.email')"
      autocomplete="email"
    >
    <!--type="password"-->
    <div class="password-field">
      <input
        v-model="form.password"
        :type="showPassword ? 'text' : 'password'"
        :placeholder="t('auth.password')"
        autocomplete="current-password"
      >
      <button
        type="button"
        class="password-toggle"
        :aria-label="showPassword ? 'Hide password' : 'Show password'"
        :aria-pressed="showPassword"
        @click="showPassword = !showPassword"
      >
        <svg
          v-if="!showPassword"
          xmlns="http://www.w3.org/2000/svg"
          width="22"
          height="22"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.8"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z" />
          <circle cx="12" cy="12" r="3" />
        </svg>

        <svg
          v-else
          xmlns="http://www.w3.org/2000/svg"
          width="22"
          height="22"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.8"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="m3 3 18 18" />
          <path d="M10.6 10.6a2 2 0 0 0 2.8 2.8" />
          <path d="M9.9 5.2A11 11 0 0 1 12 5c6.4 0 10 7 10 7a15 15 0 0 1-4 4.7" />
          <path d="M6.6 6.6C3.6 8.4 2 12 2 12s3.6 7 10 7c.9 0 1.8-.1 2.6-.4" />
        </svg>
      </button>
    </div>
    <button @click="login">
      {{ t('auth.login') }}
    </button>

    <p>
      <router-link to="/forgot-password">
        {{ t('auth.forgotPassword') }}
      </router-link>
    </p>
    <p>
      {{ t('auth.noAccount') }}
      <router-link to="/register">
        {{ t('auth.register') }}
      </router-link>
    </p>
  </div>
</template>
<style scoped>

.password-field {
  position: relative;
  display: inline-block;
  vertical-align: middle;
  width: 224px;
  max-width: 100%;
}

.password-field input {
  display: block;
  width: 100%;
  box-sizing: border-box;
  padding-right: 38px;
}

.password-toggle {
  position: absolute;
  top: 50%;
  right: 3px;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  padding: 0;
  border: 0;
  border-radius: 4px;
  background: transparent;
  color: #666;
  cursor: pointer;
}

.password-toggle:hover {
  color: #222;
  background: #f0f0f0;
}

.password-toggle:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 1px;
}

.password-toggle svg {
  display: block;
  flex-shrink: 0;
}

</style>