<script setup lang="ts">
import type { Project } from '../../types/Project.dto'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
defineProps<{
  project: Project
}>()
function formatProjectDate(
  date: string | null | undefined,
): string {
  if (!date) return '—';

  const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(date);

  if (!match) return '—';

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);

  return new Intl.DateTimeFormat('sv-SE', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(new Date(year, month - 1, day));
}
</script>

<template>
  <div class="project-header">
    <h2>
      {{ project.city }}
      –
      {{ project.address }}
    </h2>

      <div class="project-dates">
      <div class="project-date-item">
        <span class="project-date-label">
          {{ t('project.startDate') }}
        </span>

        <span class="project-date-value">
          {{ formatProjectDate(project.startDate) }}
        </span>
      </div>

      <div class="project-date-item">
        <span class="project-date-label">
          {{ t('project.endDate') }}
        </span>

        <span
          v-if="project.isCompleted && project.endDate"
          class="project-date-value project-date-completed"
        >
          {{ formatProjectDate(project.endDate) }}
        </span>

        <span
          v-else
          class="project-date-value project-date-active"
        >
          {{ t('project.inProgress') }}
        </span>
      </div>

      <div
        v-if="project.durationDays != null"
        class="project-date-item"
      >
        <span class="project-date-label">
          {{ t('project.duration') }}
        </span>

        <span class="project-date-value">
          {{ project.durationDays }}
          {{ t('project.calendarDays') }}
        </span>
      </div>
    </div>

  </div>
</template>

<style scoped>
.project-header {
  margin-bottom: 20px;
}

.project-header h2 {
  margin: 0;
  color: #111827;
  font-size: 22px;
  line-height: 1.3;
}

.project-dates {
  display: flex;
  flex-wrap: wrap;
  align-items: stretch;
  gap: 10px;
  margin-top: 12px;
}

.project-date-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
  min-width: 125px;
  padding: 10px 13px;
  border: 1px solid var(--surface-border, #e2e8f0);
  border-radius: 10px;
  background: var(--surface-card, #ffffff);
}

.project-date-label {
  color: var(--text-color-secondary, #64748b);
  font-size: 12px;
  font-weight: 500;
}

.project-date-value {
  color: var(--text-color, #1e293b);
  font-size: 14px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.project-date-completed {
  color: #15803d;
}

.project-date-active {
  color: #b45309;
}

@media (max-width: 480px) {
  .project-dates {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
  }

  .project-date-item {
    min-width: 0;
    padding: 9px 10px;
  }

  .project-date-value {
    font-size: 13px;
  }
}
</style>