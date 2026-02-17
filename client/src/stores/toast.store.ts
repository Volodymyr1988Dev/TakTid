import { defineStore } from 'pinia'
import { ref } from 'vue'

export type ToastType = 'success' | 'error'

export interface Toast {
  id: number
  message: string
  type: ToastType
}

export const useToastStore = defineStore('toast', () => {
  const toasts = ref<Toast[]>([])
  let idCounter = 0

  function show(message: string, type: ToastType = 'success') {
    const id = idCounter++

    toasts.value.push({ id, message, type })

    setTimeout(() => {
      remove(id)
    }, 3000)
  }

  function remove(id: number) {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  return {
    toasts,
    show,
    remove
  }
})