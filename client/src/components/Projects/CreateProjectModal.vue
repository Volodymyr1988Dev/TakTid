<script setup lang="ts">
import { ref } from 'vue'
import api from '../../api/axios'
import type { Project } from '../../types/Project.dto';
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
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
    <button @click="$emit('close')">
      ← {{ t('project.back') }}
    </button>
    <input
      v-model="city"
      :placeholder="t('project.city')"
    >
    <input
      v-model="address"
      :placeholder="t('project.address')"
    >
    <button @click="submit">
      {{ t('project.create') }}
    </button>
  </div>
</template>