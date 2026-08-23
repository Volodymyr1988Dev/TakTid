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
import { MATERIAL_CATALOG, getMaterialDefinition } from '../const/MaterialCatalog'

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

const textareaRef =
  ref<HTMLTextAreaElement | null>(null)

function createEmptyItems(): MaterialItem[] {
  return MATERIAL_CATALOG.map(material => ({
    materialKey: material.key,
    quantity: null,
    price: null,
    note: null,
  }))
}


const materialForm =
  reactive<MaterialFormState>({
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

function resetForm() {
  materialForm.other = ''
  materialForm.items = createEmptyItems()
}

function fillFormFromList() {
  const list = materialStore.materialList

  if (!list) {
    resetForm()
    return
  }

  materialForm.other =
    list.other ?? ''

  materialForm.items =
    MATERIAL_CATALOG.map(material => {
      const existing =
        list.items?.find(
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
        note:
          existing?.note ?? null,
      }
    })
}

function searchProjects(
  event: { query: string },
) {
  const query =
    event.query
      .trim()
      .toLowerCase()

  if (!query) {
    filteredProjects.value =
      projectStore.projects

    return
  }

  filteredProjects.value =
    projectStore.projects.filter(
      project =>
        project.address
          ?.toLowerCase()
          .includes(query) ||
        project.city
          ?.toLowerCase()
          .includes(query),
    )
}
/*
function setSelectedProject(
  project: Project | null,
) {
  selectedProject.value = project

  materialForm.projectId =
    project?.id ?? ''
}
*/
async function setSelectedProject(
  project: Project | null,
) {
  selectedProject.value =
    project

  const id =
    project?.id ?? ''

  if (!id) {
    materialForm.projectId = ''
    materialStore.clear()
    resetForm()
    isEditing.value = true

    return
  }

  await loadProject(id)
}

//let projectLoadRequest = 0
async function loadProject(
  projectId: string,
) {
  //const requestId = ++projectLoadRequest

  if (!projectId) {
    //materialStore.materialList = null
    materialStore.clear()

    materialForm.projectId = ''

    resetForm()

    selectedProject.value = null
    isEditing.value = true

    return
  }

  materialForm.projectId = projectId

  const project =
    projectStore.projects.find(
      item => item.id === projectId,
    ) ?? null

  selectedProject.value = project

  await materialStore.load(projectId)

  if (materialStore.materialList) {
    fillFormFromList()

    isEditing.value = false
  } else {
    resetForm()

    isEditing.value = true
  }

  await autoResize()
}
/*
watch(
  () => selectedProject.value,
  async project => {
    const id = project?.id ?? ''

    if (!id) {
      return
    }

    if (id === materialForm.projectId) {
      await loadProject(id)
    }
  },
)
*/
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

function autoResize() {
  nextTick(() => {
    const textarea =
      textareaRef.value

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

      items:
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
            materialKey: item.materialKey,

            quantity:
              item.quantity,

            price:
              item.price,

            note:
              item.note?.trim() || null,
          })),
    }

    await materialStore.save(
      payload,
    )

    fillFormFromList()

    isEditing.value = false
  } finally {
    saving.value = false
  }
}

function openPriceModal() {
  priceDialog.value = true
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

    selectedProject.value =
      project

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

  return material
    ? t(material.labelKey)
    : materialKey
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
</script>

<template>
  <div class="material-form">

    <!-- PROJECT SELECTOR -->
    <div class="project-selector">
      <label class="field-label">
        {{ t('common.selectProject') }}
      </label>

      <AutoComplete
        :model-value="selectedProject"
        :suggestions="filteredProjects"
        option-label="address"
        dropdown
        force-selection
        :disabled="saving"
        @update:model-value="setSelectedProject"
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
      class="grid"
    >
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
        class="row"
      >
        <div class="label">
            <div class="material-name">
                {{ materialLabel(item.materialKey) }}
            </div>

            <textarea
                v-if="isEditing"
                v-model="item.note"
                class="material-note-input"
                rows="1"
                :placeholder="t('material.notePlaceholder')"
                :disabled="saving"
            />

            <div
                v-else-if="item.note"
                class="material-note"
            >
                {{ item.note }}
            </div>
            </div>

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
            />

            <span class="unit">
            {{ materialUnit(item.materialKey) }}
            </span>
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

    <!-- ACTIONS -->
    <div class="actions">

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
  gap: 14px;
  padding: 12px;
  color: #111827;
}

.project-selector {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  font-weight: 600;
  color: #475569;
}

.project-option {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 4px 0;
}

