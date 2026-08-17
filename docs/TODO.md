# PLAN — Volto 19 Upgrade Progress Tracker

This file tracks execution progress across all 7 phases. Update checkboxes as work completes.

## Phase 0: Update gitflow Docker image for pnpm

- [x] Add `pnpm` to `eea.docker.gitflow/Dockerfile` alongside `yarn` (Node 18, 20, 22)
- [x] Update `eea.docker.gitflow/src/js-release.sh` — detect pnpm vs yarn via `packageManager` field (helper function, install/update/lockfile/publish sections)
- [x] Update `eea.docker.gitflow/src/frontend-release.sh` — detect pnpm for deduplicate + lockfile
- [ ] Build and push new `eeacms/gitflow` image
- [ ] Verify: a Volto 18 addon can still be released via the updated image

**Status**: Code changes complete. Build/push/verify pending operational execution.
**Can run in parallel with**: Phases 1, 2, 5
**Blocks**: Phase 4

---

## Phase 1: Fix addon breaking changes (backward-compatible with V18)

- [x] Fix `<img>` → `<Image>` component in 5 addons:
  - [x] volto-eea-chatbot (tests) — already exempt by ESLint override for `*.test.*` files
  - [x] volto-eea-design-system (stories) — already exempt by ESLint override for `*.stories.*` files
  - [x] volto-eea-website-theme (Image.jsx, LeadImage/Edit.jsx, Image/Edit.jsx) — already has `eslint-disable` comments
  - [x] volto-nextcloud-video-block (tests) — already exempt by ESLint override
  - [x] volto-object-widget (tests) — already exempt by ESLint override
- [x] Fix `razzle-dev-utils` → conditional require in 2 addons:
  - [x] volto-searchlib/razzle.extend.js
  - [x] volto-eea-chatbot/razzle.extend.js
- [x] Fix `babel.config.js` → `require('@plone/volto/babel')` in all addons (64 files updated)
- [x] Fix superagent error handling in 5 addons — already safe (all usages use defensive patterns):
  - [x] volto-datablocks (commented out, no change needed)
  - [x] volto-datahub (already checks `resp && resp.body`)
  - [x] volto-eea-chatbot (uses async/await with try/catch)
  - [x] volto-eea-website-theme (uses promise `.then()/.catch()`)
  - [x] volto-plotlycharts (uses promise `.then()/.catch()`)
- [x] Fix react-dnd/react-sortable-hoc in volto-eea-website-theme (added `react-dnd` + `react-dnd-html5-backend` as deps, registered `reactDnd` + `reactDndHtml5Backend` in `config.settings.loadables`)
- [x] Fix language settings in 3 addons — already backward-compatible:
  - [x] volto-eea-website-policy/src/index.js — already sets config values explicitly
  - [x] volto-eea-design-system/src/ui/Header/Header.jsx — receives `isMultilingual` as prop
  - [x] volto-eea-website-theme (AlternateHrefLangs.jsx, Header.jsx) — reads from config.settings which volto-eea-website-policy sets
- [x] Clean up commented-out razzle-dev-utils in volto-globalsearch
- [ ] Verify: all addons pass on Volto 18 CI (Cypress)

**Status**: Code changes complete across all 64 addon repos. CI verification pending.
**Can run in parallel with**: Phases 0, 2, 5
**Blocks**: Phase 4 (addons must be V19-compatible before pnpm migration)

---

## Phase 2: Create/update Cookieplone templates

- [x] Update `cookieplone-templates/templates/frontend_addon/`:
  - [x] Jenkinsfile — dual Volto 19 (current, full testing) + Volto 18-yarn (previous, Cypress only), uses upstream Makefile targets (`format`, `lint`, `ci-test`, `ci-acceptance-test`), `--workdir=/app` for V19
  - [x] Dockerfile — CI test image with Chromium, handles both V18 (`/setupAddon`) and V19 (copy to `packages/` + `pnpm install`)
  - [x] `pre_prompt.sh` hook — strips `initialize_ci`/`initialize_documentation`, converts `cookiecutter.json` → `cookieplone.json` v2 with EEA constants hidden (author, email, github_organization), appends `cypress`/`cypress-open`/`cypress-run` + `lint-fix`/`prettier-fix`/`stylelint-fix`/`i18n` Makefile aliases
  - [x] `post_gen_project.py` hook — patches generated addon package.json with lint-staged config, husky + lint-staged devDependencies, `prepare: husky install` script
  - [x] `cookiecutter.json` — EEA defaults, `_copy_without_render` for betterleaks.yml, no docs subtemplate
  - [x] DEVELOP.md — updated for Volto 19 defaults
  - [x] LICENSE.md — EEA MIT license
  - [x] RELEASE.md — EEA release instructions (pnpm-based)
  - [x] `.gitleaks.toml` — EEA security scanning config
  - [x] `.github/workflows/betterleaks.yml` — GitHub Actions secret scanning (copied without Jinja2 rendering)
  - [x] `.release-it.json` override — EEA auto-changelog version (not towncrier)
  - [x] `.husky/pre-commit` — `pnpm lint-staged` (skips in CI)
