# Campania „red → green" Volto 19 (2026-10-17, sesiunile 2–3)

**Status: 57 verzi / 10 roșii** (35/32 la începutul sesiunii 2, 50/15 la finalul ei). Toate cele 4 PR-uri cu
SonarQube roșu sînt verzi, `volto-searchlib` e verde, iar cele 2 PR-uri rămase în urmă față de `develop`
au fost sincronizate.

## Fapte cheie

- **Sync `volto19` ← `develop`** la singurele 2 PR-uri cu `behind > 0` (din 59): `block-data-table` #20
  (**verde complet**) și `block-toc` #53 (V19 verde, V18 roșu — amânat la cererea userului;
  diagnostic în `diagnostics/block-toc-v18-slate-focus.md`).
- **Batch F**: `object-widget` verde (`RAZZLE_CI` + `vi.mock` care întorcea `undefined`), `group-block` V19
  verde (unit + integrare), `theme #395` lint verde.
- **Batch G — coverage (SonarQube)**: `chatbot` #45 79.30 → **81.60**, `policy` #138 26.90 → **74.00**,
  `embed` #88 46.60 → **67.00**, `redmine` #30 41.30 → **51.20**; toate cu `Jenkins Success` și PR `CLEAN`.
  Mecanismul complet în `diagnostics/sonar-coverage.md`.
- **`volto-searchlib` verde** (era roșu de la începutul campaniei): unit 303 + integrare 2+2;
  trei cauze în `diagnostics/searchlib-unit-and-build.md`.
- PR-uri verzi & `MERGEABLE`: chatbot #45, policy #138, embed #88, redmine #30, block-data-table #20;
  branch-uri verzi: object-widget, searchlib, group-block (V19 — V18 încă roșu).
- Docs canonice: `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md`; DS `6c28303ea`; datahub `fd7fd5c`.

## Fișiere

- [DECISIONS.md](DECISIONS.md) — decizii, alternative respinse, override-uri.
- [PLAN.md](PLAN.md) — faze, status și operaționalul de continuare.
- [REPORT.md](REPORT.md) — rezultate, commit-uri, dovezi.
- [TODO.md](TODO.md) — ce a rămas deschis + închis.
- [HANDOFF.md](HANDOFF.md) — pentru sesiunea următoare.
- `diagnostics/sonar-coverage.md` — cum se calculează poarta Sonar și cum se repară (API public, două lcov-uri,
  rețeta de harness local).
- `diagnostics/block-toc-v18-slate-focus.md` — regresia V18 de după sync (bug de focus în Volto 18.35.1).
- `diagnostics/searchlib-unit-and-build.md` — cele 3 cauze de la searchlib.
