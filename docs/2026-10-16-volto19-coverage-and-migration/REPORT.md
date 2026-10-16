# Rezultate și dovezi

## Fix-ul principal (volto-accordion-block, PR-133)

| Verificare | Rezultat | Dovadă |
|---|---|---|
| Jenkins build #5 — Volto 19 Integration | ✅ SUCCESS | GitHub checks + `All specs passed! 16/16` |
| Jenkins build #5 — Volto 18 Integration | ✅ SUCCESS | `All specs passed! 02:06 · 16/16` |
| Jenkins build #5 — Unit tests | ✅ SUCCESS | JUnit 12 teste |
| Jenkins build #5 — SonarQube compare | ✅ `OK (82.20 >= 82.20)` | log stage (`.../node/206/log`) |
| Local Volto 18, `retries=0` (strict) ×2 | ✅ 16/16 | `/tmp/vacb-cypress18-run*.log`, `/tmp/full-retries0-fixed*.log` |
| Local Volto 19, `retries=0` | ✅ 16/16 | `/tmp/v19-strict-run.log` |
| Local mergunit unit+cypress coverage | **87.00%** (261/300) | calcul lcov în sesiune |

Repro live a bug-ului (înainte de fix): navigare `/live-check/live-page` + `appHistory.push('/edit')` imediat ce `appHistory` apare → URL final `.../live-page` (view), 0 editoare de titlu. Forțare URL `/edit` înainte de boot → React error #418 (hydration mismatch).

## Analiza Jenkins a valului masiv (2026-10-16)

- 45 repo-uri cu eșecuri la checks (lista completă: `checks-summary.txt`).
- **Niciun eșec nou cauzat de fix-ul de coverage** — verificat pe commit-ul anterior pentru cazurile analizate:
  - `volto-columns-block` / `volto-datablocks` / `volto-eea-design-system` / `volto-eea-map`: unit tests „No test results found" **și pe commit-ul anterior**.
  - `volto-tabs-block`: eșecul Volto 18 = `.block.inner.title` (cursa de hidratare), deci fix-ul neplicat încă.
  - `volto-globalsearch` / `volto-searchlib`: ES lint pică și înainte.
  - `volto-widget-geolocation`: „Scan for secrets" pică și înainte (false positive).
  - `countup`, `volto-banner`, etc.: „error in 'sh'" pe Volto 18 integration și înainte.

## Cauze preexistente găsite și reparate (verificate în containere CI)

| Repo | Cauză | Verificare |
|---|---|---|
| volto-columns-block | `vi.mock('./utils')` fără `cloneData` | vitest EXIT=0, coverage 38.3% |
| volto-datablocks | 2× `vi.mock` fără `default`, `store.content` în loc de `store.getState()` | vitest EXIT=0, coverage 29.6% |
| volto-eea-design-system | `localStorage` stub-uit de Volto 19.5; `src` SVG e data-URI, nu nume de fișier | vitest EXIT=0, coverage 80.1% |
| volto-eea-map | 0 teste → praguri 5% pică | vitest EXIT=0 |
| volto-searchlib | `@eeacms/search` nerezolvabil (lipsea aliasul local) | `make lint` LINT=0 |
| volto-globalsearch | `@eeacms/search` nedeclarat + subpath `lib/*` | `make lint` LINT=0 |
| volto-widget-geolocation | comments `betterleaks:allow` pe linia greșită | fix aplicat, de re-verificat pe CI |

## Replicare

- Coverage: 66 repo-uri push-uite pe `volto19` (commit `fix: sonarqube coverage on Volto 19`); `volto-datablocks` a necesitat rebase.
- Hidratare + `mrs` 19.5.0: **61 pushed + 1 skip în batch (`volto-anchors`)**, 0 failed; cele 3 variante de pattern ratate (`volto-anchors`, `volto-block-image-cards`, `volto-block-toc`) patch-uite în pass 2.
- Verificare finală pe 62 repo-uri EEA: `mrs=19.5.0`, fără pattern vechi de hidratare, worktree curat, 0 commit-uri nepushate → **0 anomalii**.

## Artefacte brute

- `/tmp/mass-update.log`, `/tmp/replicate-run.log`, `/tmp/full-retries0-fixed.log`, `/tmp/unit-final-lcov.info`, `/tmp/cypress-cov4-lcov.info`, `/tmp/checks-summary.txt` (copiat în folder).
- Scripturile în `scripts/`.
- Verificarea finală (0 anomalii) a rulat pe 62 repo-uri EEA: tag 19.5.0, hidratare aplicată, worktree curat, fără commit-uri nepushate.

