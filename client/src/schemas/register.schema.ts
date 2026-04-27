import { z } from 'zod'

export const registerSchema = z.object({
  
  email: z.string().email({ message: 'emailValid' }),
  password: z
    .string()
    .min(6, { message: 'passwordMin' })
    .max(25, { message: 'passwordMax' }),
  name: z
    .string()
    .min(2, { message: 'nameMin' }),
})