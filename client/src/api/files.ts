import api from './axios'

export async function uploadPhoto(file: File): Promise<string> {
  const form = new FormData()
  form.append('file', file)

  const { data } = await api.post<{ url: string }>('/files/upload', form)
  return data.url
}