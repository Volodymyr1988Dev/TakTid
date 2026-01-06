<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../../api/axios'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import CreateProjectModal from './CreateProjectModal.vue'
import type { Project } from '../../types/Project.dto'

const auth = useAuthStore()
const isAdmin = auth.user?.isAdmin === true

const showCreateModal = ref(false)
//const projects = ref([])
const projects = ref<Project[]>([])
onMounted(async () => {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
})
function removeProject(id: string) {
  projects.value = projects.value.filter(p => p.id !== id)
} 
</script>

<template>
  <div class="projects">
    <button v-if="isAdmin" @click="showCreateModal = true">
      + Add Project
    </button>

    <CreateProjectModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
      @created="projects.push($event)"
    />

    <div class="grid">
      <ProjectCard
        v-for="p in projects"
        :key="p.id"
        :project="p"
        :is-admin="isAdmin"
        @deleted="removeProject"
      />
    </div>
  </div>
</template>