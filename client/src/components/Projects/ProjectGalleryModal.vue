<script setup lang="ts">
import type { ProjectImages } from '../../types/ProjectImages.ts'

defineProps<{
  photos: ProjectImages[]
  isAdmin: boolean
}>()

defineEmits<{
  (e: 'upload', files: FileList): void
  (e: 'remove', id: string): void
  (e: 'close'): void
}>()
</script>

<template>
  <div class="modal-backdrop">
    <div class="modal">
      <h3>Project photos</h3>

      <input
        v-if="isAdmin"
        type="file"
        multiple
        accept="image/*"
        @change="e => $emit('upload', (e.target as HTMLInputElement).files!)"
      />

      <div class="grid">
        <div
          v-for="p in photos"
          :key="p.id"
          class="photo"
        >
          <img :src="p.url" />
          <button
            v-if="isAdmin"
            class="delete"
            @click="$emit('remove', p.id)"
          >
            ✕
          </button>
        </div>
      </div>

      <button @click="$emit('close')">Close</button>
    </div>
  </div>
</template>

<style scoped>
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 8px;
}
.photo {
  position: relative;
}
.photo img {
  width: 100%;
  border-radius: 6px;
}
.delete {
  position: absolute;
  top: 4px;
  right: 4px;
}
</style>