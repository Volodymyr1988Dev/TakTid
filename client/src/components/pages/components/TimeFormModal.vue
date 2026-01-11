<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store'

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
const store = useTimeEntryStore()

/* ================= STATE ================= */
const start = ref('08:00')
const end = ref('17:00')
const breakMinutes = ref(60)
const kind = ref<TimeKind>(TimeKind.WORK)
const comment = ref('')
const projectId = ref<string | null>(null)

/* ================= PRE-FILL FROM ENTRY ================= */
watch(
  () => props.entry,
  e => {
    if (!e) return
    start.value = e.startTime ?? '08:00'
    end.value = e.endTime ?? '17:00'
    breakMinutes.value = e.breakMinutes ?? 0
    kind.value = e.type
    comment.value = e.comment ?? ''
    projectId.value = e.projectId ?? null
  },
  { immediate: true },
)

/* ================= PRE-FILL FROM PRESET ================= */
watch(
  () => props.preset,
  p => {
    if (!p) return
    kind.value = p.type
    breakMinutes.value = p.breakMinutes ?? 60
    projectId.value = p.projectId ?? null
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

  return (worked / 60).toFixed(2)
})

const isEdit = computed(() => !!props.entry)
const isWork = computed(() => kind.value === TimeKind.WORK)
const isMeeting = computed(() => kind.value === TimeKind.MEETING)

const isAbsence = computed(() =>
  kind.value === TimeKind.SICK ||
  kind.value === TimeKind.VAB ||
  kind.value === TimeKind.VACATION,
)
const isSaving = ref(false)

async function remove() {
  if (!props.entry) return
  if (!confirm('Delete this entry?')) return

  await store.remove(props.entry.id)
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
      ? await store.update(props.entry.id, payload)
      : await store.add(payload)

    emit('saved')
    return
  }

  /* -------- WORK / MEETING -------- */
  if (isWork.value && !projectId.value) {
    alert('Project is required')
    return
  }

  const payload = {
    date: props.date,
    type: kind.value,
    ...(isWork.value && projectId.value ? { projectId: projectId.value } : {}),
    startTime: start.value,
    endTime: end.value,
    breakMinutes: breakMinutes.value,
    comment: comment.value,
  }

  props.entry
    ? await store.update(props.entry.id, payload)
    : await store.add(payload)

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
      <h3>{{ isEdit ? 'Edit time' : 'Register time' }}</h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <!-- WORK / MEETING -->
      <div v-if="isWork || isMeeting">
        <label>
          Start
          <input
            v-model="start"
            type="time"
          >
        </label>

        <label>
          End
          <input
            v-model="end"
            type="time"
          >
        </label>

        <label>
          Break (minutes)
          <input
            v-model.number="breakMinutes"
            type="number"
            min="0"
            step="5"
          >
        </label>

        <p><strong>Hours:</strong> {{ calculatedHours }} h</p>
      </div>

      <!-- ABSENCE -->
      <div v-else-if="isAbsence">
        <p>Absence: {{ kind }}</p>
      </div>

      <textarea
        v-model="comment"
        placeholder="Comment"
      />

      <div class="actions">
        <button @click="emit('cancel')">
          Cancel
        </button>
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