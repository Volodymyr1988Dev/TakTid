import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useProjectNavigationStore = defineStore(
  'projectNavigation',
  () => {
    const selectedProjectId = ref<string | null>(null)

    function openProject(id: string) {
      selectedProjectId.value = id
    }

    function closeProject() {
      selectedProjectId.value = null
    }

    return {
      selectedProjectId,
      openProject,
      closeProject,
    }
  }
)