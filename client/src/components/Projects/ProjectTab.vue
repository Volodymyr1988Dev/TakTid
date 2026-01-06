<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth.store'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto'
import CreateProjectModal from './CreateProjectModal.vue'

const auth = useAuthStore()

//const projects: any[] = []
const isAdmin = computed(() => auth.user?.isAdmin === true)
const projects = ref<Project[]>([])
const isCreateOpen = ref(false)
onMounted(async () => {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
})
function onCreated(project: Project) {
  projects.value.push(project)
}
</script>

<template>
  <div class="projects">
    <p v-if="!projects.length">
      Попросіть адміністратора внести проект
    </p>

    <ul v-else>
      <li v-for="p in projects" :key="p.id">
        {{ p.city }} – {{ p.address }}
      </li>
    </ul>

    <button v-if="isAdmin" @click="isCreateOpen = true">
      Create project
    </button>
    <CreateProjectModal
    v-if="isCreateOpen"
    @close="isCreateOpen = false"
    @created="onCreated($event)"
    />
  </div>
  
</template>