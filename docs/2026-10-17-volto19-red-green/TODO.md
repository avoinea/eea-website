# TODO (deschis)

- [ ] **`volto-block-toc` #53 — V18 roșu după sync** (decis: amânat pentru altă iterație). Sync cu `develop` e făcut (`54bdc10`) și V19 e verde (41 unit + 4 integrare), dar stage-ul V18 pică 2/4 în testele care schimbă variația blocului. Diagnostic complet, dovezi și opțiuni A/B/C: `diagnostics/block-toc-v18-slate-focus.md`. Hardening test-side încercat de 2 ori (`e68d2f3`, `bb7d802`) — nu e suficient: textul tastat chiar se pierde (bug de focus sincron în Volto 18.35.1, plone/volto#8406 livrat în 18.36.0).
- [ ] **PR-uri verzi**:
  - [ ] `volto-editing-progress` #37 — V18 integrare pică pe `01-block-basics.cy.js:147` („2 fields missing"); pe branch a trecut → flake la build-ul de PR, de re-rulat.
  - [ ] SonarQube pe PR: `volto-eea-chatbot` #45 (doar coverage: 79.60 vs prag 80; `master` excludea `/types/` — 500 linii — iar vitest nu → patch de 1 linie în `vitest.config.mjs`), `volto-embed` #88 (46.60 vs 60.00) și `volto-eea-website-policy` #138 (26.90 vs 52.00) — la ambele, excluderile pierdute sunt zero, deci cauza e altundeva; ipoteza principală: `docker cp` pentru lcov-ul de integrare a rămas pe calea veche (`/app/src/addons/$GIT_NAME/coverage` → `/app/coverage`), deci raportul de integrare se pierde silențios.
  - [ ] `volto-redmine-helpdesk` #30 — doar coverage (41.30 vs 48.80); `captcha/**` (2363 linii) era exclus pe `master`, dar readăugarea duce doar la paritate cu master (48.8 < 80) → nu rezolvă singură.
  - [ ] Nota + checklist-ul de unpin chatbot/searchlib în body-ul `volto-eea-website-policy` #138 (owner: user).
  - [ ] `eea-website-frontend` #284 — job Jenkins pe Node 18 vs `engines ^24` (config, owner: user).
- [ ] **Ultimele branch-roșii**:
  - [ ] `volto-group-block` — V18: selectează explicit blocul înainte de a-i deschide setările în ciclul 2 (`03-block-group-view.cy.js`, test-only).
  - [ ] `volto-eea-website-theme` #395 — V18 image: mută `@plone/babel-preset-razzle` (registry) în `package.json`-ul rădăcină și scoate `workspace:*` din addon (hoist pattern-ul `*babel-preset-razzle` există deja în `.npmrc`), sau pin + regen lockfile cu core complet; apoi V18 integrare (timeout 1800).
  - [ ] `volto-object-widget` — cauză confirmată: migrarea a pierdut `RAZZLE_CI=true` din `Makefile` (`develop` îl seta de 2×), iar `packages/volto-object-widget/src/index.js:38` înregistrează blocul demo doar atunci → 1 test pică și lasă fixture-ul `/Plone/cypress` în urmă, ceea ce cascadează în celelalte 11 (400 „id invalid - it is already in use").
  - [ ] `volto-searchlib` (V19 unit sh exit 2 — consola Jenkins e auth-gated; reprodus local parțial, dar 2 din eșecuri sunt artefacte de harness, imaginea CI include addon-uri surori), `volto-slate-zotero` (V19 integrare: 2/9 — comportament de produs), `volto-eea-website-theme` #395 (V18 `@plone/babel-preset-razzle: workspace:*` → altă rută decât pinul în pachetul addonului; V18 integrare cu `timeout 1800` depășit).
- [ ] **Design-system: release + unpin** — scoate pinul DS din `volto-datahub` (`fd7fd5c`) după release (fix focus variables e pe branch-ul `volto19`, `973ebb1f6`).
- [ ] **Unpin chatbot + searchlib** — după release-urile majore, scoate override-urile din globalsearch/policy/datahub.
- [ ] **Repo `collective/*`** (authomatic, rss-provider, subsites): decizie user — PR / push / skip.
- [ ] (opțional) Lock refresh la repo-urile cu dependințe noi (`react-portal`, `lodash.debounce`, pinurile git) înainte de merge-ul PR-urilor.

# Închis în sesiune

- [x] **Batch F — `volto-object-widget`: COMPLET VERDE** (`Jenkins` success, toate stage-urile): (1) `Makefile` `start-ci` nu mai seta deloc `RAZZLE_CI`, iar `packages/volto-object-widget/src/index.js:38` înregistrează blocul demo doar atunci → V18 integrare 12/12 trec după fix; (2) `JsonWidget.test.jsx` avea două `vi.mock(..., () => {})` care întorc `undefined`, respinse de vitest 3.2.7 → 11/11 fișiere, 75 teste trec local.
- [x] **Batch F — `volto-group-block`: V19 verde, V18 deschis** (unit reparat: `Edit.test.jsx` avea o fabrică `vi.mock` care întorcea o componentă goală în loc de `{ default }` → 36 teste trec; integrarea V19 5/5 trece după ce testul de round-trip scris de noi a fost întărit cu o barieră de hidratare). Rămas: pe stage-ul V18, `03-block-group-view.cy.js` nu deschide sidebar-ul blocului după `cy.visit('/edit')` (inputul `#field-title` rămâne al paginii, valoare 'Group View Persistence'), deci blocul trebuie selectat explicit înainte de a-i deschide setările — test-only, o iterație următoare.
- [x] **Batch F — `volto-eea-website-theme` #395: parțial.** Lint rezolvat (override-ul `react/jsx-no-target-blank` cu `allowReferrer: true` restaurat din develop → stage-ul V19 ES lint verde). V18 `Build test image` rămâne roșu: cauza verificată e `@plone/babel-preset-razzle: workspace:*` (pachetul nu există în monorepo-ul Volto 18) — pinul `^1.0.1` repară imaginea, dar a stricat stage-ul V19 unit (A/B verificat: cu pin → `Unit tests` exit 2; după revert → verde), deci a fost revertat (`a1f2c07`) și are nevoie de altă rută (declarat în `package.json`-ul rădăcină, sau regenerat lockfile după pin). V18 integrare nu a apucat să ruleze din cauza imaginii; când imaginea a trecut, suita V18 a fost omorâtă de `timeout -s 9 1800` (exit 137).

- [x] **Sync `volto19` cu `develop`** la singurele 2 PR-uri rămase în urmă din 59: `volto-block-data-table` #20 (**complet verde**, Jenkins Success + SonarQube OK) și `volto-block-toc` #53 (V19 verde, V18 deschis — vezi mai sus).
- [x] Diagnostic Sonar pe 4 PR-uri: toate sunt **doar coverage**, nu bugs (`volto-eea-chatbot`, `volto-embed`, `volto-eea-website-policy`, `volto-redmine-helpdesk`).
- [x] 21 add-on-uri reparate (batch A–E), verzi pe branch (`Jenkins` success + stage-scan none).
- [x] 21 PR-uri `volto19 → develop` deschise pentru toate repo-urile verzi fără PR.
- [x] Design-system `6c28303ea` (`prepare` → `husky:install`).
- [x] Docs canonice actualizate (`35ad3f9`).
