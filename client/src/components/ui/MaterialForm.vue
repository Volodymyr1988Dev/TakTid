<script setup lang="ts">

import { reactive } from 'vue'
import { MATERIAL_CATALOG } from '../../const/MaterialCatalog'
import type { /*MaterialItem,*/ CreateMaterialListDto } from '../../types/Material'
/*
export const items = reactive<MaterialItem[]>(
  MATERIAL_CATALOG.map(label => ({
    label,
    quantity: null,
    price: null,
    unit: 'pcs',
  })),
)*/
export const materialForm = reactive<CreateMaterialListDto>({
    projectId: '',
    title: '',
    other: '',
    items: MATERIAL_CATALOG.map(label => ({
        label,
        quantity: null,
        price: null,
        unit: 'pcs',
    })),
})

</script>