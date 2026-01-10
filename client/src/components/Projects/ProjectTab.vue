<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../../api/axios'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import CreateProjectModal from './CreateProjectModal.vue'
//import ProjectGalleryModal from './ProjectGalleryModal.vue'
import ProjectPhotosModal from './ProjectPhotosModal.vue'

import type { Project } from '../../types/Project.dto'
import type { TimeSuggestion } from '../../types/Suggestion.type'
//import type { ProjectImages } from '../../types/ProjectImages'
import { TimeKind } from '../../types/timeKind.enum'

const auth = useAuthStore()
const isAdmin = auth.user?.isAdmin === true

const emit = defineEmits<{
  (e: 'select', s: TimeSuggestion): void

}>()

const projects = ref<Project[]>([])

/* ================= MODALS ================= */
const createModalOpen = ref(false) // ✅ ADD
//const galleryOpen = ref(false) // ✅ ADD
const activeProject = ref<Project | null>(null) // ✅ ADD
const selectedProject = ref<Project | null>(null)
const photoModalOpen = ref(false)
/* ================= LOAD ================= */
onMounted(loadProjects)
/* ================= ACTIONS ================= */
function removeProject(id: string) {
  projects.value = projects.value.filter(p => p.id !== id)
}

function openPhotoModal(project: Project) {
  selectedProject.value = project
  photoModalOpen.value = true
}

function selectProject(project: Project) {
  emit('select', {
    type: TimeKind.WORK,
    title: `${project.city} – ${project.address}`,
    projectId: project.id,
    breakMinutes: 60,
  })
}

/* ================= ADMIN ================= */
function onProjectCreated(project: Project) {
  projects.value.unshift(project)
}

//function openGallery(project: Project) {
//  activeProject.value = project
//  galleryOpen.value = true
//}

async function uploadImages(files: FileList) {
  if (!activeProject.value) return

  for (const file of Array.from(files)) {
    await api.post(
      `/project-images/${activeProject.value.id}`,
      { file },
      { headers: { 'Content-Type': 'multipart/form-data' } },
    )
  }

  // 🔄 reload project
  const { data } = await api.get<Project>(`/projects/${activeProject.value.id}`)
  const idx = projects.value.findIndex(p => p.id === data.id)
  if (idx !== -1) projects.value[idx] = data
}

async function removeImage(id: string) {
  await api.delete(`/project-images/${id}`)

  if (!activeProject.value) return
  activeProject.value.images = activeProject.value.images?.filter(
    img => img.id !== id,
  )
}

async function loadProjects() {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
}

async function reloadProjects() {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
}
/*
<ProjectGalleryModal
      v-if="galleryOpen && activeProject"
      :photos="activeProject.images ?? []"
      :is-admin="isAdmin"
      @upload="uploadImages"
      @remove="removeImage"
      @close="galleryOpen = false"
    />
*/    
</script>

<template>
  <div class="projects">
    <!-- ✅ ADD PROJECT BUTTON -->
    <button
      v-if="isAdmin"
      class="add-project"
      @click="createModalOpen = true"
    >
      + Add project
    </button>

    <div class="grid">
      <ProjectCard
        v-for="p in projects"
        :key="p.id"
        :project="p"
        :is-admin="isAdmin"
        @deleted="removeProject"
        @select="selectProject"
        @upload="openPhotoModal"
      />
    </div>

    <!-- @upload="openGallery" ================= MODALS ================= -->

    <CreateProjectModal
      v-if="createModalOpen"
      @close="createModalOpen = false"
      @created="onProjectCreated"
    />

    <ProjectPhotosModal
      v-if="photoModalOpen && selectedProject"
      :project="selectedProject"
      @close="photoModalOpen = false"
      @uploaded="reloadProjects"
    />
  </div>
</template>