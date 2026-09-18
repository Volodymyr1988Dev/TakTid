<script setup lang="ts">
import {
  reactive,
  ref,
  computed,
  watch,
  onMounted,
  nextTick,
} from 'vue'

import { useI18n } from 'vue-i18n'

import type { Project } from '../types/Project.dto'

import {
  MATERIAL_CATALOG,
  getMaterialDefinition,
} from '../const/MaterialCatalog'

import AutoComplete from 'primevue/autocomplete'
import Dialog from 'primevue/dialog'

import type {
  CreateMaterialListDto,
  MaterialItem,
  MaterialFormState,
} from '../types/Material'

import { useProjectStore } from '../stores/project.store'
import { useProjectMaterialStore } from '../stores/projectMaterial.store'

import 'primeicons/primeicons.css'

import html2canvas from 'html2canvas'
import jsPDF from 'jspdf'

const { t } = useI18n()

const props = defineProps<{
  projectId: string
  isAdmin: boolean
}>()

const projectStore = useProjectStore()
const materialStore = useProjectMaterialStore()

const filteredProjects = ref<Project[]>([])
const selectedProject = ref<Project | null>(null)

const isEditing = ref(false)
const priceDialog = ref(false)
const saving = ref(false)

const textareaRef = ref<HTMLTextAreaElement | null>(null)
const autocompleteRef = ref<InstanceType<typeof AutoComplete> | null>(null)

function createEmptyItems(): MaterialItem[] {
 /* return MATERIAL_CATALOG.map(material => ({
    materialKey: material.key,
    quantity: null,
    price: null,
    note: null,
  }))*/
  return []
}

const materialForm = reactive<MaterialFormState>({
  projectId: '',
  other: '',
  items: createEmptyItems(),
})

const hasOther = computed(
  () => materialForm.other.trim().length > 0,
)

const visibleItems = computed(() =>
  materialForm.items.filter(
    item =>
      item.quantity !== null &&
      item.quantity !== 0,
  ),
)
//const visibleItems = computed(() => materialForm.items)

function resetForm() {
  materialForm.other = ''
  //materialForm.items = createEmptyItems()
  
  materialForm.items = []
}
/*
function fillFormFromList() {
  const list = materialStore.materialList

  if (!list) {
    resetForm()
    return
  }

  materialForm.other = list.other ?? ''

  materialForm.items = MATERIAL_CATALOG.map(
    material => {
      const existing = list.items?.find(
        (item: MaterialItem) =>
          item.materialKey === material.key,
      )

      return {
        materialKey: material.key,

        quantity:
          existing?.quantity == null
            ? null
            : Number(existing.quantity),

        price:
          existing?.price == null
            ? null
            : Number(existing.price),

        note: existing?.note ?? null,
      }
    },
  )
}
*/
function fillFormFromList() {
  const list = materialStore.materialList

  if (!list) {
    resetForm()
    return
  }

  materialForm.other = list.other ?? ''

  materialForm.items = MATERIAL_CATALOG.map(material => {
    const existing = list.items?.find(
      (item: MaterialItem) =>
        item.materialKey === material.key,
    )

    return {
      materialKey: material.key,

      quantity:
        existing?.quantity == null
          ? null
          : Number(existing.quantity),

      price:
        existing?.price == null
          ? null
          : Number(existing.price),

      note: existing?.note ?? null,
    }
  })
}

function projectLabel(project: Project): string {
  return [project.city, project.address]
    .filter(Boolean)
    .join(' — ')
}

async function setSelectedProject(
  project: Project | null,
) {
  selectedProject.value = project

  const id = project?.id ?? ''

  if (!id) {
    materialForm.projectId = ''

    materialStore.clear()

    resetForm()

    isEditing.value = true

    return
  }

  await loadProject(id)
}

async function loadProject(
  projectId: string,
) {
  if (!projectId) {
    materialStore.clear()

    materialForm.projectId = ''

    resetForm()

    selectedProject.value = null

    isEditing.value = true

    setProjectInputReadonly()

    return
  }

  materialForm.projectId = projectId

  const project =
    projectStore.projects.find(
      item => item.id === projectId,
    ) ?? null

  selectedProject.value = project

  materialStore.clear()
  resetForm()

  await materialStore.load(projectId)

  if (materialStore.materialList) {
    fillFormFromList()

    isEditing.value = false
  } else {
    resetForm()

    isEditing.value = true
  }

  await autoResize()
  setProjectInputReadonly()
}