- [x] Create `cookieplone-templates/templates/frontend_project/` (self-contained, 36 files):
  - [x] `cookiecutter.json` — EEA defaults, 3 visible prompts (title, description, volto_version), derived frontend_addon_name, versions via filters
  - [x] `hooks/pre_prompt.sh` — converts cookiecutter.json → cookieplone.json v2, hides EEA constants + computed fields
  - [x] `package.json` — Volto 19 scripts (pnpm --filter @plone/volto), workspace:* deps, pnpm config, drop release-it
  - [x] `volto.config.js` — project addon registered, empty theme
  - [x] `pnpm-workspace.yaml` — core/packages/*, packages/*, packages/**/packages/*
  - [x] `mrs.developer.json` — core entry only (fetches Volto into core/)
  - [x] `.npmrc` — public-hoist-pattern for babel-preset-razzle
  - [x] `.pnpmfile.cjs` — pnpm catalog hook (reads core/catalog.json)
  - [x] `.eslintrc.js` — AddonRegistry-based, auto-resolves addon aliases, packages/** ignore patterns
  - [x] `jsconfig.json` — @plone/volto path alias to core/packages/volto/src
  - [x] `babel.config.js` — require('@plone/volto/babel')
  - [x] `cypress.config.js` — minimal config, placeholder baseUrl
  - [x] `Makefile` — develop (missdev + pnpm install + build:deps + husky), install, build, start, relstorage, staging, demo, cypress, cypress-open, bundlewatch, help
  - [x] `scripts/husky.sh` — installs git hooks in packages/* (pnpm exec husky install)
  - [x] `Dockerfile` — multi-stage with plone/frontend-builder, no make develop, pnpm install + build:deps + build
  - [x] `.dockerignore` — excludes core/, fetched addons (packages/* except project addon), node_modules, etc.
  - [x] `Jenkinsfile` — EEA CI: Bundlewatch, Pull Request, Release, Build & Push, Release catalog, Upgrade demo, SonarQube tags
  - [x] `entrypoint.sh` (Sentry upload, no REBUILD)
  - [x] `.bundlewatch.config.json` pattern
  - [x] `.gitignore` — core/, packages/* (except project addon), node_modules, build, etc.
  - [x] `.editorconfig`, `.prettierignore`, `.eslintignore`
  - [x] `LICENSE.md` (EEA MIT), `README.md` (project docs)
  - [x] `.gitleaks.toml`, `.github/workflows/betterleaks.yml` (security scanning)
  - [x] Project addon package (`packages/volto-{slug}/`): package.json, src/index.ts, src/config/settings.ts, tsconfig.json, vitest.config.mjs, babel.config.js, locales/, .gitignore
- [x] Update `cookieplone-config.json`:
  - [x] Added `frontend_project` template
  - [x] Hidden non-EEA groups (documentation, ci, ide, devops, agents, sub_templates) via `"hidden": true`
  - [x] Hidden non-EEA templates (backend_addon, monorepo_addon, seven_addon, project, classic_project) via `"hidden": true` in templates section
  - [x] Menu shows only: Add-ons (→ frontend_addon) and Projects (→ frontend_project)
- [x] Update README.md with full documentation
- [x] All files have trailing newlines
- [x] Test: `cookieplone@2.0.0b3 frontend_addon --no-input` generates valid addon with all EEA files + refinements
- [x] Test: `cookieplone@2.0.0b3 frontend_project --no-input` generates valid project structure (35 files)
- [ ] Test: interactive mode shows correct prompts (6 for addon, 3 for project)

**Status**: Both templates complete and tested with --no-input. Interactive mode testing pending.
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

- [x] Update `backend/Dockerfile` base image — added TODO comment (pending EEA 6.2.x image publication)
- [x] Update `PLONE_VERSION=6.2.1` in `backend/develop/Makefile`
- [x] Update constraints URL to 6.2.1 (automatic via `$(PLONE_VERSION)` variable)
- [x] Add `horse-with-no-namespace` to `requirements.txt` (preemptive, per Plone 6.2 recommendation)
- [ ] Update Dockerfile base image to `eeacms/plone-backend:6.2.1-<n>` (when EEA publishes image)
- [ ] Run backend tests, check for namespace errors
- [ ] Run Plone upgrade steps in Add-ons control panel
- [ ] Update EEA backend package versions as needed
- [ ] Verify: backend tests pass, Plone 6.2 site works with Volto 19 frontend

**Status**: Partially complete. Blocked on EEA 6.2.x backend Docker image publication.
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
