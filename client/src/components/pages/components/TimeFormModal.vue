<script setup lang="ts">
import { computed, ref, watch } from 'vue'
//import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
//import { useProjectSelector } from '../../composables/useProjectSelector'
//import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
import { useExtraEntryForm } from '../../composables/useExtraEntryForm'
import { useAbsenceEntryForm} from '../../composables/useAbsenceEntryForm'
import { useWorkEntryForm } from '../../composables/useWorkEntryForm'
//import { TimeKind } from '../../../types/timeKind.enum'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { EntryState } from '../../../types/EntryState';
import type { TimeBasedForm } from '../../../types/TimeBasedForm'
import { useProjectStore } from '../../../stores/project.store'
//import { loadProjects } from '../../composables/useProjectLoader'
//import { EntryState } from '../../../types/EntryState';
//import { computed } from 'vue'

const props = defineProps<{
  date: string
  entry?: DayEntry  | null
  preset?: TimeSuggestion | null
}>()
/*
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
*/
//const form = useTimeEntryForm(props)
//const emit = defineEmits(['saved', 'cancel'])
const emit = defineEmits<{
  (e: 'saved', entry: DayEntry): void
  (e: 'cancel'): void
  (e: 'deleted'): void
}>()
//const projectSelector = useProjectSelector()
const projectStore = useProjectStore() 

//const timeForm = useTimeEntryForm({
//  ...props,
//  projectId: projectSelector.projectId,
//})
//const projectId = computed(() => projectStore.projectId)
const projectId = ref<string | null>(projectStore.projectId)
const project = computed(() => projectStore.selectedProject)

const workForm = useWorkEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.WORK ? props.entry : null,
  projectId,//: projectSelector.projectId,
})

const absenceForm = useAbsenceEntryForm({
  date: props.date,
  entry: props.entry?.kind === EntryState.ABSENCE ? props.entry : null,
})

const extraForm = useExtraEntryForm({
  date: props.date,
  //entry: props.entry,
  entry: props.entry?.kind === EntryState.EXTRA ? props.entry : null,
  projectId,//: projectSelector.projectId,
})

const mode = ref<'WORK' | 'EXTRA'>(
  props.entry?.kind === EntryState.EXTRA ? 'EXTRA' : 'WORK',
)

//const isDirty = ref(false)
//const isHydrating = ref(false)

//const state = computed<EntryState>(() => {
//  if (absenceForm.kind.value) return EntryState.ABSENCE
//  if (mode.value === 'EXTRA') return EntryState.EXTRA
//  return EntryState.WORK
//})
const isAbsence = computed(() =>
  ['SICK', 'VAB', 'VACATION'].includes(absenceForm.kind.value)
)

//const state = computed<EntryState>(() => {
  //if (isAbsence.value) return EntryState.ABSENCE
  //if (mode.value === 'EXTRA') return EntryState.EXTRA
  //return EntryState.WORK
//})
const state = ref<EntryState>(
  isAbsence.value
    ? EntryState.ABSENCE
    : mode.value === 'EXTRA'
      ? EntryState.EXTRA
      : EntryState.WORK,
)
const isSaving = computed<boolean>(() => Boolean(activeForm.value?.isSaving) ?? false)

//const state = ref<EntryState>(
//  props.entry?.kind ?? EntryState.WORK,
//)
//function hasProjectId(e: DayEntry): e is DayEntry & { projectId: string } {
//  return e.kind === 'WORK' || e.kind === 'EXTRA'
//}
watch(
  () => projectStore.projectId,
  v => {
    console.log('[Modal] projectId changed:', v)
  },
  { immediate: true }
)
watch(
    () => absenceForm.kind.value,
    v => {
        if (v) state.value = EntryState.ABSENCE
    }
    )
