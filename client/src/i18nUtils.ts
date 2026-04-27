import { i18n } from './i18n'
//import { loadLocaleMessages } from './i18nLoader'
import dayjs from 'dayjs'

const loadedLanguages = new Set<string>()

const loaders = {
  en: async () => {
    return import('./locales/en')
  },
  uk: async () => {
    return import('./locales/uk')
  },
  sv: async () => {
    return import('./locales/sv')
  },
  ro: async () => {
    return import('./locales/ro')
  },
  pl: async () => {
    return import('./locales/pl')
  },
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
  try{

  if (!(lang in loaders)) {
    lang = 'en'
  }

  if (!loadedLanguages.has(lang)) {
    const messages = await loaders[lang]()
    if (!messages?.default) {
      console.error('Invalid locale file:', lang)
      return
    }
    console.log('LOADED LANG:', lang, messages)
    i18n.global.setLocaleMessage(lang, messages.default)
    loadedLanguages.add(lang)
  }
  i18n.global.locale.value = lang
  dayjs.locale(lang)
  localStorage.setItem('lang', lang)
  }
  catch(e){
    console.error('LANG LOAD ERROR:', lang, e)
    locale = 'en'
  }
  
}
export async function initLanguage() {
  const saved = localStorage.getItem('lang') || 'en'
  await setLanguage(saved)
}