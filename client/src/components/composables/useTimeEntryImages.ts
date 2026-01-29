import { ref } from 'vue'
import { useProjectImageStore } from '../../stores/projectImage.store'

const MAX_FILES = 10
const MAX_SIZE = 10 * 1024 * 1024

export function useTimeEntryImages() {
  const store = useProjectImageStore()
  const files = ref<File[]>([])

  function onSelect(e: Event) {
    const input = e.target as HTMLInputElement
    const selected = Array.from(input.files ?? [])

    const valid = selected.filter(
      f => f.type.startsWith('image/') && f.size <= MAX_SIZE,
    )

    if (valid.length > MAX_FILES) {
      alert('Max 10 images allowed')
      return
    }

    files.value = valid
    input.value = ''
  }

  async function upload(projectId?: string) {
    if (!projectId || files.value.length === 0) return
    await store.upload(projectId, files.value)
    files.value = []
  }

  function clear() {
    files.value = []
  }

  return {
    files,
    images: store.images,
    onSelect,
    upload,
    clear,
    removeImage: store.remove,
  }
}