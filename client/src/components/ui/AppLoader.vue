<script setup lang="ts">
defineProps<{
  text?: string
}>()
</script>

<template>
  <div class="overlay">
    <div class="loader-card">
      <div class="loader" />
      <p 
        v-if="text" 
        class="loader-text"
      >
        {{ text }}
      </p>
    </div>
  </div>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.45);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.loader-card {
  background: white;
  padding: 36px 48px;
  border-radius: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18px;
  box-shadow: 0 30px 60px rgba(0,0,0,.2);
  animation: fadeIn .25s ease;
}

.loader-text {
  font-weight: 600;
  color: #475569;
  font-size: 14px;
}

.loader {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  border: 4px solid #e2e8f0;
  border-top: 4px solid #2563eb;
  animation: spin .8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(.9); }
  to { opacity: 1; transform: scale(1); }
}
</style>