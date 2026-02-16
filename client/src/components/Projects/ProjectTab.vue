<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import CreateProjectModal from './CreateProjectModal.vue'

import type { Project } from '../../types/Project.dto'
import type { TimeSuggestion } from '../../types/Suggestion.type'
import { TimeKind } from '../../types/timeKind.enum'
import { useProjectNavigationStore } from '../../stores/projectNavigation.store'
import { useProjectStore } from '../../stores/project.store'

const auth = useAuthStore()
const isAdmin = computed(() => auth.user?.isAdmin === true)

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
  (e: 'open-details', projectId: string): void
}>()
const props = defineProps<{
  mode: 'select' | 'details'
}>()

const createModalOpen = ref(false)
//const selectedProject = ref<Project | null>(null)
//const photoModalOpen = ref(false)
const projectStore = useProjectStore()
const projectNav = useProjectNavigationStore()

const projects = computed(() => projectStore.projects)
onMounted(() => {
  projectStore.load()
})
function removeProject(id: string) {
  projectStore.removeProject(id)
}
/*
function openPhotoModal(project: Project) {
  selectedProject.value = project
  photoModalOpen.value = true
}*/
function createWorkSuggestion(project: Project): TimeSuggestion {
  return {
    type: TimeKind.WORK,
    title: `${project.city} – ${project.address}`,
    projectId: project.id,
    breakMinutes: 60,
  }
}
function onProjectClick(project: Project) {
  projectStore.select(project)
  if (props.mode === 'select') {
    
    emit('select',createWorkSuggestion(project))
  }
  else {
    projectNav.openProject(project.id)
  }

  if (props.mode === 'details') {
    emit('open-details', project.id)
  }
}

function onProjectCreated(project: Project) {
  projectStore.addProject(project)
}  
</script>

<template>
  <div class="projects">
    <button
      v-if="isAdmin"
      class="add-project"
      @click="createModalOpen = true"
    >
      + Add project
    </button>
    <div class="project-list-scroll">
      <div class="grid">
        <ProjectCard
          v-for="p in projects"
          :key="p.id"
          :project="p"
          :is-admin="isAdmin"
          @deleted="removeProject"
          @select="onProjectClick(p)"
        />
      </div>
    </div>

    <CreateProjectModal
      v-if="createModalOpen"
      @close="createModalOpen = false"
      @created="onProjectCreated"
    />
  </div>
</template>
<style scoped src="./project-list.css"></style>