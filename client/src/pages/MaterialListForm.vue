<script setup lang="ts">
import { reactive, ref, computed, watch, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Project } from '../types/Project.dto'
import { MATERIAL_CATALOG } from '../const/MaterialCatalog'
import AutoComplete from 'primevue/autocomplete'
import Dialog from 'primevue/dialog'
import type {
  CreateMaterialListDto,
  MaterialItem,
} from '../types/Material'

import { useProjectStore } from '../stores/project.store'
import { useProjectMaterialStore } from '../stores/projectMaterial.store'
import 'primeicons/primeicons.css'

const { t } = useI18n()
const props = defineProps<{ projectId: string, isAdmin: boolean }>()

const materialStore = useProjectMaterialStore()
const projectStore = useProjectStore()

const filteredProjects = ref<Project[]>([])
const selectedProject = ref<Project | null>(null)

const textareaRef = ref<HTMLTextAreaElement>()

const isEditing = ref(true)
const priceDialog = ref(false)

/*
watch(selectedProject, project => {
  materialForm.projectId = project?.id ?? ''
})
   onMounted(async () => {

      autoResize()

      await projectStore.load()

      if (props.projectId) {

          selectedProject.value =
              projectStore.projects.find(
                  p => p.id === props.projectId
              ) ?? null

      }

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
      materialForm.other = ''
      materialForm.items = MATERIAL_CATALOG.map(label => ({
        label,
        quantity: null,
        price: null,
        unit: 'pcs',
      }))
      return
    }
    await materialStore.load(id)

    const list = materialStore.materialList
    materialForm.other = list?.other ?? ''

    materialForm.items =
      MATERIAL_CATALOG.map(label => {
        const existing = list?.items?.find((i: MaterialItem) => i.label === label)
        return {
          label,
          quantity:
              existing?.quantity == null
                  ? null
                  : Number(existing.quantity),

          price:
              existing?.price == null
                  ? null
                  : Number(existing.price),
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
  await materialStore.save(payload)
  await materialStore.load(materialForm.projectId)

  const list = materialStore.materialList

  materialForm.other = list?.other ?? ''


  materialForm.items = MATERIAL_CATALOG.map(label => {
    const existing =
      list?.items.find(
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
  const list = materialStore.materialList

  if (!list) return

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
function openPriceModal() {
  priceDialog.value = true
}*/
let loadRequestId = 0

const createEmptyItems = (): MaterialItem[] =>
  MATERIAL_CATALOG.map(label => ({
    label,
    quantity: null,
    price: null,
    unit: 'pcs',
  }))

const materialForm = reactive<CreateMaterialListDto>({
  projectId: '',
  other: '',
  items: createEmptyItems(),
})

const hasOther = computed(() =>
  materialForm.other.trim().length > 0,
)

const visibleItems = computed(() =>
  materialForm.items.filter(
    item =>
      item.quantity !== null &&
      item.quantity !== 0,
  ),
)

function syncFormFromList(): void {
  const list = materialStore.materialList

  materialForm.other = list?.other ?? ''

  materialForm.items = MATERIAL_CATALOG.map(label => {
    const existing = list?.items?.find(
      (item: MaterialItem) =>
        item.label === label,
    )

    return {
      label,
      quantity:
        existing?.quantity == null
          ? null
          : Number(existing.quantity),

      price:
        existing?.price == null
          ? null
          : Number(existing.price),

      unit: existing?.unit ?? 'pcs',
    }
  })

  autoResize()
}

function resetForm(): void {
  materialForm.other = ''
  materialForm.items = createEmptyItems()

  nextTick(() => {
    autoResize()
  })
}

function autoResize(): void {
  nextTick(() => {
    if (!textareaRef.value) return

    textareaRef.value.style.height = 'auto'
    textareaRef.value.style.height =
      `${textareaRef.value.scrollHeight}px`
  })
}

function searchProjects(event: { query: string }): void {
  const query = event.query.toLowerCase().trim()

  filteredProjects.value =
    projectStore.projects.filter(project =>
      project.address
        .toLowerCase()
        .includes(query) ||
      project.city
        .toLowerCase()
        .includes(query),
    )
}

/**
 * Load material list whenever selected project changes.
 */
watch(
  () => materialForm.projectId,
  async projectId => {
    const requestId = ++loadRequestId

    if (!projectId) {
      materialStore.clear()
      resetForm()
      isEditing.value = true
      return
    }

    await materialStore.load(projectId)

    // A newer project was selected while this request
    // was still loading.
    if (requestId !== loadRequestId) {
      return
    }

    syncFormFromList()

    /**
     * Existing list -> show read-only list.
     * No list -> open empty form for creation.
     */
    isEditing.value =
      materialStore.materialList === null
  },
)

