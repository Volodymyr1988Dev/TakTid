export interface User {
  id: string
  email: string
  name?: string
  isAdmin: boolean
  CanCreateProjects: boolean
  SpecialCan: boolean
}