import type { Locator, Page } from '@playwright/test';

/**
 * Product-facing labels used by the current Flutter web UI.
 *
 * Flutter's ValueKey is not a web data-testid. These helpers deliberately
 * use the visible Material labels and explicit Semantics labels that the app
 * already emits, rather than reaching into Flutter renderer internals.
 */
export const ui = {
  auth: {
    login: 'Anmelden',
    logout: 'Auf allen Geräten abmelden',
    profileRoute: 'Route: /profile',
  },
  navigation: {
    learning: 'Lernen',
    field: 'Expedition',
    herbarium: 'Herbarium',
    profile: 'Profil',
  },
  catalog: {
    ecosystems: 'Ökosysteme',
    levels: 'Lernpfad',
    learningUnit: 'Lerneinheit',
    startQuiz: 'Abschlussquiz starten',
  },
  learning: {
    quiz: 'Quiz',
    complete: 'Level abschließen',
    completed: 'Level abgeschlossen',
  },
  field: {
    title: 'Finde und bestimme\neine Pflanze',
    gallery: 'Aus Galerie wählen',
    emptyPhotoState: 'Wähle ein Foto für die Bestimmung',
    identify: 'Pflanze bestimmen',
    processing: 'Abgleich läuft',
    identified: 'Ergebnis verfügbar',
    refresh: 'Status aktualisieren',
    save: 'Ergebnis speichern',
  },
  herbarium: {
    title: 'MEIN HERBARIUM',
    addObservation: 'Neuen Fund bestimmen',
  },
} as const;

/**
 * The isolated compose stack deliberately seeds this one published release.
 * These labels are a contract with demo-seed.js, not a production-content
 * fixture or a fabricated API response in the browser test.
 */
export const seededJourney = {
  ecosystem: 'Mitteleuropäischer Laubwald',
  levelCard: 'Deine nächste Aufgabe 1. Arten erkennen',
  levelTitle: 'Arten erkennen',
  collectionTargets: ['Rotbuche', 'Stiel-Eiche', 'Hainbuche'],
  quiz: [
    ['Welches Rindenmerkmal passt besonders gut zur Rotbuche?', 'Glatt und weißgrau'],
    ['Welches Blattmerkmal spricht eher für die Stiel-Eiche als für die Trauben-Eiche?', 'Sehr kurzer Blattstiel und oft geöhrter Grund'],
    ['Zu welcher Familie gehört die Hainbuche trotz ihres Namens?', 'Birkengewächse'],
    ['Wie sind die Blätter des Berg-Ahorns am Zweig angeordnet?', 'Gegenständig'],
    ['Welche Knospenfarbe ist für die Gewöhnliche Esche besonders charakteristisch?', 'Mattschwarz'],
    ['Welches Blattmerkmal ist typisch für die Winter-Linde?', 'Herzförmige Spreite'],
    ['Welche Wuchsform zeigt die Gewöhnliche Hasel meistens?', 'Mehrstämmiger Strauch'],
    ['Wann blüht das Busch-Windröschen typischerweise?', 'Von März bis Mai'],
    ['Welche Blütenform passt zum Bär-Lauch?', 'Weiße sternförmige Blüten in einer Scheindolde'],
    ['Wie stehen die Wedel des Gewöhnlichen Wurmfarns typischerweise?', 'Trichterförmig aus einem Stock'],
  ],
} as const;

const exactText = (page: Page, text: string): Locator =>
  page.getByText(text, { exact: true });

const namedButton = (page: Page, name: string): Locator =>
  page.getByRole('button', { name, exact: true });

/**
 * Flutter Web exposes the semantic DOM after its built-in accessibility
 * placeholder is activated. This is a renderer accessibility handshake, not
 * a product-state action. Modern renderers that already expose semantics have
 * no placeholder, so this remains a no-op for them.
 */
