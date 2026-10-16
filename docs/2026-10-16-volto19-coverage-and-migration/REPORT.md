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
