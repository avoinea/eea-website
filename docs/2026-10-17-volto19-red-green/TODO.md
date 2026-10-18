# TODO (deschis)

- [ ] **`volto-block-toc` #53 — V18 roșu după sync** (decis: amânat pentru altă iterație). Sync cu `develop` e făcut (`54bdc10`) și V19 e verde (41 unit + 4 integrare), dar stage-ul V18 pică 2/4 în testele care schimbă variația blocului. Diagnostic complet, dovezi și opțiuni A/B/C: `diagnostics/block-toc-v18-slate-focus.md`. Hardening test-side încercat de 2 ori (`e68d2f3`, `bb7d802`) — nu e suficient: textul tastat chiar se pierde (bug de focus sincron în Volto 18.35.1, plone/volto#8406 livrat în 18.36.0).
- [ ] **PR-uri verzi**:
  - [x] `volto-editing-progress` #37 — REZOLVAT: `01-block-basics.cy.js` așteaptă PATCH-ul de control panel și asertează pe `.ep-sidenav-btn` / `.sidenav-ol--ep` (nu pe `.progress__title` al workflow-progress). V18 5/5, V19 5/5, unit 74.
  - [ ] SonarQube pe PR: REZOLVAT integral în batch G (chatbot #45, embed #88, policy #138, redmine #30 — toate verzi); vezi `diagnostics/sonar-coverage.md`.
  - [ ] Nota + checklist-ul de unpin chatbot/searchlib în body-ul `volto-eea-website-policy` #138 (owner: user).
  - [ ] `eea-website-frontend` #284 — job Jenkins pe Node 18 vs `engines ^24` (config, owner: user).
- [ ] **Ultimele branch-roșii**:
  - [x] `volto-group-block` — REZOLVAT: V18+V19 integrare 5/5, unit 36. `selectGroupBlock()` selectează wrapper-ul `.block.group:not(.inner)` înainte de a deschide setările (`.block.group` prindea și wrapper-ul interior `ui drag block inner group`).
  - [ ] `volto-eea-website-theme` #395 — V19 COMPLET VERDE (unit 637, integrare 23) după: mock global `Loadable` în `vitest.setup.jsx` (337 unhandled rejections), aserțiune pe `<img>`-ul real în `Image/Edit.test.jsx`, importul corect în `10-object-browser-selection-limit.cy.js`, așteptarea PATCH-ului în `07-lead-image.cy.js`, selectorii V18 în `01-block-basics.cy.js`. RĂMÎNE: integrarea V18 expiră la `timeout -s 9 1800` (exit 137) — diagnostic și ipoteze în `diagnostics/theme-v18-integration-hang.md`.
  - [x] `volto-object-widget` — REZOLVAT: migrarea pierduse `RAZZLE_CI=true` din `Makefile` (`develop` îl seta de 2×), iar `src/index.js:38` înregistrează blocul demo doar atunci → 1 test pica și lăsa fixture-ul `/Plone/cypress` în urmă, cascadă în celelalte 11 (400 „id invalid - it is already in use"); plus `vi.mock` care întorcea `undefined` în `JsonWidget.test.jsx`.
  - [x] `volto-searchlib` — REZOLVAT (vezi „Închis în sesiune").
  - [x] `volto-slate-zotero` — REZOLVAT: `39223bd` (`waitForSidebarCitationCount(1)` înainte de save în spec 08) + `0d9f518` (produs: `ZoteroDataWrapper` ignoră răspunsurile `/collections/top` întîrziate cît timp userul e într-o colecție). V18 9/9, V19 9/9, unit 35; diagnostic în `diagnostics/slate-zotero-v19.md`.
- [ ] **Design-system: release + unpin** — scoate pinul DS din `volto-datahub` (`fd7fd5c`) după release (fix focus variables e pe branch-ul `volto19`, `973ebb1f6`).
- [ ] **Unpin chatbot + searchlib** — după release-urile majore, scoate override-urile din globalsearch/policy/datahub.
- [ ] **Repo `collective/*`** (authomatic, rss-provider, subsites): decizie user — PR / push / skip.
- [ ] (opțional) Lock refresh la repo-urile cu dependințe noi (`react-portal`, `lodash.debounce`, pinurile git) înainte de merge-ul PR-urilor.

# Închis în sesiune

- [x] **`volto-searchlib`: branch COMPLET VERDE** (era roșu de la începutul campaniei). Trei cauze distincte, toate reparate: (1) `jest.mock`/`jest.fn` nehoistate sub vitest în `SearchInput.test.jsx` (4 teste) și `TopFilterLayout.test.jsx`; (2) `require('@eeacms/volto-eea-chatbot')` în corpul testelor din `ChatbotAnswer.test.jsx` — ocolea fabrica `vi.mock` și încărca pachetul real prin loader-ul Node, care pica pe importul de director `./ChatBlock` (11 teste); (3) build-ul V19 al integrării: `razzle-dev-utils/makeLoaderFinder` nedeclarat de nimeni (pe V18 se rezolva prin razzle-ul din core, pe V19 nu mai există) → adăugat în `devDependencies` la rădăcină. Rezultat: unit 303, integrare 2+2, Jenkins `Success`. Detalii: `diagnostics/searchlib-unit-and-build.md`.

- [x] **Batch G — toate cele 4 PR-uri cu SonarQube roșu sînt VERZI** (`Jenkins` Success + `SonarQube` success + toate testele, PR-uri `CLEAN`):
  - [x] `volto-eea-chatbot` #45: 79.30 → **81.60** (master 84.80; trece pragul de 80). Cauza: fișierele barrel (`markdown/index.jsx` 56 linii, `utils/index.tsx` 49, `schema.jsx` 9) erau excluse din raportul unit dar readuse ca 0% de instrumentarea de integrare.
  - [x] `volto-eea-website-policy` #138: 26.90 → **74.00** (master 52.00) — teste reale pentru customizarea `HTML/Edit.jsx` (344 linii la 0%) + `blacklistRoutes.js`.
  - [x] `volto-embed` #88: 46.60 → **67.00** (master 60.00) — teste pentru `MapsWidget.jsx` (210 linii, fără niciun test), `Share`, `FigureNote`, `PrivacyProtection/utils` + completări pe `Sources`/`Toolbar`.
  - [x] `volto-redmine-helpdesk` #30: 41.30 → **51.20** (master 48.80) — `captcha/**` (2363 linii la 0%) exclus din ambele lcov-uri, ca pe master.
- [x] Mecanismul complet documentat în `diagnostics/sonar-coverage.md` (semantica porții, API-ul Sonar public, uniunea celor două lcov-uri, rețeta de harness local + capcanele de symlink).

- [x] **Batch F — `volto-object-widget`: COMPLET VERDE** (`Jenkins` success, toate stage-urile): (1) `Makefile` `start-ci` nu mai seta deloc `RAZZLE_CI`, iar `packages/volto-object-widget/src/index.js:38` înregistrează blocul demo doar atunci → V18 integrare 12/12 trec după fix; (2) `JsonWidget.test.jsx` avea două `vi.mock(..., () => {})` care întorc `undefined`, respinse de vitest 3.2.7 → 11/11 fișiere, 75 teste trec local.
- [x] **Batch F — `volto-group-block`: V19 verde, V18 deschis** (unit reparat: `Edit.test.jsx` avea o fabrică `vi.mock` care întorcea o componentă goală în loc de `{ default }` → 36 teste trec; integrarea V19 5/5 trece după ce testul de round-trip scris de noi a fost întărit cu o barieră de hidratare). Rămas: pe stage-ul V18, `03-block-group-view.cy.js` nu deschide sidebar-ul blocului după `cy.visit('/edit')` (inputul `#field-title` rămâne al paginii, valoare 'Group View Persistence'), deci blocul trebuie selectat explicit înainte de a-i deschide setările — test-only, o iterație următoare.
- [x] **Batch F — `volto-eea-website-theme` #395: parțial.** Lint rezolvat (override-ul `react/jsx-no-target-blank` cu `allowReferrer: true` restaurat din develop → stage-ul V19 ES lint verde). V18 `Build test image` rămâne roșu: cauza verificată e `@plone/babel-preset-razzle: workspace:*` (pachetul nu există în monorepo-ul Volto 18) — pinul `^1.0.1` repară imaginea, dar a stricat stage-ul V19 unit (A/B verificat: cu pin → `Unit tests` exit 2; după revert → verde), deci a fost revertat (`a1f2c07`) și are nevoie de altă rută (declarat în `package.json`-ul rădăcină, sau regenerat lockfile după pin). V18 integrare nu a apucat să ruleze din cauza imaginii; când imaginea a trecut, suita V18 a fost omorâtă de `timeout -s 9 1800` (exit 137).

- [x] **Sync `volto19` cu `develop`** la singurele 2 PR-uri rămase în urmă din 59: `volto-block-data-table` #20 (**complet verde**, Jenkins Success + SonarQube OK) și `volto-block-toc` #53 (V19 verde, V18 deschis — vezi mai sus).
- [x] Diagnostic Sonar pe 4 PR-uri: toate sunt **doar coverage**, nu bugs (`volto-eea-chatbot`, `volto-embed`, `volto-eea-website-policy`, `volto-redmine-helpdesk`).
- [x] 21 add-on-uri reparate (batch A–E), verzi pe branch (`Jenkins` success + stage-scan none).
- [x] 21 PR-uri `volto19 → develop` deschise pentru toate repo-urile verzi fără PR.
- [x] Design-system `6c28303ea` (`prepare` → `husky:install`).
- [x] Docs canonice actualizate (`35ad3f9`).
