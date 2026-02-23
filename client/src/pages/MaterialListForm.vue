<script setup lang="ts">
import { ref, reactive } from 'vue'

const isEditing = ref(true)
const title = ref('')

const items = reactive([
  { label: 'stuprör 2.5m', value: '' },
  { label: 'stuprör 6m', value: '' },
  { label: 'stuprörshållare', value: '' },
  { label: 'lövsil', value: '' },
  { label: 'omvik', value: '' },
  { label: 'rörvinkel', value: '' },
  { label: 'ränna 6m', value: '' },
  { label: 'ränna 4m', value: '' },
  { label: 'ränna hooks', value: '' },
  { label: 'vindskivor trä', value: '' },
  { label: 'vindskiveplåt', value: '' },
  { label: 'metal stairs', value: '' },
  { label: 'glidskydd', value: '' },
  { label: 'ränngavel', value: '' },
  { label: 'tek7/silicone', value: '' },
  { label: 'nails for pistol', value: '' },
  { label: 'screws 55mm', value: '' },
  { label: '33mm metal screws', value: '' },
  { label: 'screws 120mm', value: '' },
  { label: 'screws 75+80mm', value: '' },
  { label: 'clips', value: '' },
  { label: 'nokband', value: '' },
  { label: 'fågelband', value: '' },
  { label: 'fotplåt 2m', value: '' },
  { label: 'trash bags', value: '' },
  { label: 'paint', value: '' },
])

const other = ref('')

function save() {
  isEditing.value = false
}

function edit() {
  isEditing.value = true
}
</script>
<template>
  <div 
    class="material-form"
  >
    <input
      v-model="title"
      placeholder="Title"
      class="title-input"
      :disabled="!isEditing"
    >

    <div
      v-for="item in items"
      :key="item.label"
      class="row"
    >
      <div class="label">
        {{ item.label }}
      </div>

      <input
        v-model="item.value"
        :disabled="!isEditing"
        placeholder="st / pack / number"
      >
    </div>

    <div class="other-section">
      <label>Other</label>
      <textarea
        v-model="other"
        :disabled="!isEditing"
        rows="3"
      />
    </div>

    <button 
      v-if="isEditing" 
      @click="save"
    >
      Save
    </button>

    <button 
      v-else 
      @click="edit"
    >
      Edit
    </button>
  </div>
</template>
<style scoped>
.material-form {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.title-input {
  border-radius: 10px;
  border: 1px solid #ddd;
  font-weight: 600;
}

.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1px;
}

.label {
  flex: 2;
  font-size: 14px;
}

.row input {
  flex: 1;
  border-radius: 8px;
  border: 1px solid #ccc;
}

textarea {
  width: 100%;
  resize: vertical;
  border-radius: 8px;
  border: 1px solid #ccc;
}

button {
  margin-top: 10px;
  border-radius: 10px;
  border: none;
  background: #2563eb;
  color: white;
  font-weight: 600;
}
</style>