watch(
  () => props.projectId,
  async id => {
    if (!id) {
      return
    }

    if (!projectStore.projects.length) {
      await projectStore.load()
    }

    await loadProject(id)
  },
  {
    immediate: true,
  },
)

watch(
  selectedProject,
  () => {
    setProjectInputReadonly()
  },
)

function autoResize() {
  nextTick(() => {
    const textarea = textareaRef.value

    if (!textarea) {
      return
    }

    textarea.style.height = 'auto'

    textarea.style.height =
      `${textarea.scrollHeight}px`
  })
}

watch(
  () => materialForm.other,
  () => autoResize(),
)

function edit() {
  if (!materialStore.materialList) {
    isEditing.value = true
    return
  }

  fillFormFromList()

  isEditing.value = true

  autoResize()
}

async function save() {
  if (saving.value) {
    return
  }

  if (!materialForm.projectId) {
    window.alert(
      t('common.selectProject'),
    )

    return
  }

  saving.value = true

  try {
    const payload: CreateMaterialListDto = {
      projectId:
        materialForm.projectId,

      other:
        materialForm.other.trim(),

      /*items:
        materialForm.items
          .filter(
            item =>
              item.quantity !== null &&
              item.quantity !== 0 &&
              !Number.isNaN(
                item.quantity,
              ),
          )
          .map(item => ({
            materialKey:
              item.materialKey,

            quantity:
              item.quantity,

            price:
              item.price,

            note:
              item.note?.trim() || null,
          })),*/
          items: materialForm.items
            .filter(item => {
              const quantity = Number(item.quantity)

              return (
                Number.isFinite(quantity) &&
                quantity > 0
              )
            })
            .map(item => ({
              materialKey: item.materialKey,
              quantity: Number(item.quantity),
              price:
                item.price == null ||
                !Number.isFinite(Number(item.price))
                  ? null
                  : Number(item.price),
              note: item.note?.trim() || null,
            })),
    }

    await materialStore.save(payload)

    fillFormFromList()

    isEditing.value = false
  } finally {
    saving.value = false
  }
}

function openPriceModal() {
  priceDialog.value = true
}

