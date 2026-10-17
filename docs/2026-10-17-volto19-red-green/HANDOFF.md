# Handoff — pentru sesiunea următoare

## Stare

Campania red→green Volto 19: **dashboard 57 verzi / 10 roșii** (de la 50/15 la finalul sesiunii 2).
În sesiunea 3 s-au închis: sync-ul celor 2 PR-uri rămase în urmă față de `develop`, batch F (object-widget complet,
group-block V19, theme lint), batch G (**toate cele 4 PR-uri cu SonarQube roșu**) și `volto-searchlib` (unit + integrare).
Toate commit-urile sunt pe branch-urile `volto19` (vezi `REPORT.md`); docs pe `main`.

Branch-uri/PR-uri de referință: `chatbot` #45 `db5e20b`, `policy` #138 `c012de6`, `embed` #88 `d30623f`,
`redmine` #30 `f4bb8d5`, `block-data-table` #20 `f7823d3`, `searchlib` `1f1231e`, `object-widget` `fc8a5fc`,
`group-block` `5edc69c`, `theme` `a1f2c07`, `block-toc` `bb7d802`.

## Ce face sesiunea următoare (primii pași)

1. **Merge la PR-urile verzi** (decizia userului): `chatbot` #45, `policy` #138, `embed` #88, `redmine` #30,
   `block-data-table` #20 — toate `MERGEABLE`/`CLEAN`. După merge, verifică dacă mai e nevoie de unpin-urile
   din `TODO.md`.
2. **Ultimele 5 roșii acționabile**, în ordinea dificultății:
   - `group-block` V18: test-only, selectarea explicită a blocului în ciclul 2 din `03-block-group-view.cy.js`
     (V19 e verde; pe 18.35.1 sidebar-ul rămâne pe tab-ul Document după `cy.visit('/edit')`).
   - `editing-progress` #37 V18: `01-block-basics.cy.js:147` („2 fields missing"); pe branch trece → de re-rulat,
     apoi de reprodus local cu harness-ul.
   - `theme` #395 V18 image: pinul în addon **strică** stage-ul V19 unit (A/B verificat) → încearcă
     `@plone/babel-preset-razzle` (registry) în `package.json`-ul rădăcină + scos `workspace:*` din addon;
     apoi V18 integrare (timeout 1800 — dacă expiră, e problemă de durată, nu de test).
   - `slate-zotero` V19 integrare 2/9 (comportament de produs, nu test).
   - `block-toc` V18: amânat de user; dacă se reia, diagnosticul e complet în
     `diagnostics/block-toc-v18-slate-focus.md` (bug de focus sincron în Volto 18.35.1, plone/volto#8406).
3. **Amânate de user** (nu le atinge fără confirmare): `countup`, cele 3 `collective/*` (authomatic, rss-provider,
   subsites), `eea-website-frontend` #284.

## Capcane de mediu (verificate în sesiunile 2–3)

- **Sonar e citibil fără login**: `https://sonarqube.eea.europa.eu/api/measures/component?component=<proiect>&pullRequest=<nr>` (și `branch=master`, `component_tree` pentru defalcare pe fișiere). De aici vin cifrele exacte, nu din check-run-uri. Un singur `metricKeys` invalid → eroare pentru tot request-ul.
- **Poarta Sonar** trece dacă `PR >= master` **sau** `PR >= 80`; metrica combină linii + branchuri, iar Sonar unește **două** lcov-uri (unit + integrare cypress) → excluderile trebuie puse în `vitest.config.mjs` **și** în `.coverage.babel.config.js`. Detalii: `diagnostics/sonar-coverage.md`.
- **Harness local pentru unit/coverage**: copiază `core/packages/volto` în repo (gitignored) și leagă `node_modules` al core-ului; providerul `@vitest/coverage-istanbul` nu e instalat în `frontend/` — ia-l din npm în `/tmp` și leagă-l simbolic în `frontend/node_modules/@vitest/`. Addon-urile surori se **copiază** (`rsync`), nu se linkează (Vite respinge symlink-urile care ies din repo și mesajele sînt înșelătoare). `vitest` scrie raportul de coverage doar dacă run-ul se termină cu succes.
- **`packages/volto-matomo`, `packages/volto-eea-map`, `packages/volto-searchlib`, `packages/volto-block-data-figure`** sînt **symlink-uri track-uite în git** în repo-urile de addon — nu le suprascrie/șterge (`git checkout -- <path>`).
- **Jenkins**: consola e auth-gated, dar `check-run`-ul aggregate `Jenkins` conține summary-ul stagiilor picate (uneori trunchiat înainte de output-ul vitest). jUnit-ul e copiat de CI, dar check-ul de stagiu raportează uneori „No test results found". Pentru re-trigger: push (sau commit gol). Jenkins poate pusha „style: Automated code fix" pe `volto19` → `git fetch && git rebase origin/volto19` înainte de push.
- **Hook local**: `lint-staged` nu e instalat → `git commit --no-verify` după ce rulezi manual `eslint --max-warnings=0` + `prettier --check --ignore-path /dev/null`.
- **Teste moștenite din jest**: `jest.mock` nu e hoistat sub vitest (aliasul global `jest = vi` nu ajută) → `vi.hoisted` + `vi.mock`; `require(...)` în teste ocolește fabrica și încarcă pachetul real prin loader-ul Node → folosește import ESM; fabricile de mock trebuie să întoarcă un obiect (`{ default: ... }`), altfel vitest 3 aruncă „is not returning an object".
- **Dashboard**: `dashboard/` (untracked) — `curl http://127.0.0.1:3210/api/status` (rulează `npm start` în `dashboard/` dacă nu e pornit).
- **prettier de la rădăcina monorepo-ului e vacu u**: `.gitignore` ignoră `frontend/`; rulează cu `--ignore-path /dev/null`.

## Skill-uri utile

- `volto19-green-campaign` (principal; scripturi în `.agents/skills/volto19-green-campaign/scripts/`).
- `plone-frontend-developer` (Vitest/coverage/Volto 19), `handoff` la finalul sesiunii.
- Subagenți: diagnostice read-only (`scout`) și scriere de teste (`worker`), un singur writer per repo, validare de către părinte înainte de push.
