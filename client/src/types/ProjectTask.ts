export interface ProjectTask {
  id: string
  title: string
  done: boolean
  completedByName: string | null
  completedAt: string | null
}