async function downloadPdf() {
  if (!selectedProject.value || !visibleItems.value.length) {
    return
  }

  const project = selectedProject.value

  const projectName = projectLabel(project)

  const safeFileName = projectName
    .replace(/[<>:"/\\|?*\x00-\x1F]/g, '')
    .replace(/\s+/g, '_')
    .replace(/_+/g, '_')
    .trim()

  const pdfContainer = document.createElement('div')

  pdfContainer.style.position = 'fixed'
  pdfContainer.style.left = '-10000px'
  pdfContainer.style.top = '0'
  pdfContainer.style.width = '794px'
  pdfContainer.style.padding = '35px'
  pdfContainer.style.background = '#ffffff'
  pdfContainer.style.color = '#111827'
  pdfContainer.style.fontFamily =
    'Arial, Helvetica, sans-serif'
  pdfContainer.style.boxSizing = 'border-box'

  const title = document.createElement('div')

  title.style.fontSize = '24px'
  title.style.fontWeight = '700'
  title.style.marginBottom = '6px'
  title.textContent = projectName

  const subtitle = document.createElement('div')

  subtitle.style.fontSize = '14px'
  subtitle.style.color = '#64748b'
  subtitle.style.marginBottom = '22px'
  subtitle.textContent = t('common.material')

  pdfContainer.appendChild(title)
  pdfContainer.appendChild(subtitle)

  const table = document.createElement('table')

  table.style.width = '100%'
  table.style.borderCollapse = 'collapse'
  table.style.fontSize = '12px'

  const thead = document.createElement('thead')
  const headerRow = document.createElement('tr')

  const headers = [
    t('common.material'),
    t('common.quantity'),
    t('common.unit'),
    t('material.note'),
  ]

  headers.forEach((header, index) => {
    const th = document.createElement('th')

    th.textContent = header

    th.style.borderBottom = '2px solid #334155'
    th.style.padding = '8px'
    th.style.textAlign =
      index === 0 || index === 3
        ? 'left'
        : 'center'
    th.style.fontWeight = '700'

    headerRow.appendChild(th)
  })

  thead.appendChild(headerRow)
  table.appendChild(thead)

  const tbody = document.createElement('tbody')

  visibleItems.value.forEach(item => {
    const row = document.createElement('tr')

    const materialCell = document.createElement('td')
    const quantityCell = document.createElement('td')
    const unitCell = document.createElement('td')
    const noteCell = document.createElement('td')

    materialCell.textContent =
      materialLabel(item.materialKey)

    quantityCell.textContent =
      item.quantity == null
        ? ''
        : String(item.quantity)

    unitCell.textContent =
      materialUnit(item.materialKey)

    noteCell.textContent =
      item.note?.trim() || ''

    materialCell.style.textAlign = 'left'
    quantityCell.style.textAlign = 'center'
    unitCell.style.textAlign = 'center'
    noteCell.style.textAlign = 'left'

    ;[
      materialCell,
      quantityCell,
      unitCell,
      noteCell,
    ].forEach(cell => {
      cell.style.padding = '7px 8px'
      cell.style.borderBottom =
        '1px solid #e2e8f0'
      cell.style.verticalAlign = 'middle'
    })

    row.appendChild(materialCell)
    row.appendChild(quantityCell)
    row.appendChild(unitCell)
    row.appendChild(noteCell)

    tbody.appendChild(row)
  })

  table.appendChild(tbody)
  pdfContainer.appendChild(table)

  if (hasOther.value) {
    const otherTitle = document.createElement('div')

    otherTitle.textContent = t('common.other')

    otherTitle.style.marginTop = '20px'
    otherTitle.style.fontSize = '13px'
    otherTitle.style.fontWeight = '700'

    const otherText = document.createElement('div')

    otherText.textContent =
      materialForm.other.trim()

    otherText.style.marginTop = '6px'
    otherText.style.padding = '9px'
    otherText.style.border =
      '1px solid #d1d5db'
    otherText.style.borderRadius = '6px'
    otherText.style.fontSize = '12px'
    otherText.style.whiteSpace = 'pre-wrap'

    pdfContainer.appendChild(otherTitle)
    pdfContainer.appendChild(otherText)
  }

  const date = document.createElement('div')

  date.textContent =
    new Date().toLocaleDateString()

  date.style.marginTop = '20px'
  date.style.fontSize = '10px'
  date.style.color = '#94a3b8'
  date.style.textAlign = 'right'

  pdfContainer.appendChild(date)

  document.body.appendChild(pdfContainer)

  try {
    const canvas = await html2canvas(
      pdfContainer,
      {
        scale: 2,
        backgroundColor: '#ffffff',
        useCORS: true,
      },
    )

    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4',
    })

    const pageWidth = 210
    const pageHeight = 297

    const margin = 10

    const contentWidth =
      pageWidth - margin * 2

    const contentHeight =
      pageHeight - margin * 2

    const pagePixelHeight = Math.floor(
      canvas.width *
        (contentHeight / contentWidth),
    )

    let offsetY = 0
    let pageNumber = 0

    while (offsetY < canvas.height) {
      const sliceHeight = Math.min(
        pagePixelHeight,
        canvas.height - offsetY,
      )

      const pageCanvas =
        document.createElement('canvas')

      pageCanvas.width = canvas.width
      pageCanvas.height = sliceHeight

      const context =
        pageCanvas.getContext('2d')

      if (!context) {
        throw new Error(
          'Unable to create PDF canvas',
        )
      }

      context.fillStyle = '#ffffff'
      context.fillRect(
        0,
        0,
        pageCanvas.width,
        pageCanvas.height,
      )

      context.drawImage(
        canvas,
        0,
        offsetY,
        canvas.width,
        sliceHeight,
        0,
        0,
        canvas.width,
        sliceHeight,
      )

      const imageData =
        pageCanvas.toDataURL('image/png')

      const imageHeight =
        sliceHeight *
        (contentWidth / canvas.width)

      if (pageNumber > 0) {
        pdf.addPage()
      }

      pdf.addImage(
        imageData,
        'PNG',
        margin,
        margin,
        contentWidth,
        imageHeight,
      )

      offsetY += sliceHeight
      pageNumber++
    }

    pdf.save(
      `${safeFileName || 'material-list'}.pdf`,
    )
  } finally {
    document.body.removeChild(pdfContainer)
  }
}

