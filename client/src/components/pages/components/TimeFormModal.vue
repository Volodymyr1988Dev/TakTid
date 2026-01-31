<script setup lang="ts">
import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
//import { TimeKind } from '../../../types/timeKind.enum'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
//import { loadProjects } from '../../composables/useProjectLoader'
//import { EntryState } from '../../../types/EntryState';
//import { computed } from 'vue'

const props = defineProps<{
  date: string
  entry?: DayEntry  | null
  preset?: TimeSuggestion | null
}>()
const {
  comment,
  isSaving,
  save,
  remove,
  isEdit,
  isAbsence,
  mode,
  start,
  end,
  breakMinutes,
  calculatedHours,
  images,
  kind,
  //projectId,
  project,
} = useTimeEntryForm(props)
const {
  previews,
  //onSelect
} = images
//const emit = defineEmits(['saved', 'cancel'])
const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'cancel'): void
  (e: 'deleted'): void
}>()

async function onSave() {
  const entry = await save()
  if (entry) emit('saved', entry)
}
async function onDelete() {
  await remove()
    emit('deleted')
}
//const form = useTimeEntryForm(props)
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <button 
          class="back-btn" 
          @click="emit('cancel')"
        >
          ← Back
        </button>
      </header>

      <h3>{{ isEdit ? 'Edit time' : 'Register time' }}</h3>
      <p><strong>Date:</strong> {{ date }}</p>
      <div
        v-if="project"
        class="project-pill"
      >
        <strong>{{ project.city }}</strong>
        <small>{{ project.address }}</small>
      </div>
      <select 
        v-if="!isAbsence" 
        v-model="mode"
      >
        <option value="WORK">
          Work
        </option>
        <option value="EXTRA">
          Extra work
        </option>
      </select>

      <div v-if="!isAbsence">
        <input 
          v-model="start" 
          type="time" 
        >
        <input 
          v-model="end" 
          type="time" 
        >
        <input 
          v-model.number="breakMinutes" 
          type="number" 
          min="0" 
        >

        <input 
          type="file" 
          multiple 
          accept="image/*" 
          @change="images.onSelect" 
        >
        <div class="previews">
          <img
            v-for="(src, i) in previews"
            :key="i"
            :src="src"
          >
        </div>

        <p>{{ calculatedHours }} h</p>
      </div>

      <p v-else>
        Absence: {{ kind }}
      </p>

      <textarea 
        v-model="comment" 
        placeholder="Comment" 
      />

      <div class="actions">
        <button 
          v-if="isEdit" 
          class="danger" 
          @click="onDelete"
        >
          Delete
        </button>
        <button 
          class="primary" 
          :disabled="isSaving" 
          @click="onSave"
        >
          Save
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.project-pill {
  background: #f1f5f9;
  padding: 8px 12px;
  border-radius: 10px;
  cursor: pointer;
  margin-bottom: 12px;
}
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.4);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  background: white;
  padding: 16px;
  border-radius: 12px;
  width: 420px;
}

.modal-header {
  margin-bottom: 8px;
}

.back-btn {
  background: none;
  border: none;
  cursor: pointer;
}

.actions {
  display: flex;
  justify-content: space-between;
  margin-top: 16px;
}

.primary {
  background: #2563eb;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
}

.danger {
  background: #dc2626;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
}
.previews {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}
.previews img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 6px;
}
</style>