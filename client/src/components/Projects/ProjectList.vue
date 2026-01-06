<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '../../stores/auth.store'
import ProjectCard from './ProjectCard.vue'
import CreateProjectModal from './CreateProjectModal.vue'
import type { Project } from '../../types/Project.dto'

const auth = useAuthStore()
const isAdmin = auth.user?.isAdmin === true

const showCreateModal = ref(false)
//const projects = ref([])
const projects = ref<Project[]>([])
</script>

<template>
  <button v-if="isAdmin" @click="showCreateModal = true">
    Add Project
  </button>

  <CreateProjectModal
    v-if="showCreateModal"
    @close="showCreateModal = false"
    @created="projects.push($event)"
  />

  <ProjectCard
    v-for="p in projects"
    :key="p.id"
    :project="p"
    :is-admin="isAdmin"
  />
</template>