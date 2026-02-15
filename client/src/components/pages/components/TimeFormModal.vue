<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useProjectStore } from '../../../stores/project.store'

import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useEntryFormSelector } from '../../composables/useEntryFormSelector'
import { useTimeEntryStore } from '../../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../../stores/projectAssignment.store'

import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
//import { EntryState } from '../../../types/EntryState'
import type { AbsenceForm, EntryMode, TimeForm } from '../../../types/Form.types'
//import type { WorkForm, ExtraForm } from '../../../types/Form.types'
import { isWorkSuggestion  } from '../../../types/suggestion.guard'
import { TimeKind } from '../../../types/timeKind.enum'
import ProjectTab from '../../Projects/ProjectTab.vue'

/* ================= props / emits ================= */

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
  dayEntries?: DayEntry[]
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'deleted'): void
  (e: 'cancel'): void
}>()

/* ================= mode ================= */

const mode = ref<EntryMode>('WORK')
const selectingProject = ref(false)
//const projectSelected = computed(() => !!projectStore.selectedProject)
/* ================= project ================= */

const projectStore = useProjectStore()
const timeEntryStore = useTimeEntryStore()
const assignmentStore = useProjectAssignmentStore()

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
  entry: props.entry && props.entry.type === TimeKind.WORK ? props.entry : null,
  projectId,
  dayEntries: props.dayEntries,
})

const extraForm = useExtraEntryForm({
  date: props.date,
  entry: props.entry?.type === TimeKind.EXTRA ? props.entry : null,
  projectId,
  //dayEntries: props.dayEntries,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
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
/*
const resolvedType = computed<TimeKind>(() => {
  if (mode.value === 'WORK') return TimeKind.WORK
  if (mode.value === 'EXTRA') return TimeKind.EXTRA
  return absenceForm.absenceType.value
})*/
watch(
  () => [props.entry, props.preset] as const,
  ([entry, preset]) => {

    //currentEntryId.value = entry?.id ?? null
    //currentType.value = entry?.type ?? null

    if (entry) {

      if ('projectId' in entry && entry.projectId) {
        const project = projectStore.getById(entry.projectId)
        if (project) projectStore.select(project)
      }

      if (entry.type === TimeKind.WORK) mode.value = 'WORK'
      else if (entry.type === TimeKind.EXTRA) mode.value = 'EXTRA'
      else mode.value = 'ABSENCE'

      return
    }

    if (preset) {
      if (isWorkSuggestion(preset)) {
        mode.value = preset.type
        const project = projectStore.getById(preset.projectId)
        if (project) projectStore.select(project)
      } else {
        mode.value = 'ABSENCE'
        absenceForm.absenceType.value = preset.type
      }
      return
    }

    mode.value = 'WORK'
  },
  { immediate: true }
)

watch(mode, (newMode, oldMode) => {
  if (
    (oldMode === 'WORK' && newMode === 'EXTRA') ||
    (oldMode === 'EXTRA' && newMode === 'WORK')
  ) {
    const from = oldMode === 'WORK' ? workForm : extraForm
    const to = newMode === 'WORK' ? workForm : extraForm

    to.start.value = from.start.value
    to.end.value = from.end.value
    to.form.breakMinutes.value = from.form.breakMinutes.value
    to.comment.value = from.comment.value
  }
})

function onProjectSelected(suggestion: TimeSuggestion) {
  if (isWorkSuggestion(suggestion)) {
    const project = projectStore.getById(suggestion.projectId)
    if (project) {
      projectStore.select(project)
    }
  }

  selectingProject.value = false
}

const originalEntryId = computed(() => props.entry?.id ?? null)
const originalType = computed(() => props.entry?.type ?? null)
//const currentEntryId = ref<string | null>(props.entry?.id ?? null)
//const currentType = ref<TimeKind | null>(props.entry?.type ?? null)

async function onSave() {
  if (projectMissing.value) {
    alert('Please select a project')
    return
  }

  const switchingBetweenTimeTypes =
    originalEntryId.value &&
    originalType.value &&
    originalType.value !== mode.value &&
    (
      originalType.value === TimeKind.WORK ||
      originalType.value === TimeKind.EXTRA
    )

  try {

    if (switchingBetweenTimeTypes && originalEntryId.value) {

      if (originalType.value === TimeKind.WORK) {
        await timeEntryStore.remove(originalEntryId.value)
      }

      if (originalType.value === TimeKind.EXTRA) {
        await assignmentStore.remove(originalEntryId.value)
      }

      const newEntry = await activeForm.value.save()

      if (newEntry) emit('saved', newEntry)
      return
    }

    const entry = await activeForm.value.save()

    if (entry) emit('saved', entry)

  } catch (e) {
    console.error('Save failed', e)
  }
}

async function onDelete() {

  deleting.value = true
  try {
    await activeForm.value.remove()
    emit('deleted')
  } finally {
    deleting.value = false
  }
}
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
        v-if="isTimeMode"
        class="project-pill clickable"
        @click="selectingProject = true"
      >
        <div 
          v-if="projectStore.selectedProject" 
          class="project-info"
        >
          <strong>{{ projectStore.selectedProject.city }}  </strong>
          <small class="change-hint">{{ projectStore.selectedProject.address }}</small>
        </div>
        <div v-else>
          <span class="error">Click to select project</span>
        </div>
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
                type="button"
                class="remove"
                @click.stop="timeForm.images.removeAt(i)"
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
        <select v-model="absence.absenceType.value">
          <option 
            value="SICK"
          >
            Sick
          </option>
          <option value="VAB">
            VAB
          </option>
          <option 
            value="VACATION"
          >
            Vacation
          </option>
        </select>
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
      <!-- PROJECT SELECT MODAL -->
      <div
        v-if="selectingProject"
        class="modal-backdrop project-modal-layer"
      >
        <div class="project-modal">
          <ProjectTab
            mode="select"
            @select="onProjectSelected"
          />

          <button
            class="close-projects"
            @click="selectingProject = false"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: #ffffff;
  padding: 24px;
  border-radius: 16px;
  width: 440px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
}

.back-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 14px;
  color: #475569;
}

