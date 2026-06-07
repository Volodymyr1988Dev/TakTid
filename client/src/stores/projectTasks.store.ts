import { defineStore } from 'pinia'
import { ref } from 'vue'

import {
  getProjectTasks,
  toggleTask,
  deleteTask,
  importTasks,
  updateTask,
} from '../api/projectTasks.api'
import type { ProjectTask } from '../types/ProjectTask'

export const useProjectTasksStore =
defineStore('projectTasks', () => {

  //const tasks = ref([])
  const tasks = ref<ProjectTask[]>([])

  async function load(projectId: string) {

    const { data } =
      await getProjectTasks(projectId)

    tasks.value = data
  }
  async function remove(taskId: string) {
    await deleteTask(taskId)

    tasks.value =
        tasks.value.filter(
        t => t.id !== taskId
        )
    }

    async function importFromImages(
    projectId: string,
    files: File[],
    ) {
    const { data } =
        await importTasks(
        projectId,
        files,
        )

    tasks.value.push(...data)
    }

    async function updateTaskData(
    taskId: string,
    dto: {
        title: string
        note: string | null
        attentionNote: string | null
    },
    ) {

    const { data } =
        await updateTask(
        taskId,
        dto,
        )

    const index =
        tasks.value.findIndex(
        t => t.id === taskId,
        )

    if (index >= 0) {
        tasks.value[index] =
        data
    }
    }

  async function toggle(taskId: string) {

    const { data } =
      await toggleTask(taskId)

    const index =
      tasks.value.findIndex(t => t.id === taskId)

    if (index !== -1) {
      tasks.value[index] = data
    }
  }

  return {
    tasks,
    load,
    toggle,
    remove,
    importFromImages,
    updateTaskData,
  }
})