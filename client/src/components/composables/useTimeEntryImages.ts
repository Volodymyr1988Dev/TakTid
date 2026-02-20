import { ref, onBeforeUnmount } from 'vue'
import { useProjectImageStore } from '../../stores/projectImage.store'

const MAX_FILES = 10
const MAX_SIZE = 10 * 1024 * 1024

export function useTimeEntryImages() {
  const store = useProjectImageStore()
  const files = ref<File[]>([])
  const previews = ref<string[]>([])
  function rebuildPreviews() {
    previews.value.forEach(url => URL.revokeObjectURL(url))

    previews.value = files.value.map(file =>
      URL.createObjectURL(file)
    )
  }

  function onSelect(e: Event) {
    const input = e.target as HTMLInputElement
    const selected = Array.from(input.files ?? [])
      .filter(f => f.type.startsWith('image/') && f.size <= MAX_SIZE)

    const merged = [...files.value, ...selected].slice(0, MAX_FILES)

    files.value = merged
    rebuildPreviews()
    input.value = ''
  }
  async function upload(projectId?: string) {
    if (!projectId || !files.value.length) return
    await store.upload(projectId, files.value)
    clear()
  }

  function removeAt(index: number) {
    const url = previews.value[index]

    if (!url) return
    files.value = files.value.filter((_, i) => i !== index)
    rebuildPreviews()
  }

  function clear() {
    previews.value.forEach(url => URL.revokeObjectURL(url))
    files.value = []
    previews.value = []
  }
  
  onBeforeUnmount(() => {
    clear()
  })

  return {
    files,
    previews,
    onSelect,
    upload,
    clear,
    removeAt,
  }
}