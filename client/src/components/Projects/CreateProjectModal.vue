<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto';

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'created', project: Project): void
}>()

const city = ref('')
const address = ref('')

async function submit() {
  const { data } = await api.post('/projects', {
    city: city.value,
    address: address.value,
  })
  emit('created', data)
  emit('close')
}
</script>

<template>
  <div class="modal">
    <input v-model="city" placeholder="City" />
    <input v-model="address" placeholder="Address" />
    <button @click="submit">Create</button>
    <button @click="$emit('close')">Cancel</button>
  </div>
</template>