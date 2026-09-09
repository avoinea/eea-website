# PLAN — Volto 19 Upgrade Progress Tracker

This file tracks execution progress across all 7 phases. Update checkboxes as work completes.

## Phase 0: Update gitflow Docker image for pnpm

- [x] Add `pnpm` to `eea.docker.gitflow/Dockerfile` alongside `yarn` (Node 18, 20, 22)
- [x] Update `eea.docker.gitflow/src/js-release.sh` — detect pnpm vs yarn via `packageManager` field (helper function, install/update/lockfile/publish sections)
- [x] Update `eea.docker.gitflow/src/frontend-release.sh` — detect pnpm for deduplicate + lockfile
- [ ] Build and push new `eeacms/gitflow` image
- [ ] Verify: a Volto 18 addon can still be released via the updated image

**Status**: Code changes complete (branch `pnpm-support`, pushed, clean). Build/push/verify pending operational execution.
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
  - [x] **Makefile** — custom EEA Makefile (replaces upstream), slim 24-target Makefile with pnpm, ports 3000/8080, EEA target names (`ci-fix`, `test-ci`, `start-ci`, `check-ci`, `cypress-ci`), `RAZZLE_INTERNAL_API_PATH` exported, Vitest coverage/junit flags, curl-based `check-ci`, `--project` + absolute `specPattern` for cypress
  - [x] **docker-compose.yml** — backend-only (`eeacms/plone-backend` on port 8080 with `eea.kitkat:testing`)
  - [x] Jenkinsfile — dual Volto 19 (current, EEA Makefile targets) + Volto 18-yarn (previous, yarn directly), based on existing EEA V18 Jenkinsfile with V19 path swaps (`/app` workdir, `/app/packages/$GIT_NAME/` for coverage/junit, `/app/cypress/` for cypress results), three separate lint stages
  - [x] Dockerfile — CI test image with Chromium, handles both V18 (`/setupAddon`) and V19 (copy to `packages/` + `pnpm install`)
  - [x] `pre_prompt.sh` hook — strips `initialize_ci`/`initialize_documentation`, converts `cookiecutter.json` → `cookieplone.json` v2 with EEA constants hidden. No longer appends Makefile targets.
  - [x] `post_gen_project.py` hook — patches addon package.json with lint-staged config, husky + lint-staged + `@cypress/code-coverage` + `@vitest/coverage-v8` devDependencies, `prepare: "cd ../.. && husky install || true"` script
  - [x] `cookiecutter.json` — EEA defaults, `_copy_without_render` for betterleaks.yml, no docs subtemplate
  - [x] Cypress support files (EEA override):
    - [x] `cypress/support/commands.js` — EEA commands (autologin, createContent, removeContent, setWorkflow, Slate helpers, navigate, getIfExists)
    - [x] `cypress/support/e2e.js` — `@cypress/code-coverage/support`, `slateBeforeEach`/`slateAfterEach`
    - [x] `cypress/tests/example.cy.js` — EEA-style test (block basics)
  - [x] `.husky/pre-commit` — moved to repo root (not addon package), `pnpm lint-staged` (skips in CI)
  - [x] `src/config/settings.test.ts` — example Vitest test
  - [x] DEVELOP.md — updated for Volto 19 defaults
  - [x] LICENSE.md — EEA MIT license
  - [x] RELEASE.md — EEA release instructions (pnpm-based)
  - [x] `.gitleaks.toml` — EEA security scanning config
  - [x] `.github/workflows/betterleaks.yml` — GitHub Actions secret scanning (copied without Jinja2 rendering)
  - [x] `.release-it.json` override — EEA auto-changelog version (not towncrier)
  - [x] All files have trailing newlines
  - [x] Test: `cookieplone@2.0.0b3 frontend_addon --no-input` generates valid addon — `make install`, `make test`, `make test-ci`, `make cypress-run` all verified
  - [ ] Test: interactive mode shows correct prompts (6 for addon, 3 for project)
  - [ ] Verify: V18-yarn stage in Jenkinsfile works — `npx cypress run` in V18 Docker image (addon doesn't have `cypress:run` script; `npx` must find cypress binary via V18's `/setupAddon && yarn install`)
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
- [x] `frontend_project` template aligned with the proven `eea-website-frontend` implementation (2026-09-09): missdev Docker build + SSR dependency check, „Volto frontend checks” Jenkins stage, EEA scripts, `razzle.extend.js`, no `jsconfig.json`, no storybook — validated by `--no-input` generation (all rendered files syntax-checked)
- [ ] Test: interactive mode shows correct prompts (6 for addon, 3 for project)
- [x] Both templates generated and run end-to-end (2026-09-09, cookieplone-templates `87cdc91`): addon `make install`/`make test`/`make test-ci` all pass (junit + coverage); project `pnpm install`/`build:deps`/`make check` exit 0; fixed the generated `.npmrc` hoisting bug (system eslint resolution) + addon post_gen gaps (test scripts, towncrier removal)

