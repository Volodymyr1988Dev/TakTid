<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useProjectStore } from '../../../stores/project.store'

import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useEntryFormSelector } from '../../composables/useEntryFormSelector'

import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
//import { EntryState } from '../../../types/EntryState'
import type { AbsenceForm, EntryMode, TimeForm } from '../../../types/Form.types'
//import type { WorkForm, ExtraForm } from '../../../types/Form.types'
import { isWorkSuggestion  } from '../../../types/suggestion.guard'
import { TimeKind } from '../../../types/timeKind.enum'

/* ================= props / emits ================= */

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'deleted'): void
  (e: 'cancel'): void
}>()

/* ================= mode ================= */

const mode = ref<EntryMode>('WORK')

/* ================= project ================= */

const projectStore = useProjectStore()
const isTimeMode = computed(() => mode.value !== 'ABSENCE')

const projectId = computed(() =>
  isTimeMode.value
    ? projectStore.selectedProject?.id ?? null
    : null,
)

const projectMissing = computed(
  () => isTimeMode.value && !projectId.value,
)

/* ================= forms ================= */

const workForm = useWorkEntryForm({
  date: props.date,
  //entry: props.entry?.kind === EntryState.WORK ? props.entry : null,
  //entry: props.entry && props.entry.kind === 'WORK' ? props.entry : null,
  entry: props.entry && props.entry.type === TimeKind.WORK ? props.entry : null,
  projectId,
})

const extraForm = useExtraEntryForm({
  date: props.date,
  //entry: props.entry?.kind === 'EXTRA' ? props.entry : null, //EntryState.EXTRA ? props.entry : null,
  entry: props.entry?.type === TimeKind.EXTRA ? props.entry : null,
  projectId,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  //entry: props.entry?.kind === EntryState.ABSENCE ? props.entry : null,
   //entry: props.entry && props.entry.kind === 'ABSENCE'
   entry: props.entry && (
    props.entry.type === TimeKind.SICK ||
    props.entry.type === TimeKind.VAB ||
    props.entry.type === TimeKind.VACATION
  )
    ? props.entry
    : null,
})

const activeForm = useEntryFormSelector(mode, {
  work: workForm,
  extra: extraForm,
  absence: absenceForm,
})

const timeForm = computed<TimeForm | null>(() => {
  //return activeForm.value.kind === 'ABSENCE'
  return activeForm.value.mode === 'ABSENCE'
    ? null
    : activeForm.value
})

const absence = computed<AbsenceForm | null>(() => {
  return activeForm.value.mode === 'ABSENCE'
    ? activeForm.value
    : null
})
/* ================= derived ================= */

const isSaving = computed(() => activeForm.value.isSaving.value)
const deleting = ref(false)
const isBlocking = computed(() => isSaving.value)
/* ================= debug ================= */

watch(
  () => mode.value,
  (m) => {
    console.group('[TimeFormModal] MODE CHANGED')
    console.log('mode:', m)
    console.log('activeForm:', activeForm.value)
    console.groupEnd()
  },
  { immediate: true },
)

/* ================= effects ================= */

watch(
  () => [props.entry, props.preset] as const,
  ([entry, preset]) => {
    console.group('[TimeFormModal] INIT')

    /* ================= EDIT MODE ================= */
    if (entry) {
      if (entry.type === TimeKind.WORK) {
        mode.value = 'WORK'
      } else if (entry.type === TimeKind.EXTRA) {
        mode.value = 'EXTRA'
      } else {
        mode.value = 'ABSENCE'
      }

      console.log('edit entry detected:', entry)
      console.log('resolved mode:', mode.value)
      console.groupEnd()
      return
    }

    /* ================= PRESET MODE ================= */
    if (preset) {
      if (isWorkSuggestion(preset)) {
        mode.value = preset.type
        console.log('time preset detected:', preset)
      } else {
        mode.value = 'ABSENCE'
        absenceForm.absenceType.value = preset.type
        console.log('absence preset detected:', preset)
      }

      console.groupEnd()
      return
    }

    /* ================= DEFAULT ================= */
    mode.value = 'WORK'
    console.log('default mode WORK')
    console.groupEnd()
  },
  { immediate: true },
)
/*
function isWorkSuggestion(
  s: TimeSuggestion
): s is Extract<TimeSuggestion, { type: 'WORK' | 'EXTRA' }> {
  return s.type === 'WORK' || s.type === 'EXTRA'
}
  */
/* ================= actions ================= */

async function onSave() {
  console.group('[TimeFormModal] SAVE')

  if (projectMissing.value) {
    console.warn('project missing')
    alert('Please select a project')
    console.groupEnd()
    return
  }

  const entry = await activeForm.value.save()
  console.log('saved entry:', entry)

  if (entry) emit('saved', entry)

  console.groupEnd()
}

