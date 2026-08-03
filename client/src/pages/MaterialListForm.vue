<script setup lang="ts">
import { reactive, ref, computed, watch, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Project } from '../types/Project.dto'
import { MATERIAL_CATALOG } from '../const/MaterialCatalog'
import AutoComplete from 'primevue/autocomplete'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import type {
  CreateMaterialListDto,
  MaterialItem,
} from '../types/Material'

import { useProjectStore } from '../stores/project.store'
import { useProjectMaterialStore } from '../stores/projectMaterial.store'
import 'primeicons/primeicons.css'

const { t } = useI18n()
const filteredProjects = ref<Project[]>([])
const projectStore = useProjectStore()
const materialStore = useProjectMaterialStore()

const isEditing = ref(true)
const showPriceDialog = ref(false)

const textareaRef = ref<HTMLTextAreaElement>()
const selectedProject = ref<Project | null>(null)

const props = defineProps<{ projectId: string, isAdmin: boolean }>()

watch(selectedProject, project => {
  materialForm.projectId = project?.id ?? ''
})
const materialForm = reactive<CreateMaterialListDto>({
  projectId: '',
  //title: '',
  other: '',
  items: MATERIAL_CATALOG.map(label => ({
    label,
    quantity: null,
    price: null,
    unit: 'pcs',
  })),
})

const hasOther = computed(() => materialForm.other.trim().length > 0)

const visibleItems = computed(() =>
  materialForm.items.filter(i => i.quantity !== null && i.quantity !== 0),
)

function searchProjects(event: { query: string }) {
  const query = event.query.toLowerCase()

  filteredProjects.value = projectStore.projects.filter(project =>
    project.address.toLowerCase().includes(query) ||
    project.city.toLowerCase().includes(query),
  )
}

function autoResize() {
  nextTick(() => {
    if (!textareaRef.value) return

    textareaRef.value.style.height = 'auto'
    textareaRef.value.style.height =
      textareaRef.value.scrollHeight + 'px'
  })
}

watch(
  () => materialForm.other,
  autoResize,
)

onMounted(async () => {
  autoResize()

  await projectStore.load()
})

watch(
  () => materialForm.projectId,
  async id => {
    if (!id) {
      //materialForm.title = ''
      materialForm.other = ''
      materialForm.items = MATERIAL_CATALOG.map(label => ({
        label,
        quantity: null,
        price: null,
        unit: 'pcs',
      }))
      return
    }
    //await materialStore.load(materialForm.projectId)
    await materialStore.load(id)

    const list = materialStore.materialList

    //materialForm.title = list?.title ?? ''
    materialForm.other = list?.other ?? ''
    //materialForm.title = materialStore.materialList?.title ?? ''

    //materialForm.other = materialStore.materialList?.other ?? ''

    materialForm.items =
      MATERIAL_CATALOG.map(label => {
        //const existing =materialStore.materialList?.items.find((i: MaterialItem) => i.label === label)
        const existing = list?.items?.find((i: MaterialItem) => i.label === label)
        return {
          label,
          quantity: existing?.quantity ?? null,
          price: existing?.price ?? null,
          unit: existing?.unit ?? 'pcs',
        }
      })

    autoResize()
  },
)

async function save() {
  const payload: CreateMaterialListDto = {
      projectId: materialForm.projectId,
      //title: materialForm.title,
      other: materialForm.other?.trim() || '',
      items: materialForm.items
        .filter(
            item =>
                item.quantity !== null &&
                item.quantity !== 0 &&
                !Number.isNaN(item.quantity),
        )
        .map(item => ({
            label: item.label,
            quantity: item.quantity,
            price: item.price,
            unit: item.unit,
        })),
  }
/*
  const payload: CreateMaterialListDto = {
    ...materialForm,
    items: materialForm.items.filter(
      item =>
        item.quantity !== null &&
        !Number.isNaN(item.quantity) &&
        item.quantity !== 0,
    ),
  }*/

  await materialStore.save(payload)
  /*
  materialForm.items = materialForm.items.filter(
    i => i.quantity !== null && i.quantity !== 0,
  )

  await materialStore.save(materialForm)*/

  materialForm.items = MATERIAL_CATALOG.map(label => {
    const existing =
      materialStore.materialList?.items?.find(
        (i: MaterialItem) => i.label === label,
      )

    return {
      label,
      quantity: existing?.quantity ?? null,
      price: existing?.price ?? null,
      unit: existing?.unit ?? 'pcs',
    }
  })

  isEditing.value = false
  }

function edit() {
  isEditing.value = true
/*
  if (materialStore.materialList) {
    materialForm.items =
      MATERIAL_CATALOG.map(label => {
        const existing =
          materialStore.materialList.items.find(
            (i: MaterialItem) => i.label === label,
          )

        return {
          label,
          quantity: existing?.quantity ?? null,
          price: existing?.price ?? null,
          unit: existing?.unit ?? 'pcs',
        }
      })

  }
*/ 
  const list = materialStore.materialList

  if (!list)
      return

  materialForm.items =
      MATERIAL_CATALOG.map(label => {

          const existing =
              list.items.find(
                  (i: MaterialItem) =>
                      i.label === label,
              )

          return {
              label,
              quantity: existing?.quantity ?? null,
              price: existing?.price ?? null,
              unit: existing?.unit ?? 'pcs',
          }
      })
  autoResize()
}
</script>

