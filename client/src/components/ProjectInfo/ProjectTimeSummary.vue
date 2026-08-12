<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { TimeEntry } from '../../types/TimeEntry.type'

const props = defineProps<{
  isAdmin: boolean
  totalWork: number
  totalExtra: number
  totalAll: number
  showDetails:
    | 'work'
    | 'extra'
    | 'total'
    | null
  filteredDetails: TimeEntry[]
  loadingDetails: boolean
}>()

const emit = defineEmits<{
  (
    e: 'toggle',
    type: 'work' | 'extra' | 'total',
  ): void
}>()

const { t } = useI18n()

function detailBadge(type: string) {
  switch (type) {
    case 'WORK':
      return {
        icon: '🛠',
        text: t('stats.work'),
        class: 'badge-work',
      }

    case 'EXTRA':
      return {
        icon: '💼',
        text: t('stats.extra'),
        class: 'badge-extra',
      }

    default:
      return {
        icon: '⏱',
        text: type,
        class: 'badge-default',
      }
  }
}
</script>

<template>
  <section class="time-summary">
    <div class="summary">
      <div
        class="summary-item work"
        :class="{
          active: showDetails === 'work',
          clickable: isAdmin,
        }"
        @click="
          isAdmin &&
          emit('toggle', 'work')
        "
      >
        🛠
        {{ t('stats.work') }}
        <strong>
          {{ totalWork }}h
        </strong>
      </div>

      <div
        class="summary-item extra"
        :class="{
          active: showDetails === 'extra',
          clickable: isAdmin,
        }"
        @click="
          isAdmin &&
          emit('toggle', 'extra')
        "
      >
        💼
        {{ t('stats.extra') }}
        <strong>
          {{ totalExtra }}h
        </strong>
      </div>

      <div
        class="summary-item total"
        :class="{
          active: showDetails === 'total',
          clickable: isAdmin,
        }"
        @click="
          isAdmin &&
          emit('toggle', 'total')
        "
      >
        ⏱
        {{ t('stats.total') }}
        <strong>
          {{ totalAll }}h
        </strong>
      </div>
    </div>

    <div
      v-if="loadingDetails"
      class="loading-details"
    >
      {{ t('common.loading') }}
    </div>

    <div
      v-else-if="isAdmin && showDetails"
      class="details-list"
    >
      <div
        v-for="entry in filteredDetails"
        :key="entry.id"
        class="detail-row"
      >
        <div class="detail-top">
          <span
            class="type-badge"
            :class="
              detailBadge(entry.type).class
            "
          >
            {{ detailBadge(entry.type).icon }}
            {{ detailBadge(entry.type).text }}
          </span>

          <span class="detail-date">
            {{ entry.date }}
          </span>

          <span class="detail-hours">
            {{ entry.hours }}h
          </span>
        </div>

        <div class="user-info">
          <div class="name">
            {{ entry.user?.name }}
          </div>

          <div class="email">
            {{ entry.user?.email }}
          </div>
        </div>

        <div
          v-if="entry.comment"
          class="detail-comment"
        >
          {{ entry.comment }}
        </div>
      </div>
    </div>

    <div
      v-else
      class="user-summary"
    >
      <div class="user-card">
        <div class="hours-breakdown">
          <span class="work">
            {{ t('stats.work') }}
            {{ totalWork }}h
          </span>

          <span class="extra">
            {{ t('stats.extra') }}
            {{ totalExtra }}h
          </span>

          <span class="total">
            {{ t('stats.total') }}
            {{ totalAll }}h
          </span>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.summary {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.summary-item {
  padding: 8px 14px;
  border-radius: 10px;
  font-weight: 500;
  user-select: none;
  transition: .2s;
}

.summary-item.work {
  color: #2ecc71;
}

.summary-item.extra {
  color: #d4a900;
}

.summary-item.total {
  color: #111827;
}

.summary-item.clickable {
  cursor: pointer;
  border: 1px solid #e5e7eb;
  background: white;
}

.summary-item.clickable:hover {
  background: #f1f5f9;
  transform: translateY(-1px);
}

.summary-item.active {
  background: #2563eb;
  color: white;
  border-color: #2563eb;
}

.detail-row {
  padding: 12px 0;
  border-bottom: 1px solid #eee;
}

.detail-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.type-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 14px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 600;
}

.badge-work {
  background: #2ecc71;
  color: white;
}

.badge-extra {
  background: #f1c40f;
  color: black;
}

.badge-default {
  background: #94a3b8;
  color: white;
}

.detail-date {
  color: #64748b;
}

.detail-hours {
  white-space: nowrap;
  font-weight: 600;
}

.user-info {
  margin-top: 8px;
}

.name {
  font-weight: 600;
  font-size: 14px;
}

.email {
  font-size: 11px;
  color: #94a3b8;
  overflow-wrap: anywhere;
}

.detail-comment {
  margin-top: 8px;
  word-break: break-word;
  font-size: 13px;
  color: #666;
}

.user-card {
  border: 1px solid #eee;
  padding: 16px;
  border-radius: 12px;
  background: white;
}

.hours-breakdown {
  display: flex;
  gap: 12px;
  font-size: 13px;
}

.work {
  color: #2ecc71;
}

.extra {
  color: #d4a900;
}

.total {
  font-weight: 600;
}

@media (max-width: 640px) {
  .summary {
    flex-direction: column;
    gap: 8px;
  }

  .summary-item {
    width: 100%;
    text-align: center;
  }

  .detail-row {
    padding: 14px;
    margin-bottom: 12px;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    background: white;
  }

  .detail-top {
    flex-direction: column;
    align-items: flex-start;
  }

  .hours-breakdown {
    flex-direction: column;
    gap: 6px;
  }
}
</style>