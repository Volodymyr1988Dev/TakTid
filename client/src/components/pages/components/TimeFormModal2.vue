<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { EntryState } from '../../../types/EntryState'
import type { TimeBasedForm } from '../../../types/TimeBasedForm'
import { useProjectStore } from '../../../stores/project.store'

const props = defineProps<{
  date: string
  entry?: DayEntry | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'cancel'): void
  (e: 'deleted'): void
}>()


const projectStore = useProjectStore()

type EntryMode = 'WORK' | 'EXTRA' | 'ABSENCE'

const mode = ref<EntryMode>(
  props.entry?.kind === EntryState.EXTRA
    ? 'EXTRA'
    : props.entry?.kind === EntryState.ABSENCE
      ? 'ABSENCE'
      : 'WORK'
)

const isTimeMode = computed(
  () => mode.value === 'WORK' || mode.value === 'EXTRA'
)
const projectId = computed<string | null>(() =>
  isTimeMode.value
    ? projectStore.selectedProject?.id ?? null
    : null
)

const project = computed(() => projectStore.selectedProject)
const deleting = ref(false)
const state = ref<EntryState>(
  props.entry?.kind ?? EntryState.WORK
)

const workForm = useWorkEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.WORK ? props.entry : null,
  projectId,
})

const extraForm = useExtraEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.EXTRA ? props.entry : null,
  projectId,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.ABSENCE ? props.entry : null,
})

const activeForm = computed(() => {
  switch (mode.value) {
    case 'WORK':
      return workForm
    case 'EXTRA':
      return extraForm
    case 'ABSENCE':
      return absenceForm
    default:
      return null
  }
})

const projectMissing = computed(() =>
  isTimeMode.value && !projectId.value
)
const isSaving = computed(() => {
  const saving = Boolean(activeForm.value?.isSaving?.value)
  return saving
})

const startModel = computed({
  get: () =>
    isTimeMode.value ? (activeForm.value as TimeBasedForm).start.value : '',
  set: v => {
    if (isTimeMode.value) {
      (activeForm.value as TimeBasedForm).start.value = v
    }
  },
})
const endModel = computed({
  get: () =>
    isTimeMode.value ? (activeForm.value as TimeBasedForm).end.value : '',
  set: v => {
    if (isTimeMode.value) {
      (activeForm.value as TimeBasedForm).end.value = v
    }
  },
})
const breakMinutesModel = computed({
  get: () =>
    isTimeMode.value ? (activeForm.value as TimeBasedForm).breakMinutes.value : 0,
  set: v => {
    if (isTimeMode.value) {
      (activeForm.value as TimeBasedForm).breakMinutes.value = v
    }
  },
})
const commentModel = computed<string>({
  get: () =>
    mode.value === 'ABSENCE'
      ? absenceForm.comment.value
      : (activeForm.value as TimeBasedForm)?.comment.value ?? '',
  set: v => {
    if (mode.value === 'ABSENCE') {
      absenceForm.comment.value = v
    } else {
      ;(activeForm.value as TimeBasedForm).comment.value = v
    }
  },
})


const imagePreviews = computed<string[]>(() =>
  isTimeMode.value
    ? (activeForm.value as TimeBasedForm).images.previews.value
    : []
)

const savingText = computed(() => {
  if (!isSaving.value) return ''
  return deleting.value
    ? 'Please wait, removing entry…'
    : 'Please wait, saving entry…'
})

watch(
  () => props.entry,
  e => {
    if (!e) return
    if ((e.kind === 'WORK' || e.kind === 'EXTRA') && e.projectId) {
      projectStore.getById(e.projectId)
    }
  },
  { immediate: true },
)
watch(
  () => props.preset,
  preset => {
    if (!preset) return

    if (
      preset.type === 'SICK' ||
      preset.type === 'VAB' ||
      preset.type === 'VACATION'
    ) {
      mode.value = 'ABSENCE'
      absenceForm.kind.value = preset.type
    }
  },
  { immediate: true },
)
async function onSave() {
  
  try {
    if (!activeForm.value) {
      console.error('[Modal] activeForm is NULL, state:', state.value)
      alert('Internal error: no active form')
      return
    }

    if (isTimeMode.value && !projectId.value) {
      alert('Please select a project')
      return
    }

    if (projectMissing.value /*&& state.value !== EntryState.ABSENCE*/) {
      alert('Please select a project before saving')
      console.warn('[Modal] project missing, abort save')
      return
    }

    const entry = await activeForm.value.save()

    if (entry) emit('saved', entry)
  } catch (e) {
    console.error('[Modal] SAVE FAILED', e)
  }
}

async function onDelete() {
  deleting.value = true
  try {
    await activeForm.value?.remove()
    emit('deleted')
  } catch (e) {
    console.error('[Modal] DELETE FAILED', e)
  }
  finally {
    deleting.value = false
  }
}
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

      <h3>
        {{
          mode === 'ABSENCE'
            ? `Register absence (${absenceForm.kind})`
            : activeForm?.isEdit
              ? 'Edit time'
              : 'Register time'
        }}
      </h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <div 
        v-if="isTimeMode && project" 
        class="project-pill"
      >
        <p 
          v-if="projectMissing" 
          class="error"
        >
          Please select a project
        </p>
        <strong>{{ project.city }}  </strong>
        <small>{{ project.address }}</small>
      </div>

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

      <div v-if="isTimeMode">
        <input 
          v-model="startModel" 
          type="time" 
        >
        <input 
          v-model="endModel" 
          type="time" 
        >
        <input 
          v-model.number="breakMinutesModel" 
          type="number" 
          min="0" 
        >

        <input
          type="file"
          multiple
          accept="image/*"
          @change="(activeForm as TimeBasedForm).images.onSelect"
        >

        <div 
          v-if="imagePreviews.length" 
          class="previews"
        >
          <img
            v-for="(src, i) in imagePreviews"
            :key="i"
            :src="src"
          >
        </div>

        <p>{{ (activeForm as TimeBasedForm).calculatedHours }} h</p>
      </div>

      <p v-else>
        Absence: {{ absenceForm.kind }}
      </p>

      <textarea
        v-model="commentModel"
        placeholder="Comment"
      />

      <div class="actions">
        <span 
          v-if="isSaving" 
          class="loading"
        >
          {{ savingText }}
        </span>
        <button
          v-if="activeForm?.isEdit?.value"
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
.error {
  color: #dc2626;
  background: #c89191;
  padding: 8px 12px;
  border-radius: 8px;
  margin: 8px 0;
}
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
.loading {
  font-size: 14px;
  color: #475569;
}
</style>