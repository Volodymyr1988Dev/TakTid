<script setup lang="ts">

//import { ref } from 'vue'

const model = defineModel<'time' | 'projects' | 'stats'>()
//const selectedProjectId = ref<string | null>(null)
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
}
</style>