watch(mode, v => {
  if (state.value === EntryState.ABSENCE) return
  state.value = v === 'EXTRA' ? EntryState.EXTRA : EntryState.WORK
})
/*
watch(
  [start, end, breakMinutes],
  () => {
    if (isHydrating.value) return
    if (!props.entry) return

    //const same =
    //  normalizeTime(start.value) === normalizeTime(props.entry.startTime) &&
    //  normalizeTime(end.value) === normalizeTime(props.entry.endTime) &&
    //  normalizedBreakMinutes.value === props.entry.breakMinutes

    //isDirty.value = !same
    isDirty.value = true
  }
)
watch(
  () => props.entry,
  async (e) => {
    isHydrating.value = true
    isDirty.value = false
    if (!e) {
      isHydrating.value = false
      return
    }
    //if (e.kind === 'WORK') {
    //if (isWorkEntry(e)) {
    //isInitialized.value = false
    if (e.kind === 'WORK') {
      mode.value = 'WORK'
      kind.value = e.type
      //start.value = e.startTime
      start.value = normalizeTime(e.startTime)
      //end.value = e.endTime
      end.value = normalizeTime(e.endTime)
      breakMinutes.value = e.breakMinutes ?? 0
      projectId.value = e.projectId
      comment.value = e.comment ?? ''
      //if (e.projectId) {
      //  await imageStore.load(e.projectId)
      //}
      if (hasProjectId(e)) {
        projectId.value = e.projectId
        //await imageStore.load(e.projectId)
      }
    } //else {
    //if (isExtraEntry(e)) {
    else if (e.kind === 'EXTRA') {
      mode.value = 'EXTRA'
      //start.value = e.startTime ?? '08:00'
      start.value = normalizeTime(e.startTime) ?? '08:00'
      //end.value = e.endTime ?? '17:00'
      end.value = normalizeTime(e.endTime) ?? '17:00'
      breakMinutes.value = e.breakMinutes ?? 60
      projectId.value = e.projectId
      comment.value = e.comment ?? ''
      if (hasProjectId(e)) {
        projectId.value = e.projectId
        //await imageStore.load(e.projectId)
      }
    }
    else if (e.kind === 'ABSENCE') {
      mode.value = 'WORK'
      kind.value = e.type
      comment.value = e.comment ?? ''
    }
    else {
      console.warn('Unknown entry kind', e)
    }
    isHydrating.value = false
    //isInitialized.value = true
  },
  { immediate: true },
)
//function activateAbsence() {
//  state.value = EntryState.ABSENCE
//}

watch(
  () => absenceForm.kind.value,
  () => {
    state.value = EntryState.ABSENCE
  }
)
  */
const projectMissing = computed(() =>
  (state.value === EntryState.WORK || state.value === EntryState.EXTRA)
  && !projectId.value //!projectSelector.projectId.value
)
const activeForm = computed(() =>
  state.value === EntryState.ABSENCE
    ? absenceForm
    : activeTimeForm.value!
//}
)

/*
const activeTimeForm = computed<TimeBasedForm | null>(() => {
  if (state.value === EntryState.WORK) return workForm
  if (state.value === EntryState.EXTRA) return extraForm
  return null
})
*/
//const activeTimeForm = ref<TimeBasedForm | null>(
//  state.value === EntryState.WORK ? workForm : extraForm
//)

const activeTimeForm = computed<TimeBasedForm | null>(() => {
  if (state.value === EntryState.WORK) return workForm
  if (state.value === EntryState.EXTRA) return extraForm
  return null
})
//watch(state, (v) => {
//  if (v === EntryState.WORK) activeTimeForm.value = workForm
//  else if (v === EntryState.EXTRA) activeTimeForm.value = extraForm
//  else activeTimeForm.value = null
//})
const imagePreviews = computed<string[]>(() =>
  activeTimeForm.value?.images?.previews.value ?? []
)

const startModel = computed<string>({
  get: () => activeTimeForm.value?.start.value ?? '',
  set: v => {
    if (activeTimeForm.value) {
      activeTimeForm.value.start.value = v
    }
  },
})

const endModel = computed<string>({
  get: () => activeTimeForm.value?.end.value ?? '',
  set: v => { if (activeTimeForm.value) activeTimeForm.value.end.value = v }
  //set: v => activeTimeForm.value && (activeTimeForm.value.end = v),
})

