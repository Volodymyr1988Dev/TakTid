<script setup lang="ts">
import { reactive, onMounted, ref } from 'vue';
import dayjs, { Dayjs } from 'dayjs';
import api from '../api/axios';
import { useTimeEntryStore } from '../stores/timeEntry.store';
//import { date } from 'zod/v4';
import type { TimeKind } from '../types/timeKind.enum';
import type { Project } from '../types/Project.dto';

const props = defineProps<{ date: Dayjs, projectId?: string }>()
const emit = defineEmits<{ close: [] }>()
const store = useTimeEntryStore();
const form = reactive({
  //date : props.date,
  start: '07:00',
  end: '16:00',
  breakMinutes: 60,
  type: 'WORK' as TimeKind,
  projectId: props.projectId,
  comment: '',
});

function calcHours(): number {
  const start = dayjs(`${props.date.format('YYYY-MM-DD')} ${form.start}`);
  const end = dayjs(`${props.date.format('YYYY-MM-DD')} ${form.end}`);

  return (end.diff(start, 'minute') - form.breakMinutes) / 60;
}

async function save() {
  await api.post('/time-entries', {
    date: props.date.format('YYYY-MM-DD'),
    hours: calcHours(),
    type: form.type,
    projectId: form.projectId,
    breakMinutes: form.breakMinutes,
    comment: form.comment,
  });
  await store.loadByPeriod(
    props.date.startOf('month').format('YYYY-MM-DD'),
    props.date.endOf('month').format('YYYY-MM-DD'),
  );
  emit('close');
}
const projects = ref<Project[]>([])
onMounted(async () => {
  const { data } = await api.get<Project[]>('/projects')
  projects.value = data
})
</script>

<template>
  <div class="modal">
    <h3>{{ props.date.format('DD MMM YYYY') }}</h3>
    <select v-model="form.projectId">
      <option :value="undefined">Without project</option>

      <option
        v-for="p in projects"
        :key="p.id"
        :value="p.id"
      >
        {{ p.city }} – {{ p.address }}
      </option>
    </select>
    <input v-model="form.start" type="time" />
    <input v-model="form.end" type="time" />
    <input v-model.number="form.breakMinutes" type="number" />

    <p>Hours: {{ calcHours() }}</p>

    <textarea v-model="form.comment" />
    <button @click="save">Save</button>
    <button @click="emit('close')">Cancel</button>
  </div>
</template>