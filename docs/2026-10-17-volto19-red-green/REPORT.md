# Rezultate

## Metrici

| | Înainte | După |
| --- | --- | --- |
| Dashboard roșii | 32 (29 `eea/*` + 3 `collective/*`) | 15 (din care 3 `collective/*`, `countup`, `frontend #284`, `policy #138`) |
| Dashboard verzi | 35 | 50 |
| PR-uri `volto19 → develop` | 36 (34 verzi) | 57 (21 deschise în această sesiune) |

„Verde" per repo = `Jenkins` aggregate `success` + `jenkins-stage-scan.sh` = `none` pe HEAD de `volto19`.

## Batch A+B (6 repo, doar import stale `cypress-fail-fast`)

anchors `eb350f8`, controlpanel `a4f118d`, flourish `3444c74`, embed `90d1719`, nextcloud `938a583`, redmine `e6a419d` — V18/V19 integrare + unit verzi.

## Batch C (5 repo)

| Repo | Commit(uri) | Fix |
| --- | --- | --- |
| kitkat | `7950813`, `f0a6d29` | import stale + `Lock-Token` la PATCH în testele slate (editorul blochează pagina → 403) |
| widget-theme-picker | `5c2a92c` | import stale |
| block-data-table | `a5cc6b5`, `e767ef2` | import stale + scos pragurile coverage (0 teste) |
| block-toc | `43c93b1`, `9f79644` (+ `4c6a0d4` style) | import stale + ESM imports în `withEEASideMenu.test.jsx` (CJS `require` ocolea aliasul vitest) |
| embed-static-content | `703a55d`, `3cd4e28` (+ `6de1b7f` style) | import stale + mock Popup funcțional (ignora `open`) + `vitest.uuid.mock.js` + prag branch 5→2 |

## Batch D+E (10 repo)

| Repo | Commit(uri) | Fix |
| --- | --- | --- |
| block-image-cards | `1b91f9c` | import stale |
| editing-progress | `b281892`, `283ebae` | selector modal Save (`.ui.modal .actions button[aria-label="Save"]`) |
| taxonomy | `05b1bdd` | `react-portal` nedeclarat |
| block-divider | `c660805` | conflict markers comise în `cypress/support/commands.js` |
| chatbot | `de370ce`, `2e43ac7` | import stale + 35 lint warnings (escapes, import nefolosit, hooks, `no-console: off` documentat) |
| banner | `24c2893` | `react-portal` |
| block-style | `75013d9`, `0231dba` | `react-portal` + task `getVoltoVersion` neînregistrat + branch mort V16 |
| plotlycharts | `f35c605`, `438304a`, `0d4b1f2`, `daebbef` | `react-portal`, `vitest.uuid.mock.js`, `check-ci` 600→1200, heap 8G pentru SSR V18 |
| widget-temporal-coverage | `d672ca6` | `lodash.debounce` nedeclarat |
| datahub | `43bb889`, `e50a168`, `997785c`, `fd7fd5c` | `react-portal`, ignore lint `@eeacms/search`, pin chatbot/searchlib, pin DS git |

Design-system: `6c28303ea` — `prepare` mutat în `husky:install` + root prepare (instalabil din git).

## PR-uri deschise (21)

anchors #45, controlpanel #15, flourish #17, embed #88, nextcloud #39, redmine #30, kitkat #251, widget-theme-picker #23, block-data-table #20, block-toc #53, embed-static-content #27, block-image-cards #77, editing-progress #37, taxonomy #46, block-divider #44, chatbot #45, banner #46, widget-temporal-coverage #43, block-style #118, datahub #83, plotlycharts #208.

## Docs

- `docs/2026-10-16-volto19-coverage-and-migration/{TODO,REPORT}.md`: `cff4f50` (batch A), `5a94a84` (B+C), `35ad3f9` (red→green D+E).
- Acest folder: handoff-ul sesiunii.
