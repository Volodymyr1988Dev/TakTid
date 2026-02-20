<script setup lang="ts">
const model = defineModel<'time' | 'projects' | 'stats'>()
defineProps<{
  isAdmin: boolean
}>()
</script>

<template>
  <footer class="bottom-tabs-container">
    <nav class="bottom-tabs">
      <button
        :class="{ active: model === 'time' }"
        @click="model = 'time'"
      >
        Time
      </button>

      <button
        :class="{ active: model === 'projects' }"
        @click="model = 'projects'"
      >
        Projects
      </button>
      <button
        v-if="isAdmin"
        :class="{ active: model === 'stats' }"
        @click="model = 'stats'"
      >
        Stats
      </button>
    </nav>
  </footer>
</template>

<style scoped>
.bottom-tabs-container {
  height: 60px;
}

.bottom-tabs {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;

  display: flex;
  justify-content: space-around;
  align-items: center;

  height: 56px;
  padding: 4px 8px;

  background: transparent;
  border-top: 1px solid #e2e8f0;

  z-index: 500;
}

.bottom-tabs button {
  flex: 1;
  height: 40px;
  border-radius: 10px;
  border: none;
  background: transparent;

  font-size: 13px;
  font-weight: 500;
  color: #64748b;

  transition: all 0.15s ease;
}

.bottom-tabs button.active {
  background: #2563eb;
  color: white;
  font-weight: 600;
}

.bottom-tabs button:hover {
  background: #e2e8f0;
}

.bottom-tabs button:active {
  transform: scale(0.97);
}
</style>