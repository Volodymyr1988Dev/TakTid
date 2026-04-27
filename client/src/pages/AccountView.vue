<script setup lang="ts">
import { ref, computed } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.store'
import { useUserStore } from '../stores/user.store'
import type { User } from '../types/userInterface'
//import { useToastStore } from '../stores/toast.store'
import { useToast } from '../components/composables/useToast'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const auth = useAuthStore()
const userStore = useUserStore()
const router = useRouter()
const toast = useToast()

const name = ref(auth.user?.name ?? '')
const email = ref(auth.user?.email ?? '')
const password = ref('')
const confirmPassword = ref('')

const showUsers = ref(false)
const selectedUser = ref<User | null>(null)
const isAdmin = computed(() => auth.user?.isAdmin === true)

function goToDashboard() {
  router.push('/dashboard')
}

async function updateProfile(data: Partial<User> & { password?: string }) {
  if (!auth.user) return

  try {
    await userStore.updateUser(auth.user.id, data)

    toast.show(t('toast.profileUpdated'))

    setTimeout(() => router.push('/dashboard'), 700)
  } catch (e: unknown) {
    if (axios.isAxiosError(e)) {
      toast.error(e.response?.data?.message ?? t('errors.updateFailed'))
    } else {
      toast.error(t('errors.updateFailed'))
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
    toast.error(t('toast.passwordShort'))
    return
  }

  if (password.value !== confirmPassword.value) {
    toast.error(t('toast.passwordMatch'))
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

   try {
    const user = selectedUser.value

    await userStore.deleteUser(user.id)

    toast.show(
      `User ${user.name ?? 'No name'} (${user.email}) deleted successfully`
    )

    selectedUser.value = null
  } catch (e: unknown) {
    if (axios.isAxiosError(e)) {
      toast.error(e.response?.data?.message ?? t('errors.deleteFailed'))
    } else {
      toast.error(t('errors.deleteFailed'))
    }
  }
}

async function restoreUser(user: User) {
  try {
    await userStore.restoreUser(user.id)

    toast.show(
      `User ${user.name ?? 'No name'} (${user.email}) ${t('toast.restoreSuccess')}`
    )
  } catch (e: unknown) {
    if (axios.isAxiosError(e)) {
      toast.error(e.response?.data?.message ?? t('errors.restoreFailed'))
    } else {
      toast.error(t('errors.restoreFailed'))
    }
  }
}

</script>

<template>
  <div class="account">
    <h1>{{ t('account.title') }}</h1>
    <div class="block">
      <input 
        v-model="name" 
        :placeholder="t('auth.name')"
      >
      <button @click="saveName">
        {{ t('account.saveName') }}
      </button>
    </div>

    <div class="block">
      <input 
        v-model="email" 
        :placeholder="t('auth.email')" 
      >
      <button @click="saveEmail">
        {{ t('account.saveEmail') }}
      </button>
    </div>

    <div class="block">
      <input
        v-model="password"
        type="password"
        :placeholder="t('auth.password')"
      >
      <input
        v-model="confirmPassword"
        type="password"
        :placeholder="t('account.confirmPassword')"
      >
      <button @click="savePassword">
        {{ t('account.savePassword') }}
      </button>
    </div>
    
    <button 
      class="cancel" 
      @click="goToDashboard"
    >
      {{ t('account.cancel') }}
    </button>

    <div 
      v-if="isAdmin" 
      class="admin-panel"
    >
      <button 
        class="manage" 
        @click="toggleUsers"
      >
        {{ t('account.manageUsers') }}
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
              {{ t('common.delete') }}
            </button>

            <button
              class="restore"
              @click="restoreUser(user)"
            >
              {{ t('account.restore') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div 
      v-if="selectedUser" 
      class="modal"
    >
      <div class="modal-content">
        <p>
          {{ t('account.confirmDelete', { name: selectedUser.name ?? 'User', email: selectedUser.email }) }}
        </p>

        <button 
          class="delete" 
          @click="deleteUser"
        >
          {{ t('common.yes') }}
        </button>
        <button @click="selectedUser = null">
          {{ t('common.no') }}
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