/**
 * Load projects once.
 */
onMounted(async () => {
  await projectStore.load()

  if (!props.projectId) {
    return
  }
  if (props.projectId) {
    setProject(props.projectId)
  }
  /*
  const project =
    projectStore.projects.find(
      p => p.id === props.projectId,
    ) ?? null

  selectedProject.value = project

  if (project) {
    materialForm.projectId = project.id
  }*/
})

watch(
  () => props.projectId,
  projectId => {
    if (projectId) {
      setProject(projectId)
    }
  },
)
/**
 * Save current material list.
 */
async function save(): Promise<void> {
  if (!materialForm.projectId) {
    return
  }

  const payload: CreateMaterialListDto = {
    projectId: materialForm.projectId,

    other:
      materialForm.other.trim() || '',

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

  /**
   * Store.save() already receives the updated entity
   * from the backend, so there is no need for another GET.
   */
  await materialStore.save(payload)

  syncFormFromList()

  /**
   * Return to read-only list after saving.
   */
  isEditing.value = false
}

/**
 * Return from read-only list to editing mode.
 */
function edit(): void {
  if (!materialStore.materialList) {
    return
  }

  syncFormFromList()
  isEditing.value = true
}

function openPriceModal(): void {
  priceDialog.value = true
}
function selectProject(project: Project | null): void {
  selectedProject.value = project
  materialForm.projectId = project?.id ?? ''
}
function setProject(projectId: string): void {
  const project =
    projectStore.projects.find(
      p => p.id === projectId,
    ) ?? null
  if (!project) {
    selectedProject.value = null
    materialForm.projectId = ''
    return
  }
  selectedProject.value = project
  materialForm.projectId = project?.id ?? ''
}

</script>

<template>
  <div class="material-form">
    <!--
    <AutoComplete
      v-model="selectedProject"
      :suggestions="filteredProjects"
      :label="t('common.selectProject')"
      optionLabel="address"
      dropdown
      forceSelection
      @complete="searchProjects"
    >
      <template #option="{ option }">
        <div class="project-option">
         
          <div class="city">
              {{ option.city }}
          </div>

          <div class="address">
              {{ option.address }}
          </div>
        </div>

      </template>

    </AutoComplete>
-->
      <AutoComplete
        v-model="selectedProject"
        :suggestions="filteredProjects"
        :placeholder="t('common.selectProject')"
        optionLabel="address"
        dropdown
        forceSelection
        @complete="searchProjects"
        @update:model-value="selectProject"
      >
        <template #option="{ option }">
          <div class="project-option">
            <div class="city">
              {{ option.city }}
            </div>

            <div class="address">
              {{ option.address }}
            </div>
          </div>
        </template>
      </AutoComplete>
    <div
      v-if="isEditing || visibleItems.length"
      class="grid"
      :class="{ 'view-mode': !isEditing }"
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
          step="1"
          :disabled="!isEditing"
          :class="{ 'readonly-quantity': !isEditing }"
        >
      </div>

      <div
        v-if="isEditing || hasOther"
        class="other-section"
      >

        <label>
          {{ t('common.other') }}
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
    <!--v-if="isEditing"-->
    <div
      class="sticky-actions"
    >
      <button
        v-if="isEditing"
        class="save-btn"
        @click="save"
      >
        {{ t('common.save') }}
      </button>

      <button
        v-else
        class="save-btn secondary"
        @click="edit"
      >
        {{ t('common.edit') }}
      </button>
    </div>
    <button
      v-if="isEditing && isAdmin"
      class="edit-prices-btn"
      @click="openPriceModal"
    >
      <i class="pi pi-pencil"></i>
      {{ t('common.editPrices') }}
    </button>
    <Dialog
      v-model:visible="priceDialog"
      modal
      header="Material Prices"
      :style="{ width: '700px', maxWidth: '95vw' }"
    >
      <div class="price-list">
        <div
          v-for="item in materialForm.items"
          :key="item.label"
          class="price-row"
        >
          <span>{{ item.label }}</span>
          <input
            v-model.number="item.price"
            type="number"
            step="0.01"
            placeholder="0.00"
          >
        </div>
      </div>

      <template #footer>
        <button @click="priceDialog = false">
          {{ t('common.done') }}
        </button>
      </template>
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
    gap:8px;
    padding:10px;

    color:#111827;
}

