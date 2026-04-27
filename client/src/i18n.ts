import { createI18n } from 'vue-i18n'

const savedLang =
  typeof window !== 'undefined'
    ? localStorage.getItem('lang')
    : null

const browserLang =
  typeof navigator !== 'undefined'
    ? navigator.language.slice(0, 2)
    : 'en'

const availableLangs = ['en', 'uk', 'sv', 'ro', 'pl']

const lang =
  savedLang ??
  (availableLangs.includes(browserLang) ? browserLang : 'en')
/*
const messages = {
  en: {
    calendar: {
      weekLabel: 'Week {num}',
    },
  },
  uk: {
    calendar: {
      weekLabel: 'Тиждень {num}',
    },
  },
  sv: {
    calendar: {
      weekLabel: 'Vecka {num}',
    },
  },
  ro: {
    calendar: {
      weekLabel: 'Săptămâna {num}',
    },
  },
  pl: {
    calendar: {
      weekLabel: 'Tydzień {num}',
    },
  },
}
*/
export const i18n = createI18n({
  legacy: false,
  locale: lang,
  fallbackLocale: 'en',
  messages: {},
})