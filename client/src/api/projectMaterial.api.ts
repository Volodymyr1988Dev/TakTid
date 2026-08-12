import type { CreateMaterialListDto, MaterialList, UpdateMaterialListDto } from '../types/Material'
import api from './axios'

export async function getMaterialList(
  projectId: string,
) : Promise<MaterialList | null> {
  try {
    const { data } = await api.get<MaterialList>(
      `/project-materials/project/${projectId}`,
    )

    return data
  } catch (error: any) {
    if (error?.response?.status === 404) {
      return null
    }

    throw error
  }
}
export async function createMaterialList(
  payload: CreateMaterialListDto,
) : Promise<MaterialList | null> {
  const { data } =
    await api.post(
      '/project-materials',
      payload,
    )

  return data
}
export async function updateMaterialList(
  id: string,
  payload: UpdateMaterialListDto,
) : Promise<MaterialList | null> {
  const { data } =
    await api.patch(
      `/project-materials/${id}`,
      payload,
    )

  return data
}
export async function removeMaterialList(
  id: string,
) : Promise<void> {
  const { data } =
    await api.delete(
      `/project-materials/${id}`,
    )

  return data
}

export async function deleteMaterialList(
  id: string,
): Promise<void> {
  await api.delete(`/project-materials/${id}`)
}