.title-input{
    border:1px solid #ddd;
    border-radius:10px;
    padding:8px;
}

.grid{
    display:grid;
    gap:5px;
}

.row{
    display:grid;
    grid-template-columns:minmax(0,1fr) 72px;
    gap:8px;
    align-items:center;
    min-height: 30px;
}

.label{
    min-width: 0;
    font-size: 13px;
    line-height: 1.15;
    color: #111827;
    /*flex:1;*/
    white-space:normal;
    word-break:break-word;

}
.readonly-quantity {
  -webkit-appearance: none;
  appearance: none;

  opacity: 1;
  color: #111827;
  -webkit-text-fill-color: #111827;
}
.row input{
    width: 72px;
    height: 28px;
    box-sizing: border-box;

    border:1px solid #ccc;
    border-radius:7px;
    padding: 3px 5px;

    text-align: center;
    font-size: 13px;
    color: #111827;
    background: #fff;
}

.grid.view-mode {
  gap: 2px;
}
.view-mode .row {
  min-height: 24px;
  grid-template-columns: minmax(0, 1fr) 55px;
  gap: 6px;
}
.view-mode .label {
  font-size: 12px;
  line-height: 1.1;
}

.view-mode .row input {
  width: 55px;
  height: 23px;

  padding: 0;

  border: none;
  background: transparent;

  font-size: 12px;
  font-weight: 600;
  color: #111827;

  text-align: right;
  pointer-events: none;
}

.price{
    width:90px;
}

.other-section{
    display:flex;
    flex-direction:column;

    font-size: 12px;
    font-weight: 600;

    /*gap:4px;*/
}

textarea{
    width: 100%;
    box-sizing: border-box;

    resize:none;
    overflow:hidden;
    border:1px solid #ccc;
    border-radius:8px;
    padding:6px;

    font-size: 13px;
    color: #111827;
    background: #fff;
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
    opacity:0.9;
}
.quantity{
    width:72px;
    text-align:center;
}

.sticky-actions{
  position: sticky;
  bottom: 0;
  background: white;
  padding: 8px 0;
  border-top: 1px solid #e5e7eb;
  z-index: 20;
}

.save-btn{
  width:100%;
  padding:12px;
  border:none;
  border-radius:10px;
  background:#2563eb;
  color:white;
  font-size:15px;
  font-weight:700;
}

.save-btn.secondary{
  background:#64748b;
}

.price-list{
  display:flex;
  flex-direction:column;
  gap:10px;
  max-height:60vh;
  /*overflow:auto;*/
  overflow-y: auto;
}

.price-row{
  display:grid;
  grid-template-columns:1fr 120px;
  gap:10px;
  align-items:center;
}
.project-option{

    display:flex;
    flex-direction:column;
    gap:2px;

}

.city{

    font-weight:700;
    color:var(--primary-color);

}

.address{

    font-size:0.9rem;
    opacity:0.8;

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
    padding:6px;
    gap: 6px;
}
.label{
    flex:1;
    white-space:normal;
    word-break:break-word;
    font-size:12px;
    line-height:1.1;
}


.row{
    display:grid;
    grid-template-columns:1fr 72px 40px;
    gap:8px;
    align-items:center;
  }

  .label{
    font-size:13px;
    line-height:1.2;
    white-space:normal;
    word-break:break-word;
  }

  .row input{
    width:68px;
    text-align:center;
    padding:2px 4px;
    height: 26px;
    font-size: 12px;
  }

  .price-btn{
    width:40px;
    height:40px;
  }

  .material-form{
    padding:10px;
  }
  .sticky-actions{
    position: static;
    border-top:none;
    padding:0;
  }

  .save-btn{
    width:auto;
    min-width:180px;
  }
  .grid.view-mode {
    gap: 1px;
  }

  .view-mode .row {
    grid-template-columns: minmax(0, 1fr) 52px;
    gap: 5px;
    min-height: 22px;
  }

  .view-mode .label {
    font-size: 11.5px;
    line-height: 1.05;
  }

  .view-mode .row input {
    width: 52px;
    height: 21px;

    font-size: 11.5px;
    font-weight: 600;
  }
   .other-section {
    margin-top: 3px;
  }

  .other-section label {
    font-size: 11px;
  }
  .sticky-actions {
    position: static;
    padding: 4px 0;
    border-top: none;
  }

  .save-btn {
    width: auto;
    min-width: 150px;
    padding: 10px 16px;
    font-size: 14px;
  }
  .price-row {
    grid-template-columns: minmax(0, 1fr) 90px;
    gap: 8px;
  }
}

</style>