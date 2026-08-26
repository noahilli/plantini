export const ui = {
  app: {
    shell: 'app-shell',
    ready: 'app-ready',
    authenticatedSession: 'auth-session',
    offlineBanner: 'network-offline-banner',
  },
  navigation: {
    ecosystems: 'nav-ecosystems',
    field: 'nav-field',
    herbarium: 'nav-herbarium',
  },
  auth: {
    login: 'auth-login',
    register: 'auth-register',
    logout: 'auth-logout',
    verificationPending: 'auth-verification-pending',
  },
  oidc: {
    register: 'oidc-register',
    email: 'oidc-email',
    password: 'oidc-password',
    passwordConfirmation: 'oidc-password-confirmation',
    submitRegistration: 'oidc-submit-registration',
    submitLogin: 'oidc-submit-login',
    verificationComplete: 'oidc-verification-complete',
  },
  catalog: {
    ecosystemListReady: 'ecosystem-list-ready',
    levelListReady: 'level-list-ready',
  },
  learning: {
    unitReady: 'learning-unit-ready',
    startQuiz: 'learning-start-quiz',
    resume: 'learning-resume',
    levelCompleted: 'learning-level-completed',
    offlinePackageReady: 'offline-package-ready',
  },
  quiz: {
    question: 'quiz-question',
    feedback: 'quiz-feedback',
    next: 'quiz-next',
    pause: 'quiz-pause',
    paused: 'quiz-paused',
  },
  field: {
    taskReady: 'field-task-ready',
    startTask: 'field-task-start',
    photoInput: 'field-photo-input',
    declineLocation: 'field-location-decline',
    submit: 'field-submit',
    identification: 'field-identification',
    retryIdentification: 'field-identification-retry',
    confirmIdentification: 'field-identification-confirm',
    storageError: 'field-storage-error',
  },
  sync: {
    status: 'sync-status',
    retry: 'sync-retry',
    conflict: 'sync-conflict',
  },
  herbarium: {
    listReady: 'herbarium-list-ready',
  },
  accessibility: {
    mainHeading: 'a11y-main-heading',
    primaryAction: 'a11y-primary-action',
  },
} as const;

export const entityTestId = {
  ecosystem: (id: string) => `ecosystem-card-${id}`,
  level: (id: string) => `level-card-${id}`,
  quizAnswer: (id: string) => `quiz-answer-${id}`,
  fieldTask: (id: string) => `field-task-${id}`,
  observation: (id: string) => `herbarium-observation-${id}`,
};
