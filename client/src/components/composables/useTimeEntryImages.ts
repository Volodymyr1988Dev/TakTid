import { ref, watch } from 'vue'
import { useProjectImageStore } from '../../stores/projectImage.store'
//import { RefSymbol } from '@vue/reactivity'
//import type { Ref } from 'vue'

const MAX_FILES = 10
const MAX_SIZE = 10 * 1024 * 1024

export function useTimeEntryImages() {
  const store = useProjectImageStore()
  const files = ref<File[]>([])
  //const previews = ref<string[]>([])
  //const rawPreviews = ref<string[]>([])
  const previews = ref<string[]>([])
  // const previews = computed<string[]>(() =>
  //  files.value.map(file => URL.createObjectURL(file)),
  //)

  watch(files, () => {
    previews.value.forEach(URL.revokeObjectURL)
    previews.value = files.value.map(f => URL.createObjectURL(f))
  })

  function onSelect(e: Event) {
    const input = e.target as HTMLInputElement
    files.value = Array.from(input.files ?? [])
      .filter(f => f.type.startsWith('image/') && f.size <= MAX_SIZE)
      .slice(0, MAX_FILES)

    //const valid = selected.filter(
    //  f => f.type.startsWith('image/') && f.size <= MAX_SIZE,
    //)

    //if (valid.length > MAX_FILES) {
    //  alert('Max 10 images allowed')
    //  return
    //}
    //previews.value = selected.map(file =>
    //URL.createObjectURL(file),
  //)

    //files.value = valid
    //files.value = selected //selected valid
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
    previews,
    //images: store.images,
    onSelect,
    upload,//: store.upload,
    clear,//: () => (files.value = []),
    //removeImage: store.remove,
  }
}