function showAllProjects() {
  filteredProjects.value = [...projectStore.projects]
}

onMounted(async () => {
  if (!projectStore.projects.length) {
    await projectStore.load()
  }

  if (props.projectId) {
    const project =
      projectStore.projects.find(
        item =>
          item.id === props.projectId,
      ) ?? null

    selectedProject.value = project

    materialForm.projectId =
      props.projectId

    await loadProject(
      props.projectId,
    )
  }

  await autoResize()
})

function materialLabel(
  materialKey: string,
): string {
  const material =
    getMaterialDefinition(
      materialKey,
    )

  return material?.label ?? materialKey
}

function materialUnit(
  materialKey: string,
): string {
  const material =
    getMaterialDefinition(
      materialKey,
    )

  return material
    ? t(material.unitKey)
    : ''
}
function setProjectInputReadonly() {
  nextTick(() => {
    const component = autocompleteRef.value as unknown as {
      $el?: HTMLElement
    }

    const root = component.$el

    const input = root?.querySelector(
      'input.p-autocomplete-input',
    ) as HTMLInputElement | null

    if (!input) return

    input.readOnly = true
  })
}
</script>

<template>
  <div class="material-form">
    <!-- PROJECT SELECTOR -->

    <div class="project-selector">
      <label class="field-label">
        {{ t('common.selectProject') }}
      </label>
      <AutoComplete
        ref="autocompleteRef"
        :model-value="selectedProject"
        :suggestions="filteredProjects"
        :option-label="projectLabel"
        dropdown
        force-selection
        :disabled="saving"
        @update:model-value="setSelectedProject"
        
        @dropdown-click="showAllProjects"
        @show="setProjectInputReadonly"
        @hide="setProjectInputReadonly"
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
        
        <template #empty>
          <div class="empty-projects">
            {{ t('project.noProject') }}
          </div>
        </template>
      </AutoComplete>
    </div>

    <!-- MATERIALS -->

    <div
      v-if="
        isEditing ||
        visibleItems.length
      "
      class="materials-container"
    >
      <!-- HEADER -->

      <div
        v-if="isEditing"
        class="material-header"
      >
        <div class="header-material">
          {{ t('common.material') }}
        </div>

        <div class="header-quantity">
          {{ t('common.quantity') }}
        </div>

        <div class="header-unit">
          {{ t('common.unit') }}
        </div>

        <div class="header-note">
          {{ t('material.note') }}
        </div>
      </div>

      <!-- ROWS -->

      <div
        v-for="
          item in
          (
            isEditing
              ? materialForm.items
              : visibleItems
          )
        "
        :key="item.materialKey"
        class="material-row"
      >
        <!-- MATERIAL -->

        <div class="material-cell">
          <div class="material-name">
            {{ materialLabel(item.materialKey) }}
          </div>
        </div>

        <!-- QUANTITY -->

        <div class="quantity-cell">
          <input
            v-model.number="item.quantity"
            type="number"
            min="0"
            step="0.01"
            inputmode="decimal"
            :disabled="
              !isEditing || saving
            "
            :aria-label="
              materialLabel(item.materialKey)
            "
          />
        </div>

        <!-- UNIT -->

        <div class="unit-cell">
          {{ materialUnit(item.materialKey) }}
        </div>

        <!-- NOTE -->

        <div class="note-cell">
          <textarea
            v-if="isEditing"
            v-model="item.note"
            class="material-note-input"
            rows="1"
            :placeholder="
              t('material.notePlaceholder')
            "
            :disabled="saving"
          />

          <div
            v-else-if="item.note"
            class="material-note"
          >
            {{ item.note }}
          </div>
        </div>
      </div>

      <!-- OTHER -->

      <div
        v-if="
          isEditing ||
          hasOther
        "
        class="other-section"
      >
        <label>
          {{ t('common.other') }}
        </label>

        <textarea
          ref="textareaRef"
          v-model="materialForm.other"
          rows="1"
          :disabled="
            !isEditing || saving
          "
          @input="autoResize"
        />
      </div>
    </div>

    <!-- ACTIONS class="actions"-->

    <div
      :class="{
        'actions-view': !isEditing,
        'actions-editing': isEditing,
      }">
      <button
        v-if="isEditing"
        class="save-btn"
        :disabled="saving"
        @click="save"
      >
        <i
          v-if="saving"
          class="pi pi-spin pi-spinner"
        />

        {{
          saving
            ? t('common.loading')
            : t('common.save')
        }}
      </button>

      <template v-else>
        <button
          class="save-btn secondary"
          @click="edit"
        >
          <i class="pi pi-pencil" />

          {{ t('common.edit') }}
        </button>

        <button
          v-if="isAdmin"
          class="edit-prices-btn"
          @click="openPriceModal"
        >
          <i class="pi pi-dollar" />

          {{ t('common.editPrices') }}
        </button>
        <button
          class="pdf-btn"
          :disabled="!visibleItems.length"
          @click="downloadPdf"
        >
          <i class="pi pi-download"></i>
          <span>PDF</span>
        </button>
      </template>

      <button
        v-if="
          isEditing &&
          isAdmin
        "
        class="edit-prices-btn"
        @click="openPriceModal"
      >
        <i class="pi pi-dollar" />

        {{ t('common.editPrices') }}
      </button>
    </div>

    <!-- PRICE DIALOG -->

    <Dialog
      v-model:visible="priceDialog"
      modal
      :header="t('common.editPrices')"
      :style="{
        width: '700px',
        maxWidth: '95vw',
      }"
      :draggable="false"
    >
      <div class="price-list">
        <div
          v-for="
            item in materialForm.items
          "
          :key="item.materialKey"
          class="price-row"
        >
          <span class="price-label">
            {{ materialLabel(item.materialKey) }}
          </span>

          <input
            v-model.number="item.price"
            type="number"
            min="0"
            step="0.01"
            inputmode="decimal"
            placeholder="0.00"
          />
        </div>
      </div>

      <template #footer>
        <button
          class="dialog-done-btn"
          @click="
            priceDialog = false
          "
        >
          {{ t('common.done') }}
        </button>
      </template>
    </Dialog>
  </div>
