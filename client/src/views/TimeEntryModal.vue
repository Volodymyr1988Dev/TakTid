<script setup lang="ts">
import { reactive } from 'vue';
import dayjs, { Dayjs } from 'dayjs';
import api from '../api/axios';

const props = defineProps<{ date: Dayjs }>()
const emit = defineEmits<{ close: [] }>()

const form = reactive({
  start: '07:00',
  end: '16:00',
  breakMinutes: '60' as unknown as number,
  comment: '',
});

function calcHours(): number {
  const start = dayjs(`${props.date.format('YYYY-MM-DD')} ${form.start}`);
  const end = dayjs(`${props.date.format('YYYY-MM-DD')} ${form.end}`);

  return (end.diff(start, 'minute') - form.breakMinutes) / 60;
}

async function save(): Promise<void> {
  await api.post('/time-entries', {
    date: props.date.format('YYYY-MM-DD'),
    hours: calcHours(),
    type: 'WORK',
    comment: form.comment,
  });

  emit('close');
}
</script>

<template>
  <div class="modal">
    <h3>{{ props.date.format('DD MMM YYYY') }}</h3>

    <input v-model="form.start" type="time" />
    <input v-model="form.end" type="time" />
    <input v-model.number="form.breakMinutes" type="number" />

    <p>Hours: {{ calcHours() }}</p>

    <textarea v-model="form.comment" />

    <button @click="save">Save</button>
    <button @click="emit('close')">Cancel</button>
  </div>
</template>