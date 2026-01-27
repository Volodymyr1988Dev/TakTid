<script setup lang="ts">
import { useTimeEntryForm } from '../../composables/useTimeEntryForm'
import type { DayEntry } from '../../../types/DayEntry.type'
import type { TimeSuggestion } from '../../../types/Suggestion.type'

const props = defineProps<{
  date: string
  entry?: DayEntry  | null
  preset?: TimeSuggestion | null
}>()

const emit = defineEmits(['saved', 'cancel'])

const form = useTimeEntryForm(props)

const {
  start,
  end,
  breakMinutes,
  comment,
  //projectId,
  //images,
  imageStore,
  errors,
  calculatedHours,
  //isEdit,
  //isAbsence,
  onImagesSelected,
  removeExistingImage,
  save,
} = form
</script>

<template>
  <div class="modal">
    <button @click="emit('cancel')">
      ← Back
    </button>

    <input
      v-model="start" 
      type="time"  
    >
    <span class="error">{{ errors.start }}</span>

    <input 
      v-model="end"
      type="time" 
    >
    <span class="error">{{ errors.end }}</span>

    <input
      v-model.number="breakMinutes"
      type="number"
    >

    <input 
      type="file" 
      multiple 
      accept="image/*" 
      @change="onImagesSelected" 
    >

    <!-- EXISTING -->
    <div v-if="imageStore.images.length">
      <div 
        v-for="img in imageStore.images" 
        :key="img.id"
      >
        <img :src="img.url">
        <button @click="removeExistingImage(img.id)">
          ✕
        </button>
      </div>
    </div>

    <textarea v-model="comment" />

    <p>{{ calculatedHours }} h</p>

    <button @click="save">
      Save
    </button>
  </div>
</template>

<style scoped>
.modal-header {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 8px;
}

.back-btn {
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
  color: #374151;
}

.extra-work {
  margin-top: 8px;
  min-height: 60px;
}
.selected-images {
  margin-top: 8px;
  font-size: 13px;
  color: #444;
}

.selected-images ul {
  padding-left: 16px;
}

.selected-images li {
  line-height: 1.4;
}
.existing-images {
  margin-top: 12px;
}

.thumbs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.thumb {
  position: relative;
}

.thumb img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 6px;
}

.thumb .remove {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #e11d48;
  color: white;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  cursor: pointer;
}
</style>