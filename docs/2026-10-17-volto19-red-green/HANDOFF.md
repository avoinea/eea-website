# Handoff — pentru sesiunea următoare

## Stare

Campania red→green Volto 19: **dashboard 60 verzi / 3 roșii**. Sesiunea 4 a închis `group-block`,
`editing-progress` și `slate-zotero`; `theme` e verde pe V19 (unit 637 + integrare 23). Sesiunea 5 a
**reprodus local** hang-ul V18 al temei și l-a izolat: nu e infra/timeout, e o **buclă de JS în browser**
declanșată de `cy.getSlate().click()` pe pagină goală. Nimic nu s-a modificat în cod în sesiunea 5.

Branch: `theme` `1ad6096` pe `volto19` (doar integrarea V18 roșie). Restul commit-urilor de referință ca în
sesiunea 4: `group-block` `df1af90`, `editing-progress` `0f02968`, `slate-zotero` `0d9f518`, `chatbot` #45
`db5e20b`, `policy` #138 `c012de6`, `embed` #88 `d30623f`, `redmine` #30 `f4bb8d5`, `block-data-table` #20
`f7823d3`, `searchlib` `1f1231e`, `object-widget` `fc8a5fc`. **Fără merge-uri** (decizia 23).

## Primii pași

1. **Izolează clicul** (~40 s/run, în containerul `theme-v18-fe`): `cy.get('.block.inner').last().click({force:true})`
   singur → apoi + `block-add-button` → apoi + chooser „Text” → apoi + butonul `.slate`. Unul dintre ele dă bucla.
2. **Ia stack-ul buclei**: repro în Chromium simplu din container, cu `Debugger.enable` **înainte** de navigare
   (token din `POST /Plone/@login`, cookie `auth_token`, conținut creat prin REST, click-uri prin CDP `Input`),
   apoi `Debugger.pause` → frame-uri; mapare coloană → sursă prin sourcemap-ul din `build/static/js/*.map`.
   Scripturile CDP din sesiunea 5 (dacă mai există): `/tmp/cdp-probe.mjs`, `/tmp/cdp-fresh.mjs`, `/tmp/cdp-map.mjs`.
3. **Fix test-side** (probabil): pre-crearea blocului text prin REST în `slateBeforeEach`, sau calea
   `{enter}`/slash-command, în locul fallback-ului cu `force: true` din `cypress/support/commands.js:394-424`.
4. ~~Apoi `block-toc` V18~~ — **închis în sesiunea 6**: cauza era imaginea (`eeacms/frontend-builder:18` livra Volto 18.35.1), urcată la 18.36.0 în `eea/frontend-builder` 18.x `7cb8c2e`; plus merge `develop` `a99d9a2` și retype mărginit `30384bd` → PR #53 verde complet. Vezi `diagnostics/block-toc-v18-slate-focus.md` și `diagnostics/frontend-builder-18-image.md`.
5. **Re-verifică `theme` V18 pe imaginea nouă** înainte de stack-ul prin CDP: hang-ul izolat în sesiunea 5 (`cy.getSlate().click()` pe pagină goală) poate fi chiar bug-ul de focus Slate reparat în 18.36.0.

Amânate de user (nu le atinge fără confirmare): cele 3 `collective/*` (authomatic, rss-provider,
subsites), `eea-website-frontend` #284.

## Stare locală (sesiunea 5)

- Containere **pornite**: `theme-v18-plone` (backend healthy) + `theme-v18-fe` (V18 prod pe :3000); imaginea
  `theme-v18-local` construită. Oprire: `docker rm -f theme-v18-fe theme-v18-plone && docker rmi theme-v18-local`.
- Sondele de bisect sînt **doar în container** (`/app/cypress/tests/{60..99}-*.cy.js`) și în `/tmp/probes/` pe
  host; repo-ul `frontend/packages/volto-eea-website-theme` e curat (`git status` gol).
- Dashboard: `dashboard/` (untracked) — `curl http://127.0.0.1:3210/api/status`; dacă nu răspunde, `npm start`
  în `dashboard/`.

## Capcane de mediu

