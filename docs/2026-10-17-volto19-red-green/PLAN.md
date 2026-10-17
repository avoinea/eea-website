# Plan

## Faze

- [x] **Faza 1 — mini-val fail-fast (13 repo)**: A — anchors `eb350f8`, controlpanel `a4f118d`, flourish `3444c74`; B — embed `90d1719`, nextcloud `938a583`, redmine `e6a419d`; C — kitkat `f0a6d29`, widget-theme-picker `5c2a92c`, data-table `e767ef2`, toc `4c6a0d4`, embed-static-content `6de1b7f`; D — block-image-cards `1b91f9c`, chatbot `de370ce`.
- [x] **Faza 2 — alte cauze (batch D+E)**: editing-progress `283ebae`, taxonomy `05b1bdd`, block-divider `c660805`, banner `24c2893`, block-style `0231dba`, plotlycharts `daebbef`, widget-temporal-coverage `d672ca6`, datahub `fd7fd5c`.
- [x] **Faza 3 — PR-uri + docs**: 21 PR-uri; docs canonice `35ad3f9`; DS `6c28303ea`; handoff-ul de față.
- [ ] **Faza 4 — PR-uri verzi**: re-run/flake `editing-progress #37` (V18 integrare, test `01-block-basics.cy.js:147`); SonarQube pe PR: `chatbot #45`, `embed #88`, `redmine #30`; nota de unpin în body-ul `policy #138`.
- [ ] **Faza 5 — ultimele branch-roșii**: `group-block` (V19 unit + V18 build test image), `object-widget` (V19 unit + V18 integrare), `searchlib` (V19 unit: ChatbotAnswer 11 + TopFilterLayout 1), `slate-zotero` (V19 integrare), `theme #395` (lint + `@plone/babel-preset-razzle` V18 + DS release).
- [ ] **Faza 6 — unpin-uri**: DS release → scos pinul din datahub; chatbot/searchlib release → scos pinurile din globalsearch/policy/datahub.
- [x] **Faza 7 — sync cu `develop`** (sesiunea 3): `block-data-table` #20 (`f7823d3`, verde complet) și `block-toc` #53 (`54bdc10` merge + `bb7d802` hardening test; V19 verde, V18 deschis).
- [x] **Faza 8 — batch F**: `object-widget` (`20705d6` RAZZLE_CI + `fc8a5fc` vi.mock → verde complet), `group-block` (`6d0c076` vi.mock + `5edc69c` barieră de hidratare → V19 verde), `theme #395` (`cda9236` lint + `eca6cc9`/`a1f2c07` pin A/B → lint verde, V18 image deschis).
- [x] **Faza 9 — coverage (batch G)**: `redmine` #30 (`f4bb8d5`), `chatbot` #45 (`e0d32d0` + `db5e20b`), `policy` #138 (`c012de6`, teste), `embed` #88 (`d30623f`, teste) — toate verzi.
- [x] **Faza 10 — `volto-searchlib`**: `01ef5f4` (SearchInput + TopFilterLayout), `f6ed9e3` (`require` → import ESM în ChatbotAnswer), `1f1231e` (`razzle-dev-utils` în root devDeps) → verde complet.
- [ ] **Faza 11 — ultimele 5**: `group-block` V18 (test-only), `theme #395` V18 image (rută alternativă la pin), `editing-progress` #37, `slate-zotero` V19, plus verificarea `block-toc` dacă se acceptă V18-roșu.

## Operațional

- Stare: `scripts/jenkins-spotcheck.sh`, dashboard `http://127.0.0.1:3210/api/status` (server local în `dashboard/`, untracked).
- Stagii reale: `scripts/jenkins-stage-scan.sh <repo...>`.
- PR-uri: `scripts/open-volto19-prs.sh [--dry-run] <repo...>` (title „chore: Volto 19 support").
- Poll: buclă `gh api repos/eea/<repo>/commits/<sha>/check-runs` până toate `completed` și fără concluzii non-success.
- Scripturile sunt în `.agents/skills/volto19-green-campaign/scripts/`.
- Fără lock refresh la dependințele noi: CI instalează non-frozen și rezolvă în imagine (de revizuit la PR).
- **Oracol Sonar** (fără login): `curl -s "https://sonarqube.eea.europa.eu/api/measures/component?component=<proiect>&pullRequest=<nr>&metricKeys=coverage,line_coverage,branch_coverage,lines_to_cover,uncovered_lines"` și `.../measures/component_tree?...&qualifiers=FIL&ps=500`. Vezi `diagnostics/sonar-coverage.md`.
- **Harness local pentru unit/coverage**: `core/` copiat în repo (gitignored) + `node_modules` al core-ului linkat + providerul `@vitest/coverage-istanbul` luat din npm în `/tmp` și linkat în `frontend/node_modules/@vitest/`; addon-urile surori se **copiază** (`rsync`), nu se linkează (Vite le respinge). Rețeta completă: `diagnostics/sonar-coverage.md`.
- **Push**: Jenkins poate pusha „style: Automated code fix" pe `volto19` → `git fetch && git rebase origin/volto19` înainte de push (întâlnit la group-block). Hook-ul local `lint-staged` nu e instalat → `--no-verify` după ce rulăm manual eslint+prettier.
