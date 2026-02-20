<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
//import api from '../api/axios'
//import type { LoginResponse } from '../types/LoginResponse'

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
    alert('Invalid password or email')
    console.log(e)
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
      Don't have account?
      <router-link to="/register">
        Register
      </router-link>
    </p>
  </div>
</template>