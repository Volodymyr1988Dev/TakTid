import api from './axios'

export async function getMaterialList(
  projectId: string,
) {
  const { data } =
    await api.get(
      `/project-materials/project/${projectId}`,
    )

  return data
}
export async function createMaterialList(
  payload: any,
) {
  const { data } =
    await api.post(
      '/project-materials',
      payload,
    )

  return data
}
export async function updateMaterialList(
  id: string,
  payload: any,
) {
  const { data } =
    await api.patch(
      `/project-materials/${id}`,
      payload,
    )

  return data
}
export async function removeMaterialList(
  id: string,
) {
  const { data } =
    await api.delete(
      `/project-materials/${id}`,
    )

  return data
}