h3 {
  margin-bottom: 12px;
}

.project-pill {
  background: #f1f5f9;
  padding: 12px 14px;
  border-radius: 12px;
  margin-bottom: 14px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: 0.2s;
}

.project-pill:hover {
  background: #e2e8f0;
  border-color: #cbd5e1;
}

.project-info {
  display: flex;
  flex-direction: column;
}

.error {
  color: #dc2626;
  background: #fee2e2;
  padding: 6px 10px;
  border-radius: 8px;
}

.change-hint {
  font-size: 12px;
  color: #64748b;
}

select,
input,
textarea {
  width: 100%;
  margin-bottom: 10px;
  padding: 8px;
  border-radius: 8px;
  border: 1px solid #cbd5e1;
}

textarea {
  resize: vertical;
  min-height: 70px;
}

.previews {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
}

.preview {
  position: relative;
}

.previews img {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 8px;
}

.preview .remove {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #dc2626;
  color: white;
  border-radius: 50%;
  border: none;
  width: 20px;
  height: 20px;
  font-size: 12px;
  cursor: pointer;
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
  border-radius: 10px;
  border: none;
}

.danger {
  background: #dc2626;
  color: #ffffff;
  padding: 8px 16px;
  border-radius: 10px;
  border: none;
}

.loading {
  font-size: 14px;
  color: #475569;
}

/* overlay saving */
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.spinner {
  background: white;
  padding: 20px 32px;
  border-radius: 14px;
  font-weight: 600;
}

/* Project modal */
.project-modal-layer {
  z-index: 2000;
}

.project-modal {
  background: white;
  width: 520px;
  max-height: 85vh;
  border-radius: 16px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.project-modal :deep(.projects) {
  overflow-y: auto;
  max-height: 70vh;
}

.close-projects {
  margin-top: 12px;
  padding: 8px;
  border-radius: 8px;
  border: none;
  background: #e2e8f0;
}
</style>