<template>
  <div class="material-form">

    <AutoComplete
      v-model="selectedProject"
      :suggestions="filteredProjects"
      optionLabel="address"
      dropdown
      forceSelection
      @complete="searchProjects"
    >
      <template #option="{ option }">

        <div class="project-option">

          <strong>
            {{ option.city }}
          </strong>

          <span>
            {{ option.address }}
          </span>

        </div>

      </template>

    </AutoComplete>
    <!--
    <select v-model="materialForm.projectId">
      <option value="">
        {{ t('common.selectProject') }}
      </option>

      <option
        v-for="project in projectStore.projects"
        :key="project.id"
        :value="project.id"
      >
        <div>

        <strong>

        {{project.city}}

        </strong>

        ➜

        {{project.address}}

        </div>-->
        <!--{{project.city}}  ➤  {{ project.address }}-->
      <!--  
      </option>
    </select>
  -->
    <!--
    <input
      v-model="materialForm.title"
      class="title-input"
      :disabled="!isEditing"
      :placeholder="t('common.title')"
    >
    -->

    <div
      v-if="isEditing || visibleItems.length"
      class="grid"
    >

      <div
        v-for="item in (isEditing ? materialForm.items : visibleItems)"
        :key="item.label"
        class="row"
      >

        <div class="label">
          {{ item.label }}
        </div>

        <input
          v-model.number="item.quantity"
          type="number"
          step="0.01"
          :disabled="!isEditing"
        >
      </div>

      <div
        v-if="isEditing || hasOther"
        class="other-section"
      >

        <label>
          Other
        </label>

        <textarea
          ref="textareaRef"
          v-model="materialForm.other"
          rows="1"
          :disabled="!isEditing"
          @input="autoResize"
        />

      </div>

    </div>

    <div
      v-if="isEditing"
      class="sticky-actions"
    >
      <button @click="save">
        {{ t('common.save') }}
      </button>
    </div>
    <button
      v-else
      @click="edit"
    >
      {{ t('common.edit') }}
    </button>
    <Button
      v-if="props.isAdmin"
      icon="pi pi-dollar"
      label="Edit prices"
      severity="secondary"
      @click="showPriceDialog = true"
    />
    <Dialog
      v-model:visible="showPriceDialog"
      modal
      header="Material Prices"
      :style="{ width: '700px' }"
    >
      <div
        v-for="item in materialForm.items"
        :key="item.label"
        class="price-row"
      >
        <span>
          {{ item.label }}
        </span>

        <input
          v-model.number="item.price"
          type="number"
          step="0.01"
        >
      </div>
    </Dialog>
  </div>
</template>

<style scoped>
.select{
    width:100%;
    padding:10px 14px;
    border-radius:10px;
    border:1px solid #d1d5db;
    background:white;
    font-size:14px;
    max-height:300px;
}
.material-form{
    display:flex;
    flex-direction:column;
    gap:10px;
    padding:12px;
}

.title-input{
    border:1px solid #ddd;
    border-radius:10px;
    padding:8px;
}

.grid{
    display:grid;
    gap:6px;
}

.row{
    display:grid;
    grid-template-columns:minmax(0,1fr) 90px 90px;
    gap:8px;
    align-items:center;
}

.label{/*
    overflow:hidden;
    text-overflow:ellipsis;*/

    flex:1;
    white-space:normal;
    word-break:break-word;
}

.row input{
    border:1px solid #ccc;
    border-radius:8px;
    padding:5px;
}

.price{
    width:90px;
}

.other-section{
    display:flex;
    flex-direction:column;
    gap:4px;
}

textarea{
    resize:none;
    overflow:hidden;
    border:1px solid #ccc;
    border-radius:8px;
    padding:8px;
}

button{
    padding:10px;
    border:none;
    border-radius:10px;
    background:#2563eb;
    color:white;
    font-weight:600;
}

button:hover{
    opacity:.9;
}
.quantity{
    width:72px;
    text-align:center;
}
.sticky-actions{
    position:sticky;
    bottom:0;
    z-index:50;

    background:white;

    padding:12px;

    margin-top:12px;

    border-top:1px solid #e5e7eb;
}

.sticky-actions button{
    width:100%;
    height:48px;
}

@media(max-width:700px){
.row input{
  width:70px;
  text-align:center;
  padding:2px;
}
.row{
    /*grid-template-columns:1fr;
    font-size:11px;*/

    display:flex;
    align-items:center;
    gap:8px;
}

.price{
    width:100%;
}
.price-btn{
    width:36px;
    height:36px;
}
.material-form{
    padding:8px;
}
.label{
    flex:1;
    white-space:normal;
    word-break:break-word;
    font-size:13px;
    line-height:1.2;
}
}

</style>