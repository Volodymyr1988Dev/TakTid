<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store'
import { useProjectAssignmentStore } from '../../../stores/projectAssignment.store'

/* ================= PROPS ================= */
const props = defineProps<{
  date: string
  preset?: TimeSuggestion | null
  entry?: TimeEntry | null
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
    start.value = e.startTime ?? '08:00'
    end.value = e.endTime ?? '17:00'
    breakMinutes.value = e.breakMinutes ?? 30
    kind.value = e.type
    comment.value = e.comment ?? ''
    projectId.value = e.projectId ?? null
    mode.value = 'WORK'
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

  const worked = endMin - startMin - breakMinutes.value
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

async function remove() {
  if (!props.entry) return
  if (!confirm('Delete this entry?')) return

  await timeStore.remove(props.entry.id)
  emit('saved')
}
/* ================= SAVE ================= */
async function save() {
  if (isSaving.value) return
  isSaving.value = true
  try{
    if (isAbsence.value) {
    const payload = {
      date: props.date,
      type: kind.value,
      startTime: '08:00',
      endTime: '17:00',
      breakMinutes: 60,
      comment: comment.value,
    }

    props.entry
      ? await timeStore.update(props.entry.id, payload)
      : await timeStore.add(payload)

    emit('saved')
    return
  }
  /* -------- WORK / MEETING -------- */
  if (!projectId.value) {
      alert('Project is required')
      return
    }

  //const extraWork = ref('')
  if (mode.value === 'WORK') {
    const payload ={
      date: props.date,
      type: kind.value,
      projectId: projectId.value,
      startTime: start.value,
      endTime: end.value,
      breakMinutes: breakMinutes.value,
      comment: comment.value,
    }

  props.entry
    ? await timeStore.update(props.entry.id, payload)
    : await timeStore.add(payload)
  }
  if (mode.value === 'EXTRA') {
      await assignmentStore.create({
        projectId: projectId.value,
        date: props.date,
        comment: comment.value,
        //text: extraText.value,
      })
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