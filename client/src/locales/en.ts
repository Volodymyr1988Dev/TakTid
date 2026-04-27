//import { toDisplayString } from "vue";

export default {
  common: {
    title: 'Title',
    addProject: 'Add project',
    delete: 'Delete',
    back: 'Back',
    create: 'Create',
    loading: 'Loading...',
    error: 'Something went wrong',
    yes: 'Yes',
    no: 'No',
    save: 'Save',
    cancel: 'Cancel',
    edit: 'Edit',
    deleteConfirm: 'Are you sure?',
    registerTime: 'Register time',

  },

  project: {
    title: 'Projects',
    create: 'Create project',
    add: 'Add project',
    city: 'City',
    address: 'Address',
    confirmDelete: 'Are you sure?',
    info: 'Info',
    back: 'Back',
    hideImages: 'Hide Images',
    showImages: 'Show Images',
  },

  auth: {
    login: 'Login',
    register: 'Register',
    email: 'Email',
    password: 'Password',
    name: 'Name',
    noAccount: "Do not have account?",
    haveAccount: 'Already have account?',
    invalid: 'Invalid email or password',
    registerFailed: 'Register failed'
  },

  stats: {
    title: 'Statistics',
    year: 'Year',
    month: 'Month',
    load: 'Load',
    exportExcel: 'Export Excel',
    exportPDF: 'Export PDF',
    details: 'Details',
    hideDetails: 'Hide details',

    work: 'Work',
    extra: 'Extra',
    extraWork: 'Extra work',
    meeting: 'Meeting',
    sick: 'Sick',
    vacation: 'Vacation',
    vab: 'VAB',
    redDay: 'Red Day',
    dayOff: 'Day off',
    total: 'Total',
    absence: 'Absence',

    period: 'Period',
    user: 'User',
    monthlyReport: 'Monthly Report',

    workWithExtra: 'Work + Extra',
    workWithRedDay: 'Work + Red Day',
    totalWithRedDay: 'Total + Red Day',

    errors: {
      load: 'Failed to load statistics',
      year: 'Year must be ≥ 2025',
      month: 'Month must be between 1 and 12',

    }
  },

  tabs: {
    time: 'Time',
    projects: 'Projects',
    list: 'List',
    stats: 'Stats',
    helpers: 'Helpers',
    suggestions: 'Suggestions',
    internal: 'Internal',
    absence: 'Absence',
  },

  calculator: {
    idealSpacing: 'Ideal Spacing in cm',
    length: 'Length in cm',
    spacing: 'Spacing in cm',
    errorLength: 'Length must be ≥ 20 cm',
    errorSpacing: 'Spacing must be ≥ 20 cm',
    errorIdeal: 'Ideal spacing must be a number and ≥ 20 cm',

    exact: 'Exact',
    ideal: 'Ideal',
    difference: 'Difference',
    lower: 'Lower spacing',
    upper: 'Upper spacing',
    segments: 'Segments',
  },

  hook: {
    title: 'Hook Calculator',
    length: 'Length',
    fixedEdge: 'Fixed edge',
    lengthPlaceholder: 'Enter length',
    fixedEdgePlaceholder: 'Enter fixed edge',
    spacing: 'Spacing',
    hooks: 'Hooks',
    left: 'Left edge',
    right: 'Right edge',

    errors: {
      length: 'Length must be ≥ 60 cm',
      edge: 'Invalid edge value',
      lengthNumber: 'Length must be a valid number',
    }
  },
  errors: {
    unauthorized: 'Unauthorized',
    forbidden: 'Forbidden',
    registerFailed: 'Register failed',
    updateFailed: 'Update failed',
    deleteFailed: 'Delete failed',
    restoreFailed: 'Restore failed',
    breakNumber: 'Break must be a valid number',
    invalidBreak: 'Invalid break',
    noProject: 'Saved assignment has no project',
    imageUploadFailed: 'Image upload failed',
    deleteExtraWork: 'Delete extra work?',
    noProjectId: 'WORK requires projectId',
    accessDenied: 'Access denied',
    loadStats: 'Failed to load stats',
    loadUserDetails: 'Failed to load user details',
    monthValid: 'Month must be a valid number',
    monthRange: 'Month must be between 1 and 12',
    emailValid: 'Not valid email',
    passwordMin: 'Password must be at least 6 characters',
    passwordMax: 'Password must be at most 25 characters',
    nameMin: 'Name must be at least 2 characters',
    unavailableAbsence: 'Unavailable to create absence, because you have working time all day',
    twoAbsences: 'Two absence entries are not allowed in one day',
    dayContains8Hours: 'Day already contains 8 working hours'
  },
  account: {
    title: 'Account settings',
    saveName: 'Save name',
    saveEmail: 'Save email',
    savePassword: 'Save password',
    cancel: 'Cancel',
    manageUsers: 'Manage users',
    deleteConfirm: 'Are you sure you want to delete',
    deleted: 'deleted successfully',
    restored: 'restored successfully',
    passwordShort: 'Password must be at least 6 characters',
    passwordMatch: 'Passwords do not match',
    confirmPassword: 'Confirm password',
    restore: 'Restore',
  },
  calendar: {
    week: 'Week',
    weekLabel: 'Week {num}',
    month: 'Month',
    logout: 'Log out',
    comment: 'Comment',
    save: 'Save'
  },
    week: {
    mon: 'Mon',
    tue: 'Tue',
    wed: 'Wed',
    thu: 'Thu',
    fri: 'Fri',
    sat: 'Sat',
    sun: 'Sun',
  },
  toast: {
    profileUpdated: 'Profile updated successfully',
    passwordShort: 'Password must be at least 6 characters',
    passwordMatch: 'Passwords do not match',
    deleteFailed: 'Delete failed',
    updateFailed: 'Update failed',
    restoreFailed: 'Restore failed',
    restoreSuccess: 'Restored successfully',
    success: 'Success',
    error: 'Error',
    loadProjectStats: 'Failed to load project statistics.'
  }

}