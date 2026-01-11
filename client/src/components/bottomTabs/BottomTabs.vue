<script setup lang="ts">
const model = defineModel<'time' | 'projects' | 'stats'>()
defineProps<{
  isAdmin: boolean
}>()
</script>

<template>
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
</template>

<style scoped>
.bottom-tabs {
  display: flex;
  border-top: 1px solid #ddd;
}
button {
  flex: 1;
  padding: 12px;
}
.active {
  font-weight: bold;
}
</style>