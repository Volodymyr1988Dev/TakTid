<script setup lang="ts">
import type { Project } from '../../types/Project.dto'

defineProps<{
  project: Project
}>()
</script>

<template>
  <div class="project-header">
    <h2>
      {{ project.city }}
      –
      {{ project.address }}
    </h2>
  </div>
</template>

<style scoped>
.project-header {
  margin-bottom: 20px;
}

.project-header h2 {
  margin: 0;
  color: #111827;
  font-size: 22px;
  line-height: 1.3;
}
</style>