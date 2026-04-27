import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { ProjectStats } from '../types/projectStats.type'
import { getProjectStats } from '../api/projectStats.api'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
export const useProjectNavigationStore = defineStore(
  'projectNavigation',
  () => {
    const selectedProjectId = ref<string | null>(null)
    const projectStats = ref<ProjectStats | null>(null)
    const isLoading = ref(false)
    const error = ref<string | null>(null)

    async function openProject(id: string) {
      selectedProjectId.value = id
      isLoading.value = true
      error.value = null

      try {
        const { data } = await getProjectStats(id)
        projectStats.value = data
      }
      catch (e) {
        console.error(e)
        projectStats.value = null
        error.value = t('stats.loadProjectStats')
      }
      finally {
        isLoading.value = false
      }
    }

    function closeProject() {
      selectedProjectId.value = null
      projectStats.value = null
    }

    return {
      selectedProjectId,
      projectStats,
      isLoading,
      error,
      openProject,
      closeProject,
    }
  }
)