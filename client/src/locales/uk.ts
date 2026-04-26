export default {
  common: {
    addProject: 'Додати проект',
    delete: 'Видалити',
    back: 'Назад',
    create: 'Створити',
    loading: 'Завантаження...',
    error: 'Щось пішло не так',
    yes: 'Так',
    no: 'Ні',
  },

  project: {
    title: 'Проекти',
    create: 'Створити проект',
    city: 'Місто',
    address: 'Адреса',
    confirmDelete: 'Ви впевнені?',
    info: 'Інформація',
  },

  auth: {
    login: 'Увійти',
    register: 'Реєстрація',
    email: 'Email',
    password: 'Пароль',
    name: "Ім'я",
    noAccount: 'Немає акаунту?',
    haveAccount: 'Вже є акаунт?',
    invalid: 'Невірний email або пароль',
    registerFailed: 'Помилка реєстрації',
  },

  stats: {
    title: 'Статистика',
    year: 'Рік',
    month: 'Місяць',
    load: 'Завантажити',
    exportExcel: 'Експорт Excel',
    exportPDF: 'Експорт PDF',
    details: 'Деталі',
    hideDetails: 'Сховати деталі',

    work: 'Робота',
    extra: 'Переробка',
    meeting: 'Зустріч',
    sick: 'Лікарняний',
    vacation: 'Відпустка',
    vab: 'Догляд за дитиною',
    redDay: 'Святковий день',
    total: 'Всього',

    period: 'Період',
    user: 'Користувач',
    monthlyReport: 'Місячний звіт',

    workWithExtra: 'Робота + Переробка',
    workWithRedDay: 'Робота + Свято',
    totalWithRedDay: 'Всього + Свято',

    errors: {
      load: 'Помилка завантаження',
      year: 'Рік має бути ≥ 2025',
      month: 'Місяць від 1 до 12',
    }
  },

  tabs: {
    time: 'Час',
    projects: 'Проекти',
    list: 'Список',
    stats: 'Статистика',
    helpers: 'Інструменти',
  },

  calculator: {
    idealSpacing: 'Ідеальний інтервал (см)',
    length: 'Довжина (см)',
    spacing: 'Інтервал (см)',
    errorLength: 'Довжина ≥ 20 см',
    errorSpacing: 'Інтервал ≥ 20 см',
    errorIdeal: 'Інтервал ≥ 20 см',

    exact: 'Точний',
    ideal: 'Ідеальний',
    difference: 'Різниця',
    lower: 'Менший інтервал',
    upper: 'Більший інтервал',
    segments: 'Сегменти',
  },

  hook: {
    title: 'Калькулятор гачків',
    length: 'Довжина',
    fixedEdge: 'Фіксований край',
    lengthPlaceholder: 'Введіть довжину',
    fixedEdgePlaceholder: 'Введіть край',
    spacing: 'Інтервал',
    hooks: 'Гачки',
    left: 'Лівий край',
    right: 'Правий край',

    errors: {
      length: 'Довжина ≥ 60 см',
      edge: 'Невірний край',
      lengthNumber: 'Некоректне число',
    }
  },

  account: {
    title: 'Налаштування акаунту',
    saveName: "Зберегти ім'я",
    saveEmail: 'Зберегти email',
    savePassword: 'Зберегти пароль',
    cancel: 'Скасувати',
    manageUsers: 'Керування користувачами',
    deleteConfirm: 'Ви впевнені, що хочете видалити',
    deleted: 'успішно видалено',
    restored: 'успішно відновлено',
    passwordShort: 'Пароль мінімум 6 символів',
    passwordMatch: 'Паролі не співпадають',
    confirmPassword: 'Підтвердити пароль',
    restore: 'Відновити',
  },

  calendar: {
    week: 'Тиждень',
    month: 'Місяць',
    logout: 'Вийти',
    comment: 'Коментар',
    save: 'Зберегти',
  },

  week: {
    mon: 'Пн',
    tue: 'Вт',
    wed: 'Ср',
    thu: 'Чт',
    fri: 'Пт',
    sat: 'Сб',
    sun: 'Нд',
  },

  errors: {
    unauthorized: 'Не авторизовано',
    forbidden: 'Заборонено',
    registerFailed: 'Помилка реєстрації',
    updateFailed: 'Помилка оновлення',
    deleteFailed: 'Помилка видалення',
    restoreFailed: 'Помилка відновлення',
  },

  toast: {
    profileUpdated: 'Профіль оновлено',
    passwordShort: 'Пароль мінімум 6 символів',
    passwordMatch: 'Паролі не співпадають',
    deleteFailed: 'Помилка видалення',
    updateFailed: 'Помилка оновлення',
    restoreFailed: 'Помилка відновлення',
    restoreSuccess: 'Успішно відновлено',
  }
}