**Status**: Templates complete and tested with --no-input (`make install`, `make test`, `make test-ci`, `make cypress-run` all verified). Interactive mode + V18-yarn CI stage verification pending.
**Can run in parallel with**: Phases 0, 1, 5
**Blocks**: Phase 3

---

**Status**: Templates complete and tested with --no-input (`make install`, `make test`, `make test-ci`, `make cypress-run` all verified). `frontend_project` aligned with the proven implementation + re-validated by generation (2026-09-09). Interactive mode + V18-yarn CI stage verification pending.
**Can run in parallel with**: Phases 0, 1, 5
**Blocks**: Phase 3

---

## Phase 3: Generate new Volto 19 frontend project ✅ (done 2026-08-21/26 on branch `volto19`)

> Updated 2026-09-09: the migration was done **in place** on the `volto19` branch (not via template generation); the `frontend_project` template was aligned to match it on 2026-09-09 (commit `e32ed29` in cookieplone-templates).

- [x] Migrate `frontend/` to the Volto 19 pnpm workspace:
  - [x] `core/` checkout at Volto **19.3.0** (exact tag) + `pnpm-workspace.yaml` (`core/packages/*`, `packages/*`, `packages/**/packages/*`)
  - [x] `mrs.developer.json` — core output `./`, all add-ons `output: packages`, branch `volto19`
  - [x] Project add-on `packages/eea-website-frontend/` (src, locales, public, scripts, `razzle.extend.js`, vitest.config.mjs; npm name `eea-website-frontend`, peer `@plone/volto >=19 <20`)
  - [x] `volto.config.js` (27 addons) + `VOLTOCONFIG` env in root scripts
  - [x] `razzle.extend.js` (gzip + brotli via new `compression-webpack-plugin` API + handsontable IgnorePlugin + node-target `performance.hints: false`) — loaded via `AddonRegistry.getAddonExtenders()` (the official Volto 19 mechanism, not `razzle.config.js`)
  - [x] `.bundlewatch.config.json`, `.nvmrc` (22), `.release-it.json`, `.storybook/` (kept from master)
  - [x] `cypress/` (smoke + acceptance), `cypress.eeacms.json` + `cypress.slate.json`, root `cypress.config.js` (junit + code-coverage + fail-fast)
  - [x] EEA scripts migrated to pnpm/packages (`scripts/`: update.sh, status.sh, pull.sh, release.py, pull-requests.py, pull-requests-volto.py, husky.sh)
  - [x] `pnpm.overrides` — all 67 add-on pins as `workspace:*` + react/react-dom 18.2.0 + react-refresh + chalk 4.1.2
  - [x] Makefile (ci-install/check/ci-i18n/build/bundlewatch/relstorage/staging/demo/update/status/pull) — `missdev --no-config --output=packages`
  - [x] Dockerfile: `plone/frontend-builder:19.3.0` + missdev + `--frozen-lockfile` + prod prune + `pnpm rebuild @sentry/cli` + `check-server-dependencies.cjs` gate; runtime `plone/frontend-prod-config:19` + corepack pnpm
  - [x] Jenkinsfile: „Volto 19 frontend checks” stage (ci-install → check → ci-i18n → build → bundlewatch + Docker build + wait-on + cypress:smoke); Build & Push extended to branch `volto19`
  - [x] `entrypoint.sh`: Sentry upload; **REBUILD dropped** (2026-09-09, commit `e3c598c`)
  - [x] `scripts/check-server-dependencies.cjs` — verifies the SSR bundle's production deps after prune (caught: postcss, react-is, wikibase-sdk, @sentry/cli)
- [x] Verify: `pnpm install --frozen-lockfile` passes against the restructured add-on workspaces (2026-09-09, 12m16s, pnpm 10.20.0, commit `6d58e97`)
- [ ] Verify: full `pnpm build` + `pnpm start` locally (build exercised by the CI-fix commits on Aug 25–26; Jenkins status on `volto19` not checkable from this sandbox)

**Status**: Done. Lockfile regenerated + committed for the restructured workspaces.
**Depends on**: Phase 2
**Blocks**: Phase 4, Phase 6

---

## Phase 4: Addon pnpm migration + npm publish 🔶 (repo restructuring done; reconcile + publish pending)

