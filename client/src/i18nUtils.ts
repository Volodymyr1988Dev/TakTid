import { i18n } from './i18n'
//import { loadLocaleMessages } from './i18nLoader'
import dayjs from 'dayjs'

const loadedLanguages = new Set<string>()

export async function setLanguage(locale: string) {
  // якщо ще не завантажена — підтягуємо
  if (!loadedLanguages.has(locale)) {
    const messages = await import(`./locales/${locale}.ts`)
    i18n.global.setLocaleMessage(locale, messages.default)
    loadedLanguages.add(locale)
  }

  // ставимо мову
  i18n.global.locale.value = locale

  dayjs.locale(locale)
  // зберігаємо
  localStorage.setItem('lang', locale)
}

export async function initLanguage() {
  const saved = localStorage.getItem('lang') || 'en'
  await setLanguage(saved)
}