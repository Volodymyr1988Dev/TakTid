import api from './axios'
import type { ProjectReceipt } from '../types/projectReceipts.type'

export interface PaginatedReceiptsResponse {
  data: ProjectReceipt[]
  total: number
  page: number
  lastPage: number
}

export function uploadProjectReceipts(
  projectId: string,
  files: File[],
) {
  const formData = new FormData()

  files.forEach(file => {
    formData.append('files', file)
  })

  return api.post<ProjectReceipt[]>(
    `/project-receipts/${projectId}`,
    formData,
  )
}

export function getProjectReceipts(
  projectId: string,
) {
  return api.get<ProjectReceipt[]>(
    `/project-receipts/project/${projectId}`,
  )
}

export function getProjectReceiptsPaginated(
  projectId: string,
  page: number,
  limit: number,
) {
  return api.get<PaginatedReceiptsResponse>(
    `/project-receipts/project/${projectId}?page=${page}&limit=${limit}`,
  )
}

export function removeProjectReceipt(
  receiptId: string,
) {
  return api.delete(
    `/project-receipts/${receiptId}`,
  )
}