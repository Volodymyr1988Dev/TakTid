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

function createEmptyItems(): MaterialItem[] {
  return MATERIAL_CATALOG.map(material => ({
    materialKey: material.key,
    quantity: null,
    price: null,
    note: null,
  }))
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

function searchProjects(
  event: { query: string },
) {
  const query = event.query
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
            materialKey:
              item.materialKey,

            quantity:
              item.quantity,

            price:
              item.price,

            note:
              item.note?.trim() || null,
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

/* PROJECT */

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
  color: var(
    --primary-color,
    #2563eb
  );
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

/* MATERIALS */

.materials-container {
  width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.material-header,
.material-row {
  display: grid;

  /*
   * Material | Quantity | Unit | Note
   */
  grid-template-columns:
    minmax(180px, 1.5fr)
    90px
    70px
    minmax(150px, 1fr);

  column-gap: 10px;
  align-items: center;
}

.material-header {
  min-height: 32px;
  padding: 5px 8px;

  color: #64748b;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.02em;

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
  min-height: 46px;
  padding: 5px 8px;

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

/* QUANTITY */

.quantity-cell {
  display: flex;
  align-items: center;
  justify-content: center;

  min-width: 0;
}

.quantity-cell input {
  width: 76px;
  height: 34px;

  border: 1px solid #d1d5db;
  border-radius: 7px;

  padding: 5px 6px;

  text-align: center;

  background: white;
  color: #111827;

  font-size: 13px;
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

/* UNIT */

.unit-cell {
  min-width: 0;

  color: #64748b;
  font-size: 12px;

  text-align: center;
  white-space: nowrap;

  overflow: hidden;
  text-overflow: ellipsis;
}

/* NOTE */

.note-cell {
  min-width: 0;
}

.material-note-input {
  width: 100%;
  min-height: 32px;
  height: 32px;

  margin: 0;
  padding: 6px 8px;

  border: 1px solid #d1d5db;
  border-radius: 7px;

  background: #fff;
  color: #111827;

  font-family: inherit;
  font-size: 12px;
  line-height: 1.35;

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
  font-size: 12px;
  line-height: 1.35;

  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
/* OTHER */

.other-section {
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-top: 8px;
  padding: 8px;
  border-top: 1px solid #e2e8f0;
}

.other-section label {
  color: #475569;
  font-size: 12px;
  font-weight: 600;
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
  font-size: 13px;
  line-height: 1.4;

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

/* ACTIONS */

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

/* PRICE DIALOG */

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

/* DIALOG */

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

/* MOBILE */

@media (max-width: 700px) {
  .material-form {
    padding: 6px;
    gap: 10px;
  }

  .materials-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .material-header,
  .material-row {
    grid-template-columns:
      minmax(120px, 1.35fr)
      62px
      55px
      minmax(110px, 1fr);

    column-gap: 6px;
  }

  .material-header {
    min-height: 30px;
    padding: 4px 5px;

    font-size: 9px;
    letter-spacing: 0.01em;
  }

  .material-header > div {
    white-space: nowrap;
  }

  .material-row {
    min-height: 42px;
    padding: 4px 5px;
  }

  .material-name {
    font-size: 12px;
    line-height: 1.2;
  }

  .quantity-cell input {
    width: 58px;
    height: 32px;

    padding: 4px;
    font-size: 12px;
  }

  .unit-cell {
    font-size: 10px;
  }

  .material-note-input {
    height: 32px;
    min-height: 32px;

    padding: 5px 6px;
    font-size: 11px;
  }

  .material-note {
    font-size: 11px;
  }

  .other-section {
    padding: 6px;
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