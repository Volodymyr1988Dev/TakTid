export type ViewerItemType =
  | 'image'
  | 'receipt'

export interface ViewerItem {
  id: string
  url: string
  createdAt?: string
  type: ViewerItemType
}
/*
export interface ViewerItem {
  id: string
  url: string
  createdAt?: string
  //type: 'image' | 'receipt'
  
}*/
