# SonarQube coverage gate — cum se calculează și cum se repară

Rezultat: cele 4 PR-uri roșii pe coverage au devenit verzi (batch G).

| Repo (PR) | coverage înainte | după | master | stare |
|---|---|---|---|---|
| `volto-eea-chatbot` #45 | 79.30 | **81.60** | 84.80 | Jenkins `Success`, Sonar `success`, PR `CLEAN` |
| `volto-eea-website-policy` #138 | 26.90 | **74.00** | 52.00 | idem |
| `volto-embed` #88 | 46.60 | **67.00** | 60.00 | idem |
| `volto-redmine-helpdesk` #30 | 41.30 | **51.20** | 48.80 | idem |

## Semantica porții (verificată)

Mesajul porții e o conjuncție de eșecuri:

```text
The percentage of coverage is smaller in the PR-XX branch (N) than the master (M) branch and is under the 80% threshold
```

deci **trece** dacă `N >= M` **sau** `N >= 80`. Dovadă: `redmine` a trecut cu `51.20 >= 48.80` (sub 80).

`coverage` (metricul din poartă) = `(linii acoperite + branchuri acoperite) / (linii + branchuri)`, nu doar
linii — de asta `chatbot` pica la 79.30 deși avea 83.8% linii (branchuri 73.3%).

## De unde vin cifrele (fără login la Jenkins/Sonar)

API-ul Sonar de la `https://sonarqube.eea.europa.eu` e **public** (fără token):

```bash
# total pe PR / pe master
curl -s "https://sonarqube.eea.europa.eu/api/measures/component?component=<proiect>&pullRequest=<nr>&metricKeys=coverage,line_coverage,branch_coverage,lines_to_cover,uncovered_lines"
curl -s "https://sonarqube.eea.europa.eu/api/measures/component?component=<proiect>&branch=master&metricKeys=coverage"

# defalcarea pe fișiere (de aici se vede ce trebuie acoperit)
curl -s "https://sonarqube.eea.europa.eu/api/measures/component_tree?component=<proiect>&pullRequest=<nr>&metricKeys=coverage,line_coverage,branch_coverage,uncovered_lines,lines_to_cover&qualifiers=FIL&ps=500"
```

Atenție: dacă un singur `metricKeys` e invalid (`covered_lines`, `uncovered_branches`,
`branches_to_cover` nu există), API-ul întoarce eroare pentru tot request-ul.

## Mecanismul real: Sonar unește DOUĂ lcov-uri

`Jenkinsfile`:

```groovy
sonar-scanner -Dsonar.javascript.lcov.reportPaths=./xunit-reports-current/coverage/lcov.info,./cypress-coverage-current/coverage/lcov.info
```

- `xunit-reports-current` = lcov-ul **unit** (vitest, `packages/<addon>/vitest.config.mjs` → `coverage.exclude`);
- `cypress-coverage-current` = lcov-ul de **integrare**, produs de instrumentarea `babel-plugin-istanbul` din
  `.coverage.babel.config.js` (`include: ['packages/*/src/**']`), copiat din containerul cypress.

Sonar numără ca „lines to cover” fișierele care apar în **uniunea** celor două rapoarte; un fișier absent din
ambele nu intră în metrică. Consecințe practice:

1. **Excluderea doar din `vitest.config.mjs` nu e suficientă** — instrumentarea de integrare readuce fișierul.
   Prima încercare pe `chatbot` (doar vitest) a dat 79.60 → 79.30 (zgomot).
2. **Excluderile trebuie oglindite în `.coverage.babel.config.js`** (opțiunile pluginului `istanbul`), care
   folosește același `cwd` = rădăcina workspace-ului (`/app`), deci pattern-urile arată
   `packages/*/src/**/...`.
3. Fișiere de tip barrel (`index.*`), `*schema.*`, `*config.*` sînt excluse din raportul unit dar **nu** din
   cel de integrare → apar ca 0% și trag media în jos. Pe `chatbot` asta valora 110 linii
   (`markdown/index.jsx` 56, `utils/index.tsx` 49, `schema.jsx` 9): 79.30 → **81.60**.

## Rețete

- **Excludere legitimă** (cod vândut/nesemnificativ, ca pe master): `redmine` — `captcha/widget.js` +
  `worker.js` = 2363 linii la 0%, pe master erau excluse de jest (`collectCoverageFrom` cu `!.../captcha/**`).
  Fix = `src/captcha/**` în vitest **și** `packages/*/src/**/captcha/**` în `.coverage.babel.config.js`.
- **Teste reale** (cînd nu există excludere de recuperat): `policy` (customizarea HTML/Edit, 344 linii la 0%),
  `embed` (`MapsWidget.jsx` 210 linii fără niciun test + `Toolbar/*` parțial). Scrise de subagenți `worker`,
  validate de părinte (eslint `--max-warnings=0`, suita completă, coverage măsurat).

## Harness local pentru coverage (rețetă verificată)

```bash
cd frontend/packages/<repo>
[ -d core ] || { mkdir -p core/packages; rsync -a --exclude node_modules --exclude .git ../../core/packages/volto core/packages/; }
ln -sfn .../frontend/core/packages/volto/node_modules core/packages/volto/node_modules   # /core e gitignored

# providerul de coverage nu există în instalarea părinte; se ia din npm și se leagă simbolic:
mkdir -p /tmp/covprovider && (cd /tmp && npm i @vitest/coverage-istanbul@<versiunea din repo>)
ln -sfn /tmp/node_modules/@vitest/coverage-istanbul frontend/node_modules/@vitest/coverage-istanbul

../../node_modules/.bin/vitest run --config packages/<repo>/vitest.config.mjs --coverage --coverage.reporter=text
```

Capcane de harness (toate întâlnite și rezolvate):

- Addon-urile surori sînt **monorepo-uri**: link-ul corect e `packages/<sora> -> ../<sora>/packages/<sora>`
  (nu `../<sora>`), altfel `@eeacms/<sora>/utils` nu se rezolvă.
- **Symlink-urile ies din `server.fs.allow`** și Vite refuză rezolvarea: pentru un run local e nevoie de o
  **copie reală** (`rsync -a --exclude node_modules ../<sora>/packages/<sora>/ packages/<sora>/`).
- `packages/volto-matomo`, `packages/volto-eea-map`, `packages/volto-searchlib`,
  `packages/volto-block-data-figure` sînt **symlink-uri track-uite în git** în repo-urile de addon — nu le
  suprascrie/șterge (se restaurează cu `git checkout -- <path>`).
- Dependințe npm care lipsesc local (ex. `@datapunt/matomo-tracker-react`) se instalează în `/tmp` și se leagă
  simbolic în `frontend/node_modules/`.
- `vitest` scrie raportul de coverage doar cînd run-ul se termină cu succes: dacă un fișier de test pică la
  transform (import nerezolvabil), folosește lista de fișiere care rulează, altfel tabelul nu apare.
