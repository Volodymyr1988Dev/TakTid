<script setup lang="ts">
import { reactive } from 'vue'
import { MATERIAL_CATALOG } from '../../const/MaterialCatalog'
import type {
  CreateMaterialListDto,
  MaterialItem,
} from '../../types/Material'

export interface MaterialFormState {
  projectId: string
  other: string
  items: MaterialItem[]
}

function createEmptyItems(): MaterialItem[] {
  return MATERIAL_CATALOG.map(material => ({
    materialKey: material.key,
    quantity: null,
    price: null,
    note: null,
  }))
}

export const materialForm = reactive<CreateMaterialListDto>({
  projectId: '',
  title: '',
  other: '',
  items: createEmptyItems(),
})
</script>