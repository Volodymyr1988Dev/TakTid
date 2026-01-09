<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { TimeKind } from '../../../types/timeKind.enum'
import type { TimeEntry } from '../../../types/TimeEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'
import { useTimeEntryStore } from '../../../stores/timeEntry.store2'

const props = defineProps<{
  date: string
  preset?: TimeSuggestion | null
  entry?: TimeEntry | null
}>()

const emit = defineEmits(['close'])
const store = useTimeEntryStore()

const start = ref('08:00')
const end = ref('17:00')
const breakMinutes = ref(60)
const kind = ref<TimeKind>(TimeKind.WORK)
const comment = ref('')
const projectId = ref<string | null>(null)

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

function toMin(t: string): number {
  const parts = t.split(':')
  const h = Number(parts[0] ?? 0)
  const m = Number(parts[1] ?? 0)
  return h * 60 + m
}

const hours = computed(() =>
  Math.max((toMin(end.value) - toMin(start.value) - breakMinutes.value) / 60, 0),
)
const isWork = computed(() => kind.value === TimeKind.WORK)
const isAbsence = computed(() => 
kind.value === TimeKind.SICK ||
kind.value === TimeKind.VAB ||
kind.value === TimeKind.VACATION
)
const isMeeting = computed(() => kind.value === TimeKind.MEETING)
async function save() {
  if (
    kind.value === TimeKind.SICK ||
    kind.value === TimeKind.VAB ||
    kind.value === TimeKind.VACATION ||
    kind.value === TimeKind.MEETING
  ) {
    if (props.entry) {
      await store.update(props.entry.id, {
        type: kind.value,
        comment: comment.value,
        hours: 8,
      })
    } else {
      await store.add({
        date: props.date,
        hours: 8,
        type: kind.value,
        comment: comment.value,
      })
    }
    emit('close')
    return
  }

  if (props.entry) {
    await store.update(props.entry.id, {
      hours: hours.value,
      breakMinutes: breakMinutes.value,
      comment: comment.value,
    })
  } else {
    await store.add({
      date: props.date,
      startTime: start.value,
      endTime: end.value,
      hours: hours.value,
      breakMinutes: breakMinutes.value,
      type: kind.value,
      comment: comment.value,
      projectId: projectId.value!,
    })
  }

  emit('close')
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <h3>Register time</h3>

      <p><strong>Date:</strong> {{ date }}</p>

      <!-- ================= WORK ================= -->
      <div v-if="isWork">
        <label>
          Start
          <input type="time" v-model="start" :disabled="!!entry" />
        </label>

        <label>
          End
          <input type="time" v-model="end" :disabled="!!entry" />
        </label>

        <label>
          Break (minutes)
          <input type="number" v-model.number="breakMinutes" min="0" step="5" />
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
      <textarea
        v-model="comment"
        placeholder="Comment"
      />

      <div class="actions">
        <button @click="emit('close')">Cancel</button>
        <button class="primary" @click="save">Save</button>
      </div>
    </div>
  </div>
</template>