# Campania „red → green" Volto 19 (2026-10-17 → 19, sesiunile 2–5)

**Status: 61 verzi / 2 roșii** (35/32 la începutul sesiunii 2, 50/15 la finalul ei, 57/10 la finalul sesiunii 3, 59/4 după batch-ul H, 60/3 după sesiunea 5).
`group-block`, `editing-progress`, `slate-zotero` și **`block-toc` #53** (sesiunea 6) sînt complete verzi; `theme` e verde pe V19
(unit 637 + integrare 23), dar integrarea V18 încă expiră la timeout. Rămîn `theme` V18 și `countup` (skip).

Sesiunea 5 a reprodus hang-ul V18 al temei local și l-a izolat la `cy.getSlate().click()` pe pagină goală — nu e infra,
e o buclă de JS în browser. Detalii: `diagnostics/theme-v18-integration-hang.md`.

Sesiunea 6 a adus `block-toc` #53 la verde complet pe ambele matrițe. Cauza reală a eșecului V18 nu era testul, ci
**imaginea**: `eeacms/frontend-builder:18` livra Volto 18.35.1, iar fix-ul de focus Slate (`plone/volto#8406`) e în 18.36.0.
Imaginea a fost urcată în `eea/frontend-builder` 18.x (`7cb8c2e`), plus merge `develop` și un retype mărginit pentru cursa
rămasă de re-render. Detalii: `diagnostics/block-toc-v18-slate-focus.md`, `diagnostics/frontend-builder-18-image.md`.

## Fapte cheie

- **Sync `volto19` ← `develop`** la singurele 2 PR-uri cu `behind > 0` (din 59): `block-data-table` #20
  (**verde complet**) și `block-toc` #53 (două merge-uri: `54bdc10`, `a99d9a2`; **verde complet** din sesiunea 6,
  după ce imaginea V18 a fost urcată la 18.36.0 — `diagnostics/block-toc-v18-slate-focus.md`).
- **Batch F**: `object-widget` verde (`RAZZLE_CI` + `vi.mock` care întorcea `undefined`), `group-block` V19
  verde (unit + integrare), `theme #395` lint verde.
- **Batch G — coverage (SonarQube)**: `chatbot` #45 79.30 → **81.60**, `policy` #138 26.90 → **74.00**,
  `embed` #88 46.60 → **67.00**, `redmine` #30 41.30 → **51.20**; toate cu `Jenkins Success` și PR `CLEAN`.
  Mecanismul complet în `diagnostics/sonar-coverage.md`.
- **`volto-searchlib` verde** (era roșu de la începutul campaniei): unit 303 + integrare 2+2;
  trei cauze în `diagnostics/searchlib-unit-and-build.md`.
- **Batch H (sesiunea 4)**: `group-block` **verde complet** (V18+V19 integrare 5, unit 36),
  `editing-progress` **verde complet** (V18+V19 integrare 5, unit 74), `theme` #395 V19 **verde** (unit 637,
  integrare 23) — rămîne doar integrarea V18 (timeout, diagnostic în
  `diagnostics/theme-v18-integration-hang.md`).
- **CI mai vizibil**: `theme` `Makefile test-ci` folosește acum și `--reporter=default`, deci eșecurile de unit
  apar în consola Jenkins (înainte check-ul zicea „No test results found").
- **`volto-slate-zotero` verde** (`39223bd`, `0d9f518`): V18 9/9, V19 9/9, unit 35. O cursă de test (save
  înainte de commit-ul citației) + un bug real de produs (`/collections/top` întîrziat repopula lista de items
  cu colecții-fantomă). Diagnostic + rețeta de repro local în `diagnostics/slate-zotero-v19.md`.
- PR-uri verzi & `MERGEABLE`: chatbot #45, policy #138, embed #88, redmine #30, block-data-table #20;
  branch-uri verzi: object-widget, searchlib, group-block, editing-progress.
- Docs canonice: `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md`; DS `6c28303ea`; datahub `fd7fd5c`.

## Fișiere

- [DECISIONS.md](DECISIONS.md) — decizii, alternative respinse, override-uri.
- [PLAN.md](PLAN.md) — faze, status și operaționalul de continuare.
- [REPORT.md](REPORT.md) — rezultate, commit-uri, dovezi.
- [TODO.md](TODO.md) — ce a rămas deschis + închis.
- [HANDOFF.md](HANDOFF.md) — pentru sesiunea următoare.
- `diagnostics/sonar-coverage.md` — cum se calculează poarta Sonar și cum se repară (API public, două lcov-uri,
  rețeta de harness local).
- `diagnostics/block-toc-v18-slate-focus.md` — regresia V18 de după sync: **rezolvată** (imaginea V18 la 18.36.0, merge `develop`, retype mărginit) + cele două straturi de cauză.
- `diagnostics/frontend-builder-18-image.md` — de ce `eeacms/frontend-builder:18` livra 18.35.1, cum s-a urcat la 18.36.0 (`7cb8c2e`) și cum se verifică imaginea publicată.
- `diagnostics/searchlib-unit-and-build.md` — cele 3 cauze de la searchlib.
- `diagnostics/theme-v18-integration-hang.md` — de ce integrarea V18 a temei expiră: repro local (comenzi),
  tabelul de bisect, declanșatorul (`cy.getSlate().click()`) și următorii pași.
- `diagnostics/slate-zotero-v19.md` — cele 2 curse (test + produs) și rețeta de repro local (Node 24, IPv4).
