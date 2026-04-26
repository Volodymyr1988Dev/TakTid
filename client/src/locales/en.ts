//import { toDisplayString } from "vue";

export default {
  common: {
    addProject: 'Add project',
    delete: 'Delete',
    back: 'Back',
    create: 'Create',
    loading: 'Loading...',
    error: 'Something went wrong',
    yes: 'Yes',
    no: 'No'

  },

  project: {
    title: 'Projects',
    create: 'Create project',
    city: 'City',
    address: 'Address',
    confirmDelete: 'Are you sure?',
    info: 'Info'
  },

  auth: {
    login: 'Login',
    register: 'Register',
    email: 'Email',
    password: 'Password',
    name: 'Name',
    noAccount: "Don't have account?",
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
    meeting: 'Meeting',
    sick: 'Sick',
    vacation: 'Vacation',
    vab: 'VAB',
    redDay: 'Red Day',
    total: 'Total',

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
    helpers: 'Helpers'
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
  }

}