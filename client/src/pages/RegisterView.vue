<script setup lang="ts">
import { useForm, useField } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { useRouter } from 'vue-router'
import { registerSchema } from '../schemas/register.schema'
import api from '../api/axios'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const router = useRouter()

const { handleSubmit, isSubmitting } = useForm({
  validationSchema: toTypedSchema(registerSchema),
})

const { value: email, errorMessage: emailError } = useField<string>('email')
const { value: password, errorMessage: passwordError } = useField<string>('password')
const { value: name, errorMessage: nameError } = useField<string>('name')

const onSubmit = handleSubmit(async (values) => {
  try {
    await api.post('/auth/register', values)
    await router.push('/login')
  } catch (err) {
    console.error(t('errors.registerFailed'), err)
    alert(t('errors.registerFailed') + ': ' + (err as Error).message)
  }
})
</script>

<template>
  <div class="auth">
    <h1>{{ t('auth.register') }}</h1>

    <input
      v-model="email"
      type="email"
      placeholder="t('auth.email')"
    >
    <p 
      v-if="emailError" 
      class="error"
    >
      {{ emailError }}
    </p>
    <input
      v-model="password"
      type="password"
      placeholder="t('auth.password')"
    >
    <p 
      v-if="passwordError" 
      class="error"
    >
      {{ passwordError }}
    </p>
    <input
      v-model="name"
      type="text"
      placeholder="t('auth.name')"
    >
    <p 
      v-if="nameError" 
      class="error"
    >
      {{ nameError }}
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
</style>