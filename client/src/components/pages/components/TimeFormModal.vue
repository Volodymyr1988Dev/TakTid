<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm } from '../../composables/useAbsenceEntryForm'
import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { EntryState } from '../../../types/EntryState'
import type { TimeBasedForm } from '../../../types/TimeBasedForm'
import { useProjectStore } from '../../../stores/project.store'

/* =======================
   PROPS + EMITS
======================= */
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

/* =======================
   DEBUG LIFECYCLE
======================= */
console.log('[Modal] setup start')

onMounted(() => {
  console.log('[Modal] mounted')
})

/* =======================
   PROJECT STORE
======================= */
const projectStore = useProjectStore()

type EntryMode = 'WORK' | 'EXTRA' | 'ABSENCE'

const isTimeMode = computed(
  () => mode.value === 'WORK' || mode.value === 'EXTRA'
)
//const projectId = computed<string | null>(() => {
//  const id = projectStore.selectedProject?.id ?? null
//  console.log('[Modal] projectId computed:', id)
//  return id
//})
const projectId = computed<string | null>(() =>
  isTimeMode.value
    ? projectStore.selectedProject?.id ?? null
    : null
)

const project = computed(() => projectStore.selectedProject)

/* =======================
   STATE
======================= */
const state = ref<EntryState>(
  props.entry?.kind ?? EntryState.WORK
)

console.log('[Modal] initial state:', state.value)

/* =======================
   FORMS
======================= */
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

/* =======================
   MODE (WORK / EXTRA)
======================= */
/*
const mode = computed<'WORK' | 'EXTRA'>({
  get: () => {
    const m = state.value === EntryState.EXTRA ? 'EXTRA' : 'WORK'
    console.log('[Modal] mode get:', m)
    return m
  },
  set: v => {
    console.log('[Modal] mode set:', v)
    state.value = v === 'EXTRA'
      ? EntryState.EXTRA
      : EntryState.WORK
  },
})
  */
//const mode = ref<EntryMode>(
//  props.entry?.kind ?? 'WORK'
//)
const mode = ref<EntryMode>(
  props.entry?.kind === EntryState.EXTRA
    ? 'EXTRA'
    : props.entry?.kind === EntryState.ABSENCE
      ? 'ABSENCE'
      : 'WORK'
)
/* =======================
   ACTIVE TIME FORM (SAFE)
======================= */
/*
const activeTimeForm = computed<TimeBasedForm | null>(() => {
  console.log('[Modal] compute activeTimeForm, state:', state.value)

  if (state.value === EntryState.WORK) return workForm
  if (state.value === EntryState.EXTRA) return extraForm
  return null
})
*/
/* =======================
   ACTIVE FORM (FOR SAVE / DELETE)
======================= */
/*
const activeForm = computed(() => {
  console.log('[Modal] compute activeForm, state:', state.value)

  if (state.value === EntryState.ABSENCE) return absenceForm
  return activeTimeForm.value
})
*/
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
/* =======================
   DERIVED STATE
======================= */

/*
const projectMissing = computed(() => {
  const missing =
    (state.value === EntryState.WORK || state.value === EntryState.EXTRA) &&
    !projectId.value

  console.log('[Modal] projectMissing:', missing)
  return missing
})
*/
const projectMissing = computed(() =>
  isTimeMode.value && !projectId.value
)
const isSaving = computed(() => {
  const saving = Boolean(activeForm.value?.isSaving?.value)
  console.log('[Modal] isSaving:', saving)
  return saving
})

/* =======================
   MODELS
======================= */
/*
const startModel = computed<string>({
  get: () => activeTimeForm.value?.start.value ?? '',
  set: v => {
    if (activeTimeForm.value) {
      console.log('[Modal] start set:', v)
      activeTimeForm.value.start.value = v
    }
  },
})

const endModel = computed<string>({
  get: () => activeTimeForm.value?.end.value ?? '',
  set: v => {
    if (activeTimeForm.value) {
      console.log('[Modal] end set:', v)
      activeTimeForm.value.end.value = v
    }
  },
})

const breakMinutesModel = computed<number>({
  get: () => activeTimeForm.value?.breakMinutes.value ?? 0,
  set: v => {
    if (activeTimeForm.value) {
      console.log('[Modal] breakMinutes set:', v)
      activeTimeForm.value.breakMinutes.value = v
    }
  },
})
*/
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
    //state.value === EntryState.ABSENCE
    mode.value === 'ABSENCE'
      ? absenceForm.comment.value
      //: activeTimeForm.value?.comment.value ?? '',
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
  //activeTimeForm.value?.images?.previews.value ?? []
  isTimeMode.value
    ? (activeForm.value as TimeBasedForm).images.previews.value
    : []
)

/* =======================
   WATCHERS (DEBUG)
======================= */
watch(state, v => {
  console.log('[Modal] state changed:', v)
})

//watch(() => props.entry, v => {
//  console.log('[Modal] props.entry changed:', v)
//})
watch(
  () => props.entry,
  e => {
    if (!e) return
    //if (e?.kind === EntryState.EXTRA && e.projectId) {
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

    console.log('[Modal] preset received:', preset)

    if (
      preset.type === 'SICK' ||
      preset.type === 'VAB' ||
      preset.type === 'VACATION'
    ) {
      //state.value = EntryState.ABSENCE
      mode.value = 'ABSENCE'
      absenceForm.kind.value = preset.type
    }
  },
  { immediate: true },
)

/* =======================
   ACTIONS
======================= */
async function onSave() {
  console.log('[Modal] SAVE CLICK')
  console.log('[Modal] state:', state.value)
  console.log('[Modal] activeForm:', activeForm.value)
  console.log('[ExtraForm] projectId:', projectId.value)
  
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
    console.log('[Modal] save result:', entry)

    if (entry) emit('saved', entry)
  } catch (e) {
    console.error('[Modal] SAVE FAILED', e)
  }
}

async function onDelete() {
  console.log('[Modal] DELETE CLICK')

  try {
    await activeForm.value?.remove()
    emit('deleted')
  } catch (e) {
    console.error('[Modal] DELETE FAILED', e)
  }
}
/*
<h3>
  {{
    state === EntryState.ABSENCE
      ? `Register absence (${absenceForm.kind})`
      : activeTimeForm?.isEdit
        ? 'Edit time'
        : 'Register time'
  }}
</h3>

<h3>
        {{
          state === EntryState.ABSENCE || activeTimeForm?.isEdit
            ? 'Edit time'
            : 'Register time'
        }}
      </h3>
*/
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
        v-if="project" 
        class="project-pill"
      >
        <p 
          v-if="projectMissing" 
          class="error"
        >
          Please select a project
        </p>
        <strong>{{ project.city }}</strong>
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
        <button
          v-if="activeForm?.isEdit || mode === 'ABSENCE'"
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
.error {
  color: #dc2626;
  background: #fee2e2;
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
</style>