export interface MaterialItem {
  label: string
  quantity: number | null
  price: number | null
  unit: string
}

export interface MaterialList {
  id: string
  projectId: string
  title: string | null
  other: string | null
  createdAt?: string
  updatedAt?: string
  items: MaterialItem[]
}

export interface CreateMaterialListDto {
  projectId: string
  title?: string
  other: string
  items: MaterialItem[]
}

export interface UpdateMaterialListDto {
  title?: string
  other?: string
  items: MaterialItem[]
}