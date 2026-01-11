<script setup lang="ts">
import { ref } from 'vue'
import type { Project } from '../../types/Project.dto'
import { uploadProjectImage } from '../../api/ProjectImages.api'

const props = defineProps<{
  project: Project
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'uploaded'): void
}>()

const file = ref<File | null>(null)
const loading = ref(false)

async function upload() {
  if (!file.value) return

  loading.value = true
  await uploadProjectImage(props.project.id, file.value)
  loading.value = false

  emit('uploaded')
  emit('close')
}
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <h3>Add project photo</h3>

      <input
        type="file"
        accept="image/*"
        @change="e => file = (e.target as HTMLInputElement).files?.[0] ?? null"
      >

      <div class="actions">
        <button @click="emit('close')">
          Cancel
        </button>
        <button
          class="primary"
          :disabled="!file || loading"
          @click="upload"
        >
          Upload
        </button>
      </div>
    </div>
  </div>
</template>