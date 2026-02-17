<script setup lang="ts">
import { ref, computed } from 'vue'
import axios from 'axios'
//import api from '../api/axios'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import { useUserStore } from '../stores/user.store'
import type { User } from '../types/userInterface'

const auth = useAuthStore()
const userStore = useUserStore()
const router = useRouter()

const name = ref(auth.user?.name ?? '')
const email = ref(auth.user?.email ?? '')
const password = ref('')
const confirmPassword = ref('')

const error = ref('')
const success = ref('')

const showUsers = ref(false)
//const showConfirm = ref(false)
const selectedUser = ref<User | null>(null)
const isAdmin = computed(() => auth.user?.isAdmin === true)

function clearMessages() {
  error.value = ''
  success.value = ''
}
/*
async function saveName() {
  clearMessages()

  try {
    //await api.put(`/users/${auth.user!.id}`, { name: name.value })
    await userStore.$patch(() => {})
    await auth.updateUser(data)
    success.value = 'Updated successfully'
    setTimeout(() => router.push('/dashboard'), 700)

    await auth.fetchMe()
    success.value = 'Name updated'
    redirectAfterSuccess()
  } catch (e: unknown) {
    handleError(e)
  }
}
function redirectAfterSuccess() {
  setTimeout(() => {
    router.push('/dashboard')
  }, 700)
}
function goToDashboard() {
  router.push('/dashboard')
}*/
/* ---------- EMAIL ---------- 
async function saveEmail() {
  clearMessages()

  try {
    await saveProfile({ password: password.value })
    password.value = ''
    confirmPassword.value = ''

    await api.put(`/users/${auth.user!.id}`, { email: email.value })
    await auth.fetchMe()
    success.value = 'Email updated'
    redirectAfterSuccess()
  } catch (e: unknown) {
    handleError(e)
  }
}

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
    //await api.put(`/users/${auth.user!.id}`, { password: password.value})
    await saveProfile({ password: password.value })
    password.value = ''
    confirmPassword.value = ''
    success.value = 'Password updated'
    redirectAfterSuccess()
  } catch (e: unknown) {
    handleError(e)
  }
}

function handleError(e: unknown) {
  if (axios.isAxiosError(e)) {
    error.value = e.response?.data?.message ?? 'Update failed'
  } else {
    error.value = 'Update failed'
  }
}

async function toggleUsers() {
  showUsers.value = !showUsers.value
  if (showUsers.value) {
    await userStore.fetchUsers()
  }
}

function confirmDelete(user: User) {
  selectedUser.value = user
}


async function deleteUser() {
  if (!selectedUser.value) return
  await userStore.deleteUser(selectedUser.value.id)
  selectedUser.value = null
}

async function restoreUser(user: User) {
  await userStore.restoreUser(user.id)
}*/

function goToDashboard() {
  router.push('/dashboard')
}

async function updateProfile(data: Partial<User> & { password?: string }) {
  if (!auth.user) return

  clearMessages()

  try {
    await userStore.updateUser(auth.user.id, data)
    success.value = 'Updated successfully'
    setTimeout(() => router.push('/dashboard'), 700)
  } catch (e: unknown) {
    if (axios.isAxiosError(e)) {
      error.value = e.response?.data?.message ?? 'Update failed'
    } else {
      error.value = 'Update failed'
    }
  }
}

async function saveName() {
  await updateProfile({ name: name.value })
}

async function saveEmail() {
  await updateProfile({ email: email.value })
}

async function savePassword() {
  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters'
    return
  }

  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    return
  }

  await updateProfile({ password: password.value })

  password.value = ''
  confirmPassword.value = ''
}

async function toggleUsers() {
  showUsers.value = !showUsers.value
  if (showUsers.value) {
    await userStore.fetchUsers()
  }
}

function confirmDelete(user: User) {
  selectedUser.value = user
}

async function deleteUser() {
  if (!selectedUser.value) return
  await userStore.deleteUser(selectedUser.value.id)
  selectedUser.value = null
}

async function restoreUser(user: User) {
  await userStore.restoreUser(user.id)
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
    <button 
      class="cancel" 
      @click="goToDashboard"
    >
      Cancel
    </button>
    <!-- ADMIN PANEL -->
    <div 
      v-if="isAdmin" 
      class="admin-panel"
    >
      <button 
        class="manage" 
        @click="toggleUsers"
      >
        Manage users
      </button>

      <div 
        v-if="showUsers" 
        class="users"
      >
        <div
          v-for="user in userStore.users"
          :key="user.id"
          class="user-row"
        >
          <div>
            {{ user.name ?? 'No name' }} ({{ user.email }})
          </div>

          <div>
            <button
              class="delete"
              @click="confirmDelete(user)"
            >
              Delete
            </button>

            <button
              class="restore"
              @click="restoreUser(user)"
            >
              Restore
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Confirm Modal -->
    <div 
      v-if="selectedUser" 
      class="modal"
    >
      <div class="modal-content">
        <p>
          Are you sure you want to delete
          {{ selectedUser.name ?? 'User' }}
          ({{ selectedUser.email }})?
        </p>

        <button 
          class="delete" 
          @click="deleteUser"
        >
          Yes
        </button>
        <button @click="selectedUser = null">
          No
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.account {
  max-width: 500px;
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
.cancel {
  margin-top: 16px;
  background: transparent;
  border: 1px solid #ccc;
  padding: 6px 12px;
  cursor: pointer;
}
.admin-panel {
  margin-top: 40px;
  border-top: 1px solid #ddd;
  padding-top: 20px;
}

.users {
  margin-top: 20px;
}

.user-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.deleted {
  color: red;
  font-weight: bold;
}

.delete {
  background: #ff4d4f;
  color: white;
}

.restore {
  background: #52c41a;
  color: white;
}

.modal {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
}
</style>