</template>

<style scoped>
.material-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 8px;
  color: #111827;
}

/* PROJECT */

.project-selector {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field-label {
  font-size: 12px;
  font-weight: 600;
  color: #475569;
}

.project-option {
  display: flex;
  flex-direction: column;
  gap: 1px;
  padding: 3px 0;
}

.city {
  font-weight: 700;
  font-size: 13px;
  color: var(
    --primary-color,
    #2563eb
  );
}

.address {
  font-size: 12px;
  color: #64748b;
}

.empty-projects {
  padding: 8px;
  color: #64748b;
  font-size: 13px;
}

:deep(.p-autocomplete) {
  width: 100%;
}

:deep(.p-autocomplete-input) {
  width: 100%;
  min-height: 38px;
  padding: 5px 10px;
  border: 1px solid #d1d5db;
  border-radius: 8px 0 0 8px;
  font-size: 13px;
}

:deep(.p-autocomplete-dropdown) {
  width: 40px;
  min-height: 38px;
  border-radius: 0 8px 8px 0;
  border: 1px solid #d1d5db;
  border-left: 0;
}

:deep(.p-autocomplete-panel) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.p-autocomplete-option) {
  padding: 7px 10px;
}


.materials-container {
  width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.material-header,
.material-row {
  display: grid;

  grid-template-columns:
    minmax(150px, 1.45fr)
    68px
    48px
    minmax(120px, 1fr);

  column-gap: 6px;
  align-items: center;
}

.material-header {
  min-height: 28px;
  padding: 3px 5px;

  color: #64748b;
  font-size: 9px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.025em;

  border-bottom: 1px solid #e2e8f0;
}

.material-header > div {
  min-width: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.header-material {
  text-align: left;
}

.header-quantity,
.header-unit {
  text-align: center;
}

.header-note {
  text-align: left;
}

.material-row {
  min-height: 39px;
  padding: 3px 5px;

  border-bottom: 1px solid #f1f5f9;
}

.material-row:last-child {
  border-bottom: none;
}

.material-cell {
  min-width: 0;
}

.material-name {
  font-size: 13px;
  font-weight: 500;
  line-height: 1.25;

  overflow-wrap: anywhere;
}


.quantity-cell {
  display: flex;
  align-items: center;
  justify-content: center;

  min-width: 0;
}

.quantity-cell input {
  width: 62px;
  height: 29px;

  border: 1px solid #d1d5db;
  border-radius: 6px;

  padding: 3px 4px;

  text-align: center;

  background: white;
  color: #111827;

  font-size: 12px;
}

.quantity-cell input:focus {
  outline: none;
  border-color: var(
    --primary-color,
    #2563eb
  );
}

.quantity-cell input:disabled {
  background: #f8fafc;
  color: #475569;
}


.unit-cell {
  min-width: 0;

  color: #64748b;
  font-size: 10px;
  font-weight: 500;

  text-align: center;
  white-space: nowrap;

  overflow: hidden;
  text-overflow: ellipsis;
}

.note-cell {
  min-width: 0;
}

.material-note-input {
  width: 100%;
  min-height: 28px;
  height: 28px;

  margin: 0;
  padding: 4px 6px;

  border: 1px solid #d1d5db;
  border-radius: 6px;

  background: #fff;
  color: #111827;

  font-family: inherit;
  font-size: 10.5px;
  line-height: 1.25;

  resize: none;
  overflow: hidden;
}

.material-note-input:focus {
  outline: none;
  border-color: var(
    --primary-color,
    #2563eb
  );
}

.material-note {
  color: #64748b;
  font-size: 10.5px;
  line-height: 1.25;

  white-space: pre-wrap;
  overflow-wrap: anywhere;
}

.other-section {
  display: flex;
  flex-direction: column;
  gap: 3px;
  margin-top: 5px;
  padding: 5px;
  border-top: 1px solid #e2e8f0;
}

.other-section label {
  color: #475569;
  font-size: 10px;
  font-weight: 600;
}

.other-section textarea {
  width: 100%;
  min-height: 34px;

  resize: none;
  overflow: hidden;

  border: 1px solid #d1d5db;
  border-radius: 6px;

  padding: 5px 6px;

  font-family: inherit;
  font-size: 11px;
  line-height: 1.25;

  background: white;
  color: #111827;
}

.other-section textarea:focus {
  outline: none;
  border-color: var(
    --primary-color,
    #2563eb
  );
}

.actions {
  display: flex;
  gap: 7px;
  align-items: stretch;
  flex-wrap: wrap;
}

.save-btn,
.edit-prices-btn {
  border: none;
  border-radius: 8px;
  padding: 8px 12px;

  color: white;

  font-weight: 600;
  cursor: pointer;
}

.pdf-btn {
  border: none;
  border-radius: 8px;
  padding: 8px 12px;
  color: white;
  background: #334155;
  font-weight: 600;
  cursor: pointer;

  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.pdf-btn:hover {
  opacity: 0.9;
}

.pdf-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-btn {
  flex: 1;
  background: #2563eb;
}

.save-btn.secondary {
  background: #64748b;
}

.save-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.edit-prices-btn {
  background: #475569;
}

.save-btn:hover:not(:disabled),
.edit-prices-btn:hover {
  opacity: 0.9;
}

.price-list {
  display: flex;
  flex-direction: column;
  gap: 7px;

  max-height: 60vh;
  overflow-y: auto;

  padding-right: 3px;
}

.price-row {
  display: grid;

  grid-template-columns:
    minmax(0, 1fr)
    110px;

  gap: 8px;
  align-items: center;
}

.price-label {
  overflow-wrap: anywhere;
}

.price-row input {
  width: 110px;

  border: 1px solid #d1d5db;
  border-radius: 7px;

  padding: 7px;

  text-align: right;
}

.dialog-done-btn {
  border: none;
  border-radius: 8px;

  padding: 8px 16px;

  background: #2563eb;
  color: white;

  font-weight: 600;
  cursor: pointer;
}

:deep(.p-dialog) {
  border-radius: 12px;
  overflow: hidden;
}

:deep(.p-dialog-header) {
  padding: 13px 16px;
}

:deep(.p-dialog-content) {
  padding: 8px 16px 16px;
}

:deep(.p-dialog-footer) {
  padding: 10px 16px 13px;
}

@media (max-width: 700px) {
  .material-form {
    padding: 3px;
    gap: 5px;
  }

  .project-selector { 
    gap: 2px; 
  } 
  .field-label { 
    font-size: 9px; 
    line-height: 1.1;
  }
  :deep(.p-autocomplete) {
    width: 100%;
  }
  :deep(.p-autocomplete-input) { 
    min-height: 30px; 
    height: 30px;
    padding: 2px 7px; 
    font-size: 10.5px; 
  } 
  :deep(.p-autocomplete-dropdown) { 
    width: 30px; 
    min-height: 30px; 
  } 

  .project-option { 
    padding: 2px 0; 
    gap: 0;
    line-height: 1.1;
  } 
  .city { 
    font-size: 10.5px; 
    line-height: 1.1;
  }
  .address { 
    font-size: 9.5px; 
    line-height: 1.1;
  }

  .material-header,
  .material-row {
    grid-template-columns:
      minmax(105px, 1.45fr)
      50px
      34px
      minmax(78px, 1fr);

    column-gap: 4px;
  }

  .materials-container { 
    width: 100%; 
    overflow-x: hidden; 
  }

  .material-header {
    min-height: 18px;
    padding: 1px 3px;

    font-size: 7.5px;
    letter-spacing: 0.01em;
  }

  .material-header > div {
    min-width: 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .material-row {
    min-height: 24px;
    height: 24px;
    padding: 1px 3px;
  }

  .material-name {
    font-size: 9.5px;
    line-height: 1.05;
    min-width: 0;

    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .quantity-cell input {
    width: 44px;
    height: 21px;
    border-radius: 4px;
    padding: 1px 2px;
    font-size: 10px;
  }

  .unit-cell {
    font-size: 8.5px;
    line-height: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .material-note-input {
    width: 100%;
    height: 26px;
    min-height: 26px;
    padding: 2px 5px;
    border-radius: 5px;
    font-size: 9px;
    line-height: 1.1;
  }

  .material-note {
    font-size: 9px;
    line-height: 1.1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .other-section {
    gap: 2px; 
    margin-top: 2px; 
    padding: 3px;
  }
  .other-section label { 
    font-size: 9px; 
    line-height: 1;
  } 
  .other-section textarea { 
    min-height: 29px; 
    padding: 3px 5px; 
    border-radius: 5px; 
    font-size: 9.5px; 
  }

  .actions {
    /*flex-direction: column;
    gap: 5px;*/
    display: grid;
    gap: 4px;
  }

.actions.actions-view {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.actions.actions-editing {
  grid-template-columns: 1fr;
}
.save-btn,
.edit-prices-btn,
.pdf-btn {
  width: 100%;
  min-height: 32px;
  height: 32px;
  padding: 4px 5px;
  border-radius: 6px;
  font-size: 9.5px;

  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}
  .price-row {
    grid-template-columns:
      minmax(0, 1fr)
      85px;
  }

  .price-row input {
    width: 85px;
  }

  :deep(.p-dialog) {
    width: calc(100vw - 14px) !important;
    max-width: calc(100vw - 14px) !important;
  }

  :deep(.p-dialog-content) {
    padding-left: 10px;
    padding-right: 10px;
  }
  :deep(.p-dialog-header) { 
    padding: 11px 12px; 
  } 
  :deep(.p-dialog-footer) { 
    padding: 8px 12px 10px; 
  }

}
</style>