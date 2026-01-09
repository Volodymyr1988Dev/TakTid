<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto'

const props = defineProps<{
  project: Project
  isAdmin: boolean
}>()

const emit = defineEmits<{
  (e: 'select', project: Project): void
  (e: 'deleted', id: string): void
}>()

const openMenu = ref(false)

function toggleMenu(e: MouseEvent) {
  e.stopPropagation()
  openMenu.value = !openMenu.value
}

async function confirmDelete(e: MouseEvent) {
  e.stopPropagation()
  if (!confirm('Are you sure?')) return
  await api.delete(`/projects/${props.project.id}`)
  emit('deleted', props.project.id)
}
</script>

<template>
  <div class="project-card" @click="emit('select', project)">
    <div>
      <strong>{{ project.city }}</strong>
      <span>{{ project.address }}</span>
    </div>

    <span
      v-if="isAdmin"
      class="dots"
      @click="toggleMenu"
    >
      ⋮
    </span>

    <ul v-if="openMenu" class="menu">
      <li>Info</li>
      <li class="danger" @click="confirmDelete">Delete</li>
    </ul>
  </div>
</template>