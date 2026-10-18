<script setup lang="ts">
import { ref } from 'vue'
import { useForm, useField } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { useRouter } from 'vue-router'
import { registerSchema } from '../schemas/register.schema'
import api from '../api/axios'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const router = useRouter()
const showPassword = ref(false)
const { handleSubmit, isSubmitting } = useForm({
  validationSchema: toTypedSchema(registerSchema),
})

const { value: email, errorMessage: emailError } = useField<string>('email')
const { value: password, errorMessage: passwordError } = useField<string>('password')
const { value: name, errorMessage: nameError } = useField<string>('name')

const onSubmit = handleSubmit(async (values) => {
  try {
    //await api.post('/auth/register', values)
     const { data } = await api.post(
      '/auth/register',
      values,
    )
     alert(
      data.message ??
        t('auth.registrationPending'),
    )
    await router.push('/login')
  } catch (err) {
    console.error(t('errors.registerFailed'), err)
    alert(t('errors.registerFailed') + ': ' + (err as Error).message)
  }
})
</script>

<template>
  <LanguageSwitcher class="auth-lang"/>
  <div class="auth">
    <h1>{{ t('auth.register') }}</h1>

    <input
      v-model="email"
      type="email"
      :placeholder="t('auth.email')"
    >
    <p 
      v-if="emailError" 
      class="error"
    >
      {{ emailError && t(`errors.${emailError}`) }}
    </p>
    <div class="password-field">
      <!--type="password"-->
      <input
        v-model="password"
        :type="showPassword ? 'text' : 'password'"
        :placeholder="t('auth.password')"
        autocomplete="new-password"
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
    <p 
      v-if="passwordError" 
      class="error"
    >
    {{ passwordError && t(`errors.${passwordError}`) }}
    </p>
    <input
      v-model="name"
      type="text"
      :placeholder="t('auth.name')"
      autocomplete="name"
    >
    <p 
      v-if="nameError" 
      class="error"
    >
      {{ nameError && t(`errors.${nameError}`) }}
    </p>

    <button 
      :disabled="isSubmitting" 
      @click="onSubmit"
    >
      {{ t('auth.register') }}
    </button>

    <p>
      {{ t('auth.haveAccount') }}
      <router-link to="/login">
        {{ t('auth.login') }}
      </router-link>
    </p>
  </div>
</template>
<style scoped>
.error {
  color: red;
  font-size: 12px;
}
button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

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