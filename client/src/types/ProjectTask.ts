export interface ProjectTask {
  id: string
  title: string
  done: boolean
  completedByName: string | null
  completedAt: string | null
  comment: string | null
  note: string | null
  attentionNote: string | null
}