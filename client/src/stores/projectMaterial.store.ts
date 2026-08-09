import { ref } from 'vue'
import { defineStore } from 'pinia'
import { getMaterialList, updateMaterialList, createMaterialList } from '../api/projectMaterial.api'
import type {
    MaterialList,
    CreateMaterialListDto,
    UpdateMaterialListDto,
} from '../types/Material'

export const useProjectMaterialStore = defineStore('projectMaterial', () => {
  const materialList = ref<MaterialList | null>(null)

async function load(
  projectId: string,
) : Promise<MaterialList | null> {
      const list = await getMaterialList(projectId)
      materialList.value = list
      return list
}
function clear(): void {
      materialList.value = null
    }
async function save(
  payload: CreateMaterialListDto,
) : Promise<MaterialList | null> {

  if (materialList.value?.id) {

    const updatePayload: UpdateMaterialListDto = {
      other: payload.other,
      items: payload.items,
    }

    materialList.value =
      await updateMaterialList(
        materialList.value.id,
        updatePayload,
      )

  } else {

    materialList.value =
      await createMaterialList( payload )
  }
  return materialList.value
}
return {
  materialList,
  load,
  save,
  clear,
}
})
