<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto';

const props = defineProps<{
  project: Project
  isAdmin: boolean
}>()

const openMenu = ref(false)

function toggleMenu() {
  openMenu.value = !openMenu.value
}

async function confirmDelete() {
  if (!confirm('Are you sure?')) return
  await api.delete(`/projects/${props.project.id}`)
}
</script>

<template>
  <div class="project-card">
    <span>{{ project.city }} – {{ project.address }}</span>

    <span v-if="isAdmin" class="dots" @click="toggleMenu">⋮</span>

    <ul v-if="openMenu">
      <li>Info</li>
      <li class="danger" @click="confirmDelete">Delete</li>
    </ul>
  </div>
</template>