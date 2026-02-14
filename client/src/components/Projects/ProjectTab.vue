<script setup lang="ts">
//import { ref, onMounted, computed, watch } from 'vue'
import { ref, computed, onMounted } from 'vue'
//import api from '../../api/axios'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import CreateProjectModal from './CreateProjectModal.vue'
//import ProjectGalleryModal from './ProjectGalleryModal.vue'

import type { Project } from '../../types/Project.dto'
import type { TimeSuggestion } from '../../types/Suggestion.type'
//import type { ProjectImages } from '../../types/ProjectImages'
import { TimeKind } from '../../types/timeKind.enum'
import { useProjectNavigationStore } from '../../stores/projectNavigation.store'
import { useProjectStore } from '../../stores/project.store'

const auth = useAuthStore()
//const isAdmin = auth.user?.isAdmin === true
const isAdmin = computed(() => auth.user?.isAdmin === true)

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void
  (e: 'open-details', projectId: string): void
}>()
const props = defineProps<{
  mode: 'select' | 'details'
}>()
//const projects = ref<Project[]>([])
/* ================= MODALS ================= */
const createModalOpen = ref(false) // ✅ ADD
//const galleryOpen = ref(false) // ✅ ADD
//const activeProject = ref<Project | null>(null) // ✅ ADD
const selectedProject = ref<Project | null>(null)
const photoModalOpen = ref(false)
const projectStore = useProjectStore()
const projectNav = useProjectNavigationStore()

const projects = computed(() => projectStore.projects)
/* ================= LOAD ================= */
//onMounted(loadProjects)
onMounted(() => {
  projectStore.load()
})/*
watch(
  () => auth.isInitialized,
  (ready: boolean) => {
    if (ready && auth.isAuthenticated) {
      loadProjects()
    }
  },
  { immediate: true }
)*/
/*
watch(
  () => auth.isAuthenticated,
  async (logged) => {
    if (logged) {
      await projectStore.load()
    }
  },
  { immediate: true }
)*/
/* ================= ACTIONS ================= */
function removeProject(id: string) {
  //projects.value = projects.value.filter(p => p.id !== id)
  projectStore.removeProject(id)
}

function openPhotoModal(project: Project) {
  selectedProject.value = project
  photoModalOpen.value = true
}
function createWorkSuggestion(project: Project): TimeSuggestion {
  return {
    //kind: 'WORK',
    type: TimeKind.WORK,
    title: `${project.city} – ${project.address}`,
    projectId: project.id,
    breakMinutes: 60,
  }
}
function onProjectClick(project: Project) {
  projectStore.select(project)
  if (props.mode === 'select') {
    
    emit('select',createWorkSuggestion(project)/* {
      kind: 'WORK',
      type: TimeKind.WORK,
      title: `${project.city} – ${project.address}`,
      projectId: project.id,
      breakMinutes: 60,
    }*/)
  }
  else {
    //emit('open-details', project.id)
    projectNav.openProject(project.id)
  }

  if (props.mode === 'details') {
    emit('open-details', project.id)
  }
}

/* ================= ADMIN ================= */
function onProjectCreated(project: Project) {
  //projects.value.unshift(project)
  projectStore.addProject(project)
}

//function openGallery(project: Project) {
//  activeProject.value = project
//  galleryOpen.value = true
//}

//async function loadProjects() {
  //const { data } = await api.get<Project[]>('/projects')
  //projects.value = data
//  projectStore.load()
//}   
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
    <!--@select="selectProject"-->
    <div class="grid">
      <ProjectCard
        v-for="p in projects"
        :key="p.id"
        :project="p"
        :is-admin="isAdmin"
        @deleted="removeProject"
        @select="onProjectClick(p)"
        @upload="openPhotoModal"
      />
    </div>

    <!-- @upload="openGallery" ================= MODALS ================= -->

    <CreateProjectModal
      v-if="createModalOpen"
      @close="createModalOpen = false"
      @created="onProjectCreated"
    />
  </div>
</template>
<style scoped src="./project-list.css"></style>