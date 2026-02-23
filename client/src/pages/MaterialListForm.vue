<script setup lang="ts">
import { ref, reactive } from 'vue'

const isEditing = ref(true)
const title = ref('')

const items = reactive([
  { label: 'Stupror 2.5m', value: '' },
  { label: 'Stupror 6m', value: '' },
  { label: 'Stupror hollare', value: '' },
  { label: 'Lövsil', value: '' },
  { label: 'Omvik', value: '' },
  { label: 'Rörvinkil', value: '' },
  { label: 'Ränna 6m', value: '' },
  { label: 'Ränna 4m', value: '' },
  { label: 'Ränna hooks', value: '' },
  { label: 'Vindskrivor träd', value: '' },
  { label: 'Vindskrivor plåt', value: '' },
  { label: 'metal stairs', value: '' },
  { label: 'glidskydd', value: '' },
  { label: 'Ränna govel', value: '' },
  { label: 'silikon', value: '' },
  { label: 'nails for pistol', value: '' },
  { label: 'scrues 55mm', value: '' },
  { label: '33mm metal scrues', value: '' },
  { label: '120mm', value: '' },
  { label: '75+80mm', value: '' },
  { label: 'klips', value: '' },
  { label: 'nok band', value: '' },
  { label: 'fogel band', value: '' },
  { label: 'Fotplåt 2m', value: '' },
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
  <div class="material-form">

    <input
      v-model="title"
      placeholder="Title"
      class="title-input"
      :disabled="!isEditing"
    />

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
      />
    </div>

    <div class="other-section">
      <label>Other</label>
      <textarea
        v-model="other"
        :disabled="!isEditing"
        rows="3"
      />
    </div>

    <button v-if="isEditing" @click="save">
      Save
    </button>

    <button v-else @click="edit">
      Edit
    </button>

  </div>
</template>
<style scoped>
.material-form {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.title-input {
  padding: 10px;
  border-radius: 10px;
  border: 1px solid #ddd;
  font-weight: 600;
}

.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.label {
  flex: 2;
  font-size: 14px;
}

.row input {
  flex: 1;
  padding: 6px;
  border-radius: 8px;
  border: 1px solid #ccc;
}

textarea {
  width: 100%;
  resize: vertical;
  padding: 8px;
  border-radius: 8px;
  border: 1px solid #ccc;
}

button {
  margin-top: 10px;
  padding: 10px;
  border-radius: 10px;
  border: none;
  background: #2563eb;
  color: white;
  font-weight: 600;
}
</style>
