# Handoff — pentru sesiunea următoare

## Stare

Campania red→green Volto 19: **dashboard 60 verzi / 3 roșii** (57/10 la finalul sesiunii 3).
În sesiunea 4 s-au închis complet `group-block`, `editing-progress` și `slate-zotero`, iar `theme` e verde pe
V19 (unit 637 + integrare 23). Rămîn: `theme` V18 integrare (hang), `block-toc` V18 (amânat de user) și
`countup` (skip).

Oprire la cererea userului după sesiunea 4. **Nu s-au făcut merge-uri** (decizie user: totul se lucrează pe
branch-urile `volto19`). Toate commit-urile de mai jos sînt deja pushuite pe `volto19`; docs pe `main`
(`403d06a`).

Branch-uri/PR-uri de referință: `group-block` `df1af90`, `editing-progress` `0f02968`, `slate-zotero`
`0d9f518`, `theme` `1ad6096`, `chatbot` #45 `db5e20b`, `policy` #138 `c012de6`, `embed` #88 `d30623f`,
`redmine` #30 `f4bb8d5`, `block-data-table` #20 `f7823d3`, `searchlib` `1f1231e`, `object-widget` `fc8a5fc`.

## Ce face sesiunea următoare (primii pași)

1. **`theme` V18 integrare** — singurul blocaj acționabil rămas. `timeout -s 9 1800` (exit 137) pe
   `01-block-basics.cy.js`; pe `develop` (pre-migrare) V18 integrarea trecea (23 teste), deci e regresie de
   migrare. Ipotezele și pașii (repro local amd64 emulat, consola Jenkins, bisect pe `33945b3`) sînt în
   `diagnostics/theme-v18-integration-hang.md`.
2. **`block-toc` V18** — amânat de user; diagnostic complet în `diagnostics/block-toc-v18-slate-focus.md`
   (bug de focus sincron în Volto 18.35.1, plone/volto#8406).
3. **Amânate de user** (nu le atinge fără confirmare): `countup`, cele 3 `collective/*` (authomatic,
   rss-provider, subsites), `eea-website-frontend` #284.

## Capcane de mediu (verificate în sesiunile 2–4)

- **Harness local integrare (zotero)**: backend `eeacms/plone-backend:latest` (`SITE=Plone`, `PROFILES=eea.kitkat:testing`), frontend din `frontend/core/packages/volto` cu Node 24 (engines `^24`) și `NODE_OPTIONS="--dns-result-order=ipv4first --max-old-space-size=16384"` — altfel razzle leagă bundle-ul client pe IPv6 (`[::1]:3001`) și Cypress nu hidratează. Rețeta completă: `diagnostics/slate-zotero-v19.md`.
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
