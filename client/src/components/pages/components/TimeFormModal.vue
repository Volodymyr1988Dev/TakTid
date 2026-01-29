<script setup lang="ts">
import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
//import { TimeKind } from '../../../types/timeKind.enum'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

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
} = useTimeEntryForm(props)
const emit = defineEmits(['saved', 'cancel'])

const form = useTimeEntryForm(props)
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

      <h3>{{ form.isEdit ? 'Edit time' : 'Register time' }}</h3>
      <p><strong>Date:</strong> {{ date }}</p>

      <select 
        v-if="!form.isAbsence" 
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

        <p>{{ calculatedHours }} h</p>
      </div>

      <p v-else>
        Absence: {{ form.kind }}
      </p>

      <textarea 
        v-model="comment" 
        placeholder="Comment" 
      />

      <div class="actions">
        <button 
          v-if="isEdit" 
          class="danger" 
          @click="remove"
        >
          Delete
        </button>
        <button 
          class="primary" 
          :disabled="isSaving" 
          @click="save"
        >
          Save
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
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
</style>