import api from './axios'

export async function uploadProjectImage(
  projectId: string,
  file: File,
) {
  const form = new FormData()
  form.append('file', file)

  const { data } = await api.post(
    `/project-images/${projectId}`,
    form,
    {
      headers: { 'Content-Type': 'multipart/form-data' },
    },
  )

  return data
}

export async function deleteProjectImage(imageId: string) {
  await api.delete(`/project-images/${imageId}`)
}