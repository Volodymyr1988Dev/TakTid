<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useProjectStore } from '../stores/project.store'

import { useWorkEntryForm } from '../components/composables/useWorkEntryForm'
import { useExtraEntryForm } from '../components/composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../components/composables/useAbsenceEntryForm'
import { useEntryFormSelector } from '../components/composables/useEntryFormSelector'
import { useTimeEntryStore } from '../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../stores/projectAssignment.store'
import { deleteByType } from '../components/helpers/deleteByType'
import type { DayEntry } from '../types/DayEntry.type'
import type { TimeSuggestion } from '../types/Suggestion.type'
import type { AbsenceForm, EntryMode, TimeForm } from '../types/Form.types'
import { isWorkSuggestion  } from '../types/suggestion.guard'
import { TimeKind } from '../types/timeKind.enum'
import ProjectTab from './ProjectTab.vue'


const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
  dayEntries?: DayEntry[]
  externalLoading?: boolean
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'deleted'): void
  (e: 'cancel'): void
}>()


const mode = ref<EntryMode>('WORK')
const selectingProject = ref(false)

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
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  entry: props.entry && (
    props.entry.type === TimeKind.SICK ||
    props.entry.type === TimeKind.VAB ||
    props.entry.type === TimeKind.VACATION ||
    props.entry.type === TimeKind.DAY_OFF
  )
    ? props.entry
    : null,
  dayEntries: props.dayEntries,   
})

const activeForm = useEntryFormSelector(mode, {
  work: workForm,
  extra: extraForm,
  absence: absenceForm,
})

const timeForm = computed<TimeForm | null>(() => {
  return activeForm.value.mode === 'ABSENCE'
    ? null
    : activeForm.value
})

const absence = computed<AbsenceForm | null>(() => {
  return activeForm.value.mode === 'ABSENCE'
    ? activeForm.value
    : null
})

const isSaving = computed(() => activeForm.value.isSaving.value)
const deleting = ref(false)
const isBlocking = computed(() => isSaving.value || deleting.value || props.externalLoading === true)

//const loader= 

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

      await deleteByType(originalType.value, originalEntryId.value, {
        timeEntryStore,
        assignmentStore,
      })

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
const spinnerText = computed(() => {
  if (deleting.value) return 'Please wait, removing…'
  if (isSaving.value) return 'Please wait, saving…'
  if (props.externalLoading) return 'Please wait, loading…'
  return ''
})
</script>

<template>
  <div 
    v-if="isBlocking" 
    class="overlay"
  >
    <div class="loader-wrapper">
      <div class="loader" />
      <p class="loader-text"> 
        <!--spinner-->
        {{ spinnerText }}
      </p>
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
        <strong>
          Date:
        </strong>
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
          <option 
            value="DAY_OFF"
          >
            Day off
          </option>
        </select>
      </div>

      <!-- COMMENT -->
      <textarea
        v-model="activeForm.comment.value"
        placeholder="Comment"
      />
      <p 
        v-if="absence?.error?.value" 
        class="warning"
      >
        {{ absence.error.value }}
      </p>

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
          <button
            class="close-projects"
            @click="selectingProject = false"
          >
            Cancel
          </button>
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
  /*background: rgba(0, 0, 0, 0.45);*/
  background: rgba(15, 23, 42, 0.45);

  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;

  backdrop-filter: blur(4px);
  animation: fadeOverlay 0.2s ease-out;
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
.warning {
  background: #fee2e2;
  color: #b91c1c;
  padding: 10px;
  border-radius: 8px;
  margin-bottom: 10px;
}
.loader-text {
  font-size: 15px;
  font-weight: 600;
  color: #475569;
  text-align: center;
  letter-spacing: 0.3px;
}



/* HTML: <div class="loader"></div> */
.loader {
  width: 50px;
  height: 28px;
  --_g: no-repeat radial-gradient(farthest-side,#000 94%,#0000);
  background:
    var(--_g) 50%  0,
    var(--_g) 100% 0;
  background-size: 12px 12px;
  position: relative;
  animation: l23-0 1.5s linear infinite;
}
.loader:before {
  content: "";
  position: absolute;
  height: 12px;
  aspect-ratio: 1;
  border-radius: 50%;
  background: #000;
  left:0;
  top:0;
  animation: 
    l23-1 1.5s linear infinite,
    l23-2 0.5s cubic-bezier(0,200,.8,200) infinite;
}
@keyframes l23-0 {
  0%,31%  {background-position: 50% 0   ,100% 0}
  33%     {background-position: 50% 100%,100% 0}
  43%,64% {background-position: 50% 0   ,100% 0}
  66%     {background-position: 50% 0   ,100% 100%}
  79%     {background-position: 50% 0   ,100% 0}
  100%    {transform:translateX(calc(-100%/3))}
}
@keyframes l23-1 {
  100% {left:calc(100% + 7px)}
}
@keyframes l23-2 {
  100% {top:-0.1px}
}
.loader-wrapper {
  background: white;
  padding: 40px 50px;
  border-radius: 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 22px;
  min-width: 220px;

  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);

  animation: fadeInScale 0.25s ease-out;

  @keyframes fadeOverlay {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes fadeInScale {
  from {
    opacity: 0;
    transform: scale(0.92);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
}
</style>