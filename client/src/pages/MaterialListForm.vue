<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
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

const hasOther = computed(() => other.value.trim().length > 0)

//const visibleItems = ref<typeof items>([])

const visibleItems = computed(() => items.filter(i => i.value?.trim()))
function save() {
  /*visibleItems.value = items.filter(
    (item) => item.value !== '' && item.value !== null
  )*/
  isEditing.value = false
  setTimeout(autoResize)
}

function edit() {
  isEditing.value = true
  setTimeout(autoResize)
}

const textareaRef = ref<HTMLTextAreaElement | null>(null)

function autoResize() {
  const el = textareaRef.value
  if (!el) return
  el.style.height = 'auto'
  el.style.height = el.scrollHeight + 'px'
}
watch(other, () => {
  setTimeout(autoResize)
})

onMounted(() => {
  autoResize()
})
</script>
<template>
  <div 
    class="material-form"
  >
    <input
      v-model="title"
      :placeholder="t('common.title')"
      class="title-input"
      :disabled="!isEditing"
    >
    <!--item in items-->
    <div
      v-if="isEditing || visibleItems.length"
      class="grid">
      <div v-if="!isEditing && !visibleItems.length && !hasOther">
        No data
      </div>
      <div
        v-for=" item in (isEditing ? items : visibleItems)"
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
      <div 
        v-if="isEditing || hasOther"
        class="other-section"
      >
        <label>Other</label>
        <textarea
          ref="textareaRef"
          @input="autoResize"
          v-model="other"
          :disabled="!isEditing"
          rows="1"
        />
        <!--rows="3"-->
      </div>
    </div>

    <button 
      v-if="isEditing" 
      @click="save"
    >
      {{ t('common.save') }}
    </button>

    <button 
      v-else 
      @click="edit"
    >
      {{ t('common.edit') }}
    </button>
  </div>
</template>
<style scoped>
.material-form {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 10px;
}

.title-input {
  border-radius: 10px;
  border: 1px solid #ddd;
  font-weight: 600;
  padding: 1px;
}

.row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1px;
}

.label {
  /*flex: 2;*/
  flex: 1;
  font-size: 14px;
  color: #333;
  padding: 1px 6px /*6px 0*/;
/*
  border-radius: 8px;
  border: 1px solid #ccc;
  padding: 6px;
  font-size: 14px;
  color: #333;*/
}

.row input {
  flex: 1;
  border-radius: 8px;
  border: 1px solid #ccc;
}

textarea {
  width: 100%;
  resize: /*vertical*/none;
  border-radius: 8px;
  border: 1px solid #ccc;
  overflow: hidden;
  padding: 1px;
}
.other-section {
  grid-column: span 2;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

button {
  margin-top: 10px;
  border-radius: 10px;
  border: none;
  background: #2563eb;
  color: white;
  font-weight: 600;
  padding: 10px;
}
button:hover {
  opacity: 0.9;
}
.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1px /*8px 16px*/;
}
@media (max-width: 600px) {
  .grid {
    grid-template-columns: 1fr;
  }

  .row {
    /*flex-direction: column;*/
    align-items: flex-start;
    /*gap: 4px;*/
  }

  .label {
    font-size: 13px;
  }

  .row input {
    width: 100%;
  }
  .other-section {
    grid-column: span 1;
  }
}
</style>
