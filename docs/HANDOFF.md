# HANDOFF — Volto 19 Upgrade (Session 2)

## What was done this session

### `volto-test-addon` → Volto 19 (PR #15, green)

The test add-on was regenerated from the EEA `cookieplone-templates` `frontend_addon` template and upgraded to Volto 19:
- **pnpm workspace** layout: root `-dev` package + `packages/volto-test-addon/`
- **Babel**: `'razzle'` → `'@plone/razzle'`; entry `src/index.js` → `src/index.ts`
- **Jest → Vitest** (`vitest.config.mjs`, `src/config/settings.test.ts`)
- **New EEA Makefile/Jenkinsfile/Dockerfile/docker-compose** (pnpm, ports 3000/8080, dual Volto 19 + Volto 18 CI)
- **EEA Cypress support** (commands/e2e/example) + `cypress/tests/` layout
- **packageManager**: `pnpm@10.20.0`, Volto `19.3.0`
- **Preserved**: `applyConfig` + `// test` logic, locales (en/de/it/ro), CHANGELOG history, LICENSE (2020), EEA README/RELEASE/DEVELOP, auto-comment workflow

PR #15 is **green** (Jenkins, SonarQube, Volto 18 + 19 Integration tests, Volto 19 Unit tests, Betterleaks, branch, pr-merge — all pass).

### `eeacms/frontend-builder` — common builder image

Created `eea/frontend-builder` repo branches `18.x` + `19.x`:
- `FROM plone/frontend-builder:18`/`:19` + Chromium (pinned via Debian snapshot) + Cypress deps + `ENTRYPOINT ["pnpm"]`/`CMD ["start"]`
- Docker Hub auto-builds `eeacms/frontend-builder:18`/`:19`
- The **common bits** (Chromium, Cypress deps, ENTRYPOINT/CMD) are baked once; per-add-on `Dockerfile` is just the overlay

### `cookieplone-templates` — fixes + simplification

The EEA `frontend_addon` template was fixed and simplified:
- **Dockerfile**: `FROM eeacms/frontend-builder:${VOLTO_VERSION}` + overlay (`rm -rf /app/cypress` + `cp -r .../. /app/` + `pnpm install` + `make build-deps`). No Chromium/WORKDIR/ENTRYPOINT/CMD (inherited from base).
- **Jenkinsfile**: `CURRENT_VOLTO=19` + `PREVIOUS_VOLTO=18` (both pnpm), unified V18 stage (same Makefile flow as V19, not yarn).
- **Makefile**: `check-ci` uses bash `/dev/tcp` (no curl in the base image) + 600s timeout for the prod build.
- **`cypress.config.js`** (EEA override): `reporter: 'junit'` + `@cypress/code-coverage/task`.
- **`.gitleaks.toml`**: drop `.npmrc` from `forbidden-secret-file` (benign pnpm config); allowlist Cypress `admin` test credentials.
- **DEVELOP.md/RELEASE.md**: `make` → `make install`; `.release-it.json` path → `packages/<addon>/`.
- **`post_gen_project.py`**: remove `jest-addon.config.js` for Vitest; `remove_conditional_files()`.
- **`.husky/pre-commit`**: executable (100755).
- **`.dockerignore`**: keep `.git`/`core`/`node_modules`/`build` out of the build context.

### `eea.docker.gitflow` — pnpm support (Phase 0)

- `Dockerfile`: add `pnpm` alongside `yarn` (Node 18, 20, 22)
- `src/js-release.sh`: detect pnpm vs yarn via `packageManager` field
- `src/frontend-release.sh`: detect pnpm for deduplicate + lockfile

## Key findings (the "gotchas")

1. **`rm -rf /app/cypress` is critical**: the base `plone/frontend-builder` ships an **upstream Volto** `cypress/support/e2e.js` that uses `reset-fixture` → `POST /Plone/RobotRemote`. The EEA backend doesn't expose `/Plone/RobotRemote` → 404. The add-on's **EEA** `cypress/support/e2e.js` (`slateBeforeEach` — creates content via REST API) must **replace** the base's. Without `rm -rf /app/cypress` first, `cp -r` **merges** (base's `reset-fixture` files remain alongside the add-on's), and Cypress loads the wrong `e2e.js`.

2. **`check-ci` uses bash `/dev/tcp`**: `plone/frontend-builder` does **not** install `curl` or `wget`. The EEA `make check-ci` must use bash's built-in `/dev/tcp/localhost/3000` (no external binary). The 600s timeout covers the `pnpm build && pnpm start:prod` time.

3. **`cp -r` nesting**: `cp -r /app/src/addons/<addon>/cypress /app/cypress` (where `/app/cypress` already exists in the base) **nests** → `/app/cypress/cypress/`. Use `rm -rf /app/cypress` first, then `cp -r`.

4. **Catalog injection**: `pnpm install` in the add-on workspace resolves `catalog:` specifiers via the `.pnpmfile.cjs` hook (reads `core/catalog.json`). If `core` is symlinked **outside** the workspace, pnpm may not resolve the catalog. Use a real `core/` directory inside the workspace (or `mrs-developer` to clone into `./core`).

