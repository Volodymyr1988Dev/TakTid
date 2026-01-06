<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api/axios'

const router = useRouter()

const form = reactive({
  email: '',
  password: '',
  name: '',
})

async function register() {
  try {
    await api.post('/auth/register', form)
    await router.push('/login')
  } catch (err) {
    console.error('Register failed', err)
    alert('Помилка реєстрації')
  }
}
</script>

<template>
  <div class="auth">
    <h1>Register</h1>

    <input v-model="form.email" type="email" placeholder="Email" />
    <input v-model="form.password" type="password" placeholder="Password" />
    <input v-model="form.name" type="text" placeholder="Name" />

    <button @click="register">Register</button>

    <p>
      Вже маєш акаунт?
      <router-link to="/login">Увійти</router-link>
    </p>
  </div>
</template>