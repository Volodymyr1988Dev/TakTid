<script setup lang="ts">
import { ref, computed } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto'

const props = defineProps<{
  project: Project
  isAdmin: boolean
}>()

/**
 */
const emit = defineEmits<{
  (e: 'select', project: Project): void
  (e: 'deleted', id: string): void
  (e: 'upload', project: Project): void
}>()

const openMenu = ref(false)

/**
 * ✅ Safe first image
 */
const firstImageUrl = computed(() => {
  return props.project.images?.[0]?.url ?? null
})

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
  <div
    class="project-card"
    @click="emit('select', project)"
  >
    <!-- PHOTO -->
    <div class="photo">
      <img
        v-if="firstImageUrl"
        :src="firstImageUrl"
        alt="Project photo"
      >
      <div
        v-else
        class="placeholder"
      >
        No photo
      </div>

      <span
        v-if="project.images && project.images.length > 1"
        class="badge"
      >
        +{{ project.images.length - 1 }}
      </span>
    </div>

    <!-- INFO -->
    <div class="info">
      <strong class="info-strong">{{ project.city }}</strong>
      <span>{{ project.address }}</span>
    </div>

    <!-- ADMIN MENU -->
    <span
      v-if="isAdmin"
      class="dots"
      @click="toggleMenu"
    >
      ⋮
    </span>

    <ul
      v-if="openMenu"
      class="menu"
    >
      <li>Info</li>
      <li
        class="danger"
        @click="confirmDelete"
      >
        Delete
      </li>
      <li @click.stop="emit('upload', project)">
        Add photo
      </li>
    </ul>
  </div>
</template>