export async function enableFlutterWebSemantics(page: Page): Promise<void> {
  const placeholder = page.getByRole('button', { name: 'Enable accessibility' });
  await placeholder.waitFor({ state: 'visible', timeout: 10_000 }).catch(() => undefined);
  if (await placeholder.isVisible().catch(() => false)) {
    // Flutter positions this accessibility-only element outside the visual
    // canvas. The browser cannot assign it a viewport coordinate, but the
    // renderer's public accessibility handshake is the click event itself.
    await placeholder.dispatchEvent('click');
  }
}

export const appUi = {
  loginButton: (page: Page): Locator => namedButton(page, ui.auth.login),
  logoutButton: (page: Page): Locator => exactText(page, ui.auth.logout),
  profileRoute: (page: Page): Locator => exactText(page, ui.auth.profileRoute),

  fieldNavigation: (page: Page): Locator =>
    page.getByRole('tab', { name: ui.navigation.field, exact: true }),
  learningNavigation: (page: Page): Locator =>
    page.getByRole('tab', { name: ui.navigation.learning, exact: true }),
  herbariumNavigation: (page: Page): Locator =>
    page.getByRole('tab', { name: ui.navigation.herbarium, exact: true }),
  profileNavigation: (page: Page): Locator =>
    page.getByRole('tab', { name: ui.navigation.profile, exact: true }),

  ecosystemsTitle: (page: Page): Locator => exactText(page, ui.catalog.ecosystems),
  ecosystem: (page: Page): Locator => page.getByRole('button', {
    name: new RegExp(`^(?:Ökosystem )?${escapeRegex(seededJourney.ecosystem)}`),
  }),
  levelsTitle: (page: Page): Locator => exactText(page, ui.catalog.levels),
  levelCard: (page: Page): Locator => page.getByRole('button', {
    name: seededJourney.levelCard,
    exact: true,
  }),
  learningUnitTitle: (page: Page): Locator => exactText(page, ui.catalog.learningUnit),
  levelTitle: (page: Page): Locator => exactText(page, seededJourney.levelTitle),
  startQuizButton: (page: Page): Locator => namedButton(page, ui.catalog.startQuiz),
  startExpeditionButton: (page: Page): Locator =>
    page.getByRole('button', { name: / sammeln$/, exact: true }),

  quizTitle: (page: Page): Locator => exactText(page, ui.learning.quiz),
  quizQuestion: (page: Page, question: string): Locator =>
    exactText(page, `Quizfrage ${question}`),
  quizAnswer: (page: Page, answer: string): Locator =>
    page.getByRole('button', { name: `Antwort ${answer}`, exact: true }),
  completeLevelButton: (page: Page): Locator => namedButton(page, ui.learning.complete),
  completedLevel: (page: Page): Locator =>
    page.getByRole('group', {
      name: `Level abgeschlossen: ${seededJourney.levelTitle}`,
      exact: true,
    }),

  fieldTitle: (page: Page): Locator => exactText(page, ui.field.title),
  chooseFromGalleryButton: (page: Page): Locator => namedButton(page, ui.field.gallery),
  emptyPhotoState: (page: Page): Locator => exactText(page, ui.field.emptyPhotoState),
  identifyPlantButton: (page: Page): Locator => namedButton(page, ui.field.identify),
  selectedMedia: (page: Page): Locator => page.getByText(/e2e-leaf\.png/, { exact: false }),
  identificationProcessing: (page: Page): Locator => exactText(page, ui.field.processing),
  identificationReady: (page: Page): Locator =>
    page.getByRole('group', { name: new RegExp(ui.field.identified) }),
  refreshIdentificationButton: (page: Page): Locator => namedButton(page, ui.field.refresh),
  candidate: (page: Page, name: string): Locator =>
    page.getByRole('button', { name: new RegExp(`^${escapeRegex(name)}\\b`) }),
  saveObservationButton: (page: Page): Locator => namedButton(page, ui.field.save),

  herbariumTitle: (page: Page): Locator => exactText(page, ui.herbarium.title),
  addObservationButton: (page: Page): Locator => namedButton(page, ui.herbarium.addObservation),
  herbariumEntry: (page: Page, name: string): Locator =>
    page.getByRole('button', { name: new RegExp(`^${escapeRegex(name)}\\b`) }).first(),
} as const;

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^$()|[\]\\]/g, '\\$&');
}
