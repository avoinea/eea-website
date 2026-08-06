# 11 — Execution Plan

## 7 phases with dependencies

```
Phase 0 (gitflow image)  ─────────────────────────────────┐
Phase 1 (addon fixes)    ──────────────────────┐         │
Phase 2 (templates)      ──────────────────────┤         │
                                                    │         │
Phase 3 (generate project) ◄─────────────────────┘         │
                                                    │         │
Phase 4 (addon pnpm)     ◄───────────────────────────────────┘
                                                    │
Phase 5 (backend)       ──────────────────────────┤
                                                    │
Phase 6 (cutover)       ◄───────────────────────────┘
```

## Phase 0: Update gitflow Docker image

**Goal**: Ensure `eeacms/gitflow` supports pnpm before any addon migrations.

**Steps**:
1. Add `pnpm` to the gitflow Dockerfile alongside `yarn`
2. Update `js-release.sh` to detect pnpm vs yarn (`packageManager` field in `package.json`)
3. Build and push new `eeacms/gitflow` image
4. Verify addon release still works for a yarn-based addon

**Verify**: A Volto 18 addon can still be released via the updated gitflow image.

**Can run in parallel with**: Phases 1, 2, 5

## Phase 1: Fix addon breaking changes (backward-compatible)

**Goal**: Fix all known Volto 19 breaking changes in addons, in ways that also work on Volto 18.

**Steps** (on each addon's `develop` branch):
1. Fix `<img>` → `<Image>` in 5 addons
2. Fix `razzle-dev-utils` → conditional require in 2 addons
3. Fix `babel.config.js` → `require('@plone/volto/babel')` in all addons
4. Fix superagent error handling in 5 addons
5. Fix react-dnd/react-sortable-hoc in 1 addon (add as dependency)
6. Fix language settings in 3 addons (read from backend API)
7. Clean up commented-out `razzle-dev-utils` in `volto-globalsearch`

**Verify**: All addons pass on Volto 18 CI (Cypress).

**Can run in parallel with**: Phases 0, 2, 5

## Phase 2: Create/update Cookieplone templates

**Goal**: EEA templates ready to generate Volto 19 projects and dual-V18/V19 addons.

**Steps**:
1. Update `frontend_addon` template — add Volto 19 Jenkins stage, Vitest config, `@plone/volto/babel`
2. Create `frontend_project` template — standalone frontend, pnpm workspace, EEA Jenkinsfile/Dockerfile/Makefile
3. Update `cookieplone-config.json` with new template entry
4. Test: generate a sample project and addon, verify structure

**Verify**: `cookieplone frontend_project --no-input` generates a valid project structure.

**Can run in parallel with**: Phases 0, 1, 5

## Phase 3: Generate new Volto 19 frontend project

**Goal**: New frontend repo on a branch, ready for testing.

**Steps**:
1. Run `cookieplone frontend_project` with EEA defaults (Volto 19.3.0)
2. Copy over project-specific config:
   - `mrs.developer.json` (output: `packages/`)
   - `volto.config.js` with 26 project-level addons
   - Custom `razzle.config.js` (compression + handsontable)
   - `.bundlewatch.config.json`
   - Cypress config, tests, fixtures
   - `locales/`, `public/`, `theme/`
   - EEA scripts (`update.sh`, `status.sh`, `pull.sh`, `pull-requests.py`, `release.py`)
3. Configure `pnpm.overrides` (EEA addon pins + React + react-refresh)
4. Update Makefile (yarn → pnpm, drop workspace protocol scripts)
5. Update Dockerfile (multi-stage with `plone/frontend-builder:19.3.0`)
6. Update Jenkinsfile (Bundlewatch stage: yarn → pnpm)
7. Update `entrypoint.sh` (drop REBUILD, keep Sentry)

**Verify**: `pnpm install && pnpm build` succeeds. `pnpm start` serves the site.

**Depends on**: Phase 2

## Phase 4: Addon pnpm migration + npm publish

**Goal**: All addons have pnpm-compatible configs and new npm versions published.

**Steps** (per addon):
1. Update `package.json` — pnpm-compatible devDependencies, `packageManager` field
2. Drop Jest config, add `vitest.config.mjs`
3. Publish new npm version (Volto 19-compatible)
4. Update `mrs.developer.json` branches/tags to point to Volto 19-compatible releases

**Verify**: Volto 19 CI pipeline (Vitest + Cypress) passes for all addons.

**Depends on**: Phases 0, 3

## Phase 5: Backend upgrade (parallel)

**Goal**: Backend running Plone 6.2.x.

**Steps**:
1. Update Dockerfile base image to `eeacms/plone-backend:6.2.1-<n>`
2. Update `PLONE_VERSION=6.2.1` in Makefile
3. Update constraints URL to 6.2.1
4. Run tests, check for namespace errors
5. Add `horse-with-no-namespace` to `requirements.txt` if needed
6. Update EEA backend package versions as needed
7. Run Plone upgrade steps in the Add-ons control panel

**Verify**: Backend tests pass, Plone 6.2 site works with Volto 19 frontend.

**Can run in parallel with**: Phases 0, 1, 2, 3, 4

## Phase 6: Cutover

**Goal**: Production deployment on Volto 19 + Plone 6.2.

**Steps**:
1. Merge new frontend to `master`/`develop`
2. Build and push new Docker images (Jenkins handles this via gitflow)
3. Deploy to demo, verify end-to-end
4. Update Helm charts:
   - Remove `REBUILD` from debug deployment
   - Update volume mount path: `src/addons/` → `packages/`
5. Deploy to production
6. Monitor for issues

**Verify**: Production site works end-to-end (Volto 19 + Plone 6.2).

**Depends on**: Phases 3, 4, 5