- **Docker V18**: `eeacms/frontend-builder:18` e doar amd64 → `--platform linux/amd64` la pull/build/run
  (Rosetta merge pe arm64). **Build din context curat**: `.dockerignore` nu exclude `packages/*/node_modules`,
  deci node_modules-urile V19 din worktree strică instalarea V18 („react-portal doesn't exist”).
- **`theme` V18: check-run-ul de stagiu e fals `success`** („No test results found”) — se crede doar agregatul
  `Jenkins`.
- **Jenkins**: consola e auth-gated; `check-run`-ul `Jenkins` are summary cu stagiile picate (trunchiat ~2.5 KB)
  și `output.text` cu arborele de timpi. jUnit-ul raportează uneori „No test results found”. Re-trigger:
  push sau commit gol; Jenkins poate pusha „style: Automated code fix” pe `volto19` → `git fetch && git rebase
  origin/volto19` înainte de push.
- **Harness local integrare V19 (zotero)**: backend `eeacms/plone-backend:latest` (`SITE=Plone`,
  `PROFILES=eea.kitkat:testing`), frontend din `frontend/core/packages/volto` cu Node 24 (engines `^24`) și
  `NODE_OPTIONS="--dns-result-order=ipv4first --max-old-space-size=16384"`; rețeta în
  `diagnostics/slate-zotero-v19.md`.
- **Harness local unit/coverage**: `core/` copiat în repo (gitignored) + `node_modules`-ul core-ului; providerul
  `@vitest/coverage-istanbul` luat din npm în `/tmp` și legat simbolic în `frontend/node_modules/@vitest/`;
  addon-urile surori se **copiază** (`rsync`), nu se linkează (Vite respinge symlink-urile în afara repo-ului).
  `vitest` scrie raportul de coverage doar dacă run-ul se termină cu succes.
- **`packages/volto-matomo`, `packages/volto-eea-map`, `packages/volto-searchlib`,
  `packages/volto-block-data-figure`** sînt symlink-uri track-uite în git în repo-urile de addon — nu le
  suprascrie/șterge (`git checkout -- <path>`).
- **Sonar** e citibil fără login: `sonarqube.eea.europa.eu/api/measures/component?component=<proiect>&pullRequest=<nr>`
  (+ `branch=master`, `component_tree`). Poarta trece dacă PR ≥ master **sau** ≥ 80; excluderile trebuie puse în
  `vitest.config.mjs` **și** `.coverage.babel.config.js`. Detalii: `diagnostics/sonar-coverage.md`.
- **Hook local**: `lint-staged` nu e instalat → `git commit --no-verify` după ce rulezi manual eslint
  `--max-warnings=0` + `prettier --check --ignore-path /dev/null` (prettier de la rădăcina monorepo-ului e vacu u:
  `.gitignore` ignoră `frontend/`).
- **Jest → vitest**: `jest.mock` nu e hoistat → `vi.hoisted` + `vi.mock`; `require()` în teste ocolește fabrica
  (loader-ul Node încarcă pachetul real) → import ESM; fabricile de mock trebuie să întoarcă un obiect
  (`{ default: ... }`).

## Skill-uri utile

`volto19-green-campaign` (principal; scripturi în `.agents/skills/volto19-green-campaign/scripts/`),
`plone-frontend-developer` (Vitest/coverage/Volto 19), `volto-cypress-writer` (selectori/flake Cypress),
`handoff` la finalul sesiunii. Subagenți read-only (`scout`) pentru diagnostic; un singur writer per repo.

## Stare la închiderea sesiunii 8 (2026-10-20)

**Unde sîntem**: `volto-eea-website-theme` (branch `volto19`) are **3 commit-uri locale nepusheiate**:
`b21bd2d` (SlateEditor rebazat pe 19.5 — verificat), `94c2ae7` (fix build: `LeadImage/schema.js`
restaurat), `08967a2` (Form rebazat pe 18 — al userului; pe V19 pierde `withSaveAsDraft`).
Push-ul e amînat intenționat: CI-ul durează ~38 min și se blochează oricum pe V18.

**Primii pași concreți**:
1. Rebasează umbrele **V19-first** (decizie user), în ordinea din `PLAN.md` Faza 16 — începe cu
   `ContentsItem.jsx` (+228/-270 față de core 19.5), apoi `DefaultView.jsx` și `Form.jsx`.
   Pentru fiecare: ia fișierul din `19.5.0`, re-aplică delta EEA din `.diff`, regenerează `.diff`,
   rulează unit + cele două integrări.
2. Hang-ul V18: bisect-ul e complet negativ pe `SlateEditor`, pe calea „add block", pe
   `persistentHelper`-ul `Link` și pe `render.jsx`. Continuă cu ipotezele din
   `diagnostics/theme-shadows-audit.md` §4 (applyConfig, design-system/block-style, umbrele Volto de pe
   calea editorului, `withBlockExtension`, umbrele slate rămase).
3. După ce V18 trece: push pe `volto19` (cele 3 commit-uri + fixurile) și urmărește PR #395.

**Capcane de mediu (verificate în sesiunea 8)**:
- Testul `07-lead-image.cy.js` pică local (behavior `plone.leadimage`) și cu `Form` din core 19.5 pus ca
  umbră → flaky de mediu, nu regresie; în CI a trecut.
- Unit local: `npx vitest run --config packages/volto-eea-website-theme/vitest.local.config.mjs` dă
  625/625 cu 2 suite neîncărcabile (artefacte de alias/JSX); CI face 637.
- Build-ul V18/V19 se face **din context curat** (`rsync` fără `node_modules`/`core`/`build`), altfel
  `packages/*/node_modules` de V19 umbresc instalarea.
- `timeout` nu există pe macOS — rulează-l în container (`docker exec ... sh -c 'timeout -s 9 ...'`).
- CDP: `Debugger.enable` **înainte** de navigare; comenzile `Input.*` nu răspund cînd renderer-ul e
  blocat (nu le aștepta); `getScriptSource` întoarce gol după pauză → ia bundle-ul + `.map` din container
  și mapează offline (`/tmp/smap.py` din sesiunea 8).
- Docker: containerele și imaginile `theme-*` au fost șterse; imaginile de bază
  `eeacms/frontend-builder:18/19` rămîn. Reconstrucție: comenzile din `diagnostics/theme-shadows-audit.md` §5.
