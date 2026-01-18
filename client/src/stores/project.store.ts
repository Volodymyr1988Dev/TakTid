import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Project } from '../types/Project.dto'
import { getProjects } from '../api/project.api'

export const useProjectStore = defineStore('projects', () => {
  const projects = ref<Project[]>([])
  const isLoaded = ref(false)

  const projectsMap = computed(() => {
    const map = new Map<string, Project>()
    projects.value.forEach(p => map.set(p.id, p))
    return map
  })

  async function load() {
    if (isLoaded.value) return
    projects.value = await getProjects()
    isLoaded.value = true
  }

  function getById(id?: string) {
    if (!id) return undefined
    return projectsMap.value.get(id)
  }

  return {
    projects,
    projectsMap,
    load,
    getById,
    isLoaded,
  }
})