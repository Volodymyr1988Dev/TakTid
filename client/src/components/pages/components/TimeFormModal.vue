<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store2'

/* ================= PROPS ================= */
const props = defineProps<{
  date: string
  preset?: TimeSuggestion | null
  entry?: TimeEntry | null
}>()

//const emit = defineEmits<{(e: 'close'): void}>()
const emit = defineEmits(['close', 'saved'])
const store = useTimeEntryStore()

/* ================= STATE ================= */
const start = ref('08:00')
const end = ref('17:00')
const breakMinutes = ref(60)
const kind = ref<TimeKind>(TimeKind.WORK)
const comment = ref('')
const projectId = ref<string | null>(null)
//const title = ref(props.entry?.title ?? props.preset?.title ?? '')

/* ================= PRE-FILL FROM ENTRY ================= */
watch(
  () => props.entry,
  entry => {
    if (!entry) return

    start.value = entry.startTime ?? '08:00'
    end.value = entry.endTime ?? '17:00'
    breakMinutes.value = entry.breakMinutes ?? 0
    kind.value = entry.type
    comment.value = entry.comment ?? ''
    projectId.value = entry.projectId ?? null
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
function toMin(t: string): number {
  const [h, m] = t.split(':').map(Number)
  return (h ?? 0) * 60 + (m ?? 0)
}

/* ================= COMPUTED ================= */
const hours = computed(() => {
  const total =
    toMin(end.value) -
    toMin(start.value) -
    breakMinutes.value

  return Math.max(total / 60, 0)
})

const isEdit = computed(() => !!props.entry)
const isWork = computed(() => kind.value === TimeKind.WORK)

const ABSENCE_KINDS = [
  TimeKind.SICK,
  TimeKind.VAB,
  TimeKind.VACATION,
  TimeKind.MEETING,
] as const

const isAbsence = computed(() =>
  ABSENCE_KINDS.includes(kind.value as any),
)

const isMeeting = computed(() => kind.value === TimeKind.MEETING)

/* ================= SAVE ================= */
async function save() {
  /* -------- ABSENCE / MEETING -------- */
  if (isAbsence.value) {
    const payload = {
      type: kind.value,
      comment: comment.value,
      hours: 8,
    }

    if (props.entry) {
      await store.update(props.entry.id, payload)
    } else {
      await store.add({
        date: props.date,
        ...payload,
      })
    }

    emit('close')
    return
  }

  /* -------- WORK -------- */
  if (!projectId.value) {
    console.warn('Project is required')
    return
  }

  const payload = {
    startTime: start.value,
    endTime: end.value,
    breakMinutes: breakMinutes.value,
    hours: hours.value,
    comment: comment.value,
  }

  if (props.entry) {
    await store.update(props.entry.id, payload)
  } else {
    await store.add({
      date: props.date,
      type: TimeKind.WORK,
      projectId: projectId.value,
      ...payload,
    })
  }

  emit('close')
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <h3>{{ isEdit ? 'Edit time' : 'Register time' }}</h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <!-- ================= WORK ================= -->
      <div v-if="isWork">
        <label>
          Start
          <input type="time" v-model="start" />
        </label>

        <label>
          End
          <input type="time" v-model="end" />
        </label>

        <label>
          Break (minutes)
          <input
            type="number"
            min="0"
            step="5"
            v-model.number="breakMinutes"
          />
        </label>

        <p><strong>Hours:</strong> {{ hours.toFixed(2) }}</p>
      </div>

      <!-- ================= MEETING ================= -->
      <div v-else-if="isMeeting">
        <p>Meeting / internal time</p>
      </div>

      <!-- ================= ABSENCE ================= -->
      <div v-else-if="isAbsence">
        <p>Absence: {{ kind }}</p>
      </div>

      <!-- ================= COMMENT ================= -->
      <textarea v-model="comment" placeholder="Comment" />

      <div class="actions">
        <button @click="emit('close')">Cancel</button>
        <button class="primary" @click="save">Save</button>
      </div>
    </div>
  </div>
</template>