const breakMinutesModel = computed<number>({
  get: () => activeTimeForm.value?.breakMinutes.value ?? 0,
  set: v => { if (activeTimeForm.value) activeTimeForm.value.breakMinutes.value = v }
  //set: v => activeTimeForm.value && (activeTimeForm.value.breakMinutes = v),
})
/*
const commentModel = computed<string>({
  get: () => {
    if (state.value === EntryState.ABSENCE) {
      return absenceForm.comment.value
    }
    return activeTimeForm.value?.comment ?? ''
  },
  set: (v: string) => {
    if (state.value === EntryState.ABSENCE) {
      absenceForm.comment.value = v
    } else if (activeTimeForm.value) {
      activeTimeForm.value.comment = v
    }
  },
})
  */
 const commentModel = computed<string>({
  get: () =>
    state.value === EntryState.ABSENCE
      ? absenceForm.comment.value
      : activeTimeForm.value?.comment.value ?? '',
  set: v => {
    if (state.value === EntryState.ABSENCE) {
      absenceForm.comment.value = v
    } else if (activeTimeForm.value) {
      activeTimeForm.value.comment.value = v
    }
  },
})
/*
const isTimeBased = computed(
  () => state.value !== EntryState.ABSENCE,
)

const start = computed({
  get: () =>
    isTimeBased.value ? activeForm.value.start : '',
  set: v => {
    if (isTimeBased.value) activeForm.value.start = v
  },
})

const end = computed({
  get: () =>
    isTimeBased.value ? activeForm.value.end : '',
  set: v => {
    if (isTimeBased.value) activeForm.value.end = v
  },
})

const breakMinutes = computed({
  get: () =>
    isTimeBased.value ? activeForm.value.breakMinutes : 0,
  set: v => {
    if (isTimeBased.value) activeForm.value.breakMinutes = v
  },
})

const images = computed(() =>
  isTimeBased.value ? activeForm.value.images : null,
)


const calculatedHours = computed(() =>
  isTimeBased.value ? activeForm.value.calculatedHours : '8',
)
  */
async function onSave() {
  if (projectMissing.value) {
    throw new Error('requires projectId')
  }
  //let entry
  //const entry = await save()
  //if (entry) emit('saved', entry)
  // let entry
  
  //if (state.value === EntryState.EXTRA && !projectId.value) {
  //      throw new Error('EXTRA entry requires projectId')
  //  }
  //const entry = //await activeForm.value.save()
  //state.value === EntryState.ABSENCE
  //    ? await absenceForm.save()
  //    : await activeTimeForm.value!.save()

  const entry = state.value === EntryState.ABSENCE
    ? await absenceForm.save()
    : await activeTimeForm.value!.save()

  if (entry) emit('saved', entry)//return
  //state.value === EntryState.EXTRA
  //? await extraForm.save()
  //: await timeForm.save()
  //if (state.value === EntryState.EXTRA) {
  //  entry = await extraForm.save()
  //} else {
  //  entry = await timeForm.save()
  //}

  //if (entry) emit('saved', entry)
  //emit ('saved', entry)
}
async function onDelete() {
  //if (state.value === EntryState.WORK) {
  //  await workForm.remove()
  //} else if (state.value === EntryState.ABSENCE) {
  //  await absenceForm.remove()
  await activeForm.value?.remove()
  //await activeForm.value.remove()
  //}

  emit('deleted')
}
//const form = useTimeEntryForm(props)
//activeTimeForm.images.previews[i] ?? undefined
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

      <h3>{{ activeForm.isEdit ? 'Edit time' : 'Register time' }}</h3>
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
        <strong>{{ project.city }}  </strong>
        <small>{{ project.address }}</small>
      </div>
      <select 
        v-if="state !== EntryState.ABSENCE" 
        v-model="mode"
      >
        <option value="WORK">
          Work
        </option>
        <option value="EXTRA">
          Extra work
        </option>
      </select>
      <div v-if="activeTimeForm">
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
          @change="activeTimeForm.images.onSelect" 
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

        <p>{{ activeTimeForm.calculatedHours }} h</p>
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
          v-if="activeForm?.isEdit || state === EntryState.ABSENCE" 
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