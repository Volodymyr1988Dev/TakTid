<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../../api/axios'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import type { Project } from '../../types/Project.dto'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { TimeKind } from '../../types/timeKind.enum'

const auth = useAuthStore()
const isAdmin = auth.user?.isAdmin === true

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
}>()

const projects = ref<Project[]>([])

onMounted(async () => {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
})

function removeProject(id: string) {
  projects.value = projects.value.filter(p => p.id !== id)
}

function selectProject(project: Project) {
  emit('select', {
    type: TimeKind.WORK,
    title: `${project.city} – ${project.address}`,
    projectId: project.id,
    breakMinutes: 60,
  })
}
</script>

<template>
  <div class="projects">
    <div class="grid">
      <ProjectCard
        v-for="p in projects"
        :key="p.id"
        :project="p"
        :is-admin="isAdmin"
        @deleted="removeProject"
        @select="selectProject"
      />
    </div>
  </div>
</template>