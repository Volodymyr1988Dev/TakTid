<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { numberOrNull } from '../helpers/helpers'
import type { ProjectStats } from '../../types/projectStats.type'

const props = defineProps<{
  stats: ProjectStats
  isAdmin: boolean

  totalProjectPrice: number
  extraHoursPrice: number
  workersCost: number
  profit: number

  area: number | null
  price: number | null
  extraPrice: number | null

  editMode:
    | 'area'
    | 'price'
    | 'extraPrice'
    | null
}>()

const emit = defineEmits<{
  'update:area': [
    value: number | null,
  ]

  'update:price': [
    value: number | null,
  ]

  'update:extraPrice': [
    value: number | null,
  ]

  'update:editMode': [
    value:
      | 'area'
      | 'price'
      | 'extraPrice'
      | null,
  ]

  saveArea: []
  savePrice: []
  saveExtraPrice: []
}>()

const { t } = useI18n()

const showEdit = ref(false)
</script>

<template>
  <section class="metrics-section">
    <div class="metrics-header">
      <h3>
        {{ t('project.metrics') }}
      </h3>

      <button
        v-if="isAdmin"
        class="edit-project-btn"
        @click="showEdit = !showEdit"
      >
        {{
          showEdit
            ? t('common.close')
            : t('project.editProject')
        }}
      </button>
    </div>

    <div class="metrics-wrapper">
      <div class="metric-card">
        <div class="metric-title">
          {{ t('project.totalProjectPrice') }}
        </div>

        <div class="metric-value">
          {{ totalProjectPrice.toLocaleString() }}
          kr
        </div>
      </div>

      <div class="metric-card extra-income">
        <div class="metric-title">
          {{ t('project.extraHoursIncome') }}
        </div>

        <div class="metric-value">
          {{ extraHoursPrice.toLocaleString() }}
          kr
        </div>
      </div>

      <div class="metric-card workers-cost">
        <div class="metric-title">
          {{ t('project.workersCost') }}
        </div>

        <div class="metric-value">
          {{ workersCost.toLocaleString() }}
          kr
        </div>
      </div>

      <div
        class="metric-card profit-card"
        :class="
          profit >= 0
            ? 'profit-positive'
            : 'profit-negative'
        "
      >
        <div class="metric-title">
          {{ t('project.profit') }}
        </div>

        <div
          class="metric-value"
          :class="{
            negative: profit < 0,
          }"
        >
          {{ profit.toLocaleString() }}
          kr
        </div>
      </div>
    </div>

    <div
      v-if="showEdit"
      class="edit-menu"
    >
      <button
        class="edit-btn"
        @click="
          emit('update:editMode', 'area')
        "
      >
        {{ t('project.changeArea') }}
      </button>

      <button
        class="edit-btn"
        @click="
          emit('update:editMode', 'price')
        "
      >
        {{ t('project.changePricePerM2') }}
      </button>

      <button
        class="edit-btn"
        @click="
          emit(
            'update:editMode',
            'extraPrice',
          )
        "
      >
        {{ t('project.changeExtraHourPrice') }}
      </button>
    </div>

    <div class="project-small-info">
      <div>
        {{ t('project.area') }}:
        {{ stats.project.areaM2 }} m²
      </div>

      <div>
        {{ t('project.pricePerM2') }}:
        {{ stats.project.pricePerM2 }}
      </div>

      <div>
        {{ t('project.pricePerExtraHour') }}:
        {{ stats.project.pricePerExtraH }} kr
      </div>

      <div>
        {{ t('project.extraHoursIncome') }}:
        {{ extraHoursPrice.toLocaleString() }}
        kr
      </div>
    </div>

    <div
      v-if="editMode === 'area'"
      class="modal"
    >
      <div class="modal-content">
        <label for="area">
          {{ t('project.area') }}
        </label>

        <input
          id="area"
          :value="area"
          type="number"
          :placeholder="
            t('project.area')
          "
          @input="
            emit(
              'update:area',
              numberOrNull($event),
            )
          "
        >
        <!-- Number(
                ($event.target as HTMLInputElement)
                  .value,
              ) || null, -->
        <button
          class="edit-btn"
          @click="emit('saveArea')"
        >
          {{ t('project.saveArea') }}
        </button>
      </div>
    </div>

    <div
      v-if="editMode === 'price'"
      class="modal"
    >
      <div class="modal-content">
        <label for="price">
          {{ t('project.pricePerM2') }}
        </label>

        <input
          id="price"
          :value="price"
          type="number"
          :placeholder="
            t('project.pricePerM2')
          "
          @input="
            emit(
              'update:price',
              numberOrNull($event),
            )
          "
        >
        <!-- Number(
                ($event.target as HTMLInputElement)
                  .value,
              ) || null, -->
        <button
          class="edit-btn"
          @click="emit('savePrice')"
        >
          {{ t('project.savePrice') }}
        </button>
      </div>
    </div>

    <div
      v-if="editMode === 'extraPrice'"
      class="modal"
    >
      <div class="modal-content">
        <label for="extraPrice">
          {{ t('project.pricePerExtraHour') }}
        </label>

        <input
          id="extraPrice"
          :value="extraPrice"
          type="number"
          @input="
            emit(
              'update:extraPrice',
              numberOrNull($event),
            )
          "
        >
        <!-- Number(
                ($event.target as HTMLInputElement)
                  .value,
              ) || null, -->
        <button
          class="edit-btn"
          @click="
            emit('saveExtraPrice')
          "
        >
          {{
            t(
              'project.saveExtraHourPrice',
            )
          }}
        </button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.metrics-section {
  margin-bottom: 20px;
}

.metrics-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.metrics-header h3 {
  margin: 0;
}

.metrics-wrapper {
  display: grid;
  grid-template-columns:
    repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.metric-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 2px 8px rgba(0, 0, 0, .04);
}

.metric-title {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 8px;
}

.metric-value {
  font-size: 30px;
  font-weight: 700;
  color: #111827;
}

.workers-cost {
  background: #fafafa;
  border-color: #f1f5f9;
  box-shadow: none;
}

.workers-cost .metric-value {
  color: #dc2626;
  font-size: 24px;
}

.extra-income {
  background: #f8fff9;
  border-color: #dcfce7;
  box-shadow: none;
}

.extra-income .metric-value {
  color: #16a34a;
  font-size: 24px;
}

.profit-positive {
  border: 2px solid #16a34a;
  background: #f0fdf4;
}

.profit-negative {
  border: 2px solid #dc2626;
  background: #fef2f2;
}

.profit-positive .metric-value {
  color: #16a34a;
}

.profit-negative .metric-value {
  color: #dc2626;
}

.negative {
  color: #dc2626;
}

.project-small-info {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  font-size: 12px;
  color: #888;
}

.edit-menu {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

.edit-project-btn,
.edit-btn {
  border: none;
  background: #2563eb;
  color: white;
  padding: 8px 14px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
}

.edit-project-btn:hover,
.edit-btn:hover {
  background: #1d4ed8;
}

.modal {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(0, 0, 0, .45);
}

.modal-content {
  width: min(420px, 100%);
  padding: 20px;
  border-radius: 16px;
  background: white;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.modal-content input {
  padding: 10px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
}

@media (max-width: 768px) {
  .metrics-wrapper {
    grid-template-columns: 1fr;
  }

  .metric-card {
    padding: 16px;
  }

  .metric-value {
    font-size: 24px;
  }

  .project-small-info {
    display: grid;
    grid-template-columns: 1fr;
    gap: 6px;
  }

  .metrics-header {
    align-items: flex-start;
    gap: 10px;
  }
}
</style>