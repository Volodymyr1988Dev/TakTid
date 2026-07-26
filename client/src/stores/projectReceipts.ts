import { defineStore } from 'pinia'
import { ref } from 'vue'

import {
  getProjectReceipts,
  getProjectReceiptsPaginated,
  uploadProjectReceipts,
  removeProjectReceipt,
  getProjectReceiptsCount,
} from '../api/projectReceipts'

import type { ProjectReceipt } from '../types/projectReceipts.type'

export const useProjectReceiptStore = defineStore(
  'projectReceipts',
  () => {
    const receipts = ref<ProjectReceipt[]>([])
    const loading = ref(false)

    async function load(projectId: string) {
      loading.value = true

      try {
        const { data } =
          await getProjectReceipts(projectId)

        receipts.value = data
      } finally {
        loading.value = false
      }
    }

    async function loadPaginated(
      projectId: string,
      page: number,
      limit: number,
    ) {
      loading.value = true

      try {
        const { data } =
          await getProjectReceiptsPaginated(
            projectId,
            page,
            limit,
          )

        if (page === 1) {
          receipts.value = data.data
        } else {
          receipts.value.push(...data.data)
        }

        return data
      } finally {
        loading.value = false
      }
    }

    async function upload(
      projectId: string,
      files: File[],
    ) {
      if (!projectId || files.length === 0) return

      const { data } =
        await uploadProjectReceipts(
          projectId,
          files,
        )

      receipts.value.unshift(...data)
    }


    async function getCount(projectId: string) {
      const { data } = await getProjectReceiptsCount(
        projectId,
      )
      return data.count
    }

    async function remove(
      receiptId: string,
    ) {
      await removeProjectReceipt(
        receiptId,
      )

      receipts.value =
        receipts.value.filter(
          r => r.id !== receiptId,
        )
    }

    return {
      receipts,
      loading,
      load,
      loadPaginated,
      upload,
      remove,
      getCount,
    }
  },
)