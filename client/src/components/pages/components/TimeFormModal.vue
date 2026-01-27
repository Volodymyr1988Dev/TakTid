<script setup lang="ts">
import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits(['saved', 'cancel'])

const form = useTimeEntryForm(props)

const {
  start,
  end,
  breakMinutes,
  comment,
  imageStore,
  calculatedHours,
  isEdit,
  save,
  remove,
} = form

async function onSave() {
  await save()
  emit('saved')
}

async function onDelete() {
  await remove()
  emit('saved')
}
</script>

<template>
  <div class="modal">
    <header>
      <button 
        class="back" 
        @click="emit('cancel')"
      >
        ← Back
      </button>
      <h3>{{ isEdit ? 'Edit time entry' : 'Add time entry' }}</h3>
    </header>

    <label>
      Start time
      <input 
        v-model="start" 
        type="time" 
      >
    </label>

    <label>
      End time
      <input 
        v-model="end" 
        type="time" 
      >
    </label>

    <label>
      Break (minutes)
      <input 
        v-model.number="breakMinutes" 
        type="number" 
        min="0" 
      >
    </label>

    <label>
      Comment
      <textarea v-model="comment" />
    </label>

    <p class="hours">
      Worked: <strong>{{ calculatedHours }} h</strong>
    </p>

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
        @click="onSave"
      >
        Save
      </button>
    </div>
  </div>
</template>

<style scoped>
.modal {
  background: white;
  padding: 16px;
  border-radius: 12px;
  max-width: 420px;
}

header {
  display: flex;
  align-items: center;
  gap: 12px;
}

label {
  display: flex;
  flex-direction: column;
  margin-top: 12px;
  font-size: 14px;
}

input,
textarea {
  padding: 6px 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
}

.hours {
  margin-top: 12px;
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

.back {
  background: none;
  border: none;
  cursor: pointer;
}
</style>