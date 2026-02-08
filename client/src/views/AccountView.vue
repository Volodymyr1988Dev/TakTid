<script setup lang="ts">
import { ref } from 'vue'
import api from '../api/axios'
import { useAuthStore } from '../stores/auth.store'
import axios from 'axios'

const auth = useAuthStore()

const name = ref(auth.user?.name ?? '')
const email = ref(auth.user?.email ?? '')
const password = ref('')
const confirmPassword = ref('')

const error = ref('')
const success = ref('')

function clearMessages() {
  error.value = ''
  success.value = ''
}

/* ---------- NAME ---------- */
async function saveName() {
  clearMessages()

  try {
    await api.put(`/users/${auth.user!.id}`, { name: name.value })
    await auth.fetchMe()
    success.value = 'Name updated'
  } catch (e: unknown) {
    handleError(e)
  }
}

/* ---------- EMAIL ---------- */
async function saveEmail() {
  clearMessages()

  try {
    await api.put(`/users/${auth.user!.id}`, { email: email.value })
    await auth.fetchMe()
    success.value = 'Email updated'
  } catch (e: unknown) {
    handleError(e)
  }
}

/* ---------- PASSWORD ---------- */
async function savePassword() {
  clearMessages()

  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters'
    return
  }

  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    return
  }

  try {
    await api.put(`/users/${auth.user!.id}`, {
      password: password.value,
    })

    password.value = ''
    confirmPassword.value = ''
    success.value = 'Password updated'
  } catch (e: unknown) {
    handleError(e)
  }
}

/* ---------- ERROR HANDLER ---------- */
function handleError(e: unknown) {
  if (axios.isAxiosError(e)) {
    error.value = e.response?.data?.message ?? 'Update failed'
  } else {
    error.value = 'Update failed'
  }
}
</script>

<template>
  <div class="account">
    <h1>Account settings</h1>

    <!-- NAME -->
    <div class="block">
      <input 
        v-model="name" 
        placeholder="Name" 
      >
      <button @click="saveName">
        Save name
      </button>
    </div>

    <!-- EMAIL -->
    <div class="block">
      <input 
        v-model="email" 
        placeholder="Email" 
      >
      <button @click="saveEmail">
        Save email
      </button>
    </div>

    <!-- PASSWORD -->
    <div class="block">
      <input
        v-model="password"
        type="password"
        placeholder="New password"
      >
      <input
        v-model="confirmPassword"
        type="password"
        placeholder="Confirm password"
      >
      <button @click="savePassword">
        Save password
      </button>
    </div>

    <p 
      v-if="error" 
      class="error"
    >
      {{ error }}
    </p>
    <p 
      v-if="success" 
      class="success"
    >
      {{ success }}
    </p>
  </div>
</template>

<style scoped>
.account {
  max-width: 400px;
}

.block {
  margin-bottom: 16px;
}

.error {
  color: red;
}

.success {
  color: green;
}
</style>