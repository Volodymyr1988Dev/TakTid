<script setup lang="ts">
import type { Project } from '../../../types/Project.dto'

defineProps<{
  project: Project
}>()
</script>

<template>
  <div class="card">
    <div class="title">
      {{ project.city }} – {{ project.address }}
    </div>
    <span class="star">☆</span>
  </div>
</template>

<style lang="css">
    .card {
  background: #fff;
  border-radius: 14px;
  padding: 16px;
  margin-bottom: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;

  box-shadow: 0 4px 10px rgba(0,0,0,.05);
}

.card-title {
  font-size: 16px;
  font-weight: 500;
}

.star {
  font-size: 20px;
  opacity: 0.4;
}
</style>