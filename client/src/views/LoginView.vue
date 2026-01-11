<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import api from '../api/axios'
//import type { LoginResponse } from '../types/LoginResponse'

const router = useRouter()
const auth = useAuthStore()

const form = reactive({
  email: '',
  password: '',
})

async function login() {
  try {
    const { data } = await api.post('/auth/login', form)
    auth.setUser(data.user)
    //router.push('/dashboard')
    router.replace('/dashboard')
  } catch (err) {
    alert('Невірний email або пароль')
  }
}
</script>

<template>
  <div class="auth">
    <h1>Login</h1>

    <input
      v-model="form.email"
      type="email"
      placeholder="Email"
    >
    <input
      v-model="form.password"
      type="password"
      placeholder="Password"
    >

    <button @click="login">
      Login
    </button>

    <p>
      Немає акаунту?
      <router-link to="/register">
        Зареєструватися
      </router-link>
    </p>
  </div>
</template>