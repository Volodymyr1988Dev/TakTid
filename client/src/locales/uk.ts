export default {
  common: {
    title: 'Заголовок',
    addProject: 'Додати проект',
    delete: 'Видалити',
    back: 'Назад',
    create: 'Створити',
    loading: 'Завантаження...',
    error: 'Щось пішло не так',
    yes: 'Так',
    no: 'Ні',
    save: 'Зберегти',
    cancel: 'Скасувати',
    edit: 'Редагувати',
    deleteConfirm: 'Ви впевнені?',
    registerTime: 'Зареєструвати час',
  },

  project: {
    title: 'Проекти',
    create: 'Створити проект',
    add: 'Додати проект',
    city: 'Місто',
    address: 'Адреса',
    confirmDelete: 'Ви впевнені?',
    info: 'Інформація',
    back: 'Назад',
    hideImages: 'Сховати зображення',
    showImages: 'Показати зображення',
  },

  auth: {
    login: 'Увійти',
    register: 'Реєстрація',
    email: 'Email',
    password: 'Пароль',
    name: "Ім’я",
    noAccount: 'Немає акаунту?',
    haveAccount: 'Вже є акаунт?',
    invalid: 'Невірний email або пароль',
    registerFailed: 'Помилка реєстрації'
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
    extra: 'Екстра',
    extraWork: 'Додаткова робота',
    meeting: 'Зустріч',
    sick: 'Лікарняний',
    vacation: 'Відпустка',
    vab: 'Догляд за дитиною',
    redDay: 'Святковий день',
    dayOff: 'Вихідний',
    total: 'Всього',
    absence: 'Відсутність',

    period: 'Період',
    user: 'Користувач',
    monthlyReport: 'Місячний звіт',

    workWithExtra: 'Робота + Переробка',
    workWithRedDay: 'Робота + Свято',
    totalWithRedDay: 'Всього + Свято',

    errors: {
      load: 'Помилка завантаження статистики',
      year: 'Рік має бути ≥ 2025',
      month: 'Місяць має бути від 1 до 12',
    }
  },

  tabs: {
    time: 'Час',
    projects: 'Проекти',
    list: 'Список',
    stats: 'Статистика',
    helpers: 'Інструменти',
    suggestions: 'Пропозиції',
    internal: 'Внутрішнє',
    absence: 'Відсутність',
  },

  calculator: {
    idealSpacing: 'Ідеальний інтервал (см)',
    length: 'Довжина (см)',
    spacing: 'Інтервал (см)',
    errorLength: 'Довжина має бути ≥ 20 см',
    errorSpacing: 'Інтервал має бути ≥ 20 см',
    errorIdeal: 'Ідеальний інтервал має бути числом і ≥ 20 см',

    exact: 'Точний',
    ideal: 'Ідеальний',
    difference: 'Різниця',
    lower: 'Менший інтервал',
    upper: 'Більший інтервал',
    segments: 'Сегменти',
  },

  hook: {
    title: 'Калькулятор гаків',
    length: 'Довжина',
    fixedEdge: 'Фіксований край',
    lengthPlaceholder: 'Введіть довжину',
    fixedEdgePlaceholder: 'Введіть край',
    spacing: 'Інтервал',
    hooks: 'Гаки',
    left: 'Лівий край',
    right: 'Правий край',

    errors: {
      length: 'Довжина має бути ≥ 60 см',
      edge: 'Невірне значення краю',
      lengthNumber: 'Довжина має бути числом',
    }
  },

  errors: {
    unauthorized: 'Не авторизовано',
    forbidden: 'Заборонено',
    registerFailed: 'Помилка реєстрації',
    updateFailed: 'Помилка оновлення',
    deleteFailed: 'Помилка видалення',
    restoreFailed: 'Помилка відновлення',
    breakNumber: 'Перерва має бути числом',
    invalidBreak: 'Невірна перерва',
    noProject: 'Збережений запис не має проекту',
    imageUploadFailed: 'Помилка завантаження зображення',
    deleteExtraWork: 'Видалити додаткову роботу?',
    noProjectId: 'WORK вимагає projectId',
    accessDenied: 'Доступ заборонено',
    loadStats: 'Помилка завантаження статистики',
    loadUserDetails: 'Помилка завантаження даних користувача',
    monthValid: 'Місяць має бути числом',
    monthRange: 'Місяць має бути від 1 до 12',
  },

  account: {
    title: 'Налаштування акаунту',
    saveName: "Зберегти ім’я",
    saveEmail: 'Зберегти email',
    savePassword: 'Зберегти пароль',
    cancel: 'Скасувати',
    manageUsers: 'Керування користувачами',
    deleteConfirm: 'Ви впевнені, що хочете видалити',
    deleted: 'успішно видалено',
    restored: 'успішно відновлено',
    passwordShort: 'Пароль має бути мінімум 6 символів',
    passwordMatch: 'Паролі не співпадають',
    confirmPassword: 'Підтвердіть пароль',
    restore: 'Відновити',
  },

  calendar: {
    week: 'Тиждень',
    month: 'Місяць',
    logout: 'Вийти',
    comment: 'Коментар',
    save: 'Зберегти'
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

  toast: {
    profileUpdated: 'Профіль успішно оновлено',
    passwordShort: 'Пароль має бути мінімум 6 символів',
    passwordMatch: 'Паролі не співпадають',
    deleteFailed: 'Помилка видалення',
    updateFailed: 'Помилка оновлення',
    restoreFailed: 'Помилка відновлення',
    restoreSuccess: 'Успішно відновлено',
    success: 'Успіх',
    error: 'Помилка',
    loadProjectStats: 'Не вдалося завантажити статистику проекту'
  }
}