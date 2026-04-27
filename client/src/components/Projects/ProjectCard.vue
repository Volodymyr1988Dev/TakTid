<script setup lang="ts">
import { ref } from 'vue'
import { useProjectStore } from '../../stores/project.store';
import type { Project } from '../../types/Project.dto'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const props = defineProps<{
  project: Project
  isAdmin: boolean
}>()

const emit = defineEmits<{
  (e: 'select', project: Project): void
  (e: 'deleted', id: string): void
  (e: 'upload', project: Project): void
}>()

const openMenu = ref(false)
const projectStore = useProjectStore()
function toggleMenu(e: MouseEvent) {
  e.stopPropagation()
  openMenu.value = !openMenu.value
}

async function confirmDelete(e: MouseEvent) {
  e.stopPropagation()
  if (!confirm(t('project.confirmDelete'))) return
  await projectStore.removeProject(props.project.id)
  emit('deleted', props.project.id)
}
</script>

<template>
  <div
    class="project-card"
    @click="emit('select', project)"
  >
    <div class="info">
      <strong class="info-strong">{{ project.city }}  </strong>
      <span class="space">  ➤  </span>
      <span class="change-hint">{{ project.address }}</span>
    </div>

    <span
      v-if="isAdmin"
      class="dots"
      @click="toggleMenu"
    >
      ⚙️
    </span>

    <ul
      v-if="openMenu"
      class="menu"
    >
      <li>{{ t('project.info') }}</li>
      <li
        class="danger"
        @click="confirmDelete"
      >
        {{ t('common.delete') }}
      </li>
    </ul>
  </div>
</template>