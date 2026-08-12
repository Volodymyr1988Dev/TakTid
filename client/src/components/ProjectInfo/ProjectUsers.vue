<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { ProjectStats } from '../../types/projectStats.type'

defineProps<{
  projectId: string
  stats: ProjectStats
  isAdmin: boolean
  expandedUserId: string | null
  loadingProjectUserId:
    | string
    | null
  projectUserEntries: Record<
    string,
    any[]
  >
}>()

const emit = defineEmits<{
  (e: 'toggle', userId: string): void
}>()

const { t } = useI18n()

function getWorkerSalary(
  worker: any,
): number {
  const salary =
    Number(worker.currentSalary) || 0

  const hours =
    Number(worker.totalHours) || 0

  return salary * hours
}

function getWorkerSalaryWithTax(
  worker: any,
): number {
  return getWorkerSalary(worker) * 0.3142
}

function getWorkerSalaryWithMultiTax(
  worker: any,
): number {
  return (
    getWorkerSalary(worker) *
    (1 - 1.55)
  )
}
</script>

<template>
  <section class="users-section">
    <div
      v-for="user in stats.users || []"
      :key="user.id"
      class="user-card"
      :class="{
        clickable: isAdmin,
      }"
      @click="
        isAdmin &&
        emit('toggle', user.id)
      "
    >
      <div class="user-header">
        <div>
          <strong>
            {{ user.name }}
          </strong>

          <div class="email">
            {{ user.email }}
          </div>
        </div>

        <div class="hours">
          <div class="hours-breakdown">
            <span class="work">
              {{ t('stats.work') }}
              {{ user.workHours }}h
            </span>

            <span class="extra">
              {{ t('stats.extra') }}
              {{ user.extraHours }}h
            </span>

            <span class="total">
              {{ t('stats.total') }}
              {{ user.totalHours }}h
            </span>
          </div>

          <div class="salary-info">
            <span>
              {{ t('account.salary') }}:
              {{
                getWorkerSalary(user)
                  .toFixed(0)
              }}
              kr
            </span>

            <span class="tax">
              {{ t('account.employer31Tax') }}:
              {{
                getWorkerSalaryWithTax(user)
                  .toFixed(0)
              }}
              kr
            </span>

            <span class="tax">
              {{ t('account.employerTax') }}:
              {{
                getWorkerSalaryWithMultiTax(user)
                  .toFixed(0)
              }}
              kr
            </span>
          </div>

          <button
            v-if="isAdmin"
            class="details-btn"
            @click.stop="
              emit('toggle', user.id)
            "
          >
            {{
              expandedUserId === user.id
                ? t(
                    'project.hideDetails',
                  )
                : t(
                    'project.showDetails',
                  )
            }}
          </button>
        </div>
      </div>

      <div
        v-if="
          expandedUserId === user.id
        "
        class="details"
      >
        <div
          v-if="
            loadingProjectUserId ===
            user.id
          "
          class="details-skeleton"
        >
          <div
            v-for="n in 3"
            :key="n"
            class="skeleton-line"
          />
        </div>

        <div v-else>
          <div
            v-for="entry in
              projectUserEntries[
                `${projectId}-${user.id}`
              ] || []"
            :key="entry.id"
            class="entry"
          >
            <div class="date">
              {{ entry.date }}
            </div>

            <div>
              {{ entry.hours }}h
              ({{ entry.type }})
            </div>

            <div
              v-if="entry.comment"
              class="comment"
            >
              {{ entry.comment }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.user-card {
  border: 1px solid #eee;
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 12px;
  background: white;
  transition: .2s;
}

.user-card.clickable {
  cursor: pointer;
}

.user-card.clickable:hover {
  background: #f1f5f9;
  box-shadow: 0 4px 12px rgba(0,0,0,.05);
}

.user-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.email {
  font-size: 11px;
  color: #94a3b8;
  overflow-wrap: anywhere;
}

.hours {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
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

.salary-info {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 13px;
  padding-top: 10px;
  border-top: 1px solid #f1f5f9;
}

.salary-info span:first-child {
  color: #0f172a;
  font-weight: 600;
}

.tax {
  color: #ef4444;
  font-weight: 500;
  opacity: .85;
}

.details-btn {
  padding: 8px 14px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  background: #2563eb;
  color: white;
  font-weight: 500;
}

.details {
  margin-top: 12px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 10px;
}

.entry {
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}

.comment {
  margin-top: 4px;
  color: #64748b;
}

.skeleton-line {
  height: 14px;
  margin-bottom: 8px;
  border-radius: 6px;
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 37%,
    #f0f0f0 63%
  );
  background-size: 400% 100%;
  animation: shimmer 1.4s ease infinite;
}

@keyframes shimmer {
  0% {
    background-position: 100% 0;
  }

  100% {
    background-position: 0 0;
  }
}

@media (max-width: 640px) {
  .user-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .hours {
    width: 100%;
    align-items: flex-start;
  }

  .hours-breakdown {
    flex-wrap: wrap;
  }

  .details-btn {
    width: 100%;
  }
}
</style>