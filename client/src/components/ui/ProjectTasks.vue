<script setup lang="ts">

import { onMounted, ref } from 'vue'
import { useProjectTasksStore } from '../../stores/projectTasks.store'
import type { ProjectTask } from '../../types/ProjectTask'

const props = defineProps<{
  projectId: string
  isAdmin: boolean
}>()

const store = useProjectTasksStore()

const editingTaskId = ref<string | null>(null)

const editingTitle = ref('')
const editingNote = ref('')

const editingAttentionNote = ref('')

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

function startEdit(task: ProjectTask) {

  editingTaskId.value = task.id

  editingTitle.value = task.title
    
  editingNote.value = task.note ?? ''

  editingAttentionNote.value = task.attentionNote ?? ''
}
function cancelEdit() {

  editingTaskId.value =
    null

  editingTitle.value = ''
  editingNote.value = ''
  editingAttentionNote.value = ''
}

async function saveEdit(
  taskId: string,
) {

  await store.updateTaskData(
    taskId,
    {
      title: editingTitle.value,
      note: editingNote.value,
      attentionNote: editingAttentionNote.value,
    },
  )

  editingTaskId.value =
    null
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
  class="import-btn edit-project-btn"
  v-if="isAdmin"
  @click="importTasks"
>
  Import Tasks
</button>
<input
  ref="fileInput"
  type="file"
  accept="image/*,.pdf,application/pdf"
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

<div class="checkbox-row">

    <input
      type="checkbox"
      :checked="task.done"
      @change="store.toggle(task.id)"
    >

    <div class="task-content">

      <template
        v-if="editingTaskId === task.id"
      >

        <input
          v-model="editingTitle"
          class="edit-input"
          placeholder="Title"
        >

        <textarea
          v-model="editingNote"
          class="edit-textarea"
          placeholder="Materials, colors, models"
        />

        <textarea
          v-model="editingAttentionNote"
          class="edit-textarea attention"
          placeholder="Warnings, guarantees, remarks"
        />

        <div class="edit-actions">

          <button
            class="save-btn"
            @click="saveEdit(task.id)"
          >
            Save
          </button>

          <button
            class="cancel-btn"
            @click="cancelEdit"
          >
            Cancel
          </button>

        </div>

      </template>

      <template
        v-else
      >

        <div
          class="task-title"
          :class="{ done: task.done }"
        >
          {{ task.title }}
        </div>

        <div
          v-if="task.note"
          class="task-note"
        >
          📝 {{ task.note }}
        </div>

        <div
          v-if="task.attentionNote"
          class="task-attention"
        >
          ⚠ {{ task.attentionNote }}
        </div>

        <div
          v-if="task.done"
          class="completed"
        >
          ✔ {{ task.completedByName }}
        </div>

      </template>

    </div>

  </div>

  <div
    v-if="isAdmin"
    class="actions"
  >

    <button
      class="edit-btn"
      @click="startEdit(task)"
    >
      ✏️
    </button>

    <button
      class="delete-btn"
      @click="deleteTask(task.id)"
    >
      🗑
    </button>

  </div>
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
.task-note {
  margin-top: 6px;

  color: #64748b;

  font-size: 13px;
}

.task-attention {
  margin-top: 6px;

  color: #dc2626;

  font-size: 13px;

  font-weight: 600;
}
.actions {
  display: flex;
  gap: 8px;
}

.edit-btn,
.delete-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 18px;
}

.edit-input {
  width: 100%;

  padding: 8px;

  border: 1px solid #d1d5db;

  border-radius: 6px;
}

.edit-textarea {
  width: 100%;

  min-height: 70px;

  margin-top: 8px;

  padding: 8px;

  border: 1px solid #d1d5db;

  border-radius: 6px;
}

.attention {
  border-color: #f59e0b;
}

.edit-actions {
  display: flex;

  gap: 8px;

  margin-top: 10px;
}

.save-btn {
  padding: 8px 14px;

  border: none;

  border-radius: 6px;

  background: #16a34a;

  color: white;

  cursor: pointer;
}

.cancel-btn {
  padding: 8px 14px;

  border: none;

  border-radius: 6px;

  background: #ef4444;

  color: white;

  cursor: pointer;
}
.import-btn{
  margin-top: 20px;
} 
</style>