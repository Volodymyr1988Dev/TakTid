import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Project } from '../types/Project.dto'
import { getProjects } from '../api/project.api'
import { getProjectDetails } from '../api/project.api'
import type { TimeEntry } from '../types/TimeEntry.type'
//import { updateProject } from '../api/project.api'
import { updateProjectApi, deleteProjectApi } from '../api/project.api'

export const useProjectStore = defineStore('projects', () => {
  const selectedProject = ref<Project | null>(null)
  const projectId = computed(() => selectedProject.value?.id ?? null)
  const projects = ref<Project[]>([])
  const isLoaded = ref(false)
  const isLoading = ref(false)

  const projectDetails = ref<TimeEntry[]>([])
  const loadingDetails = ref(false)

  const projectsMap = computed(() => {
    const map = new Map<string, Project>()
    projects.value.forEach(p => map.set(p.id, p))
    return map
  })

  function select(project: Project | null) {
    selectedProject.value = project
  }

  function clear() {
    selectedProject.value = null
  }

  async function load(force = false) {

    if (isLoading.value) return
    if (isLoaded.value && !force) return
    isLoading.value = true
    try {
      projects.value = await getProjects()
      isLoaded.value = true
    } catch (e) {
      console.error('Failed to load projects', e)
    }
    finally {
      isLoading.value = false
    }
  }

  function getById(id?: string) {
    if (!id) return undefined
    return projectsMap.value.get(id)
  }
  function addProject(project: Project) {
    projects.value.unshift(project)
  }

  /*function removeProject(id: string) {
    projects.value = projects.value.filter(p => p.id !== id)
  }*/

  async function removeProject(id: string) {
    try{
      await deleteProjectApi(id)

      projects.value = projects.value.filter(
        p => p.id !== id
      )

      if (selectedProject.value?.id === id) {
        selectedProject.value = null
      }
    } catch(e) {
      console.error('Failed to delete project', e)
      return
    }
    
  }

  async function loadDetails(projectId: string) {
    loadingDetails.value = true
    try {
      projectDetails.value = await getProjectDetails(projectId)
    } finally {
      loadingDetails.value = false
    }
  }
/*
  async function updateProjectData(
    id: string,
    data: /*{
      areaM2?: number | null
      pricePerM2?: number | null
    }*//* Partial<Project>
  ) {
    const response = await updateProject(id, data)

    const index = projects.value.findIndex(
      p => p.id === id
    )

    if (index !== -1) {
      projects.value[index] = response.data
    }

    return response.data
  }
*/
  async function updateProject(
    id: string,
    data: Partial<Project>,
  ) {
    const updated = await updateProjectApi(id, data)

    const index = projects.value.findIndex(
      p => p.id === id
    )

    if (index !== -1) {
      projects.value[index] = updated
    }

    if (selectedProject.value?.id === id) {
      selectedProject.value = updated
    }

    return updated
  }

  return {
    projects,
    selectedProject,
    projectId,
    projectsMap,
    addProject,
    removeProject,
    load,
    getById,
    isLoaded,
    loadDetails,
    projectDetails,
    clear,
    select,
    //updateProjectData,
    updateProject,
  }
})