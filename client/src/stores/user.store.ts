import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { User } from '../types/userInterface'
import * as userApi from '../api/user.api'
import { useAuthStore } from './auth.store'

export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([])
  const isLoading = ref(false)

  async function fetchUsers() {
    try {
      isLoading.value = true
      const { data } = await userApi.getAllUsers()
      users.value = data
      return true
    } catch (error) {
      console.error('Failed to fetch users:', error)
      throw error
    }
     finally {
      isLoading.value = false
    }
  }

  async function updateUser(id: string, data: Partial<User> & { password?: string }) {
    const { data: updated } = await userApi.updateUser(id, data)

    const auth = useAuthStore()
    if (auth.user?.id === updated.id) {
      auth.setUser(updated)
    }

    return updated
  }

  async function deleteUser(id: string) {
    await userApi.deleteUser(id)
    try {
      await fetchUsers()
    } catch (error) {
      console.error(
        'User was deleted, but the users list could not be refreshed:',
        error
      )
    }
    //await fetchUsers()
  }

  async function restoreUser(id: string) {
    await userApi.restoreUser(id)
    //await fetchUsers()
     try {
      await fetchUsers()
    } catch (error) {
      console.error(
        'User was restored, but the users list could not be refreshed:',
        error
      )
    }
  }

  async function saveSalary(
    userId: string,
    salary: number
  ) {
    await userApi.saveSalary(userId, salary)
  }

  return {
    users,
    isLoading,
    fetchUsers,
    updateUser,
    deleteUser,
    restoreUser,
    saveSalary,
  }
})