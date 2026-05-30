<script setup lang="ts">

import { onMounted, ref } from 'vue'
import { useProjectTasksStore } from '../../stores/projectTasks.store'

const props = defineProps<{
  projectId: string
  isAdmin: boolean
}>()

const store = useProjectTasksStore()

onMounted(() => {
  store.load(props.projectId)
})

const fileInput =
  ref<HTMLInputElement | null>(null)

function importTasks() {
  fileInput.value?.click()
}
async function onFileSelected(
  event: Event,
) {
  const input =
    event.target as HTMLInputElement

  const files = input.files

  if (!files?.length) {
    return
  }

  await store.importFromImages(
    props.projectId,
    Array.from(files),
  )
  input.value = ''
}
async function deleteTask(taskId: string) {
  const ok = confirm(
    'Delete task?'
  )

  if (!ok) return

  await store.remove(taskId)
}

</script>

<template>

<div class="tasks-panel">
<button
  v-if="isAdmin"
  @click="importTasks"
>
  Import Tasks
</button>
<input
  ref="fileInput"
  type="file"
  accept="image/*"
  multiple
  hidden
  @change="onFileSelected"
/>
<h3>Tasks</h3>

<div
  v-for="task in store.tasks"
  :key="task.id"
  class="task-row"
>

<label class="checkbox-row">

<input
  type="checkbox"
  :checked="task.done"
  @change="store.toggle(task.id)"
>

<div class="task-content">

<div
  class="task-title"
  :class="{ done: task.done }"
>
  {{ task.title }}
</div>

<div
  v-if="task.done"
  class="completed"
>

✔ {{ task.completedByName }}

</div>

</div>

</label>

<button
    v-if="isAdmin"
    class="delete-btn"
    @click="deleteTask(task.id)"
  >
    🗑
  </button>
</div>

</div>

</template>

<style scoped> 
.checkbox-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  cursor: pointer;
}

.checkbox-row input {
  margin-top: 4px;

  width: 18px;
  height: 18px;
}

.task-content {
  flex: 1;
}

.task-title {
  font-size: 15px;
  font-weight: 500;

  color: #111827;
}

.task-title.done {
  text-decoration: line-through;
  color: #94a3b8;
}

.completed {
  margin-top: 4px;

  font-size: 12px;

  color: #16a34a;
} 
.task-row {
  display: flex;
  justify-content: space-between;
  align-items: center;

  padding: 8px 0;
}

.delete-btn {
  border: none;
  background: transparent;

  cursor: pointer;

  font-size: 18px;
}

.delete-btn:hover {
  opacity: 0.7;
}

</style>