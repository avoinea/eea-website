# Handoff — campania „repo-uri verzi" (EEA Volto 19)

Data: 2026-10-16 ~18:45. Focus sesiune următoare: continuarea campaniei cu **Batch 2**
(opțional: mini-valul `cypress-fail-fast` pe cele 16 repo-uri rămase).

## Reguli stabilite cu userul (nu le re-deschide)
- „Verde" = toate check-urile Jenkins de pe HEAD `success` (ambele stage-uri Volto
  18/19, Unit, lint, secrets). Eșec de infrastructură („Agent was removed", docker
  flaky) → re-run; dacă persistă, raportat separat.
- Batch-uri de 3; după 3 verzi: STOP, raport, așteaptă semnalul explicit.
- Fix minim de test/CI + documentăm cauza de fond (decizia C); fără schimbări de
  cod de produs fără aprobare.
- Push direct pe `volto19`; `countup` = skip; repo-urile grele la urmă.
- Subagenți: diagnostichează/propun; părintele aplică și pushuiește.

## Stare la handoff
- **Batch 1 VERDE**: `volto-citation` `2fc4ae1`, `volto-toolbar-actions` `25bd898`,
  `volto-eea-versions` `8df9b27` (unit + ambele integrări + Jenkins Success).
- Cele 3 fix-uri per repo: praguri coverage scoase (repo-uri fără teste),
  `failOnStatusCode:false` la cleanup-ul `removeContent`, scos importul stale
  `cypress-fail-fast`. Detalii: `docs/.../REPORT.md` → „Campanie verde pe repo-uri — Batch 1".
- **Descoperire high-leverage**: importul stale `cypress-fail-fast` există în 19
  repo-uri (lista completă în `docs/.../TODO.md`). Migrarea `5091a33` a șters
  `require('cypress-fail-fast/plugin')(on, config)` din `cypress.config.js` și
  dependința din `package.json`, dar a lăsat importul în support → toate
  `cy.task('failFastShouldSkip'/'failFastFailedTests')` pică hook-urile.
- Subagent local pe `volto-citation` (repro integrare V18/19) rula la handoff;
  containerele `citation-plone` / `citation-cypress*` se curăță dacă rămân
  (`docker ps`, `docker rm -f`).

## Documente de referință (nu duplica)
Repo `avoinea/eea-website`, branch `main`, ultimul commit `59e7d56`:
`docs/2026-10-16-volto19-coverage-and-migration/` — `README.md`, `HANDOFF.md`
(capcane de mediu), `TODO.md` (batch 2 + lista fail-fast), `REPORT.md`,
`PLAN.md`, `DECISIONS.md`, `diagnostics/`, `spotcheck-2026-10-16.txt`,
`regressions-per-check.txt`, `regressions-per-title.txt`, `scripts/`.
Workspace local: `/Users/alin/sandbox/eea-website-volto19` (add-on-urile în
`frontend/packages/*`; core-urile Volto 18/19 în `volto18/`, `volto19/`).

## Ce face sesiunea următoare (pași concreți)
1. Confirmă cu userul batch 2: propunere `volto-embed-content`, `volto-redirector`,
   `volto-design-tokens` (din lista fail-fast); alternative `volto-hero-block`
   (un singur selector) sau `volto-globalsearch` + `volto-eea-website-policy`
   (aceeași lipsă `razzle-dev-utils/makeLoaderFinder`).
2. Per repo: SHA din `git ls-remote` (nu din ref-ul local — Jenkins pushuiește
   „style: Automated code fix"); verifică **toate** stagiile picate (check-urile
   de stage pot fi fals `success` cu „No test results found"); aplică fix-urile
   pattern (vezi skill-ul `volto19-green-campaign`); commituri dedicate; push;
   așteaptă Jenkins (poll bounded); raportează.
3. Actualizează `TODO.md`/`REPORT.md` după fiecare batch.

## Capcane esențiale (detalieri în `docs/.../HANDOFF.md`)
- `make test-ci` folosește doar `--reporter=junit` → fără output de erori; local
  adaugă `--reporter=default --coverage=false`.
- Nu te încrede doar în concluziile check-runs: parsează aggregate Jenkins
  `output.summary` după secțiunile `` ### `Testing / ...` `` care conțin „Error in".
- Jenkins API doar cu cookie de sesiune din Chrome (`chrome_cdp` →
  `Network.getCookies` pe `https://ci.eionet.europa.eu/`) + `Jenkins-Crumb`;
  rebuild branch: `POST /job/volto-addons/job/<repo>/job/volto19/build` → 201.
- Docker pe arm64: imaginile locale au symlink-uri pnpm rupte; NU extrage tar de
  pe macOS (AppleDouble `._*`) — folosește `git archive | docker exec -i tar`.
- macOS bash 3.2: fără `timeout`, `awk` fără `\x1f`.

## Skill-uri sugerate pentru sesiunea următoare
- `volto19-green-campaign` (nou) — protocol + tiparele de fix-uri ale campaniei.
- `volto-cypress-writer` — orice test Cypress din add-on-uri.
- `plone-frontend-developer` — build/config Volto 19, pnpm, Jenkins.
- `handoff` — la finalul sesiunii următoare.