.city {
  font-weight: 700;
  color: var(--primary-color, #2563eb);
}

.address {
  font-size: 0.9rem;
  color: #64748b;
}

.empty-projects {
  padding: 10px;
  color: #64748b;
  font-size: 14px;
}

/*
 * PrimeVue AutoComplete
 */
:deep(.p-autocomplete) {
  width: 100%;
}

:deep(.p-autocomplete-input) {
  width: 100%;
  min-height: 42px;
  padding: 9px 12px;
  border: 1px solid #d1d5db;
  border-radius: 10px 0 0 10px;
  font-size: 14px;
}

:deep(.p-autocomplete-dropdown) {
  width: 44px;
  min-height: 42px;
  border-radius: 0 10px 10px 0;
  border: 1px solid #d1d5db;
  border-left: 0;
}

:deep(.p-autocomplete-panel) {
  border-radius: 10px;
  overflow: hidden;
}

:deep(.p-autocomplete-option) {
  padding: 9px 12px;
}

/*
 * MATERIAL GRID
 */
.grid {
  display: grid;
  gap: 6px;
}

.row {
  display: grid;
  grid-template-columns:
    minmax(0, 1fr)
    90px;
  gap: 8px;
  align-items: center;
}

.label {
  min-width: 0;
  white-space: normal;
  overflow-wrap: anywhere;
  line-height: 1.25;
}

.row input {
  width: 90px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 7px 6px;
  text-align: center;
  background: white;
  color: #111827;
}

.row input:disabled {
  background: #f8fafc;
  color: #475569;
}

/*
 * OTHER
 */
.other-section {
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-top: 6px;
}

.other-section textarea {
  width: 100%;
  min-height: 40px;
  resize: none;
  overflow: hidden;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 8px;
  font-family: inherit;
  line-height: 1.4;
}

/*
 * ACTIONS
 */
.actions {
  display: flex;
  gap: 10px;
  align-items: stretch;
  flex-wrap: wrap;
}

.save-btn,
.edit-prices-btn {
  border: none;
  border-radius: 10px;
  padding: 11px 16px;
  color: white;
  font-weight: 600;
  cursor: pointer;
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

/*
 * PRICE DIALOG
 */
.price-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 60vh;
  overflow-y: auto;
  padding-right: 3px;
}

.price-row {
  display: grid;
  grid-template-columns:
    minmax(0, 1fr)
    120px;
  gap: 10px;
  align-items: center;
}

.price-label {
  overflow-wrap: anywhere;
}

.price-row input {
  width: 120px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 8px;
  text-align: right;
}

.dialog-done-btn {
  border: none;
  border-radius: 9px;
  padding: 9px 18px;
  background: #2563eb;
  color: white;
  font-weight: 600;
  cursor: pointer;
}

/*
 * PrimeVue Dialog
 */
:deep(.p-dialog) {
  border-radius: 14px;
  overflow: hidden;
}

:deep(.p-dialog-header) {
  padding: 16px 20px;
}

:deep(.p-dialog-content) {
  padding: 10px 20px 20px;
}

:deep(.p-dialog-footer) {
  padding: 12px 20px 16px;
}
.quantity-cell {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
}

.quantity-cell input {
  width: 72px;
}

.unit {
  min-width: 34px;
  color: #64748b;
  font-size: 13px;
  white-space: nowrap;
}
.material-name {
  font-weight: 500;
}

.material-note {
  margin-top: 3px;
  font-size: 12px;
  line-height: 1.35;
  color: #64748b;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}

.material-note-input {
  width: 100%;
  min-height: 32px;
  margin-top: 5px;
  padding: 6px 8px;

  border: 1px solid #d1d5db;
  border-radius: 7px;

  background: #fff;
  color: #111827;

  font-family: inherit;
  font-size: 12px;
  line-height: 1.35;

  resize: vertical;
}

.material-note-input:focus {
  outline: none;
  border-color: var(--primary-color, #2563eb);
}
/*
 * MOBILE
 */
@media (max-width: 700px) {
  .material-form {
    padding: 8px;
  }

  .row {
    grid-template-columns:
      minmax(0, 1fr)
      72px;
    gap: 8px;
  }

  .label {
    font-size: 13px;
  }

  .row input {
    width: 72px;
    padding: 6px 4px;
  }

  .actions {
    flex-direction: column;
  }

  .save-btn,
  .edit-prices-btn {
    width: 100%;
    min-height: 44px;
  }

  .price-row {
    grid-template-columns:
      minmax(0, 1fr)
      90px;
  }

  .price-row input {
    width: 90px;
  }

  :deep(.p-dialog) {
    width: calc(100vw - 20px) !important;
    max-width: calc(100vw - 20px) !important;
  }

  :deep(.p-dialog-content) {
    padding-left: 14px;
    padding-right: 14px;
  }
}
</style>