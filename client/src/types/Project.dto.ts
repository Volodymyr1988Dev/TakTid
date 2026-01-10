import type { ProjectImages } from "./ProjectImages";
export interface Project {
  id: string;
  city: string;
  address: string;
  images?: ProjectImages[]
}
