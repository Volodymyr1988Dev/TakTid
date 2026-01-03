<script setup lang="ts">
import { ref, watch } from 'vue'
import { Dayjs } from 'dayjs'
import {
  createTimeEntry,
  updateTimeEntry,
} from '../../api/TimeEntry'
import type { TimeEntry } from './../../types/TimeEntry.type'
const props = defineProps<{
  day: Dayjs
  entry?: TimeEntry
}>()

const emit = defineEmits(['close', 'saved'])

const hours = ref<number>(props.entry?.hours ?? 0)
const comment = ref(props.entry?.comment ?? '')

watch(
  () => props.entry,
  e => {
    hours.value = e?.hours ?? 0
    comment.value = e?.comment ?? ''
  },
)

async function save() {
  if (props.entry) {
    await updateTimeEntry(props.entry.id, {
      hours: hours.value,
      comment: comment.value,
    })
  } else {
    await createTimeEntry({
      date: props.day.format('YYYY-MM-DD'),
      hours: hours.value,
      comment: comment.value,
    })
  }

  emit('saved')
  emit('close')
}
</script>

<template>
  <div class="overlay" @click.self="$emit('close')">
    <div class="modal">
      <h3>{{ day.format('D MMMM') }}</h3>

      <input type="number" v-model="hours" min="0" />
      <textarea v-model="comment" placeholder="Comment" />

      <button @click="save">Save</button>
    </div>
  </div>
</template>

<style scoped src="../../styles/Modal.css"></style>