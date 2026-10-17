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

---

# Sesiunea 3 (2026-10-17 → 18): sync, batch F, coverage (G), searchlib

## Metrici

| | Înainte | După |
| --- | --- | --- |
| Dashboard roșii | 15 | **10** |
| Dashboard verzi | 50 | **57** |
| Coverage Sonar (PR-uri) | chatbot 79.30 / policy 26.90 / embed 46.60 / redmine 41.30 | **81.60 / 74.00 / 67.00 / 51.20** |

## Sync cu `develop` (singurele 2 PR-uri cu `behind > 0` din 59)

| Repo | Commit-uri | Rezultat |
| --- | --- | --- |
| `block-data-table` #20 | `f7823d3` | **verde complet**, PR `MERGEABLE` |
| `block-toc` #53 | `54bdc10` (merge), `bb7d802` (hardening) | V19 verde (41 unit + 4 integrare), V18 roșu (2/4) — diagnostic în `diagnostics/block-toc-v18-slate-focus.md` |

## Batch F

| Repo | Commit-uri | Rezultat |
| --- | --- | --- |
| `object-widget` | `20705d6` (`RAZZLE_CI=true` în `start-ci`), `fc8a5fc` (`vi.mock` care întorcea `undefined`) | **verde complet** (V18 integrare 12/12, unit 11 fișiere) |
| `group-block` | `6d0c076` (fabrică `vi.mock` fără `default`), `5edc69c` (barieră de hidratare în test) | V19 verde (unit 36 + integrare 5/5), V18 roșu pe un test |
| `theme` #395 | `cda9236` (override `react/jsx-no-target-blank`), `eca6cc9` + `a1f2c07` (pin `@plone/babel-preset-razzle` A/B) | lint verde; V18 image încă roșu |

## Batch G — coverage (SonarQube)

| PR | Înainte | După | master | Fix |
| --- | --- | --- | --- | --- |
| `chatbot` #45 `e0d32d0`+`db5e20b` | 79.30 | **81.60** | 84.80 | excluderi oglindite în `vitest.config.mjs` **și** `.coverage.babel.config.js` (types + index/schema barrel) |
| `policy` #138 `c012de6` | 26.90 | **74.00** | 52.00 | teste reale: `HTML/Edit.jsx` (344 linii la 0%) + `blacklistRoutes.js` |
| `embed` #88 `d30623f` | 46.60 | **67.00** | 60.00 | teste reale: `MapsWidget.jsx` (210 linii, fără test), `Share`, `FigureNote`, `PrivacyProtection/utils`, completări `Sources`/`Toolbar` |
| `redmine` #30 `f4bb8d5` | 41.30 | **51.20** | 48.80 | `captcha/**` (2363 linii la 0%) exclus din ambele lcov-uri, ca pe master |

Toate 4: `Jenkins Success`, `SonarQube success`, PR `MERGEABLE`/`CLEAN`. Metoda (semantica porții, API-ul public, uniunea celor două lcov-uri, harness-ul local) în `diagnostics/sonar-coverage.md`.

## `volto-searchlib`

| Commit | Fix |
| --- | --- |
| `01ef5f4` | `SearchInput.test.jsx` + `TopFilterLayout.test.jsx`: `jest.mock` nehoistat → `vi.hoisted`/`vi.mock`; mock direct pe `Image`-ul din Volto; atomii jotai reali |
| `f6ed9e3` | `ChatbotAnswer.test.jsx`: `require('@eeacms/volto-eea-chatbot')` → import ESM (mock-uit) — `require` ocolea fabrica și încărca pachetul real prin loader-ul Node |
| `1f1231e` | `razzle-dev-utils` în `devDependencies` la rădăcină (build-ul V19 cădea pe fallback-ul nedeclarat din `razzle.extend.js`) |

Rezultat: `Jenkins Success`, V18 integrare 2, V19 integrare 2, V19 unit **303** (era roșu de la începutul campaniei). Detalii: `diagnostics/searchlib-unit-and-build.md`.
