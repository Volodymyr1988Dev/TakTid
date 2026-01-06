<script setup lang="ts">
import { computed, reactive } from 'vue'
import dayjs from 'dayjs'
import { timeKind, type TimeKind } from '../../types/timeKind.enum'

interface EntryFormState {
  from: string
  to: string
  breakMinutes: number
  kind: TimeKind
  extraDescription: string
}

const form = reactive<EntryFormState>({
  from: '07:00',
  to: '16:00',
  breakMinutes: 60,
  kind: timeKind.WORK,
  extraDescription: '',
})

const totalHours = computed(() => {
  const start = dayjs(`2020-01-01 ${form.from}`)
  const end = dayjs(`2020-01-01 ${form.to}`)

  const minutes =
    end.diff(start, 'minute') - form.breakMinutes

  return Math.max(0, minutes / 60)
})
</script>

<template>
  <div>
    <input type="time" v-model="form.from" />
    <input type="time" v-model="form.to" />

    <input
      type="number"
      v-model.number="form.breakMinutes"
      placeholder="Break (minutes)"
    />

    <p>Total: {{ totalHours }} h</p>

    <div v-if="form.kind === timeKind.EXTRA">
      <textarea
        v-model="form.extraDescription"
        placeholder="Extra work description"
      />
    </div>
  </div>
</template>