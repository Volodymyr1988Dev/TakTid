<script setup lang="ts">
const model = defineModel<'time' | 'projects'>()
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