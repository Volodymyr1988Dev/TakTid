<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const router = useRouter()
const auth = useAuthStore()

const form = reactive({
  email: '',
  password: '',
})

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
    >
    <input
      v-model="form.password"
      type="password"
      :placeholder="t('auth.password')"
    >

    <button @click="login">
      {{ t('auth.login') }}
    </button>

    <p>
      {{ t('auth.noAccount') }}
      <router-link to="/register">
        {{ t('auth.register') }}
      </router-link>
    </p>
  </div>
</template>