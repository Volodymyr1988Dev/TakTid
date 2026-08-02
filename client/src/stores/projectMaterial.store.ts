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
) {
  materialList.value =
    await getMaterialList(
      projectId,
    )
}
async function save(
  payload: CreateMaterialListDto | UpdateMaterialListDto,
) {

  if (
    materialList.value?.id
  ) {
    materialList.value =
      await updateMaterialList(
        materialList.value.id,
        payload,
      )
  } else {
    materialList.value =
      await createMaterialList(
        payload,
      )
  }
}
return {
  materialList,
  load,
  save,
}
})
