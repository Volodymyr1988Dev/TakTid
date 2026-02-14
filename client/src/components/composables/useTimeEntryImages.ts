//import { ref, watch, computed, onBeforeUnmount } from 'vue'
import { ref, onBeforeUnmount } from 'vue'
import { useProjectImageStore } from '../../stores/projectImage.store'

const MAX_FILES = 10
const MAX_SIZE = 10 * 1024 * 1024

export function useTimeEntryImages() {
  const store = useProjectImageStore()
  const files = ref<File[]>([])
  //const previewsRef = ref<string[]>([])
  const previews = ref<string[]>([])
  //watch(files, () => {
  //  previewsRef.value.forEach(URL.revokeObjectURL)
  //  previewsRef.value = files.value.map(f => URL.createObjectURL(f))
  //})


  //const previews = computed<string[]>(() => previewsRef.value)
  function rebuildPreviews() {
    previews.value.forEach(url => URL.revokeObjectURL(url))

    previews.value = files.value.map(file =>
      URL.createObjectURL(file)
    )
  }

  function onSelect(e: Event) {
    const input = e.target as HTMLInputElement
    //files.value = Array.from(input.files ?? [])
    //  .filter(f => f.type.startsWith('image/') && f.size <= MAX_SIZE)
    //  .slice(0, MAX_FILES)
    const selected = Array.from(input.files ?? [])
      .filter(f => f.type.startsWith('image/') && f.size <= MAX_SIZE)

    const merged = [...files.value, ...selected].slice(0, MAX_FILES)

    files.value = merged
    rebuildPreviews()
    input.value = ''
  }
  async function upload(projectId?: string) {
    if (!projectId || !files.value.length) return
    //if (!files.value.length) return
    await store.upload(projectId, files.value)
    //files.value = []
    clear()
  }

  function removeAt(index: number) {
    //const url = previewsRef.value[index]
    const url = previews.value[index]

    if (!url) return
    //URL.revokeObjectURL(url)
    //files.value.splice(index, 1)
    files.value = files.value.filter((_, i) => i !== index)
    rebuildPreviews()
    //const [file] = files.value.splice(index, 1)
    //if (file) URL.revokeObjectURL(previewsRef.value[index])
  }

  function clear() {
    previews.value.forEach(url => URL.revokeObjectURL(url))
    files.value = []
    previews.value = []
    //files.value = []
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