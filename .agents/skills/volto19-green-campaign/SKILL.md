---
name: volto19-green-campaign
description: Continuă campania EEA Volto 19 „repo-uri verzi" — repararea eșecurilor Jenkins preexistente din add-on-urile din frontend/packages, în batch-uri de 3, cu diagnostic CI, tipare de fix-uri (cypress-fail-fast stale, praguri coverage pe raport gol, cleanup 404, lock @lock, betterleaks, selector drift) și verificare/raportare. Use when the user says „continuăm campania", „batch următor", „repo-uri verzi", or asks to fix the remaining Volto 19 add-on CI failures.
---

# Campania „repo-uri verzi" (Volto 19)

## Protocol (stabilit cu userul — nu schimba fără aprobare)

- Batch-uri de 3 repo-uri; după ce toate 3 au toate check-urile Jenkins `success`
  pe HEAD: STOP, raportează, așteaptă semnalul explicit pentru următorul batch.
- „Verde" = toate check-urile Jenkins `success` (integrare Volto 18 și 19, Unit,
  lint, secrets). Eșec de infrastructură („Agent was removed", docker build flaky)
  → re-run; dacă persistă, raportează separat, nu-l număra ca muncă de test.
- Fix minim de test/CI + documentează cauza de fond (TODO separat); cod de produs
  doar cu aprobarea userului. Push direct pe `volto19`.
- `countup` = skip; repo-urile grele (kitkat, object-widget, block-image-cards,
  searchlib, globalsearch, slate-zotero) se lasă la urmă.
- Subagenți: diagnostichează/propun; agentul principal aplică, pushuiește și
  verifică Jenkins (un singur writer per repo).

## Flux per batch

1. Starea check-urilor: `scripts/jenkins-spotcheck.sh`.
2. Pe candidați: `scripts/jenkins-stage-scan.sh <repo>` — check-urile de stage pot
   fi fals `success` („No test results found"); numai secțiunile
   `` ### `Testing / ...` `` cu „Error in" din aggregate-ul `Jenkins`
   (`output.summary`) arată stagiile cu adevărat picate.
3. Alege 3 repo-uri cu fix-uri simple (ideal aceeași clasă de problemă), SHA din
   `git ls-remote` (nu din ref-ul local — Jenkins pushuiește „style: Automated code fix").
4. Aplică tiparele de mai jos, commit dedicat per fix, push, apoi poll Jenkins
   (`gh api .../check-runs`, toate `completed`; max ~20 min/batch) și
   `scripts/classify-regressions.sh` dacă vrei comparația cu baseline-ul.
5. Actualizează `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md`
   (repo `avoinea/eea-website`, branch `main`) și raportează userului.

## Tipare de fix cunoscute

1. **`cypress-fail-fast` stale** — 19 repo-uri au `import 'cypress-fail-fast'` în
   `cypress/support/e2e.js`, dar migrarea `5091a33` a scos
   `require('cypress-fail-fast/plugin')(on, config)` din `cypress.config.js` și
   dependința din `package.json` → hook-urile pică cu
   `failFastShouldSkip` / `failFastFailedTests`. Fix: scoate importul
   (template-ul cookieplone nu folosește fail-fast).
2. **Praguri coverage pe raport gol** — repo fără teste unitare + `--coverage`
   + `coverage.thresholds` → unit stage pică. Fix: scoate pragurile din
   `packages/<addon>/vitest.config.mjs` (precedent `volto-eea-map` `b08feb2`).
3. **Cleanup 404** — `slateAfterEach` → `cy.removeContent('cypress')` primește 404
   (folderul lipsește la cleanup). Fix: `failOnStatusCode: false` în
   `cypress/support/commands.js` la `removeContent`.
4. **Cursa de hidratare (deja aplicată pe toate)** — NU reveni la
   `cy.visit(view) + appHistory.push(edit)`; `slateBeforeEach` încarcă direct
   `/cypress/my-page/edit`.
5. **Lock 403 la PATCH** — editorul montează și blochează pagina; în teste fă
   `DELETE …/@lock` (sau `failOnStatusCode:false`) înainte de PATCH
   (ex. `volto-datablocks` `c30ac71`).
6. **Betterleaks false positive** — `betterleaks:allow` trebuie pe linia
   finding-ului; altfel allowlist în `.gitleaks.toml`
   (`volto-widget-geolocation` `64ceb5f`).
7. **Selector drift Volto 19** — actualizează selectorul/testul
   (ex. `volto-hero-block` `.inline.field.align-widget …`).
8. **`razzle-dev-utils/makeLoaderFinder` lipsă** — `volto-globalsearch`,
   `volto-eea-website-policy`; de investigat dependința.

## Capcane de mediu (detalii în `docs/.../HANDOFF.md`)

- `make test-ci` folosește doar `--reporter=junit` → fără output de erori; local
  adaugă `--reporter=default --coverage=false`.
- Jenkins API se poate apela doar cu cookie-ul de sesiune din Chrome
  (`chrome_cdp` → `Network.getCookies` pe `https://ci.eionet.europa.eu/`) plus
  `Jenkins-Crumb`; rebuild branch: `POST
  /job/volto-addons/job/<repo>/job/volto19/build` → 201.
- Docker pe arm64: imaginile construite local au symlink-uri pnpm rupte (repară
  link-ul la `../../../../node_modules/.pnpm/...`); NU extrage tar de pe macOS
  (AppleDouble `._*`) — folosește `git archive | docker exec -i tar`.
- macOS bash 3.2: fără `declare -A`, fără `timeout`; `awk` BSD nu interpretează
  `\x1f`.

## Referințe

- `docs/2026-10-16-volto19-coverage-and-migration/` (README, HANDOFF, TODO,
  REPORT, diagnostics/) în repo `avoinea/eea-website`, branch `main`.
- `scripts/jenkins-spotcheck.sh`, `scripts/jenkins-stage-scan.sh`,
  `scripts/classify-regressions.sh` (scripturi operaționale ale campaniei).
