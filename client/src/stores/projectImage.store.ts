import { defineStore } from 'pinia'
import { ref } from 'vue'

import {
  getProjectImages,
  uploadProjectImages,
  removeProjectImage
} from '../api/ProjectImages.api'

import type { ProjectImage } from '../types/ProjectImage.type'

export const useProjectImageStore = defineStore('projectImages', () => {
  const images = ref<ProjectImage[]>([])
  const loading = ref(false)
  //const previews = ref<string[]>([])
  //const files = ref<File[]>([])
/*
  function onSelect(e: Event) {
    const input = e.target as HTMLInputElement
    if (!input.files) return

    files.value = Array.from(input.files)
    previews.value = files.value.map(f => URL.createObjectURL(f))
  }
*/
  async function load(projectId: string) {
    loading.value = true
    try {
      const { data } = await getProjectImages(projectId)
      images.value = data
    } finally {
      loading.value = false
    }
  }

  async function upload(projectId: string, files: File[]) {
    if (!projectId || files.length === 0) return
    const { data } = await uploadProjectImages(projectId, files)
    images.value.unshift(...data)
    //files.value = []
    //previews.value = []
  }

  async function remove(imageId: string) {
    await removeProjectImage(imageId)
    images.value = images.value.filter(i => i.id !== imageId)
  }

  return {
    images,
    loading,
    load,
    upload,
    remove,
  }
})