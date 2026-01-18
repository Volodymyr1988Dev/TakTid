<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
//import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../../stores/projectAssignment.store'
import type { DayEntry,  WorkDayEntry, ExtraDayEntry, } from '../../../types/DayEntry.type'

/* ================= PROPS ================= */
const props = defineProps<{
  date: string
  preset?: TimeSuggestion | null
  //entry?: TimeEntry | null
  entry?: DayEntry  | null
}>()

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'saved'): void
}>()
const timeStore = useTimeEntryStore()
//const store = useTimeEntryStore()
const assignmentStore = useProjectAssignmentStore()
/* ================= STATE ================= */
const start = ref('08:00')
const end = ref('17:00')
const breakMinutes = ref(60)
const kind = ref<TimeKind>(TimeKind.WORK)
const comment = ref('')
const projectId = ref<string | null>(null)

const mode = ref<'WORK' | 'EXTRA'>('WORK')
//const extraText = ref('')
//const extraWork = ref('')
/* ================= PRE-FILL FROM ENTRY ================= */
watch(
  () => props.entry,
  e => {
    if (!e) return
    //if (e.kind === 'WORK') {
    if (isWorkEntry(e)) {
      mode.value = 'WORK'
      kind.value = e.type
      start.value = e.startTime
      end.value = e.endTime
      breakMinutes.value = e.breakMinutes ?? 0
      projectId.value = e.projectId ?? null
      comment.value = e.comment ?? ''
    } //else {
    if (isExtraEntry(e)) {
      mode.value = 'EXTRA'
      start.value = e.startTime ?? '08:00'
      end.value = e.endTime ?? '17:00'
      breakMinutes.value = e.breakMinutes ?? 60
      projectId.value = e.projectId
      comment.value = e.comment ?? ''
    }
    else {
      console.warn('Unknown entry kind', e)
    }
  },
  { immediate: true },
)

/* ================= PRE-FILL FROM PRESET =================*/ 

watch(
  () => props.preset,
  p => {
    if (!p) return
    kind.value = p.type
    breakMinutes.value = p.breakMinutes ?? 60
    projectId.value = p.projectId ?? null
    //if (!isAbsence.value) {
    //  mode.value = p.type === TimeKind.EXTRA ? 'EXTRA' : 'WORK'
    //}
  },
  { immediate: true },
)

/* ================= HELPERS ================= */
function isWorkEntry(e: DayEntry): e is WorkDayEntry {
  return e.kind === 'WORK'
}

function isExtraEntry(e: DayEntry): e is ExtraDayEntry {
  return e.kind === 'EXTRA'
}

function toMinutes(t: string): number {
  const parts = t.split(':')
  if (parts.length !== 2) return 0

  const h = Number(parts[0])
  const m = Number(parts[1])

  if (Number.isNaN(h) || Number.isNaN(m)) return 0

  return h * 60 + m
}

/* ================= COMPUTED ================= */
const calculatedHours = computed(() => {
  if (!start.value || !end.value) return '0.00'

  let startMin = toMinutes(start.value)
  let endMin = toMinutes(end.value)

  // 🌙 night shift support
  if (endMin <= startMin) {
    endMin += 24 * 60
  }

  const worked = endMin - startMin - normalizedBreakMinutes.value
  if (worked <= 0) return '0.00'

  //return (worked / 60).toFixed(2)
  return worked > 0 ? (worked / 60).toFixed(2) : '0.00'
})

const isEdit = computed(() => !!props.entry)
//const isWork = computed(() => kind.value === TimeKind.WORK)
//const isMeeting = computed(() => kind.value === TimeKind.MEETING)

const isAbsence = computed(() =>
  kind.value === TimeKind.SICK ||
  kind.value === TimeKind.VAB ||
  kind.value === TimeKind.VACATION,
)
const isSaving = ref(false)
const isExtra = computed(() => mode.value === 'EXTRA')

const normalizedBreakMinutes = computed(() => {
  const value = Number(breakMinutes.value)
  return Number.isFinite(value) && value >= 0 ? value : 0
})

async function remove() {
  if (!props.entry) return
  if (!confirm('Delete this entry?')) return
  if (isExtraEntry(props.entry)) {
    await assignmentStore.remove(props.entry.id)
  } else if (isWorkEntry(props.entry)) {
    await timeStore.remove(props.entry.id)
  }
  //props.entry.kind === 'EXTRA'
  //  ? await assignmentStore.remove(props.entry.id)
  //  : await timeStore.remove(props.entry.id)
  //if (props.entry.kind === 'EXTRA') {
  //  await assignmentStore.remove(props.entry.id)
  //} else {
  //  await timeStore.remove(props.entry.id)
  //}
  emit('saved')
}
/* ================= SAVE ================= */
async function save() {
  if (isSaving.value) return
  isSaving.value = true
  try {
    if (isAbsence.value) {
      const payload = {
        date: props.date,
        type: kind.value,
        startTime: '08:00',
        endTime: '17:00',
        breakMinutes: 60,
        comment: comment.value,
      }

      props.entry?.kind === 'WORK'
        ? await timeStore.update(props.entry.id, payload)
        : await timeStore.add(payload)

      emit('saved')
      return
    }

    if (!projectId.value) {
      alert('Project is required')
      return
    }

    if (isExtra.value) {
      props.entry?.kind === 'EXTRA'
        ? await assignmentStore.update(props.entry.id, {
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: normalizedBreakMinutes.value,
          })
        : await assignmentStore.create({
            projectId: projectId.value,
            date: props.date,
            comment: comment.value,
            startTime: start.value,
            endTime: end.value,
            breakMinutes: normalizedBreakMinutes.value,
          })
    } else {
      const payload = {
        date: props.date,
        type: kind.value,
        projectId: projectId.value,
        startTime: start.value,
        endTime: end.value,
        breakMinutes: normalizedBreakMinutes.value,
        comment: comment.value,
      }

      props.entry?.kind === 'WORK'
        ? await timeStore.update(props.entry.id, payload)
        : await timeStore.add(payload)
    }
  emit('saved')
  } catch{
    alert('Something went wrong during saving')
  }
  finally{
    isSaving.value = false
  }
  /* -------- ABSENCE -------- */
  
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
      <h3>{{ isEdit ? 'Edit time' : 'Register time' }}</h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <!-- WORK / MEETING -->
      <!-- MODE -->
      <div v-if="!isAbsence">
        <select v-model="mode">
          <option value="WORK">
            Work
          </option>
          <option value="EXTRA">
            Extra work
          </option>
        </select>
      </div>
      <!-- WORK / EXTRA -->
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
        <p>{{ calculatedHours }} h</p>
      </div>

      <!-- EXTRA 
      <textarea
        v-if="mode === 'EXTRA'"
        v-model="extraText"
        placeholder="Describe extra work"
      /> -->

      <!-- ABSENCE -->
      <p v-if="isAbsence">
        Absence: {{ kind }}
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
          @click="save"
        >
          Save
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-header {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 8px;
}

.back-btn {
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
  color: #374151;
}

.extra-work {
  margin-top: 8px;
  min-height: 60px;
}
</style>