export function cloudinary(
  url: string,
  width = 600,
  options?: { quality?: string; format?: string }
) {
  const quality = options?.quality ?? 'auto'
  const format = options?.format ?? 'auto'

  return url.replace(
    '/upload/',
    `/upload/f_${format},q_${quality},c_limit,w_${width}/`
  )
}