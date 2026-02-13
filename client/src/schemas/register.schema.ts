import { z } from 'zod'

export const registerSchema = z.object({
  email: z.string().email('Not valid email'),
  password: z
    .string()
    .min(6, 'Minimum 6 symbols')
    .max(25, 'Maximum 25 symbols'),
  name: z
    .string()
    .min(2, 'Minimum 2 symbols'),
})