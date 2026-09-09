# HANDOFF — Volto 19 Upgrade

> Talk prep (Plone Conf 2026) handoff: `./HANDOFF-PLONECONF.md` — this file is migration-only.
> Session 2 report below (Aug 18). Session 3 (Sep 9) update in the next section.

## Session 3 update (2026-09-09) — docs sync + alignment fixes

Full state: `./TODO.md` (checkboxes), `./session-progress.md` (sessions 3–6 log), `./12-decision-log.md` (amendments D1–D5 + Q26–Q29).

**Ground truth vs old docs**: Phases 3 and most of 4 were already done in undocumented sessions (Aug 21–26: `frontend/` migrated to the pnpm workspace; Aug 20–Sep 8: npm publishes; Sep 4: all 67 add-ons restructured on `volto19` branches). This session verified everything against git history + npm registry, then:

- **`frontend/`** (branch `volto19`): `e3c598c` REBUILD dropped from `entrypoint.sh`; `6d58e97` `pnpm-lock.yaml` regenerated for the restructured workspaces — **`pnpm install --frozen-lockfile` verified passing** (12m16s). CI on `volto19` was guaranteed red since Sep 4 (stale lockfile); this commit is the fix.
- **`helm-charts/`**: `2b0617ce` REBUILD env removed from `debug-deployment.yaml` (structurally incompatible with the new layout; debug flow redesign deferred to Phase 6).
- **`cookieplone-templates/`**: `38c2abd` pending prompt/doc wording + `e32ed29` `frontend_project` template aligned with the proven implementation (missdev Docker build + SSR dependency check, „Volto frontend checks” stage, EEA scripts/Makefile/package.json, `razzle.extend.js`, no `jsconfig.json`/storybook); validated by generating a project with `cookieplone@2.0.0b3 --no-input`.
- **Key findings this session**: `razzle.extend.js` is the official Volto 19 webpack-extension mechanism (Q9's premise was wrong); `frontend/scripts/release.py` is broken under the new layout (reads `jsconfig.json`/`src/` — both gone); 9 add-ons have `npm latest` > `volto19` branch version; `volto19` branch is at 6.6.0 while `master` is at 6.7.0.

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
- **Status**: **GREEN** (all checks pass), PR **open, not merged** (for review)

### `eea/cookieplone-templates`
- **Branch**: `main`, in sync with `origin`
- **Commits**: `38c2abd` (prompt/doc wording) + `e32ed29` (frontend_project aligned with proven implementation) — local (for review/push)
- **State**: `frontend_addon` matches the 67 restructured add-ons 1:1; `frontend_project` aligned with `eea-website-frontend` (validated by `--no-input` generation)

### `eea/frontend-builder`
- **Branches**: `18.x` + `19.x` pushed to `origin`
- **Docker Hub**: `eeacms/frontend-builder:18` + `:19` (auto-built, with Chromium + ENTRYPOINT/CMD)
- **State**: Common builder image complete

### `eea/eea.docker.gitflow`
- **Branch**: `pnpm-support` (clean, pushed)
- **State**: pnpm support added (Phase 0). Build/push of the image pending.

### `eea/eea-website-frontend` (`./frontend/`, branch `volto19`)
- **State**: Phase 3 done (Aug 21–26). pnpm workspace, core@19.3.0, project add-on `packages/eea-website-frontend/`, Dockerfile (missdev + frozen-lockfile + Sentry rebuild + SSR check), Jenkins „Volto 19 frontend checks” stage, EEA scripts on pnpm/packages
- **Commits this session**: `e3c598c` (REBUILD dropped), `6d58e97` (lockfile regenerated + verified)
- **Unverified**: Jenkins status on `volto19`; full local `pnpm build` not re-run this session

### 67 add-on repos (`./frontend/packages/*`, branch `volto19`)
- **State**: restructured + pushed (Sep 4), clean, in sync with origin; infra (dual Jenkinsfile, vitest, Makefile, Dockerfile overlay, gitleaks) matches the `frontend_addon` template
- **npm**: 58/67 in sync with npm latest; 9 ahead-on-npm (publishes predate the restructure) — see TODO Phase 4 for the list
- **Unverified**: add-on CI (V18 + V19 pipelines) status

### `eea/helm-charts`
- **Commit this session**: `2b0617ce` — REBUILD env dropped from `eea-website-frontend` debug deployment
- **Pending (Phase 6)**: debug volume-mount redesign for the `packages/` layout (PVC on `/app/packages` shadows the baked project add-on)

## What's next for the next agent

> Phase 3 is **done** (Aug 21–26) and most of Phase 4's repo restructuring is done (Sep 4). See `./TODO.md` for the live checklist. Remaining, in order:

### Phase 3/4 follow-ups (code)
1. Push the local commits: `frontend` (`e3c598c`, `6d58e97`), `cookieplone-templates` (`38c2abd`, `e32ed29`), `helm-charts` (`2b0617ce`) — then watch Jenkins: frontend „Volto 19 frontend checks” on `volto19`, add-on pipelines (V18 + V19)
2. Reconcile the 9 add-ons where `npm latest` > `volto19` branch version (list in TODO Phase 4) — either bump repo versions or re-point publishes
3. Switch `mrs.developer.json` from `volto19` branches to tags/V19-compatible releases (stabilizes the frontend `--frozen-lockfile`)
4. Rewrite `frontend/scripts/release.py` for the new layout (`mrs.developer.json` + `packages/`) — `make release` is currently broken
5. Operational (unchanged from Session 2): build/push `eeacms/gitflow` image; verify a Volto 18 add-on release through it

### Phase 5: Backend upgrade (when EEA 6.2.x image available)
- Update `backend/Dockerfile` base image to `eeacms/plone-backend:6.2.1-<n>`
- Run Plone upgrade steps in Add-ons control panel
- Run backend tests, check for namespace errors

### Phase 6: Cutover
- Merge `volto19` to `develop`/`master` (expect 6.6.0 vs 6.7.0 CHANGELOG/version conflicts)
- Build and push new Docker images (Jenkins via gitflow)
- Redesign the debug deployment flow for the `packages/` layout (REBUILD is gone; PVC on `/app/packages` shadows the baked project add-on)
- Deploy to demo, verify end-to-end, deploy to production

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