## Sesiunea 2 — spot-check Jenkins + regresii (2026-10-16, ~17:00-17:30)

- Spot-check complet pe 63 repo-uri EEA (HEAD-ul `chore: update Volto to 19.5.0` de pe fiecare `volto19`): 23 OK, 38 FAIL, 2 în curs la ora verificării (17:15) — vezi `spotcheck-2026-10-16.txt`.
- Clasificare per-check față de ultimul commit anterior care are check-runs (nu față de `checks-summary.txt`, care era incomplet) — vezi `regressions-per-check.txt` și `regressions-per-title.txt`:
  - **Doar 2 regresii reale** cauzate de valul masiv:
    - `volto-columns-block` — `Tests / Testing / Volto 19 / Integration tests` (test latent, stage-ul Volto 19 nu rulase niciodată înainte pentru că unit-ul pica primul). Fix `e544509`: click explicit pe `.block.columnsBlock` înainte de deschiderea settings-urilor (`.columns-header` doar schimbă tab-ul sidebar-ului, nu selectează blocul). Detalii: `diagnostics/columns-block.md`.
    - `volto-slate-label` — `Tests / Testing / Volto 18 / Integration tests` + `Jenkins`. Fix `7cdbac4`: re-selecție cu pointer real (`setSlateCursor(...).dblclick()`) înainte de „Remove label"; cauza de fond: Volto 18.35.1 / slate-react 0.98.4 nu mapează un `setBaseAndExtent` după re-render, iar încărcarea directă a rutei `/edit` expune asta. Detalii: `diagnostics/slate-label.md`.
- Reparate + verificate verde pe Jenkins:
  - `volto-datablocks` `c30ac71` — `DELETE /@lock` înainte de PATCH (editorul chiar se montează acum și blochează pagina). Jenkins: 5/5 ambele stage-uri, 71 unit, success.
  - `volto-widget-geolocation` `64ceb5f` — allowlist `betterleaks` pe `SearchWidget.jsx` (finding-ul e pe linia atribuirii, comentariul inline nu era suficient). Jenkins: 26/26 ambele stage-uri, 46 unit, success.
  - `volto-group-block` `01688ee` — `});` orfan în `Edit.test.jsx` (syntax error preexistent din migrare) care rupea ES lint pe Volto 19.
- Eșecuri preexistente nou-expuse (nu regresii): `volto-searchlib` unit (vezi `diagnostics/searchlib.md`; fix localStorage `bdd6708`), `volto-slate-zotero` (al doilea test Zotero, „collections"), `volto-globalsearch` (build abortat → rebuild triggerat pe `9ac1e33`).
- La finalul sesiunii erau în curs de re-verificare pe Jenkins: `volto-columns-block`, `volto-slate-label`, `volto-group-block`, `volto-globalsearch`, `volto-searchlib`.

### Rezultate finale build-uri re-pushuite (2026-10-16 ~17:40)

| Repo | Rezultat Jenkins |
|---|---|
| `volto-columns-block` `e544509` | ✅ **VERDE** — V18 integrare 6/6, V19 integrare 6/6, unit 18, Jenkins Success |
| `volto-datablocks` `c30ac71` | ✅ **VERDE** — V18 5/5, V19 5/5, unit 71, Jenkins Success |
| `volto-widget-geolocation` `64ceb5f` | ✅ **VERDE** — V18 26/26, V19 26/26, unit 46, Jenkins Success |
| `volto-slate-label` `7cdbac4` | V18 integrare ✅ 2/2 (fix-ul funcționează); Jenkins a picat pe infrastructură („Agent was removed" la unit tests) → rebuild triggerat |
| `volto-searchlib` `bdd6708` | Jenkins a picat pe infrastructură („Agent was removed" la docker build) → rebuild triggerat; unit preexistent |
| `volto-group-block` `01688ee` (+ auto `64f5128`) | Lint reparat; acum pică unit stage pe datorii preexistente (reporter junit nu afișează detaliile) |
| `volto-globalsearch` `9ac1e33` | V19 unit ✅ 108; build-ul razzle eșuează preexistent: `Cannot find module 'razzle-dev-utils/makeLoaderFinder'` (cerut de `@eeacms/volto-eea-chatbot@4.1.0/razzle.extend.js`) — expus după ce lint-ul a trecut |
