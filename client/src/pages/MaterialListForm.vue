<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const isEditing = ref(true)
const title = ref('')

const items = reactive([
  { label: 'hängränna 6m', value: '' },
  { label: 'hängränna 4m', value: '' },
  { label: 'hängränna 3m', value: '' },
  { label: 'rännkrok', value: '' },
  { label: 'ränngavel', value: '' },
  { label: 'rännskarv', value: '' },
  { label: 'rännvinkel ytter', value: '' },
  { label: 'rännvinkel inner', value: '' },
  { label: 'omvik (omvikningskupa)', value: '' },
  { label: 'stuprör 2.5m', value: '' },
  { label: 'stuprör 3m', value: '' },
  { label: 'stuprör 4m', value: '' },
  { label: 'stuprör 6m', value: '' },
  { label: 'stuprörssvep', value: '' },
  { label: 'lövsil', value: '' },
  { label: 'rörvinkel', value: '' },
  { label: 'utkastare', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x170 3.6m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x170 4.8m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x170 4.2m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x170 5.4m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä)', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x195 4.8m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x195 5.4m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x195 3.6m', value: '' },
  { label: 'ytterpanelbräda (vindskivor trä) 22x170 22x120 22x195 22x145', value: '' },
  { label: 'vindskiveplåt', value: '' },
  { label: 'bärläktsteg', value: '' },
  { label: 'glidskydd', value: '' },
  { label: 'råspontlucka 23X540 3.6m', value: '' },
  { label: 'råspontlucka 23X540 4.2m', value: '' },
  { label: 'råspontlucka 20X540 3.6m', value: '' },
  { label: 'råspontlucka 20X540 4.2m', value: '' },
  { label: 'råspontlucka 20X540 4.8m', value: '' },
  { label: 'råspont 17mm single', value: '' },
  { label: 'råspont 19mm single', value: '' },
  { label: 'tek7/silicone', value: '' },
  { label: 'nails for pistol', value: '' },
  { label: 'screws 55mm', value: '' },
  { label: '33mm plåt skruv', value: '' },
  { label: '42mm skruv', value: '' },
  { label: '30mm trä skruv', value: '' },
  { label: 'skruv 120mm', value: '' },
  { label: 'skruv 75+80mm', value: '' },
  { label: 'vindskruva', value: '' },
  { label: 'farmarskruv', value: '' },
  { label: 'clips', value: '' },
  { label: 'nokband', value: '' },
  { label: 'fågelband', value: '' },
  { label: 'fotplåt 2m', value: '' },
  { label: 'läkts standart 25x48', value: '' },
  { label: 'läkts thin 12x50', value: '' },
  { label: 'trekantsläkt', value: '' },
  { label: 'regel', value: '' },
  { label: 'GRAN HYVLAD REGEL O/S V 45X45 4,8 M', value: '' },
  { label: 'GRAN HYVLAD REGEL O/S V 45X45 3,6 M', value: '' },
  { label: 'GRAN VILMAREGEL KORTREGEL 45X45 2.5 M', value: '' },
  { label: 'trash bags', value: '' },
  { label: 'paint', value: '' },
  { label: 'tejp', value: '' },
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
  /*display: flex;
  justify-content: space-between;
  gap: 1px;*/
  display:grid;
  grid-template-columns:minmax(0,1fr) 90px;
  gap:8px;
  align-items: center;
  border-bottom:1px dashed #ddd;
}

.label {
  /*flex: 2;*/
  flex: 1;
  font-size: 14px;
  color: #333;
  padding: 1px 6px; 
  
  overflow:hidden;
  text-overflow:ellipsis;
  white-space:nowrap;
  /*6px 0*/;
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
