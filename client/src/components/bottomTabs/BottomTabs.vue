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
/*
.bottom-tabs {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;

  height: 56px;
  background-color: #f9f9f9;
  z-index: 1000;

  border-top: 1px solid #ddd;
}
button {
  flex: 1;
  padding: 12px;
}
.active {
  font-weight: bold;
}
.bottom-tabs-container {
  padding-bottom: 56px;
}*/
.bottom-tabs-container {
  height: 70px;
}

/* MAIN BAR */
.bottom-tabs {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;

  display: flex;
  justify-content: space-around;
  align-items: center;

  height: 64px;
  padding: 6px 10px;

  background: #e1bee7;
  backdrop-filter: blur(10px);

  border-top: 1px solid #e2e8f0;

  box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.05);

  z-index: 500;
}

/* BUTTON */
.bottom-tabs button {
  flex: 1;
  height: 48px;
  border-radius: 12px;
  border: none;
  background: transparent;

  font-size: 14px;
  font-weight: 500;
  color: #64748b;

  transition: all 0.2s ease;
}

/* ACTIVE TAB */
.bottom-tabs button.active {
  background: #2563eb;
  color: white;
  font-weight: 600;
}

.bottom-tabs button:hover {
  background: #e2e8f0;
}

.bottom-tabs button:active {
  transform: scale(0.96);
}
</style>