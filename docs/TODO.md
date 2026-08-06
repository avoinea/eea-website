# PLAN — Volto 19 Upgrade Progress Tracker

This file tracks execution progress across all 7 phases. Update checkboxes as work completes.

## Phase 0: Update gitflow Docker image for pnpm

- [ ] Add `pnpm` to `eea.docker.gitflow/Dockerfile` alongside `yarn`
- [ ] Update `eea.docker.gitflow/src/js-release.sh` — detect pnpm vs yarn via `packageManager` field
- [ ] Update `eea.docker.gitflow/src/frontend-release.sh` — detect pnpm if needed
- [ ] Build and push new `eeacms/gitflow` image
- [ ] Verify: a Volto 18 addon can still be released via the updated image

**Status**: Not started
**Can run in parallel with**: Phases 1, 2, 5
**Blocks**: Phase 4

---

## Phase 1: Fix addon breaking changes (backward-compatible with V18)

- [ ] Fix `<img>` → `<Image>` component in 5 addons:
  - [ ] volto-eea-chatbot (tests)
  - [ ] volto-eea-design-system (stories)
  - [ ] volto-eea-website-theme (Image.jsx, LeadImage/Edit.jsx, Image/Edit.jsx)
  - [ ] volto-nextcloud-video-block (tests)
  - [ ] volto-object-widget (tests)
- [ ] Fix `razzle-dev-utils` → conditional require in 2 addons:
  - [ ] volto-searchlib/razzle.extend.js
  - [ ] volto-eea-chatbot/razzle.extend.js
- [ ] Fix `babel.config.js` → `require('@plone/volto/babel')` in all addons
- [ ] Fix superagent error handling in 5 addons:
  - [ ] volto-datablocks
  - [ ] volto-datahub
  - [ ] volto-eea-chatbot
  - [ ] volto-eea-website-theme
  - [ ] volto-plotlycharts
- [ ] Fix react-dnd/react-sortable-hoc in volto-eea-website-theme (add as dependency)
- [ ] Fix language settings in 3 addons (read from backend API):
  - [ ] volto-eea-website-policy/src/index.js
  - [ ] volto-eea-design-system/src/ui/Header/Header.jsx
  - [ ] volto-eea-website-theme (AlternateHrefLangs.jsx, Header.jsx)
- [ ] Clean up commented-out razzle-dev-utils in volto-globalsearch
- [ ] Verify: all addons pass on Volto 18 CI (Cypress)

**Status**: Not started
**Can run in parallel with**: Phases 0, 2, 5
**Blocks**: Phase 4 (addons must be V19-compatible before pnpm migration)

---

## Phase 2: Create/update Cookieplone templates

- [ ] Update `cookieplone-templates/templates/frontend_addon/`:
  - [ ] Add Volto 19 Jenkins testing stage (Vitest + Cypress)
  - [ ] Update `babel.config.js` to use `require('@plone/volto/babel')`
  - [ ] Add `vitest.config.mjs` template
  - [ ] Update `cookiecutter.json` if needed
- [ ] Create `cookieplone-templates/templates/frontend_project/`:
  - [ ] `cookiecutter.json` with EEA defaults
  - [ ] `Jenkinsfile` (EEA CI: Bundlewatch, Docker build, gitflow, SonarQube)
  - [ ] `Dockerfile` (multi-stage with `plone/frontend-builder`)
  - [ ] `Makefile` (EEA targets: develop, relstorage, staging, demo, cypress)
  - [ ] `entrypoint.sh` (Sentry upload, no REBUILD)
  - [ ] `.bundlewatch.config.json` pattern
- [ ] Update `cookieplone-templates/cookieplone-config.json` with `frontend_project` entry
- [ ] Test: `cookieplone frontend_project --no-input` generates valid structure
- [ ] Test: `cookieplone frontend_addon --no-input` generates valid addon

**Status**: Not started
**Can run in parallel with**: Phases 0, 1, 5
**Blocks**: Phase 3

---

## Phase 3: Generate new Volto 19 frontend project

- [ ] Run `cookieplone frontend_project` with EEA defaults (Volto 19.3.0)
- [ ] Copy over project-specific config:
  - [ ] `mrs.developer.json` (change output to `packages/`)
  - [ ] `volto.config.js` with 26 project-level addons
  - [ ] Custom `razzle.config.js` (compression plugins + handsontable fix)
  - [ ] `.bundlewatch.config.json`
  - [ ] Cypress config, tests, fixtures (update paths: `src/addons/` → `packages/`)
  - [ ] `locales/` directory
  - [ ] `public/` directory
  - [ ] `theme/` directory
  - [ ] EEA scripts (`update.sh`, `status.sh`, `pull.sh`, `pull-requests.py`, `release.py`)
- [ ] Configure `pnpm.overrides` (24 EEA addon pins + React + react-refresh)
- [ ] Update Makefile (yarn → pnpm, drop workspace protocol scripts)
- [ ] Update Dockerfile (multi-stage with `plone/frontend-builder:19.3.0`)
- [ ] Update Jenkinsfile (Bundlewatch stage: yarn → pnpm)
- [ ] Update `entrypoint.sh` (drop REBUILD, keep Sentry, `yarn` → `pnpm`/`node`)
- [ ] Verify: `pnpm install && pnpm build` succeeds
- [ ] Verify: `pnpm start` serves the site against a backend

**Status**: Not started
**Depends on**: Phase 2
**Blocks**: Phase 4, Phase 6

---

## Phase 4: Addon pnpm migration + npm publish

- [ ] Update each addon's `package.json` (pnpm-compatible devDependencies, `packageManager` field)
- [ ] Drop Jest config, add `vitest.config.mjs` in each addon
- [ ] Publish new npm versions of the 26 published addons
- [ ] Update `mrs.developer.json` branches/tags to V19-compatible releases
- [ ] Verify: Volto 19 CI pipeline (Vitest + Cypress) passes for all addons

**Status**: Not started
**Depends on**: Phases 0, 3
**Blocks**: Phase 6

---

## Phase 5: Backend upgrade to Plone 6.2 (parallel)

- [ ] Update `backend/Dockerfile` base image to `eeacms/plone-backend:6.2.1-<n>`
- [ ] Update `PLONE_VERSION=6.2.1` in `backend/develop/Makefile`
- [ ] Update constraints URL to 6.2.1
- [ ] Run backend tests, check for namespace errors
- [ ] Add `horse-with-no-namespace` to `requirements.txt` if needed
- [ ] Update EEA backend package versions as needed
- [ ] Run Plone upgrade steps in Add-ons control panel
- [ ] Verify: backend tests pass, Plone 6.2 site works with Volto 19 frontend

**Status**: Not started
**Can run in parallel with**: Phases 0, 1, 2, 3, 4
**Blocks**: Phase 6

---

## Phase 6: Cutover

- [ ] Merge new frontend to `master`/`develop`
- [ ] Build and push new Docker images (Jenkins via gitflow)
- [ ] Deploy to demo, verify end-to-end
- [ ] Update Helm charts:
  - [ ] Remove `REBUILD` env var from debug deployment (`debug-deployment.yaml`)
  - [ ] Update volume mount path: `src/addons/` → `packages/` in `debug-deployment.yaml`
- [ ] Deploy to production
- [ ] Monitor for issues

**Status**: Not started
**Depends on**: Phases 3, 4, 5