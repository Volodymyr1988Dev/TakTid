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
import ProjectTab from '../../Projects/ProjectTab.vue'

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
const selectingProject = ref(false)
//const projectSelected = computed(() => !!projectStore.selectedProject)
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
  entry: props.entry && props.entry.type === TimeKind.WORK ? props.entry : null,
  projectId,
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

watch(
  () => [props.entry, props.preset] as const,
  ([entry, preset]) => {
    if (entry) {
      if (
        entry.type === TimeKind.WORK ||
        entry.type === TimeKind.EXTRA
      ) {
        const project = projectStore.getById(entry.projectId)
        if (project) {
          projectStore.select(project)
        }
      }
      if (entry.type === TimeKind.WORK) {
        mode.value = 'WORK'
      } else if (entry.type === TimeKind.EXTRA) {
        mode.value = 'EXTRA'
      } else {
        mode.value = 'ABSENCE'
      }
      return
    }
    if (preset) {
      if (isWorkSuggestion(preset)) {
        mode.value = preset.type
        const project = projectStore.getById(preset.projectId)
        if (project) {
          projectStore.select(project)
        }
      } else {
        mode.value = 'ABSENCE'
        absenceForm.absenceType.value = preset.type
      }
      return
    }
    mode.value = 'WORK'
  },
  { immediate: true },
)
watch(projectId, (val) => {
  console.log('[ProjectId changed]', val)
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

async function onSave() {
console.log('[SAVE] projectId =', projectId.value)
  if (projectMissing.value) {
    console.warn('project missing')
    alert('Please select a project')
    return
  }

  const entry = await activeForm.value.save()

  if (entry) emit('saved', entry)

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
  padding: 10px 14px;
  border-radius: 10px;
  margin-bottom: 12px;

  transition: all 0.15s ease;
  border: 1px solid transparent;
}

.error {
  color: #dc2626;
  background: #fee2e2;
  padding: 6px 10px;
  border-radius: 8px;
  margin-bottom: 6px;
}
.project-info {
  display: flex;
  flex-direction: column;
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
.clickable {
  cursor: pointer;
}
.project-list-scroll {
  max-height: 400px;
  overflow-y: auto;
  padding-right: 8px;
}
.project-pill:hover {
  background: #e2e8f0;
  border-color: #cbd5e1;
}

/* active */
.project-pill:active {
  transform: scale(0.98);
}
.project-pill .error {
  color: #dc2626;
  background: #fee2e2;
  padding: 6px 10px;
  border-radius: 8px;
}
.change-hint {
  font-size: 11px;
  color: #64748b;
}
.project-modal-layer {
  z-index: 10000;
}

.project-modal {
  background: white;
  width: 500px;
  max-height: 80vh;
  border-radius: 14px;
  padding: 20px;

  display: flex;
  flex-direction: column;

  overflow: hidden;
}

.project-modal :deep(.projects) {
  overflow-y: auto;
  max-height: 65vh;
}
.close-projects {
  margin-top: 12px;
  background: #e2e8f0;
  border-radius: 8px;
  padding: 8px 12px;
}
</style>