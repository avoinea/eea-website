# TODO (deschis)

- [ ] **PR-uri verzi**:
  - [ ] `volto-editing-progress` #37 — V18 integrare pică pe `01-block-basics.cy.js:147` („2 fields missing"); pe branch a trecut → flake la build-ul de PR, de re-rulat.
  - [ ] SonarQube pe PR: `volto-eea-chatbot` #45, `volto-embed` #88, `volto-redmine-helpdesk` #30 (new-code coverage/bugs; aceeași clasă ca `policy` #138).
  - [ ] Nota + checklist-ul de unpin chatbot/searchlib în body-ul `volto-eea-website-policy` #138 (owner: user).
  - [ ] `eea-website-frontend` #284 — job Jenkins pe Node 18 vs `engines ^24` (config, owner: user).
- [ ] **Ultimele branch-roșii**: `volto-group-block` (V19 unit + V18 build test image), `volto-object-widget` (V19 unit + V18 integrare), `volto-searchlib` (V19 unit preexistent), `volto-slate-zotero` (V19 integrare), `volto-eea-website-theme` #395 (lint `react/jsx-no-target-blank` → restaurează override-ul `allowReferrer: true`; V18 `@plone/babel-preset-razzle: workspace:*` → pin `1.0.1` sau scos + regen lock; V19 build cere și DS release).
- [ ] **Design-system: release + unpin** — scoate pinul DS din `volto-datahub` (`fd7fd5c`) după release (fix focus variables e pe branch-ul `volto19`, `973ebb1f6`).
- [ ] **Unpin chatbot + searchlib** — după release-urile majore, scoate override-urile din globalsearch/policy/datahub.
- [ ] **Repo `collective/*`** (authomatic, rss-provider, subsites): decizie user — PR / push / skip.
- [ ] (opțional) Lock refresh la repo-urile cu dependințe noi (`react-portal`, `lodash.debounce`, pinurile git) înainte de merge-ul PR-urilor.

# Închis în sesiune

- [x] 21 add-on-uri reparate (batch A–E), verzi pe branch (`Jenkins` success + stage-scan none).
- [x] 21 PR-uri `volto19 → develop` deschise pentru toate repo-urile verzi fără PR.
- [x] Design-system `6c28303ea` (`prepare` → `husky:install`).
- [x] Docs canonice actualizate (`35ad3f9`).
