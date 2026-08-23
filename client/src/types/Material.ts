export interface MaterialItem {
  //label: string
  materialKey: string
  quantity: number | null
  price: number | null
  //unit: string
  note: string | null
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
  other?: string
  items: MaterialItem[]
}

export interface UpdateMaterialListDto {
  title?: string
  other?: string
  items: MaterialItem[]
}

export interface MaterialFormState {
  projectId: string
  other: string
  items: MaterialItem[]
}