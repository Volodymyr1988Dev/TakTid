<script setup lang="ts">
import { useToast } from '../composables/useToast';

const {toasts} = useToast()
</script>

<template>
  <div class="toast-wrapper">
    <div
      v-for="toast in toasts"
      :key="toast.id"
      :class="['toast', toast.type]"
    >
      {{ toast.message }}
    </div>
  </div>
</template>

<style scoped>
.toast-wrapper {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
}

.toast {
  margin-bottom: 10px;
  padding: 12px 18px;
  border-radius: 6px;
  color: white;
  min-width: 250px;
  font-weight: 500;
  animation: fadeIn 0.3s ease;
}

.success {
  background: #52c41a;
}

.error {
  background: #ff4d4f;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>