# Plan

## Faze

- [x] **Faza 1 — mini-val fail-fast (13 repo)**: A — anchors `eb350f8`, controlpanel `a4f118d`, flourish `3444c74`; B — embed `90d1719`, nextcloud `938a583`, redmine `e6a419d`; C — kitkat `f0a6d29`, widget-theme-picker `5c2a92c`, data-table `e767ef2`, toc `4c6a0d4`, embed-static-content `6de1b7f`; D — block-image-cards `1b91f9c`, chatbot `de370ce`.
- [x] **Faza 2 — alte cauze (batch D+E)**: editing-progress `283ebae`, taxonomy `05b1bdd`, block-divider `c660805`, banner `24c2893`, block-style `0231dba`, plotlycharts `daebbef`, widget-temporal-coverage `d672ca6`, datahub `fd7fd5c`.
- [x] **Faza 3 — PR-uri + docs**: 21 PR-uri; docs canonice `35ad3f9`; DS `6c28303ea`; handoff-ul de față.
- [ ] **Faza 4 — PR-uri verzi**: re-run/flake `editing-progress #37` (V18 integrare, test `01-block-basics.cy.js:147`); SonarQube pe PR: `chatbot #45`, `embed #88`, `redmine #30`; nota de unpin în body-ul `policy #138`.
- [ ] **Faza 5 — ultimele branch-roșii**: `group-block` (V19 unit + V18 build test image), `object-widget` (V19 unit + V18 integrare), `searchlib` (V19 unit: ChatbotAnswer 11 + TopFilterLayout 1), `slate-zotero` (V19 integrare), `theme #395` (lint + `@plone/babel-preset-razzle` V18 + DS release).
- [ ] **Faza 6 — unpin-uri**: DS release → scos pinul din datahub; chatbot/searchlib release → scos pinurile din globalsearch/policy/datahub.

## Operațional

- Stare: `scripts/jenkins-spotcheck.sh`, dashboard `http://127.0.0.1:3210/api/status` (server local în `dashboard/`, untracked).
- Stagii reale: `scripts/jenkins-stage-scan.sh <repo...>`.
- PR-uri: `scripts/open-volto19-prs.sh [--dry-run] <repo...>` (title „chore: Volto 19 support").
- Poll: buclă `gh api repos/eea/<repo>/commits/<sha>/check-runs` până toate `completed` și fără concluzii non-success.
- Scripturile sunt în `.agents/skills/volto19-green-campaign/scripts/`.
- Fără lock refresh la dependințele noi: CI instalează non-frozen și rezolvă în imagine (de revizuit la PR).
