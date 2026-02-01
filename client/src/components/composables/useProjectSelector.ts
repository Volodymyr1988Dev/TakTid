import { storeToRefs } from 'pinia'
//import { ref, computed } from 'vue'
import { useProjectStore } from '../../stores/project.store'

export function useProjectSelector() {
  const store = useProjectStore()
  const { selectedProject, projectId } = storeToRefs(store)  
  //const projectStore = useProjectStore()
  //const projectId = ref<string | null>(null)
/*
  const project = computed(() =>
    projectId.value
      ? projectStore.getById(projectId.value)
      : null,
  )

  function select(id: string) {
    projectId.value = id
  }

  function reset() {
    projectId.value = null
  }
*/
  return {
    projectId,
    project: selectedProject,
    select: store.select,
    reset: store.clear,
  }
}