import { i18n } from './i18n'
//import { loadLocaleMessages } from './i18nLoader'
import dayjs from 'dayjs'

const loadedLanguages = new Set<string>()

const loaders = {
  en: () => import('./locales/en'),
  uk: () => import('./locales/uk'),
  sv: () => import('./locales/sv'),
  ro: () => import('./locales/ro'),
  pl: () => import('./locales/pl'),
}
/*
export async function setLanguage(locale: string) {
  let lang = locale as keyof typeof loaders
  // якщо ще не завантажена — підтягуємо
  if (!loaders[lang]) {
    lang = 'en'
  }
  if (!loadedLanguages.has(locale)) {
    const loader = loaders[locale as keyof typeof loaders]

    if (!loader) {
      locale = 'en'
    }
    //const messages = await import(`./locales/${locale}.ts`)
    const messages = await loaders[locale]()
    //i18n.global.setLocaleMessage(locale, messages.default)
    //loadedLanguages.add(locale)
    i18n.global.locale.value = locale
    dayjs.locale(locale)
    localStorage.setItem('lang', locale)
  }

  // ставимо мову
  i18n.global.locale.value = locale

  dayjs.locale(locale)
  // зберігаємо
  localStorage.setItem('lang', locale)
}
*/
export async function setLanguage(locale: string) {
  let lang = locale as keyof typeof loaders

  if (!loaders[lang]) {
    lang = 'en'
  }

  if (!loadedLanguages.has(lang)) {
    const messages = await loaders[lang]()
    
    i18n.global.setLocaleMessage(lang, messages.default)
    loadedLanguages.add(lang)
  }

  i18n.global.locale.value = lang
  dayjs.locale(lang)
  localStorage.setItem('lang', lang)
}
export async function initLanguage() {
  const saved = localStorage.getItem('lang') || 'en'
  await setLanguage(saved)
}