import { defineStore } from 'pinia'
import { ref } from 'vue'

import {
  getProjectImages,
  getProjectImagesPaginated,
  uploadProjectImages,
  removeProjectImage
} from '../api/ProjectImages.api'

import type { ProjectImage } from '../types/ProjectImage.type'

export const useProjectImageStore = defineStore('projectImages', () => {
  const images = ref<ProjectImage[]>([])
  const loading = ref(false)
  async function load(projectId: string) {
    loading.value = true
    try {
      const { data } = await getProjectImages(projectId)
      images.value = data
    } finally {
      loading.value = false
    }
  }

  async function loadPaginated(
    projectId: string,
    page: number,
    limit: number,
  ) {
    loading.value = true
    try {
      const { data } = await getProjectImagesPaginated(
        projectId,
        page,
        limit,
      )

      if (page === 1) {
        images.value = data.data
      } else {
        images.value.push(...data.data)
      }

      return data
    } finally {
      loading.value = false
    }
  }

  async function upload(projectId: string, files: File[]) {
    if (!projectId || files.length === 0) return
    const { data } = await uploadProjectImages(projectId, files)
    images.value.unshift(...data)
  }

  async function remove(imageId: string) {
    await removeProjectImage(imageId)
    images.value = images.value.filter(i => i.id !== imageId)
  }

  return {
    images,
    loading,
    load,
    loadPaginated,
    upload,
    remove,
  }
})