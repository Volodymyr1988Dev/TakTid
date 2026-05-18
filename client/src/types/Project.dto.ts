import type { ProjectImages } from "./ProjectImages";
export interface Project {
  id: string;
  city: string;
  address: string;
  images?: ProjectImages[]

  areaM2?: number | null
  pricePerM2?: number | null
  pricePerExtraH?: number | null
}
