3️⃣ Tabs: Suggestions / Projects / Internal / Absence
📄 EntryTypeTabs.vue
<script setup lang="ts">
const model = defineModel<
  'suggestions' | 'projects' | 'internal' | 'absence'
>()
</script>

<template>
  <div class="tabs">
    <button @click="model = 'suggestions'">Suggestions</button>
    <button @click="model = 'projects'">Projects</button>
    <button @click="model = 'internal'">Internal</button>
    <button @click="model = 'absence'">Absence</button>
  </div>
</template>