- [x] Restructure all 67 add-ons to the Volto 19 workspace layout (root `-dev` shell + nested `packages/<addon>/`), on `volto19` branches, pushed (2026-09-04, `880de8c` + Betterleaks fix `1a71c5c` per repo)
  - [x] Each add-on: dual Jenkinsfile (`CURRENT_VOLTO=19` + `PREVIOUS_VOLTO=18`, both pnpm), EEA Makefile (`/dev/tcp` check-ci, junit), Dockerfile overlay on `eeacms/frontend-builder`, `vitest.config.mjs`, `packageManager: pnpm@10.20.0`, `.gitleaks.toml`
- [x] Frontend `pnpm-lock.yaml` regenerated for the restructured workspaces + `--frozen-lockfile` verified (2026-09-09, commit `6d58e97`)
- [ ] Reconcile versions — 9 add-ons have `npm latest` > `volto19` branch version (npm publishes from Aug 20–Sep 8 were made **before** the Sep 4 restructure, which reset the `package.json` versions):
  - `@eeacms/volto-accordion-block`: repo 13.0.3 vs npm 13.1.0 (2026-08-27)
  - `@eeacms/volto-datablocks`: repo 8.0.3 vs npm 9.0.1 (2026-08-20)
  - `@eeacms/volto-eea-chatbot`: repo 3.0.1 vs npm 4.1.0 (2026-08-31)
  - `@eeacms/volto-eea-design-system`: repo 1.60.8 vs npm 1.61.1 (2026-09-08)
  - `@eeacms/volto-eea-kitkat`: repo 33.1.1 vs npm 33.2.0 (2026-08-27)
  - `@eeacms/volto-eea-website-policy`: repo 4.0.3 vs npm 4.0.4 (2026-08-20)
  - `@eeacms/volto-eea-website-theme`: repo 4.4.0 vs npm 4.5.0 (2026-08-27)
  - `@eeacms/volto-group-block`: repo 10.0.3 vs npm 10.1.0 (2026-08-26)
  - `@eeacms/volto-taxonomy`: repo 6.0.2 vs npm 6.0.5 (2026-08-20)
- [ ] Fix `.husky/pre-commit` in all 67 add-on repos — `pnpm lint-staged` resolves only from the nested package, so every local commit fails the hook (fixed in the template: root -dev shell declares `lint-staged`, commit `968aa91`)
- [ ] Sync `volto19` branches with `develop` (merge, not rebase — branches are pushed/referenced): sweep 2026-09-09 → **51 SYNCED** (develop is an ancestor, merge = no-op), **13 DIVERGED** (merge + conflict resolution needed: the 8 npm-published + searchlib, block-divider, columns-block, statistic-block), **3 NO-DEVELOP** (volto-subsites/authomatic/rss-provider — external branching). Pilot validated on volto-accordion-block (merge commit `1c0af61`, recipe in session-progress.md)
- [ ] Verify add-on CI (V18 + V19 pipelines) passes for all 67 add-ons
- [ ] Update `mrs.developer.json` branches → tags/V19-compatible releases (also stabilizes the frontend `--frozen-lockfile` against moving branch heads)
- [ ] Fix `frontend/scripts/release.py` — broken under the new layout (reads `jsconfig.json` + `src/<path>`, both gone); needs a rewrite against `mrs.developer.json` + `packages/` (+ nested add-on versions). Same for `make release` in the frontend.

**Status**: Add-on repo restructuring complete and pushed; npm publishes partially done (58/67 in sync); version reconciliation + tags + CI verification pending.
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

- [ ] Merge new frontend to `master`/`develop` (note: `volto19` branch is at 6.6.0 while `master` is at 6.7.0 — expect CHANGELOG/version conflicts)
- [ ] Build and push new Docker images (Jenkins via gitflow)
- [ ] Deploy to demo, verify end-to-end
- [ ] Update Helm charts:
  - [x] Remove `REBUILD` env var from debug deployment (`debug-deployment.yaml`, commit `2b0617ce` on 2026-09-09; `entrypoint.sh` REBUILD dropped in frontend `e3c598c`)
  - [ ] Update volume mount path: `src/addons/` → `packages/` in `debug-deployment.yaml` — **caveat**: mounting a PVC directly on `/app/packages` shadows the baked project add-on (`packages/eea-website-frontend`, not fetched by missdev). The debug flow needs a redesign (e.g. PVC mounted elsewhere + per-add-on copy/symlink, or debug on the baked image build). Blocked until that design is decided.
- [ ] Deploy to production
- [ ] Monitor for issues

**Status**: Not started (REBUILD removal done). Debug-pod redesign pending decision.
**Depends on**: Phases 3, 4, 5
