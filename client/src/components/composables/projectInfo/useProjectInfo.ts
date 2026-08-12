import {
  computed,
  ref,
  type Ref,
} from 'vue'
import { useI18n } from 'vue-i18n'

import { getProjectStats } from '../../../api/projectStats.api'
import { useProjectStore } from '../../../stores/project.store'
import { useStatsStore } from '../../../stores/stats.store'

import type { ProjectStats } from '../../../types/projectStats.type'
import type { TimeEntry } from '../../../types/TimeEntry.type'

const EMPLOYER_TAX = 0.3142
const EMPLOYER_MULTIPLIER = 1.55

export function useProjectInfo(
  projectId: Ref<string>,
  isAdmin: Ref<boolean>,
) {
  const { t } = useI18n()

  const projectStore = useProjectStore()
  const statsStore = useStatsStore()

  const stats = ref<ProjectStats | null>(null)

  const loading = ref(true)
  const error = ref<string | null>(null)

  const area = ref<number | null>(null)
  const price = ref<number | null>(null)
  const extraPrice = ref<number | null>(null)

  const editMode = ref<
    'area' | 'price' | 'extraPrice' | null
  >(null)

  const showEdit = ref(false)

  const expandedUserId = ref<string | null>(null)

  const showDetails = ref<
    'work' | 'extra' | 'total' | null
  >(null)

  const loadingDetails = ref(false)

  let statsRequestId = 0

  async function loadStats(): Promise<void> {
    const id = projectId.value

    if (!id) {
      stats.value = null
      loading.value = false
      error.value = t('errors.missingProjectId')
      return
    }

    const requestId = ++statsRequestId

    loading.value = true
    error.value = null

    try {
      const { data } = await getProjectStats(id)

      if (requestId !== statsRequestId) {
        return
      }

      /*
       * Count is part of the same project loading operation.
       * If project changes while this request is running,
       * the result becomes obsolete.
       */
      await Promise.resolve()

      if (requestId !== statsRequestId) {
        return
      }

      stats.value = data

      area.value =
        data.project.areaM2 ?? null

      price.value =
        data.project.pricePerM2 ?? null

      extraPrice.value =
        data.project.pricePerExtraH ?? null
    } catch (err: unknown) {
      if (requestId !== statsRequestId) {
        return
      }

      const status =
        (
          err as {
            response?: {
              status?: number
            }
          }
        )?.response?.status

      error.value =
        status === 403
          ? t('errors.accessDenied')
          : t('errors.loadStats')
    } finally {
      if (requestId === statsRequestId) {
        loading.value = false
      }
    }
  }

  async function saveArea(): Promise<void> {
    await projectStore.updateProject(
      projectId.value,
      {
        areaM2: area.value,
      },
    )

    editMode.value = null

    await loadStats()
  }

  async function savePrice(): Promise<void> {
    await projectStore.updateProject(
      projectId.value,
      {
        pricePerM2: price.value,
      },
    )

    editMode.value = null

    await loadStats()
  }

  async function saveExtraPrice(): Promise<void> {
    await projectStore.updateProject(
      projectId.value,
      {
        pricePerExtraH: extraPrice.value,
      },
    )

    editMode.value = null

    await loadStats()
  }

  async function toggleDetails(
    userId: string,
  ): Promise<void> {
    if (!isAdmin.value) {
      return
    }

    if (
      expandedUserId.value === userId
    ) {
      expandedUserId.value = null
      return
    }

    expandedUserId.value = userId

    await statsStore.loadProjectUserEntries(
      projectId.value,
      userId,
    )
  }

  async function loadProjectDetails(): Promise<void> {
    if (!isAdmin.value) {
      return
    }

    loadingDetails.value = true

    try {
      await projectStore.loadDetails(
        projectId.value,
      )
    } finally {
      loadingDetails.value = false
    }
  }

  async function toggleSummary(
    type: 'work' | 'extra' | 'total',
  ): Promise<void> {
    if (!isAdmin.value) {
      return
    }

    if (showDetails.value === type) {
      showDetails.value = null
      return
    }

    showDetails.value = type

    await loadProjectDetails()
  }

  const filteredDetails = computed(() => {
    if (!showDetails.value) {
      return []
    }

    if (showDetails.value === 'total') {
      return projectStore.projectDetails
    }

    return projectStore.projectDetails.filter(
      (entry: TimeEntry) =>
        showDetails.value === 'work'
          ? entry.type === 'WORK'
          : entry.type === 'EXTRA',
    )
  })

  const totalWork = computed(
    () => stats.value?.total.work ?? 0,
  )

  const totalExtra = computed(
    () => stats.value?.total.extra ?? 0,
  )

  const totalAll = computed(
    () =>
      totalWork.value +
      totalExtra.value,
  )

  const totalProjectPrice = computed(
    () =>
      stats.value?.totalProjectPrice ?? 0,
  )

  const extraHoursPrice = computed(
    () =>
      stats.value?.extraHoursPrice ?? 0,
  )

  const workersCost = computed(() => {
    const users = stats.value?.users

    if (!users?.length) {
      return 0
    }

    return users.reduce(
      (sum: number, worker) => {
        const salary =
          Number(worker.currentSalary) || 0

        const hours =
          Number(worker.totalHours) || 0

        return (
          sum +
          hours *
            salary *
            EMPLOYER_MULTIPLIER
        )
      },
      0,
    )
  })

  const profit = computed(() => {
    return (
      totalProjectPrice.value -
      workersCost.value
    )
  })

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
    return (
      getWorkerSalary(worker) *
      EMPLOYER_TAX
    )
  }

  function getWorkerSalaryWithMultiTax(
    worker: any,
  ): number {
    return (
      getWorkerSalary(worker) *
      (1 - EMPLOYER_MULTIPLIER)
    )
  }

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

  function resetForProject(): void {
    stats.value = null
    error.value = null

    area.value = null
    price.value = null
    extraPrice.value = null

    editMode.value = null
    showEdit.value = false
    expandedUserId.value = null
    showDetails.value = null
  }

  return {
    stats,
    loading,
    error,

    area,
    price,
    extraPrice,

    editMode,
    showEdit,

    expandedUserId,

    showDetails,
    loadingDetails,

    filteredDetails,

    totalWork,
    totalExtra,
    totalAll,

    totalProjectPrice,
    extraHoursPrice,

    workersCost,
    profit,

    loadStats,
    saveArea,
    savePrice,
    saveExtraPrice,

    toggleDetails,
    toggleSummary,

    getWorkerSalary,
    getWorkerSalaryWithTax,
    getWorkerSalaryWithMultiTax,

    detailBadge,

    resetForProject,
  }
}