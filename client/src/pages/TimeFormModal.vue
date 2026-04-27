<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useProjectStore } from '../stores/project.store'

import { useWorkEntryForm } from '../components/composables/useWorkEntryForm'
import { useExtraEntryForm } from '../components/composables/useExtraEntryForm'
import { useMeetingEntryForm } from '../components/composables/useMeetingEntryForm'
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
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

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

//const isTimeMode = computed(() => mode.value !== 'ABSENCE')
const isProjectMode = computed(
  () => mode.value === 'WORK' || mode.value === 'EXTRA'
)

const projectId = computed(() =>
  //isTimeMode.value
  isProjectMode.value
    ? projectStore.selectedProject?.id ?? null
    : null,
)

const projectMissing = computed(
  //() => isTimeMode.value && !projectId.value,
  () => isProjectMode.value && !projectId.value,
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

const meetingForm = useMeetingEntryForm({
  date: props.date,
  entry: props.entry?.type === TimeKind.MEETING ? props.entry : null,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  entry: props.entry && (
    props.entry.type === TimeKind.SICK ||
    props.entry.type === TimeKind.VAB ||
    props.entry.type === TimeKind.VACATION ||
    props.entry.type === TimeKind.DAY_OFF ||
    props.entry.type === TimeKind.RED_DAY
  )
    ? props.entry
    : null,
  dayEntries: props.dayEntries,   
})

const activeForm = useEntryFormSelector(mode, {
  work: workForm,
  extra: extraForm,
  absence: absenceForm,
  meeting: meetingForm,
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

watch(
  () => [props.entry, props.preset] as const,
  ([entry, preset]) => {
    if (entry) {
      if ('projectId' in entry && entry.projectId) {
        const project = projectStore.getById(entry.projectId)
        if (project) projectStore.select(project)
      }

      if (entry.type === TimeKind.WORK) mode.value = 'WORK'
      else if (entry.type === TimeKind.EXTRA) mode.value = 'EXTRA'
      else if (entry.type === TimeKind.MEETING) mode.value = 'MEETING'
      else mode.value = 'ABSENCE'

      return
    }

    if (preset) {
      if (preset.type === TimeKind.WORK) {
        mode.value = 'WORK'
        const project = projectStore.getById(preset.projectId!)
        if (project) projectStore.select(project)
        return
      }

      if (preset.type === TimeKind.EXTRA) {
        mode.value = 'EXTRA'
        const project = projectStore.getById(preset.projectId!)
        if (project) projectStore.select(project)
        return
      }

      if (preset.type === TimeKind.MEETING) {
        mode.value = 'MEETING'
        return
      }

      mode.value = 'ABSENCE'
      absenceForm.absenceType.value = preset.type
      return
    }

    mode.value = 'WORK'
  },
  { immediate: true },
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
    alert(t('project.errorSelectProject'))
    return
  }

  const switchingBetweenTimeTypes =
    originalEntryId.value &&
    originalType.value &&
    originalType.value !== mode.value &&
    (
      originalType.value === TimeKind.WORK ||
      originalType.value === TimeKind.EXTRA ||
      originalType.value === TimeKind.MEETING
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
    console.error(t('errors.saveFailed'), e)
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
  if (deleting.value) return t('toast.deleting')
  if (isSaving.value) return t('toast.saving')
  if (props.externalLoading) return t('toast.loading')
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
        {{ spinnerText }}
      </p>
    </div>
  </div>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <button
          class="back-btn"
          @click="emit('cancel')"
        >
          ← {{ t('common.back') }}
        </button>
      </header>

      <h3>
        <template v-if="mode === 'ABSENCE'">
          {{ t('toast.registerAbsence') }} ({{ absence?.absenceType.value }})
        </template>
        <template v-else>
          {{ activeForm.isEdit.value ? t('toast.editTime') : t('toast.registerTime') }}
        </template>
      </h3>
      <p>
        <strong>
          {{ t('calendar.date') }}:
        </strong>
        {{ date }}
      </p>
      <!--isTimeMode-->
      <div
        v-if="isProjectMode"
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
          <span class="error">{{ t('errors.clickToSelectProject') }}</span>
        </div>
      </div>
      <!--isTimeMode-->
      <select
        v-if="isProjectMode"
        v-model="mode"
      >
        <option value="WORK">
          {{ t('stats.work') }}
        </option>
        <option value="EXTRA">
          {{ t('stats.extra') }}
        </option>
      </select>

      <div v-if="timeForm">
        <input
          v-model="timeForm.start.value"
          type="time"
        >

        <input
          v-model="timeForm.end.value"
          type="time"
        >
        <!--v-model.number="timeForm.form.breakMinutes.value"-->
        <input
          v-model="timeForm.form.breakMinutes.value"
          type="number"
          min="0"
        >

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

      <div v-else-if="absence">
        <select v-model="absence.absenceType.value">
          <option 
            value="SICK"
          >
            {{ t('stats.sick') }}
          </option>
          <option value="VAB">
            {{ t('stats.vab') }}
          </option>
          <option 
            value="VACATION"
          >
            {{ t('stats.vacation') }}
          </option>
          <option 
            value="DAY_OFF"
          >
            {{ t('stats.dayOff') }}
          </option>
          <option 
            value="RED_DAY"
          >
            {{ t('stats.redDay') }}
          </option>
        </select>
      </div>

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
          {{ t('common.delete') }}
        </button>

        <button
          class="primary"
          :disabled="isSaving"
          @click="onSave"
        >
          {{ t('common.save') }}
        </button>
      </div>
      <div
        v-if="selectingProject"
        class="modal-backdrop project-modal-layer"
      >
        <div class="project-modal">
          <button
            class="close-projects"
            @click="selectingProject = false"
          >
            {{ t('common.cancel') }}
          </button>
          <ProjectTab
            mode="select"
            @select="onProjectSelected"
          />
          <button
            class="close-projects"
            @click="selectingProject = false"
          >
            {{ t('common.cancel') }}
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

.overlay {
  position: fixed;
  inset: 0;
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