5. **Dual V18 + V19 pnpm works**: Volto 18 ships `vitest.config.mjs` (not just Jest). The add-on's `@plone/razzle` babel is only used by `make i18n` (the add-on's own i18n extraction), not by the CI stages. So a V19-structure add-on works on V18 pnpm without changes.

6. **Betterleaks false positives**: the Cookieplone-generated `.npmrc` (pnpm hoist patterns) is flagged by the `forbidden-secret-file` rule. The Cypress `admin`/`admin` test credentials are flagged by `secret-literal-assignment`. Both are false positives — fix in `.gitleaks.toml`.

## State of the repos

### `eea/volto-test-addon` (PR #15)
- **Branch**: `volto19` → `develop`
- **Status**: **GREEN** (all checks pass)
- **Merged**: No (for review)

### `eea/cookieplone-templates`
- **Branch**: `main`
- **Commits**: `e899c9e` (docs/dead-jest/cypress-junit/husky) on `origin/main`; `a337739` + `2ef91e8` + `8d995d1` + `f5fbe5e` **local** (for review/push)
- **State**: EEA `frontend_addon` template fixed + simplified (Dockerfile overlay, Jenkinsfile dual pnpm, Makefile /dev/tcp, cypress.config.js junit, .gitleaks.toml, DEVELOP/RELEASE, post_gen_project.py, .husky/pre-commit, .dockerignore)

### `eea/frontend-builder`
- **Branches**: `18.x` + `19.x` pushed to `origin`
- **Docker Hub**: `eeacms/frontend-builder:18` + `:19` (auto-built, with Chromium + ENTRYPOINT/CMD)
- **State**: Common builder image complete

### `eea/eea.docker.gitflow`
- **Branch**: `master` (local changes)
- **State**: pnpm support added (Phase 0). Build/push pending.

## What's next for the next agent

### Phase 3: Generate the new Volto 19 frontend project
- Run `cookieplone frontend_project` with EEA defaults (Volto 19.3.0)
- Copy over project-specific config from `./frontend/`:
  - `mrs.developer.json` (output: `packages/`)
  - `volto.config.js` (26 project-level addons)
  - `razzle.config.js` (compression + handsontable)
  - `.bundlewatch.config.json`
  - `cypress/` (update paths: `src/addons/` → `packages/`)
  - `locales/`, `public/`, `theme/`
  - EEA scripts (`update.sh`, `status.sh`, `pull.sh`, etc.)
  - `pnpm.overrides` (24 EEA addon pins + React + react-refresh)
- Verify: `pnpm install && pnpm build` succeeds + `pnpm start` serves the site

### Phase 4: Addon pnpm migration + npm publish
- Update each addon's `package.json` (pnpm-compatible devDependencies, `packageManager` field)
- Drop Jest config, add `vitest.config.mjs`
- Publish new npm versions of the 26 published addons
- Update `mrs.developer.json` branches/tags to V19-compatible releases
- Verify: Volto 19 CI pipeline (Vitest + Cypress) passes for all addons

### Phase 5: Backend upgrade (when EEA 6.2.x image available)
- Update `backend/Dockerfile` base image to `eeacms/plone-backend:6.2.1-<n>`
- Run Plone upgrade steps in Add-ons control panel
- Run backend tests, check for namespace errors

### Phase 6: Cutover
- Merge new frontend to `master`/`develop`
- Build and push new Docker images (Jenkins via gitflow)
- Deploy to demo, verify end-to-end
- Update Helm charts
- Deploy to production

## How to track progress

- Update checkboxes in `./docs/TODO.md` as each step completes
- Full session log with key learnings: `./docs/session-progress.md`
- All decisions: `./docs/12-decision-log.md`
- Build and deployment: `./docs/07-build-and-deployment.md`
- Testing strategy: `./docs/06-testing-strategy.md`

## Cookieplone quick reference

```bash
# Run with EEA templates from local checkout
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_addon
COOKIEPLONE_REPOSITORY=$(pwd)/cookieplone-templates uvx cookieplone@2.0.0b3 frontend_project

# Clear cache if templates don't update
rm -rf ~/.cookiecutters/eea/cookieplone-templates

# The menu shows only: Add-ons (→ frontend_addon) and Projects (→ frontend_project)
```

## `eeacms/frontend-builder` quick reference

```bash
# The common builder image (auto-built on Docker Hub from eea/frontend-builder branches)
# Branch 18.x → eeacms/frontend-builder:18
# Branch 19.x → eeacms/frontend-builder:19

# Add-on Dockerfile uses:
# FROM eeacms/frontend-builder:${VOLTO_VERSION}
# (VOLTO_VERSION = "18" or "19" — the Docker Hub tags)

# Jenkinsfile:
# CURRENT_VOLTO = "19"   # eeacms/frontend-builder:19
# PREVIOUS_VOLTO = "18"  # eeacms/frontend-builder:18
```