async function onDelete() {
  console.group('[TimeFormModal] DELETE')

  deleting.value = true
  try {
    await activeForm.value.remove()
    emit('deleted')
    console.log('entry deleted')
  } finally {
    deleting.value = false
    console.groupEnd()
  }
}

/*
<div
            v-if="timeForm.images.previews.value.length"
            class="previews"
          >
            <img
              v-for="(src, i) in timeForm.images.previews.value"
              :key="i"
              :src="src"
              alt="preview"
              class="preview"
            >
          </div>
*/
</script>

<template>
  <div 
    v-if="isBlocking" 
    class="overlay"
  >
    <div class="spinner">
      Please wait, saving…
    </div>
  </div>
  <div class="modal-backdrop">
    <div class="modal">
      <!-- HEADER -->
      <header class="modal-header">
        <button
          class="back-btn"
          @click="emit('cancel')"
        >
          ← Back
        </button>
      </header>

      <!-- TITLE -->
      <h3>
        <template v-if="mode === 'ABSENCE'">
          Register absence ({{ absence?.absenceType.value }})
        </template>
        <template v-else>
          {{ activeForm.isEdit.value ? 'Edit time' : 'Register time' }}
        </template>
      </h3>

      <p>
        <strong>Date:</strong>
        {{ date }}
      </p>

      <!-- PROJECT -->
      <div
        v-if="isTimeMode && projectStore.selectedProject"
        class="project-pill"
      >
        <p
          v-if="projectMissing"
          class="error"
        >
          Please select a project
        </p>

        <strong>{{ projectStore.selectedProject.city }}</strong>
        <small>{{ projectStore.selectedProject.address }}</small>
      </div>

      <!-- MODE SELECT -->
      <select
        v-if="isTimeMode"
        v-model="mode"
      >
        <option value="WORK">
          Work
        </option>
        <option value="EXTRA">
          Extra work
        </option>
      </select>

      <!-- TIME FORM -->
      <div v-if="timeForm">
        <input
          v-model="timeForm.start.value"
          type="time"
        >

        <input
          v-model="timeForm.end.value"
          type="time"
        >

        <input
          v-model.number="timeForm.form.breakMinutes.value"
          type="number"
          min="0"
        >

        <!-- IMAGES -->
        <div v-if="timeForm.images">
          <input
            type="file"
            multiple
            accept="image/*"
            @change="timeForm.images.onSelect"
          >

          <div class="previews">
            <div
              v-for="(src, i) in timeForm.images.previews.value"
              :key="i"
              class="preview"
            >
              <img :src="src">
              <button
                class="remove"
                @click="timeForm.images.removeAt(i)"
              >
                ✕
              </button>
            </div>
          </div>
        </div>

        <p>
          {{ timeForm.calculatedHours }} h
        </p>
      </div>

      <!-- ABSENCE FORM -->
      <div v-else-if="absence">
        <p>
          Absence type:
          <strong>{{ absence.absenceType.value }}</strong>
        </p>
      </div>

      <!-- COMMENT -->
      <textarea
        v-model="activeForm.comment.value"
        placeholder="Comment"
      />

      <!-- ACTIONS -->
      <div class="actions">
        <span
          v-if="isSaving"
          class="loading"
        >
          {{ deleting ? 'Removing…' : 'Saving…' }}
        </span>

        <button
          v-if="activeForm.isEdit.value"
          class="danger"
          :disabled="isSaving"
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
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  background: #ffffff;
  padding: 16px;
  border-radius: 12px;
  width: 420px;
}

.modal-header {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 8px;
}

.back-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 14px;
}

.project-pill {
  background: #f1f5f9;
  padding: 8px 12px;
  border-radius: 10px;
  margin-bottom: 12px;
}

.error {
  color: #dc2626;
  background: #fee2e2;
  padding: 6px 10px;
  border-radius: 8px;
  margin-bottom: 6px;
}

.actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
}

.primary {
  background: #2563eb;
  color: #ffffff;
  padding: 8px 16px;
  border-radius: 8px;
}

.danger {
  background: #dc2626;
  color: #ffffff;
  padding: 8px 16px;
  border-radius: 8px;
}

.previews {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}
.preview {
  position: relative;
}
.previews img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 6px;
}
.preview .remove {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #dc2626;
  color: white;
  border-radius: 50%;
  border: none;
  width: 18px;
  height: 18px;
  font-size: 12px;
  cursor: pointer;
}
.loading {
  font-size: 14px;
  color: #475569;
}
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.spinner {
  background: white;
  padding: 20px 32px;
  border-radius: 12px;
  font-weight: 600;
}
</style>