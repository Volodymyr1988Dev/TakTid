export async function loadLocaleMessages(locale: string) {
  const messages = await import(`./locales/${locale}.ts`)
  return messages.default
}