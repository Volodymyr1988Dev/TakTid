<script setup lang="ts">
import { ref } from 'vue'
const tab = ref<'suggestions' | 'projects' | 'internal' | 'absence'>('suggestions')
</script>

<template>
  <div class="tabs">
    <button @click="tab='suggestions'">Suggestions</button>
    <button @click="tab='projects'">Project</button>
    <button @click="tab='internal'">Internal</button>
    <button @click="tab='absence'">Absence</button>
  </div>

  <SuggestionsTab v-if="tab==='suggestions'" />
  <ProjectsTab v-if="tab==='projects'" />
  <InternalTab v-if="tab==='internal'" />
  <AbsenceTab v-if="tab==='absence'" />
</template>